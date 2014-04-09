function viewTargets(loc)
%
% viewTargets
% -----------
% Plots location of targets on lake.
% viewTargets(loc)

    % draw a big circle
%     theta = linspace(0,2*pi,100);
%     x = 175 .* cos(theta);
%     y = 175 .* sin(theta);
%     plot(x,y, 'b-');
    plotCircle([0,0], 175, 'b-');
    
    xlim([-200 200])
    ylim([-175 175])
    
    % plot locations
    hold on
    plot(loc(:,1), loc(:,2), 'x', 'markersize', 8)
end