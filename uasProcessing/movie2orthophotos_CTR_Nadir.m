close all; clear all;
tic

%% USER DEFINED PARAMETERS
addpath(genpath('C:\Users\user\Desktop\UAV-Processing-Toolbox')) %wherever repository is cloned
addpath(genpath('E:\ctr\uas\')) %wherever footage lives, e.g. HUB 1 or 2
baseFolder = 'E:\ctr\uas\';
fname = '20171791102.MOV';
airDataFile = 'E:\uasData\Full_AirData_Archive\2017-06-28_6-55-12_Standard.csv';
% airDataFile = 'E:\uasData\Full_AirData_Archive\2017-06-28_7-18-10_Standard.csv';

videoStartGuess = datenum('06/28/2017 11:02','mm/dd/yyyy HH:MM'); %approx, to closest minute

startTime = 0; %seconds
endTime = 4; %seconds

declination = dms2degrees([-13 49 0]);
%% GET AIRDATA PARAMS
airData=readDJILogCSV(airDataFile);
videoIndices = strfind(airData.isVideo,[0 1])+1; %finds first indices of "1"
videoTimes = airData.datetime(videoIndices);
[idx idx] = min(abs(videoTimes - videoStartGuess));
frameIndex = videoIndices(idx); % this is the index 

% extrinsic params from airdata
Zcam = distdim(airData.altitude(frameIndex)+abs(min(airData.altitude)),'feet','meters'); % meters 
azimuth = deg2rad(180-airData.gimbal_heading(frameIndex)); %heading 

% azimuth = deg2rad(180-0); %heading 


% tilt = deg2rad(90-airData.gimbal_pitch(frameIndex)); % 90 - camera angle reported 
tilt = deg2rad(180); % 90 - camera angle reported 

roll = 0;
Lat = airData.latitude(frameIndex);
Lon =airData.longitude(frameIndex);
time = airData.datetime(frameIndex);

extrinsicParams.Lat = Lat;
extrinsicParams.Lon = Lon;
extrinsicParams.Zcam = Zcam;
extrinsicParams.heading = rad2deg(azimuth);
extrinsicParams.tilt = rad2deg(tilt);
extrinsicParams.roll = roll; 
%% PREP EXTRINSIC PARAMS
Xcam = 0; Ycam = 0;
beta = [Xcam Ycam Zcam azimuth tilt roll]; %radians
% set bounds around camera "origin" that frame should extend
Xmin = Xcam - 100;
Xmax = Xcam + 100;
Ymin = Ycam - 100;
Ymax = Ycam + 100;
xy = [Xmin .03 Xmax Ymin .03 Ymax];

%% PREP INTRINSIC PARAMS (SPECIFIC TO SHOOTING MODE)
% PICK THE PATH TO THE RIGHT SHOOTING MODE, EACH FOLDER CONTAINS A UNIQUE
% 'Calib_Results.mat' 
% paramPath = 'E:\uasData\calibrationParams\4x3_photo';
% paramPath = 'E:\uasData\calibrationParams\16x9_photo';
paramPath = 'E:\uasData\calibrationParams\3840x2160_video';
% paramPath = 'E:\uasData\calibrationParams\4096x2160_video';

lcp = makeLCPFromCaltech(paramPath);

%% PREP MOVIE PARAMS
videoObject = VideoReader(fname);
totalNumberOfFrames = videoObject.NumberOfFrames;
whichFrame = 1;

%% CREATE FRAME-BY-FRAME TIME VECTOR
fps = videoObject.FrameRate;
df = (1/fps)./60./60./24;
firstFrame = ceil(startTime*fps);
lastFrame = ceil(endTime*fps);
subsetNumberOfFrames = lastFrame-firstFrame;
frameTimes = [time+(firstFrame*df):df:time+(lastFrame*df)];

%% OPEN MOVIE FRAME BY FRAME, RECTIFY 
for i = firstFrame+1:lastFrame
warning('off','all')
frame = read(videoObject,i);

[Irect,x,y]=rectframe(double(frame),beta,lcp,xy);

% TO PLOT ON RADAR IMAGE:
figure;imagesc(x,y,uint8(Irect));axis image;
xlabel('[m]');ylabel('[m]');
[X,Y] = meshgrid(x,y);
[ECam,NCam]=deg2utm(extrinsicParams.Lat,extrinsicParams.Lon); %convert camera location to UTM (meters)
Eastings = X+ECam; %add camera location to grid
Northings = Y+NCam;
[LAT,LON] = UTM2ll(Northings,Eastings,18); %convert back to lat lon
load('Y:\usrs\ctr\processed\2017-06-28\LyndePt_20171791102_pol.mat')
addpath(genpath('C:\Data\isdri\isdri-scripts'))
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-results.heading);
[xdom,ydom] = pol2cart(TH,RG);
E = xdom+results.XOrigin;
N = ydom+results.YOrigin;
% xdom = xdom + x0;
% ydom = ydom + y0;
figure;hold on
pcolor(E,N,double(data(:,:,1)));
shading interp
% colormap hot
axis image
grid on
% title(['Guadalupe ',datestr(epoch2Matlab(time(1,573))),' UTC'])
xlabel('[km]');ylabel('[km]')
pcolor(Eastings,Northings,flipud(Irect(:,:,1)));shading interp
xlim([722300 723200]);ylim([4570500 4571700])
title('11:02 Without Declination (180-azi)')


layer1(:,:,i) = uint8(Irect(:,:,1));
layer2(:,:,i) = uint8(Irect(:,:,2));
layer3(:,:,i) = uint8(Irect(:,:,3));

fprintf('completed frame %d of %d\n',whichFrame,subsetNumberOfFrames)
whichFrame = whichFrame+1;
end

[tmp1 tmp2] = fileparts(fname);
save([tmp2,'_',num2str(startTime),'_thru_',num2str(endTime),'.mat'],'layer1','layer2','layer3','x','y','extrinsicParams','frameTimes','-v7.3')

toc