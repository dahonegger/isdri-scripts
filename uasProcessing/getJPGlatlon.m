function [Lat,Lon,Time] = getJPGlatlon(fname);
    imData = imfinfo(fname);

Lat = dms2degrees(imData.GPSInfo.GPSLatitude);
if strcmp(imData.GPSInfo.GPSLatitudeRef,'S');
    Lat = -1*Lat;
end
Lon = dms2degrees(imData.GPSInfo.GPSLongitude);
if strcmp(imData.GPSInfo.GPSLongitudeRef,'W');
    Lon = -1*Lon;
end

Time = imData.DateTime;