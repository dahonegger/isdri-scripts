clear all; close all;

imDir = 'C:\Users\OSU Radar User\Desktop\UAS_Test_Flights\UAS_Tennis_Court_Test\';
UTCconvert = 7; %California local + 7hrs = UTC

%% Rename JPG Files according to Stored Time Info
addpath(genpath(imDir))
fileList = dir([imDir,'*.JPG']);
warning off
for imId = 1:numel(fileList) %loop through image files in directory
    imName = fileList(imId).name; %access file name
    renameJPG(imName,imDir,UTCconvert) %run process function
end

%% Rename movie Files according to 
%% Sort images into Subfolders (in Progress) 
renamedfileList = dir([imDir,'*.JPG']);
for imId = 1:numel(renamedfileList)
    fileDatenums(imId) = datenum(renamedfileList(imId).name,'yyyymmdd_HHMMSS');
end

% use diff function on time vector to find where diff > 30 s 
% parse directory into subdirectories using these indices
% leave standalone pictures in main directory? 


%% print gps info to excel document and/or KML?