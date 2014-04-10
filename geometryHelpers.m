% classdef GeometryHelpers
function tools = geometryHelpers
%     methods
tools.atan_smart = @atan_smart;
tools.calcDist = @calcDist;
tools.makeThetaArray = @makeThetaArray;
tools.randInCircle = @randInCircle;
    function y = atan_smart(num, den)
        if (abs(den) < 1e-6)
            den = 1e-6;
        end
        y = atan(num/den);
        if (den < 0)
            y = pi + y;
        end
    end

    function r = calcDist(p1, p2)
        r = sqrt((p1(1,1) - p2(1,1))^2 +...
            (p1(1,2) - p2(1,2))^2);
    end

    function theta = makeThetaArray(startPos, center)
        num = startPos(2) - center(2);
        den = startPos(1) - center(1);
        theta_current = atan_smart(num,den);
        dtheta = 0.2;
        if theta_current > 0
            theta = [theta_current:dtheta:2*pi, 0:dtheta:theta_current]';
        else
            theta = [theta_current:dtheta:0, 0:dtheta:(2*pi+theta_current)]';
        end
    end

    function [coords] = randInCircle(xc,yc,r)
        % Stole this from Amanda:
        % function [coords] = rand_in_circle(xc,yc,r)
        % gives a random coordinate inside the circle with center (xc,yc) and
        % radius r
        theta = 2*pi*rand(1,1);
        r = r*sqrt(rand(1,1));
        
        x = r.*cos(theta)+xc;
        y = r.*sin(theta)+yc;
        coords = [x y];
    end
end
