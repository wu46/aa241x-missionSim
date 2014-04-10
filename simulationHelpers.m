function tools = simulationHelpers
tools.reachedWp = @reachedWp;
tools.calcNextHeading = @calcNextHeading;
tools.calcFOV = @calcFOV;
tools.calcPosError = @calcPosError;
tools.isSighted = @isSighted;
tools.calcScore = @calcScore;
tools.reportPosition = @reportPosition;

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



    function fov = calcFOV(alt)
        % FOV calculation, fov as radius in m
        x = [100*0.3048, 400*0.3028];
        y = [15, 30];
        P = polyfit(x,y,1);
        fov = P(1)* alt + P(2);
    end

    function e = calcPosError(alt)
        x = [100*0.3048, 400*0.3028];
        y = [10, 20];
        P = polyfit(x,y,1);
        e = P(1)* alt + P(2);
    end

    function [targetID, targetPos] = isSighted(pos, targetLoc, alt)
        targetID = -1;
        targetPos = [];
        % position error:
        e = calcPosError(alt);
        fov = calcFOV(alt);
        % Draw camera
        plotCircle(pos, fov, 'r--');
        
        for i = 1:1:size(targetLoc,1)
            dist = sqrt((pos(1,1) - targetLoc(i,1))^2 +...
                (pos(1,2) - targetLoc(i,2))^2);
            if dist < fov
                targetID = i;
                targetPos = geo.randInCircle(targetLoc(i,1), targetLoc(i,2),e);
            end
        end
    end

    function pos = reportPosition(targetPosEstimate)
        for i = 1:1:4
            pos(i,:) = mean(targetPosEstimate{i},1);
        end
    end

    function score = calcScore(computedTargets, targets, tsight)
        %------------------------------------------------------------------------%
        % scoring - don't need to edit
        alpha = 200;                    % m, scoring parameter
        beta = 5000;                    % s, scoring parameter
        gamma = 1;                      % m, scoring parameter
        delta_rel = 1;                  % reliability index, depends on number of flights
        score = compute_score(alpha, beta, gamma, delta_rel,targets,computedTargets,tsight);
        
        %------------------------------------------------------------------------%
        function score = compute_score(alpha, beta, gamma, delta_rel,...
                targets,computed_targets,tsight)
            % function score = compute_score(alpha, beta, gamma, delta_rel,targets,computed_targets,tsight)
            % compute score with time of first sight of all targets plus the computed
            % positions
            % (Thanks to Amanda)
            P1 = alpha/(sum(max(gamma,sqrt((computed_targets(:,1)-targets(:,1)).^2 + (computed_targets(:,2)-targets(:,2)).^2))));
            P2 = beta/tsight;
            score = delta_rel*(P1+P2);
        end
    end

end
