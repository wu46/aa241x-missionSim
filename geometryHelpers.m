function tools = geometryHelpers
tools.atan_smart = @atan_smart;
tools.calcDist = @calcDist;
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
end