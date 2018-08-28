close all; clear all;
tic

%% USER DEFINED PARAMETERS
addpath(genpath('C:\Users\user\Desktop\UAV-Processing-Toolbox')) %wherever repository is cloned
addpath(genpath('D:\ctr\uas\')) %wherever footage lives, e.g. HUB 1 or 2
baseFolder = 'E:\ctr\uas\';
fname = '20171791107.MOV';
airDataFile = 'D:\uasData\Full_AirData_Archive\2017-06-28_6-55-12_Standard.csv';
videoStartGuess = datenum('06/28/2017 11:07','mm/dd/yyyy HH:MM'); %approx, to closest minute

%% GET AIRDATA PARAMS
airData=readDJILogCSV(airDataFile);
videoIndices = strfind(airData.isVideo,[0 1])+1; %finds first indices of "1"
videoTimes = airData.datetime(videoIndices);
[idx idx] = min(abs(videoTimes - videoStartGuess));
frameIndex = videoIndices(idx); % this is the index 

% extrinsic params from airdata
Zcam = distdim(airData.altitude(frameIndex),'feet','meters'); % meters 
azimuth = deg2rad(airData.gimbal_heading(frameIndex)); %heading 
tilt = deg2rad(90-airData.gimbal_pitch(frameIndex)); % 90 - camera angle reported 
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
Xmin = Xcam - 60;
Xmax = Xcam + 60;
Ymin = Ycam - 90;
Ymax = Ycam + 90;
xy = [Xmin .1 Xmax Ymin .1 Ymax];

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
numberOfFrames = videoObject.NumberOfFrames;
vidHeight = videoObject.Height;
vidWidth = videoObject.Width;

whichFrame = 1;

%% CREATE FRAME-BY-FRAME TIME VECTOR
fps = videoObject.FrameRate;
df = (1/fps)./60./60./24;
frameTimes = [time:df:time+(numberOfFrames*df)];

%% OPEN MOVIE FRAME BY FRAME, RECTIFY 
for i = 4221:numberOfFrames
warning('off','all')
frame = read(videoObject,i);

[Irect,x,y]=rectframe(double(frame),beta,lcp,xy);

layer1(:,:,i) = uint8(Irect(:,:,1));
layer2(:,:,i) = uint8(Irect(:,:,2));
layer3(:,:,i) = uint8(Irect(:,:,3));

% X(i,:) = x;
% Y(i,:) = y;

fprintf('completed frame %d of %d\n',whichFrame,numberOfFrames)
whichFrame = whichFrame+1;
end

frameTimes = frameTimes(4221:numberOfFrames);
layer1 = layer1(:,:,4221:numberOfFrames);
layer2 = layer2(:,:,4221:numberOfFrames);
layer3 = layer3(:,:,4221:numberOfFrames);

save('20171791107_rect_part2.mat','layer1','layer2','layer3','x','y','extrinsicParams','frameTimes','-v7.3')

toc