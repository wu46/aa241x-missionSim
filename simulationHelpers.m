function tools = simulationHelpers
tools.reachedWp = @reachedWp;
tools.calcNextHeading = @calcNextHeading;
tools.circularPath = @circularPath;
tools.calcFOV = @calcFOV;
tools.isSighted = @isSighted;
geo = geometryHelpers;

    function flag = reachedWp(currentPos, wp)
        flag = false;
        tol = 10;
        r = geo.calcDist(currentPos, wp);
        if r < tol
            flag = true;
        end
    end

    function heading = calcNextHeading(currentPos, nextwp)
        num = nextwp(2) - currentPos(2);
        den = nextwp(1) - currentPos(1);
        heading = geo.atan_smart(num,den);
        
        % for debugging:
        heading_deg = heading / pi * 180;
        %         fprintf('from [%.2f, %.2f] to [%.2f, %.2f] angle is %.2f\n',...
        %             currentPos, nextwp, heading_deg);
    end

    function wp = circularPath(startPos, radius, center)
        % Generate a bunch of waypoints in a circular shape around a specified
        % center.
        
        % get current angle
        num = startPos(2) - center(2);
        den = startPos(1) - center(1);
        theta_current = geo.atan_smart(num,den);
        dtheta = 0.2;
        if theta_current > 0
            theta = [theta_current:dtheta:2*pi, 0:dtheta:theta_current]';
        else
            theta = [theta_current:dtheta:0, 0:dtheta:(2*pi+theta_current)]';
        end
        wp = radius * [cos(theta), sin(theta)] +...
            [center(1) * ones(size(theta)), center(2) * ones(size(theta))];
        
    end

    function fov = calcFOV(alt)
        % FOV calculation
        p1 = [400*0.3028, 30];
        p2 = [100*0.3048, 15];
        m = (p1(1,2)-p2(1,2))/(p1(1,1)-p2(1,1));
        b = p1(1,2) - p1(1,1) * m;
        fov = m * alt + b;
    end

    function targetID = isSighted(pos, targetLoc, fov)
        targetID = -1;
        
        % Draw camera
        plotCircle(pos, fov, 'r--');
        
        for i = 1:1:size(targetLoc,1)
            dist = sqrt((pos(1,1) - targetLoc(i,1))^2 +...
                (pos(1,2) - targetLoc(i,2))^2);
            if dist < fov
                targetID = i;
            end
        end
    end

end
