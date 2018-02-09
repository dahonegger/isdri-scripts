function [uw,vw,tx,ty] = calcWindStress(windMag,windDir,rotation,anemometerHeight)

%% rotate winds - ZERO IS NORTH
windDirR = windDir - rotation;

% Convert with direction to FRF coordinates
uw = -windMag.*sind(windDirR);
vw = -windMag.*cosd(windDirR);

% convert to wind stress
tx = sign(uw).*stresstc(abs(uw),anemometerHeight);  % anemometer height 19.4 meters
ty = sign(vw).*stresstc(abs(vw),anemometerHeight);