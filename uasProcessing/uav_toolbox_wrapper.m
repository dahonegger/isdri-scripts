clear all; close all;

addpath(genpath('C:\Users\user\Desktop\UAV-Processing-Toolbox'))

% first get I from dji image/snapshot
fname = 'D:\uasData\10.11.17 Guadalupe (big rip + PR)\DJI_0010.JPG';
I = imread(fname);
% now get lcp (lens calibration profile) 
% calls the output from the Cal Tech calibration toolbox
calib_resultsPn ='C:\Users\user\Desktop\toolbox_calib\photos';
lcp = makeLCPFromCaltech(calib_resultsPn);

% now define the 6 extrinsic parameters
[Lat, Lon, time] = getJPGlatlon(fname);
[Xcam,Ycam,utmzone] = deg2utm(Lat,Lon);
% CONVERT TO UTM HERE
% these are from airdata:
Zcam = 120; % meters 
azimuth = deg2rad(283); %heading 
tilt = deg2rad(90-24.6); %camera angle reported + 90 % gimbal_pitch + 90
roll = 0;
% vectorize 'beta'
Xcam = 0;
Ycam = 0;

beta = [Xcam Ycam Zcam azimuth tilt roll]; %radians



Xmin = Xcam -700;
Xmax = Xcam;
Ymin = Ycam - 200;
Ymax = Ycam + 400;
xy = [Xmin .1 Xmax Ymin .1 Ymax];
% frameRect=makeRectSingleFramePracticum(I,xy,z, beta, lcp);

figure; imagesc(I)

addpath('C:\Users\user\Desktop')
[Irect,x,y]=rectframe(double(I),beta,lcp,xy);
% [X,Y] = meshgrid(x,y);
figure;imagesc(x,y,uint8(Irect));

figure; imagesc(y,x,uint8(flipud(rot90(Irect))))
xlim([-100 250]); ylim([-675 -10])