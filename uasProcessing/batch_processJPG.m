clear all; close all;

imDir = 'C:\Users\OSU Radar User\Desktop\drone test';
saveDir = 'C:\Users\OSU Radar User\Desktop\drone_processed';


addpath(genpath(imDir))

%% get GPS info
imData = imfinfo('DJI_0002.JPG');
Lat = dms2degrees(imData.GPSInfo.GPSLatitude);
if strcmp(imData.GPSInfo.GPSLatitudeRef,'S');
    Lat = -1*Lat;
end
Lon = dms2degrees(imData.GPSInfo.GPSLongitude);
if strcmp(imData.GPSInfo.GPSLongitudeRef,'W');
    Lon = -1*Lon;
end


%% load image

%% resave image with new name

%% print gps info to excel document (open existing excel document?)