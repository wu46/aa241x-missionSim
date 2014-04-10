function [tsight,score,res] = simFlight(varargin)
%
% simFlight
% ---------
% This function runs the mission simulation. Run without any arguments or
% specify inputs for the following params:
%   'v'     - Cruise velocity in m/s
%   'alt'   - Altitude in m
%   'path'  - Path type, 'circular' or 'spiral'
%
% Examples:
% simFlight()
% simFlight('path', 'spiral')
% simFlight('v', 10, 'path', 'circular')

%--------------------------------------------------------------------------
% INPUT PARSING
%--------------------------------------------------------------------------
if (mod(nargin,2) == 1)
    fprintf('Wrong usage, ignoring inputs...\n');
end

% DEFAULT params governing flight
v = 10; % velocity, m/s
h = 130; % altitude, m
pathType = 'circular';

% if arguments are given
if (nargin > 0)
    for i = 1:2:nargin-1
        switch varargin{i}
            case 'v'
                v = varargin{i+1};
            case 'alt'
                h = varargin{i+1};
            case 'path'
                pathType = varargin{i+1};
            otherwise
                fprintf('Option not supported for %s, ignoring value...\n',...
                varargin{i});
        end
    end
end

% get helperfunctions
sim = simulationHelpers;
path = pathMakers;

% constants
MAX_TIME = 1000; % maximum time for simulation
START_POS = [0, -150];
LAKE_RADIUS = 175;

%--------------------------------------------------------------------------
% MISSION SETUP
%--------------------------------------------------------------------------
targetLoc = generateTargets();
viewTargets(targetLoc);
targetsFound = [0 0 0 0];
allFound = false;
fov = sim.calcFOV(h);


switch pathType
    case 'circular'
        %------------------------------------------------------------------
        % PATH TYPE 1 - cicular sweep
        %------------------------------------------------------------------
        % calc number of circular paths
        overlap = 2; % overlap of two sweep paths in radius
        fovEffective = fov - overlap;
        nCircles = ceil(LAKE_RADIUS / (fovEffective * 2));
        wp = START_POS;
        % First spiral, out to in
        for i = 1:1:nCircles
            wpOneCircle = path.circularPath(wp(size(wp,1),:),...
                LAKE_RADIUS-(2*i-1)*fovEffective,...
                [0,0]);
            wp = [wp; wpOneCircle];
        end
        
        % center of lake
        wp = [wp; 0,0];
        
        % If still not found, second spiral, in to out
        for i = nCircles-1:-1:0
            wpOneCircle = path.circularPath(wp(size(wp,1),:),...
                LAKE_RADIUS-2*i*fovEffective,...
                [0,0]);
            wp = [wp; wpOneCircle];
        end
        
        
    case 'spiral'
        %------------------------------------------------------------------
        % PATH TYPE 2 - slow spiral
        %------------------------------------------------------------------
        START_POS = [0 -175];
        wp = path.spiralPath(START_POS, LAKE_RADIUS, [0,0], fov*1.8);
end

%--------------------------------------------------------------------------
% SIMULATION SETUP
%--------------------------------------------------------------------------
dt = 0.1; % time step, in s
t = 0; % start time
tCamera = 0;    % keeps track of when next to take a picture
targetPosEstimate = cell(4,1);
currentPos = START_POS;
res.xOut = currentPos(1,1);
res.yOut = currentPos(1,2);
res.tOut = t;
heading = sim.calcNextHeading(currentPos, wp(1,:));

%--------------------------------------------------------------------------
% SIMULATION LOOP
%--------------------------------------------------------------------------
% START SIMULATION
while (t<MAX_TIME)
    % update position
    currentPos = currentPos + dt*v*[cos(heading), sin(heading)];
    
    % check if target found
    if (t >= tCamera)
%         pause(0.1)
        [id,pos] = sim.isSighted(currentPos, targetLoc, h);
        tCamera = t + 3;
        if (id > 0)
            fprintf('Target #%d true location [%.2f, %.2f] reported loc [%.2f, %.2f] \n',...
                id, targetLoc(id,:), pos);
            targetsFound(id) = 1;
            targetPosEstimate{id} = [targetPosEstimate{id} ; pos];
            if (sum(targetsFound) == 4 && ~allFound)
                allFound = true;
                tsight = t;
                fprintf('DONE: All targets found, time used: %.2fs\n', t);
            end
        end
    end
    
    % check if waypoint reached
    if (sim.reachedWp(currentPos, wp(1,:)))
        wp(1,:) = []; % delete reached way point
        if (isempty(wp)) % end sim loop when all way points reached
            break;
        end
        heading = sim.calcNextHeading(currentPos, wp(1,:));
    end
    
    
    t = t + dt; % update time
    res.tOut = [res.tOut;t];
    res.xOut = [res.xOut; currentPos(1,1)];
    res.yOut = [res.yOut; currentPos(1,2)];
    
    % plot current position
    plot(currentPos(1,1) ,currentPos(1,2), 'gx')
end
%------------------------------------END-----------------------------------
% Scoring
pos = sim.reportPosition(targetPosEstimate);
score = sim.calcScore(pos, targetLoc, tsight);
%
end
% TODO:
% # ALLOW FOR MULTIPLE TARGETS TO BE SIGHTED AT ONCE
% 1. option to turn visual on/off
% 2. error checking: limit alt in fov and poserror calculation