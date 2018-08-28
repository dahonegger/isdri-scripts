% plotOnlyAlongshoreTransects
% 1/5/2018
% This code plots the alongshore transect matrices 

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
Hub = 'E:\';
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository

% file names
startTime = '20170901_0000';
endTime = '20171026_0000';

if strcmp(startTime(5:6),endTime(5:6))
    days = str2num(startTime(7:8)):str2num(endTime(7:8));
    months = str2num(startTime(5:6)).*ones(size(days));
elseif ~strcmp(startTime(5:6),endTime(5:6))
    daysS = str2num(startTime(7:8)):30;
    daysO = 1:str2num(endTime(7:8));
    days = [daysS daysO];
    months = [str2num(startTime(5:6))*ones(1,length(daysS))...
        str2num(endTime(5:6))*ones(1,length(daysO))];
    clear daysS daysO
end

% add path to mat files and choose directory for png's
baseDir = [Hub 'guadalupe\processed\'];
saveDir = [Hub 'guadalupe\postprocessed\alongshoreTransectFigures\all\'];
matDir = [Hub 'guadalupe\postprocessed\alongshoreTransectMatrix\all\'];
% matDir = 'C:\Data\ISDRI\postprocessed\alongshoreTransectMatrix\';

%% Prep files
% make save directory
mkdir([saveDir '\75']); mkdir([saveDir '\100']);
mkdir([saveDir '\150']); mkdir([saveDir '\200']);
mkdir([saveDir '\0']); mkdir([saveDir '\30']);

for dd = 1:length(days)
    fn{dd} = [matDir endTime(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d') '.mat'];
    folderName{dd} = [baseDir endTime(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d')];
end

dn1 = datenum([str2num(startTime(1:4)) str2num(startTime(5:6)) str2num(startTime(7:8))...
    str2num(startTime(10:11)) str2num(startTime(12:13)) 0]);
dnEnd = datenum([str2num(endTime(1:4)) str2num(endTime(5:6)) str2num(endTime(7:8))...
    str2num(endTime(10:11)) str2num(endTime(12:13)) 0]);

% Load transects
idxMaxIAll = []; transectMatrix100 = []; timesAll = []; transectMatrix150 = []; transectMatrix200 = []; transectMatrix75 = [];
transectMatrix30 = [];transectMatrix0 = [];
for i = 1:numel(fn)
    load(fn{i})
    transectMatrix0 = vertcat(transectMatrix0,txIMat);
    transectMatrix30 = vertcat(transectMatrix30,txIMat_30);
    transectMatrix75 = vertcat(transectMatrix75,txIMat_75);
    transectMatrix100 = vertcat(transectMatrix100,txIMat_100);
    transectMatrix150 = vertcat(transectMatrix150,txIMat_150);
    transectMatrix200 = vertcat(transectMatrix200,txIMat_200);
    idxMaxIAll = vertcat(idxMaxIAll, idxMaxI);
    timesAll = horzcat(timesAll,txDn);
end

times = timesAll(timesAll>dn1 & timesAll<dnEnd);
transectMatrix0 = transectMatrix0(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix30 = transectMatrix30(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix75 = transectMatrix75(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix100 = transectMatrix100(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix150 = transectMatrix150(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix200 = transectMatrix200(timesAll>dn1 & timesAll<dnEnd,:);
clear idxMaxI; idxMaxI = idxMaxIAll(timesAll>dn1 & timesAll<dnEnd,:);

% smooth transects using a loess filter
transectMatrixFiltered0 = zeros(size(transectMatrix0));
transectMatrixFiltered30 = zeros(size(transectMatrix30));
transectMatrixFiltered75 = zeros(size(transectMatrix75));
transectMatrixFiltered100 = zeros(size(transectMatrix100));
transectMatrixFiltered150 = zeros(size(transectMatrix150));
transectMatrixFiltered200 = zeros(size(transectMatrix200));
for t = 1:length(times)
    transectMatrixFiltered0(t,:) = smooth1d_loess(transectMatrix0(t,:),yC,800,yC);
    transectMatrixFiltered30(t,:) = smooth1d_loess(transectMatrix30(t,:),yC,800,yC);
    transectMatrixFiltered75(t,:) = smooth1d_loess(transectMatrix75(t,:),yC,800,yC);
    transectMatrixFiltered100(t,:) = smooth1d_loess(transectMatrix100(t,:),yC,800,yC);
    transectMatrixFiltered150(t,:) = smooth1d_loess(transectMatrix150(t,:),yC,800,yC);
    transectMatrixFiltered200(t,:) = smooth1d_loess(transectMatrix200(t,:),yC,800,yC);
end

% subtract off smoothed transect to find anomaly
TMat75 = transectMatrix0 - transectMatrixFiltered0;
TMat75 = transectMatrix30 - transectMatrixFiltered30;
TMat75 = transectMatrix75 - transectMatrixFiltered75;
TMat100 = transectMatrix100 - transectMatrixFiltered100;
TMat150 = transectMatrix150 - transectMatrixFiltered150;
TMat200 = transectMatrix200 - transectMatrixFiltered200;
load('C:\Data\ISDRI\isdri-scripts\ripProcessing\transects\cMap.mat')
  