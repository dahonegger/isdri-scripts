%% uas.m -
% 5/15/2018

clear all; close all
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));

movieDir = 'E:\guadalupe\postprocessed\droneImagery\';
movieName = '2017-09-01.mat';

cube1 = 'E:\guadalupe\processed\2017-09-11\Guadalupe_20172542337_pol.mat';
cube2 = 'E:\guadalupe\processed\2017-09-11\Guadalupe_20172542339_pol.mat';
cube3 = 'E:\guadalupe\processed\2017-09-11\Guadalupe_20172542341_pol.mat';

%% load video and radar image
C1 = load(cube1);
C2 = load(cube2);
C3 = load(cube3);
t1 = epoch2Matlab(mean(C1.timeInt(:)));
t2 = epoch2Matlab(mean(C2.timeInt(:)));
t3 = epoch2Matlab(mean(C3.timeInt(:)));
dv1 = datevec(t1);
dv2 = datevec(t2);
dv3 = datevec(t3);

videoLength = 4*60; % seconds
startTime = datenum([2017,09,11,16+7,38,00]);
load(movieName);
% v = VideoReader(fullfile(movieDir,movieName));

%% define radar domain
rotation = 13;
x0 = 0;         % for local
y0 = 0;
axisLimits = [-200 200 -900 -500 ];
% Convert to world coordinates
heading = C1.results.heading-rotation;
[AZI,RG] = meshgrid(C1.Azi,C1.Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = (xdom + x0);
ydom = (ydom + y0);

%% Figure 1
v.CurrentTime = 1;

fig1 = figure;
fig1.PaperUnits = 'inches';
fig1.PaperPosition = [0 0 8 6];
subplot(1,2,1)
vidFrame = readFrame(v);
image(vidFrame);
axis image
xlabel('Alongshore y (pixels)'); ylabel('Cross-shore x (pixels)')
title('UAS imagery')

subplot(1,2,2)
pcolor(ydom,xdom,double(C1.timex))
shading flat; axis image
axis(axisLimits)
set(gca,'Xdir','reverse')
colormap(hot)
caxis([30 220])
ttl = [num2str(dv1(1)) num2str(dv1(2),'%02i') num2str(dv1(3),'%02i')...
    ' - ' num2str(dv1(4),'%02i') ':' num2str(dv1(5),'%02i') ':'...
    num2str(round(dv1(6)),'%02i') ' UTC'];
title(ttl)
xlabel('Alongshore y (m)'); ylabel('Cross-shore x (m)')
figTitle1 = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\droneTP1.png';
print(fig1,figTitle1,'-dpng')

%% Figure 2
v.CurrentTime = (t2 - startTime)*24*60*60;

fig2 = figure;
fig2.PaperUnits = 'inches';
fig2.PaperPosition = [0 0 8 6];
subplot(1,2,1)
vidFrame = readFrame(v);
imagesc(x,y,xx);
axis image
xlabel('Alongshore y (pixels)'); ylabel('Cross-shore x (pixels)')
title('UAS imagery')

subplot(1,2,2)
pcolor(ydom,xdom,double(C2.timex))
shading flat; axis image
axis(axisLimits)
set(gca,'Xdir','reverse')
colormap(hot)
caxis([30 220])
ttl = [num2str(dv2(1)) num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')...
    ' - ' num2str(dv2(4),'%02i') ':' num2str(dv2(5),'%02i') ':'...
    num2str(round(dv2(6)),'%02i') ' UTC'];
title(ttl)
xlabel('Alongshore y (m)'); ylabel('Cross-shore x (m)')
figTitle2 = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\droneTP2.png';
print(fig2,figTitle2,'-dpng')

%% Figure 3
v.CurrentTime = (t3 - startTime)*24*60*60;

fig3 = figure;
fig3.PaperUnits = 'inches';
fig3.PaperPosition = [0 0 8 6];
subplot(1,2,1)
vidFrame = readFrame(v);
image(vidFrame);
axis image
xlabel('Alongshore y (pixels)'); ylabel('Cross-shore x (pixels)')
title('UAS imagery')

subplot(1,2,2)
pcolor(ydom,xdom,double(C3.timex))
shading flat; axis image
axis(axisLimits)
set(gca,'Xdir','reverse')
colormap(hot)
caxis([30 220])
ttl = [num2str(dv3(1)) num2str(dv3(2),'%02i') num2str(dv3(3),'%02i')...
    ' - ' num2str(dv3(4),'%02i') ':' num2str(dv3(5),'%02i') ':'...
    num2str(round(dv3(6)),'%02i') ' UTC'];
title(ttl)
xlabel('Alongshore y (m)'); ylabel('Cross-shore x (m)')
figTitle3 = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\droneTP3.png';
print(fig3,figTitle3,'-dpng')



% make movie
dataFolder = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI';
saveFolder = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\droneVid';
saveFolderGif = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\droneVid';

cd(dataFolder)
pngs = dirname('*.png');
outputFile = [saveFolderGif '\' 'droneVid.gif'];
delayTime = 0.5;
makeGif(pngs,outputFile,delayTime)


