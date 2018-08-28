
clear all;
airDataFile = 'C:\Users\user\Downloads\CTR_AirData_Archive\2017-06-28_6-55-12_Standard.csv';
videoStartGuess = datenum('06/28/2017 6:56','mm/dd/yyyy HH:MM'); %approx, to closest minute, get from video properties

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
% tilt = deg2rad(90-abs(airData.gimbal_pitch(frameIndex))); % 90 - camera angle reported 
% roll = 0;

Lat = airData.latitude(frameIndex);
Lon =airData.longitude(frameIndex);
time = airData.datetime(frameIndex); %in case this is 2nd or 3rd video

% extrinsicParams.Lat = Lat;
% extrinsicParams.Lon = Lon;
% extrinsicParams.Zcam = Zcam;
% extrinsicParams.heading = rad2deg(azimuth);
% extrinsicParams.tilt = rad2deg(tilt);
% extrinsicParams.roll = roll; 

meta_Data.Lat{1} = Lat; meta_Data.Lat{2} = 'decimal degrees';
meta_Data.Lon{1} = Lon; meta_Data.Lon{2} = 'decimal degrees';
meta_Data.time{1} = time; meta_Data.time{2} = 'days';
meta_Data.heading{1} = rad2deg(azimuth); meta_Data.lat{2} = 'degrees True';

data = [1,1,1];
fname = 'f_p';
save([fname,'_avg.mat'],'data','meta_Data')
