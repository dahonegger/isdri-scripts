close all; clear all;

%% USER DEFINED PARAMETERS
addpath(genpath('C:\Users\user\Desktop\UAV-Processing-Toolbox')) %wherever repository is cloned
addpath(genpath('C:\Data\isdri\isdri-scripts')) %wherever repository is cloned

baseFolder = 'F:\uasData\10.23.17 Guadalupe (cBathy)';
pngFolder = 'F:\uasData\10.23.17 Guadalupe (cBathy)\cBathy\DJI_0006 thru DJI_0009\';
fname = 'DJI_0006_DJI_0007_DJI_0008_DJI_0009.MP4';
airDataFile = 'F:\uasData\Full_AirData_Archive\2017-10-23_8-36-13_Standard.csv';
videoStartGuess = datenum('10/23/2017 8:44','mm/dd/yyyy HH:MM'); %approx, to closest minute, get from video properties
savePNGS = 1; %want to make PNGs? 1=yes
addpath(genpath(baseFolder)) %wherever footage lives, e.g. HUB 1 or 2

%% GET AIRDATA PARAMS
%this gets info for first video frame (when isVideo switches to 1) 
%use first frame for full movie duration, even if broken up 

airData=readDJILogCSV(airDataFile);
videoIndices = strfind(airData.isVideo,[0 1])+1; %finds first indices of "1"
videoTimes = airData.datetime(videoIndices);
[idx idx] = min(abs(videoTimes - videoStartGuess));
frameIndex = videoIndices(idx); % this is the index of video start

% extrinsic params from airdata
Zcam = distdim(airData.altitude(frameIndex)-abs(min(airData.altitude)),'feet','meters'); % meters 
azimuth = deg2rad(airData.gimbal_heading(frameIndex)); %heading 
tilt = deg2rad(90-abs(airData.gimbal_pitch(frameIndex))); % 90 - camera angle reported 
roll = 0;

Lat = airData.latitude(frameIndex);
Lon =airData.longitude(frameIndex);
time = airData.datetime(frameIndex); %in case this is 2nd or 3rd video

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
Xmin = Xcam - 1000;
Xmax = Xcam - 100;
Ymin = Ycam - 200;
Ymax = Ycam + 700;
xy = [Xmin .5 Xmax Ymin .5 Ymax];

%% PREP INTRINSIC PARAMS (SPECIFIC TO SHOOTING MODE)
% PICK THE PATH TO THE RIGHT SHOOTING MODE, EACH FOLDER CONTAINS A UNIQUE
% 'Calib_Results.mat' 
% paramPath = 'E:\uasData\calibrationParams\4x3_photo';
% paramPath = 'E:\uasData\calibrationParams\16x9_photo';
% paramPath = 'E:\uasData\calibrationParams\3840x2160_video';
paramPath = 'F:\uasData\calibrationParams\4096x2160_video';

lcp = makeLCPFromCaltech(paramPath);

%% PREP MOVIE PARAMS
videoObject = VideoReader(fname);
numberOfFrames = videoObject.NumberOfFrames;
vidHeight = videoObject.Height;
vidWidth = videoObject.Width;

whichFrame = 1;

%% CREATE FRAME-BY-FRAME TIME VECTOR
fps = videoObject.FrameRate;
df_frames = round(videoObject.FrameRate./2);
df_seconds = (1/2)./60./60./24;
frameTimes_all = [time:df_seconds:time+((numberOfFrames/df_frames)*df_seconds)];

%% OPEN MOVIE FRAME BY FRAME, RECTIFY 

parseVal = round(numberOfFrames./3);
globalFrame = 1;

for jj = 1:parseVal:(parseVal*2)

    whichFrame = 1;

    for i = jj:df_frames:jj+parseVal
        
        frameTimes = frameTimes_all(ceil(jj/df_frames):round((jj+parseVal)/df_frames));
        warning('off','all')
        frame = read(videoObject,i);
        [Irect,x,y]=rectframe(double(frame),beta,lcp,xy);
        layer1(:,:,whichFrame) = uint8(Irect(:,:,1));
        layer2(:,:,whichFrame) = uint8(Irect(:,:,2));
        layer3(:,:,whichFrame) = uint8(Irect(:,:,3));
        fprintf('rectified frame %d of %d\n',i,numberOfFrames)
     
        
        if savePNGS == 1
        fig=figure; hold on
        set(gcf,'visible','off')
        imagesc(x,y,uint8(Irect)); %imagesc needs 3 layers(r,g,b) in uint8 format
        title({['cBathy Footage from Guadalupe'],[datestr(frameTimes(whichFrame))]})
        xlabel('X [meters]');ylabel('Y [meters]');
        axis image
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0 0 3 3];
        saveName = datestr(frameTimes(i),'mmddyy HH.MM.SS.FFF'); %make sure there are milliseconds
        print([baseFolder,saveName,'.png'],'-dpng','-r300')
        close all
        
        else 
        end
   
        whichFrame = whichFrame+1;
        globalFrame = globalFrame+1;
    end
    
    [name,ext] = fileparts(fname);
    save([ext,'_frame',num2str(jj),'_thruFrame_',num2str(jj+parseVal),'.mat'],'layer1','layer2','layer3','x','y','extrinsicParams','frameTimes','-v7.3')

    clear('layer1','layer2','layer3');

end


