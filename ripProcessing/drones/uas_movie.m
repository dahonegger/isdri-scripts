%% uas.m -
% 5/15/2018

clear all; close all
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));
saveDir = 'E:\guadalupe\postprocessed\droneImagery\radar_drone\';

movieDir = 'E:\guadalupe\postprocessed\droneImagery\';
movieName = 'DJI_0046_orthonormal.mat';

cube1 = 'E:\guadalupe\processed\2017-09-11\Guadalupe_20172542337_pol.mat';
cube2 = 'E:\guadalupe\processed\2017-09-11\Guadalupe_20172542339_pol.mat';
cube3 = 'E:\guadalupe\processed\2017-09-11\Guadalupe_20172542341_pol.mat';

%% load video and radar image
C1 = load(cube1,'results','timeInt','Azi','Rg');
headingRadar = C1.results.heading; Rg = C1.Rg; Azi = C1.Azi; XOrigin = C1.results.XOrigin;
YOrigin = C1.results.YOrigin;
C2 = load(cube2,'timeInt');
C3 = load(cube3,'timeInt');
t1 = epoch2Matlab(mean(C1.timeInt(:)));
t2 = epoch2Matlab(mean(C2.timeInt(:)));
t3 = epoch2Matlab(mean(C3.timeInt(:)));
dvRadar = datevec(t1);
dv2 = datevec(t2);
dv3 = datevec(t3);
clear C1 C2 C3 

videoLength = 4*60; % seconds
startTime = datenum([2017,09,11,16+7,38,00]);
load([movieDir movieName]);
% yy = fliplr(y);
% v = VideoReader(fullfile(movieDir,movieName));

%% rotate
theta = 12;
B1 = imrotate(layer1(:,:,1),theta);
B2 = imrotate(layer2(:,:,1),theta);
B3 = imrotate(layer3(:,:,1),theta);
rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
xR = rotMat*[x; y(1)*ones(size(x))];
yRR = rotMat*[x(1)*ones(size(y));y];
yR = fliplr(yRR);

layers = cat(3,B1,B2,B3);

% figure,
% subplot(1,2,1)
% imagesc(xR(1,:),yR(2,:),layers)
% axis image
% set(gca,'YDir','normal')

%% convert to same spatial coordinates
lat = extrinsicParams.Lat;
lon = extrinsicParams.Lon;

[UTMy,UTMx] = ll2UTM(lat, lon);

dronex = UTMx - XOrigin;
droney = UTMy - YOrigin;

x_drone = x+dronex;
y_drone = y+droney;

x_d = x_drone;
y_d = -1*y_drone;

%% define radar domain
rotation = 13;
x0 = 0;         % for local
y0 = 0;
% axisLimits = [-200 200 -900 -500 ];
axisLimits = [-900 -500 -200 150];
% Convert to world coordinates
heading = headingRadar-rotation;
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = (xdom + x0);
ydom = (ydom + y0);

%% Figure 1
% v.CurrentTime = 1;
for i = 1:size(layer1,3) % redo 212
    
    theta = 12;
    B1 = imrotate(layer1(:,:,i),theta);
    B2 = imrotate(layer2(:,:,i),theta);
    B3 = imrotate(layer3(:,:,i),theta);
    layers = cat(3,B1,B2,B3);
    dv = datevec(frameTimes(i));
    if frameTimes(i) < t2
        dvRadar = datevec(t1);
        load(cube1,'timex')
        radar = double(timex); clear timex
    elseif frameTimes(i) >= t2 && frameTimes(i) <= t3
        dvRadar = datevec(t2);
        load(cube2,'timex')
        radar = double(timex); clear timex
    elseif frameTimes(i) > t3
        dvRadar = datevec(t3);
        load(cube3,'timex')
        radar = double(timex); clear timex
    end
    
    fig = figure('visible','off');
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 8 6];
    subplot(1,2,1)
    imagesc(x_d,y_d,layers)
    axis image
    set(gca,'YDir','normal')
    axis(axisLimits)
%     set(gca,'YTickLabel',{'200','100','0','-100','-200'},...
%         'YTick',[-200 -100 0 100 200]);
    ylabel('Alongshore y (m)'); xlabel('Cross-shore x (m)')
    ttlDrone = [num2str(dv(1)) num2str(dv(2),'%02i') num2str(dv(3),'%02i')...
        ' - ' num2str(dv(4),'%02i') ':' num2str(dv(5),'%02i') ':'...
        num2str(round(dv(6)),'%02i') ' UTC'];
    title(ttlDrone)
    
    subplot(1,2,2)
    pcolor(xdom,ydom,radar)
    shading flat; axis image
    axis(axisLimits)
    colormap(hot)
    caxis([30 220])
    set(gca,'YTickLabel',{'-200','-150','-100','-50','0','50','100','150'},...
        'YTick',[-200 -150 -100 -50 0 50 100 150]);
    ttlRadar = [num2str(dvRadar(1)) num2str(dvRadar(2),'%02i') num2str(dvRadar(3),'%02i')...
        ' - ' num2str(dvRadar(4),'%02i') ':' num2str(dvRadar(5),'%02i') ':'...
        num2str(round(dvRadar(6)),'%02i') ' UTC'];
    title(ttlRadar)
    ylabel('Alongshore y (m)'); xlabel('Cross-shore x (m)');
    figTitle1 = [saveDir 'img' num2str(i,'%04i') '.png'];
    print(fig,figTitle1,'-dpng')

    clear layers radar B1 B2 B3
    close all
    
end

% 
% %% Figure 2
% v.CurrentTime = (t2 - startTime)*24*60*60;
% 
% fig2 = figure;
% fig2.PaperUnits = 'inches';
% fig2.PaperPosition = [0 0 8 6];
% subplot(1,2,1)
% imagesc(x,y,xx);
% axis image
% xlabel('Alongshore y (pixels)'); ylabel('Cross-shore x (pixels)')
% title('UAS imagery')
% 
% subplot(1,2,2)
% pcolor(ydom,xdom,double(C2.timex))
% shading flat; axis image
% axis(axisLimits)
% set(gca,'Xdir','reverse')
% colormap(hot)
% caxis([30 220])
% ttl = [num2str(dv2(1)) num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')...
%     ' - ' num2str(dv2(4),'%02i') ':' num2str(dv2(5),'%02i') ':'...
%     num2str(round(dv2(6)),'%02i') ' UTC'];
% title(ttl)
% xlabel('Alongshore y (m)'); ylabel('Cross-shore x (m)')
% figTitle2 = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\droneTP2.png';
% print(fig2,figTitle2,'-dpng')
% 
% %% Figure 3
% v.CurrentTime = (t3 - startTime)*24*60*60;
% 
% fig3 = figure;
% fig3.PaperUnits = 'inches';
% fig3.PaperPosition = [0 0 8 6];
% subplot(1,2,1)
% vidFrame = readFrame(v);
% image(vidFrame);
% axis image
% xlabel('Alongshore y (pixels)'); ylabel('Cross-shore x (pixels)')
% title('UAS imagery')
% 
% subplot(1,2,2)
% pcolor(ydom,xdom,double(C3.timex))
% shading flat; axis image
% axis(axisLimits)
% set(gca,'Xdir','reverse')
% colormap(hot)
% caxis([30 220])
% ttl = [num2str(dv3(1)) num2str(dv3(2),'%02i') num2str(dv3(3),'%02i')...
%     ' - ' num2str(dv3(4),'%02i') ':' num2str(dv3(5),'%02i') ':'...
%     num2str(round(dv3(6)),'%02i') ' UTC'];
% title(ttl)
% xlabel('Alongshore y (m)'); ylabel('Cross-shore x (m)')
% figTitle3 = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\droneTP3.png';
% print(fig3,figTitle3,'-dpng')
% 
% 
% 
% % make movie
% dataFolder = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI';
% saveFolder = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\droneVid';
% saveFolderGif = '\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\droneVid';
% 
% cd(dataFolder)
% pngs = dirname('*.png');
% outputFile = [saveFolderGif '\' 'droneVid.gif'];
% delayTime = 0.5;
% makeGif(pngs,outputFile,delayTime)
% 
% 
