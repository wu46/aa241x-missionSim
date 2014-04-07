% script to test matlab functions

% generate locations
targetLoc = generateTargets(1);

% plot target locations
viewTargets(targetLoc);

% simulate flight
[t,x,y] = simFlight();