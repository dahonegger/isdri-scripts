% loadAndPlotRadarImage.m

clear variables

% Load file
matFile = 'E:\guadalupe\processed\2017-10-17\Guadalupe_20172902015_pol.mat';
load(matFile)

% define parameters
rotation = 0;
numRots = 200;
% startRot = size(data,3) - 201;
startRot = 1;

% create timex
clear timex
timex = mean(data(:,:,startRot:(numRots+startRot)),3);
time = mean(epoch2Matlab(timeInt(1,startRot:(numRots+startRot))));
dv = datevec(time);

% Convert to world coordinates
heading = results.heading-rotation;
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
x0 = results.XOrigin;
y0 = results.YOrigin;
xdom = (xdom + x0)/1000;
ydom = (ydom + y0)/1000;

% plot
figure,
pcolor(xdom,ydom,timex)
shading flat; axis image;
colormap(hot)
caxis([60 180])
axis([713.5 715.2 3871.7 3875.0])
xlabel('Eastings (km)'); ylabel('Northings (km)');
ttl = [num2str(dv(1)) num2str(dv(2),'%02i') num2str(dv(3),'%02i')...
    ' - ' num2str(dv(4),'%02i') ':' num2str(dv(5),'%02i') ':'...
    num2str(round(dv(6)),'%02i') ' UTC'];
title(ttl)
colorbar