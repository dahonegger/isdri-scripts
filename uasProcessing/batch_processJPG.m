clear all; close all;

imDir = 'C:\Users\OSU Radar User\Desktop\drone test\';
UTCconvert = 7; %California local + 7hrs = UTC

%% Rename JPG Files according to Stored Time Info
addpath(genpath(imDir))
fileList = dir([imDir,'DJI*']);
for imId = 1:numel(fileList) %loop through image files in directory
    imName = fileList(imId).name; %access file name
    processJPG(imName,imDir,UTCconvert) %run process function
end

%% Sort images into Subfolders (in Progress) 
renamedfileList = dir([imDir,'*.JPG']);
for imId = 1:numel(renamedfileList)
    fileDatenums(imId) = datenum(renamedfileList(imId).name,'yyyymmdd_HHMMSS');
end

% use diff function on time vector to find where diff > 30 s 
% parse directory into subdirectories using these indices
% leave standalone pictures in main directory? 


%% print gps info to excel document and/or KML?