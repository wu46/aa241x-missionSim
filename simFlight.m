%function simFlight(wp, params)
function [t,xOut,yOut] = simFlight(varargin)
% get helperfunctions
sim = simulationHelpers;

% units in metric
% params governing flight: DEFAULT
vc = 20; % velocity, m/s
h = 100; % altitude, m

% constants
MAX_TIME = 1000; % maximum time for simulation
START_POS = [0, -150];
LAKE_RADIUS = 175;
% required params
% REQUIRED_PARAMS = {
%     'vc'; %cruise vel
%     'h';  %altitude
%     
%     };

% TODO: assign input params

%     for i = 1:1:length(REQUIRED_PARAMS)
%         if (isfield(params, REQUIRED_PARAMS{i}))
%             sim.REQUIRED_PARAMS{i}
%         end
%     end

%--------------------------------------------------------------------------
% MISSION SETUP
%--------------------------------------------------------------------------
targetLoc = generateTargets();
viewTargets(targetLoc);
targetsFound = [0 0 0 0];
allFound = false;
fov = sim.calcFOV(h);

%--------------------------------------------------------------------------
% PATH TYPE 1 - cicular sweep
% calc number of circular paths
overlap = 2; % overlap of two sweep paths in radius
fovEffective = fov - overlap;
nCircles = floor(LAKE_RADIUS / (fovEffective * 2));
wp = START_POS;
% First spiral, out to in
for i = 1:1:nCircles
    wpOneCircle = sim.circularPath(wp(size(wp,1),:),...
        LAKE_RADIUS-(2*i-1)*fovEffective,...
        [0,0]);
    wp = [wp; wpOneCircle];
end

% center of lake
wp = [wp; 0,0];

% If still not found, second spiral, in to out
for i = nCircles-1:-1:0
    wpOneCircle = sim.circularPath(wp(size(wp,1),:),...
        LAKE_RADIUS-2*i*fovEffective,...
        [0,0]);
    wp = [wp; wpOneCircle];
end

%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% SIMULATION SETUP
%--------------------------------------------------------------------------
dt = 0.1; % time step, in s
t = 0; % start time
tCamera = 0;    % keeps track of when next to take a picture
currentPos = START_POS;
xOut = currentPos(1,1);
yOut = currentPos(1,2);
tOut = t;
heading = sim.calcNextHeading(currentPos, wp(1,:));


% START SIMULATION
while (t<MAX_TIME)
    % update position
    currentPos = currentPos + dt*vc*[cos(heading), sin(heading)];
    
    % check if target found
    if (t >= tCamera)
%         pause(0.1)
        id = sim.isSighted(currentPos, targetLoc, fov);
        tCamera = t + 3;
        if (id > 0)
            fprintf('Target #%d at location [%.2f, %.2f] is found\n',...
                id, targetLoc(id,:));
            targetsFound(id) = 1;
            if (sum(targetsFound) == 4)
                fprintf('DONE: All targets found, time used: %.2fs\n', t);
                break;
            end
        end
    end
    
    % check if waypoint reached
    if (sim.reachedWp(currentPos, wp(1,:)))
        %fprintf('Reached wp: %.2f, %.2f\n', wp(1,:));
        wp(1,:) = [];
        if (isempty(wp))
%             disp('should break now')
            break;
        end
        heading = sim.calcNextHeading(currentPos, wp(1,:));
        
    end
    
    % update time
    t = t + dt;
    
    tOut = [tOut;t];
    xOut = [xOut; currentPos(1,1)];
    yOut = [yOut; currentPos(1,2)];
    
    % plot current position
    plot(currentPos(1,1) ,currentPos(1,2), 'gx')
end

%--------------------------------------------------------------------------
% Helper functions
%--------------------------------------------------------------------------

    
end