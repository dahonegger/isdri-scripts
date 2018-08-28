%% temperatureAnalysis.m


%% Add path
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));
addpath(genpath('C:\Data\ISDRI\cBathy'));

warmRipTimes = [datenum([2017,9,7,23,15,0]),datenum([2017,9,8,23,35,0]),...
    datenum([2017,]),];

[boreHours, boreEndTime, tempDiffMean, tempDiffSurface] = boreInfo(ripTimes(1));

