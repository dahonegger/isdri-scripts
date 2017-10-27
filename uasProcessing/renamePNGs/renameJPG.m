function renameJPG(imName,imDir,UTCconvert)
%renameJPG 
% Renames all JPG files in a directory according to the stored time info 
% Times are converted to UTC using 'UTCConvert' value
% Input time format does not matter
% Output time format is 'yyyymmdd_HHMMSSUTC.JPG'

% Alex Simpson 9.23.2017

%% access image data
imData = imfinfo(imName);

%%% TIME %%%
imTime = imData.DateTime;
imDatenum_local = datenum(imTime,'yyyy:mm:dd HH:MM:SS');
imDatenum = imDatenum_local + UTCconvert./24; 

%%% LAT and LON %%%
Lat = dms2degrees(imData.GPSInfo.GPSLatitude);
if strcmp(imData.GPSInfo.GPSLatitudeRef,'S');
    Lat = -1*Lat;
end
Lon = dms2degrees(imData.GPSInfo.GPSLongitude);
if strcmp(imData.GPSInfo.GPSLongitudeRef,'W');
    Lon = -1*Lon;
end

%% resave image with new name
imRename = strcat(datestr(imDatenum,'yyyymmdd_HHMMSS'),'UTC.JPG');
movefile(fullfile(imDir,imName),fullfile(imDir,imRename))
%% print gps info to excel document (open existing excel document?)

end

