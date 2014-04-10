function tools = pathMakers
tools.circularPath = @circularPath;
tools.spiralPath = @spiralPath;
geo = geometryHelpers;
    function wp = circularPath(startPos, radius, center)
        % Generate a bunch of waypoints in a circular shape around a specified
        % center.
        
        
        theta = geo.makeThetaArray(startPos, center);
        wp = radius * [cos(theta), sin(theta)] +...
            [center(1) * ones(size(theta)), center(2) * ones(size(theta))];
        
    end


    function wp = spiralPath(startPos, radius, center, dr)
        wp = [];
        theta = geo.makeThetaArray(startPos, center);
        % number of spirals
        n = floor(radius/dr);
        for i = 1:1:n
            r = linspace(radius-dr*(i-1), radius-dr*i, length(theta))';
            wpOneRound = [r.* cos(theta), r.* sin(theta)] +...
                [center(1) * ones(size(theta)), center(2) * ones(size(theta))];
            wp = [wp; wpOneRound];
        end
        
        
    end
end