%%% XSTransects
% 2/5/2018

clear variables
addpath(genpath('C:\Data\ISDRI\isdri-scripts'))

% Load file
matFile = 'E:\guadalupe\processed\2017-09-23\Guadalupe_20172660600_pol.mat';
load(matFile)

% define parameters
rotation = 13;
x0 = 0;         % for local
y0 = 0;
% axisLimits = [-1200 -500 -1000 1000];
XYLimits = [-1500 -500; -1000 1000];

% set rotation(so shoreline is parallel to edge of plot)
heading = results.heading-rotation;
[AZI,RG] = meshgrid(Azi,Rg(16:xCutoff));

% interpolate onto a smaller cartesian grid
xC = XYLimits(2,1):XYLimits(2,2);
yC = XYLimits(1,1):XYLimits(1,2);
[XX,YY] = meshgrid(yC,xC);
[thC,rgC] = cart2pol(XX,YY);
aziC = wrapTo360(90 - thC*180/pi - heading);

xCutoff = 1068; % range index for clipped scan
for rot = 1:size(data,3)
    scanClipped = (double(data(16:xCutoff,:,rot)));
    tCR = interp2(AZI,RG,scanClipped,aziC',rgC');
    tC(:,:,rot) = tCR';
    clear tCR scanClipped
end
time = epoch2Matlab(mean(timeInt,1));

tCTimex = mean(tC,3);
tCMM = movmean(tC,72,3);
transect665 = squeeze(tCMM(1666,:,:));

figure,
pcolor(time,XX(1,:),transect665)
shading flat
colormap(hot)

% plot
figure,
pcolor(XX,YY,tCMM(:,:,1))
shading flat; axis image;
hold on
%     plot(xJMC,yJMC,'b.','MarkerSize',20)
%     plot(xOcC,yOcC,'g.','MarkerSize',20)
colormap(hot)
caxis([0 200])
axis(axisLimits)
xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)');
ttl = [num2str(dv(1)) num2str(dv(2),'%02i') num2str(dv(3),'%02i')...
    ' - ' num2str(dv(4),'%02i') ':' num2str(dv(5),'%02i') ':'...
    num2str(round(dv(6)),'%02i') ' UTC'];
title(ttl)
colorbar
