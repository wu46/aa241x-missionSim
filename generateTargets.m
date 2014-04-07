function loc = generateTargets(varargin)
%
% generateTargets
% ---------------
% This function generates four random targets in Lake Lag. Outputs
% cartesian co-ords of targets, with origin centered in middle of lake
% loc = generateTargets()
% loc = generateTargets(seed)
% loc = generateTargets(seed, minSeparation)

R = 175;                % radius of lake
minSeparation = 15;     % minimum separation between targets
switch nargin
    case 0
    case 1
        rng(varargin{1});
    case 2
        rng(varargin{1});
        minSeparation = varargin{2};
    otherwise
        fprintf('Error: case not supported\n');
end
loc = [];
i = 0;
while i < 4
    r = 175 * rand();
    theta = 2*pi * rand();
    x = r * cos(theta);
    y = r * sin(theta);
    new = [x,y];
    isokay = isFarEnough(new, minSeparation);
    if isokay
        loc = [loc; new];
        i = i+1;
    end
end
    function isOkay = isFarEnough(new, minSeparation)
        isOkay = logical(1);
        for n = 1:1:size(loc,1)
            dist = sqrt((new(1) - loc(n,1))^2 + ...
                (new(2) - loc(n,2))^2);
            if dist > minSeparation
                isOkay = logical(1);
            else
                isOkay = logical(0);
            end
        end
    end
end