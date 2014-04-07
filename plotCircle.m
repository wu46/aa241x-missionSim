function plotCircle(varargin)
if nargin == 4
    figure(varargin{4})
    hold on
else
    figure(gcf)
    hold on
end
% assign inputs
center = varargin{1};
radius = varargin{2};
opt = varargin{3};

% fprintf('center: [%.2f %.2f]\t radius: %.2f\n', center, radius);

theta = linspace(0,2*pi,100);
x = radius .* cos(theta);
y = radius .* sin(theta);

plot(x+center(1),y+center(2), opt);
