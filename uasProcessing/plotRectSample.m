% load('C:\Users\user\Desktop\20171791107_rect_part1.mat');
addpath('C:\Data\isdri\isdri-scripts\util')
% reconstruct first frame from RGB layers
frame1(:,:,1)=layer1(:,:,1);
frame1(:,:,2)=layer2(:,:,1);
frame1(:,:,3)=layer3(:,:,1);

% plot on x,y grid
figure(1); hold on
imagesc(x,y,frame1); %imagesc needs 3 layers(r,g,b) in uint8 format
title(['cBathy Footage from Guadalupe ',datestr(frameTimes(1))])
xlabel('X [meters]');ylabel('Y [meters]');
axis image

%%
% convert x,y --> lat,lon or UTM :
[X,Y] = meshgrid(x,y);
[ECam,NCam]=deg2utm(extrinsicParams.Lat,extrinsicParams.Lon); %convert camera location to UTM (meters)
Eastings = X+ECam; %add camera location to grid
Northings = Y+NCam;
[Lat,Lon] = UTM2ll(Northings,Eastings,10); %convert back to lat lon

% plot on UTM grid
figure(2); hold on
pcolor(Eastings,Northings,frame1(:,:,1)); shading interp;
title(['CTR Ebb Plume Front ',datestr(frameTimes(1))])
xlabel('Eastings [meters]'); ylabel('Northings [meters]');

% plot on lat,lon grid
figure(3); hold on
pcolor(Lon,Lat,frame1(:,:,1)); shading interp
title(['CTR Ebb Plume Front ',datestr(frameTimes(1))])
xlabel('Longitude'); ylabel('Latitude');


%% to make png's for movie: 
% numberOfFrames = numel(frameTimes);
% for ii = 1:15:numberOfFrames %plotting at approx. 2Hz
%     tmp(:,:,1)=layer1(:,:,ii);
%     tmp(:,:,2)=layer2(:,:,ii);
%     tmp(:,:,3)=layer3(:,:,ii);
%     fig=figure;hold on;
%     box on
%     set(fig,'visible','off')
%     imagesc(x,y,tmp); %imagesc needs 3 layers(r,g,b) in uint8 format
%     title(['CTR Ebb Plume Front ',datestr(frameTimes(ii))])
%     xlabel('X [meters]');ylabel('Y [meters]');
%     fig.PaperUnits = 'inches';
%     fig.PaperPosition = [0 0 5.8 4.3];
%     axis image
%     print(['D:\ctr\uas\20171791107\fig',num2str(ii)],'-dpng','-r300')
% end