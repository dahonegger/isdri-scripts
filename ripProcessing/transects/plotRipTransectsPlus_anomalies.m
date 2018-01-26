% plotAlongshoreTransectsPlus
% 10/7/2017

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
HubOld = 'E:\';
HubNew = 'F:\';
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository

% add path to mat files and choose directory for png's
baseDir = [HubOld 'guadalupe\processed\'];
saveDir = [HubNew 'guadalupe\postprocessed\alongshoreTransectFigures\'];
matDir = ['\\attic\hallerm\odea\ISDRI\alongshoreTransectMatrix\'];
% matDir = 'C:\Data\ISDRI\postprocessed\alongshoreTransectMatrix\';

yC = -800:800;
cAxisLims = [-30 30];
%% Prep files
% make save directory
% if ~exist(saveDir);mkdir(saveDir);end
%
startTime = '20170901_0000';
endTime = '20170910_0000';
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

for dd = 1:length(days)
    fn{dd} = [matDir startTime(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d') '.mat'];
    fn{dd} = [matDir endTime(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d') '.mat'];
%     folderName{dd} = [baseDir startTime(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d')];
%     folderName{dd} = [baseDir endTime(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d')];
end

dn1 = datenum([str2num(startTime(1:4)) str2num(startTime(5:6)) str2num(startTime(7:8))...
    str2num(startTime(10:11)) str2num(startTime(12:13)) 0]);
dnEnd = datenum([str2num(endTime(1:4)) str2num(endTime(5:6)) str2num(endTime(7:8))...
    str2num(endTime(10:11)) str2num(endTime(12:13)) 0]);

% Load transects
idxMaxIAll = []; transectMatrix100 = []; timesAll = []; transectMatrix150 = []; transectMatrix200 = []; transectMatrix75 = [];
for i = 1:numel(fn)
    load(fn{i})
    transectMatrix75 = vertcat(transectMatrix75,txIMat_75);
    transectMatrix100 = vertcat(transectMatrix100,txIMat_100);
    transectMatrix150 = vertcat(transectMatrix150,txIMat_150);
    transectMatrix200 = vertcat(transectMatrix200,txIMat_200);
    idxMaxIAll = vertcat(idxMaxIAll, idxMaxI);
    timesAll = horzcat(timesAll,txDn);
end
times = timesAll(timesAll>dn1 & timesAll<dnEnd);
transectMatrix75 = transectMatrix75(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix100 = transectMatrix100(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix150 = transectMatrix150(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix200 = transectMatrix200(timesAll>dn1 & timesAll<dnEnd,:);
clear idxMaxI; idxMaxI = idxMaxIAll(timesAll>dn1 & timesAll<dnEnd,:);
yC = -800:800;

transectMatrixFiltered75 = zeros(size(transectMatrix75));
transectMatrixFiltered100_1200 = zeros(size(transectMatrix100));
transectMatrixFiltered100_800 = zeros(size(transectMatrix100));
transectMatrixFiltered100_400 = zeros(size(transectMatrix100));
transectMatrixFiltered150 = zeros(size(transectMatrix150));
transectMatrixFiltered200 = zeros(size(transectMatrix200));
for t = 1:length(times)
%     transectMatrixFiltered75(t,:) = smooth1d_loess(transectMatrix75(t,:),yC,1200,yC);
    transectMatrixFiltered100_1200(t,:) = smooth1d_loess(transectMatrix100(t,:),yC,1200,yC);
    transectMatrixFiltered100_800(t,:) = smooth1d_loess(transectMatrix100(t,:),yC,800,yC);
    transectMatrixFiltered100_400(t,:) = smooth1d_loess(transectMatrix100(t,:),yC,400,yC);
%     transectMatrixFiltered150(t,:) = smooth1d_loess(transectMatrix150(t,:),yC,1200,yC); 
%     transectMatrixFiltered200(t,:) = smooth1d_loess(transectMatrix200(t,:),yC,1200,yC);
end    
% TMat75 = transectMatrix75 - transectMatrixFiltered75;
TMat100_1200 = transectMatrix100 - transectMatrixFiltered100_1200;
TMat100_800 = transectMatrix100 - transectMatrixFiltered100_800;
TMat100_400 = transectMatrix100 - transectMatrixFiltered100_400;
% TMat200 = transectMatrix200 - transectMatrixFiltered200;
% load('C:\Data\ISDRI\isdri-scripts\ripProcessing\transects\cMap.mat')

AST1200 = mean(TMat100_1200,1);
AST800 = mean(TMat100_800,1);
AST400 = mean(TMat100_400,1);

AST1200 = mean(TMat100_1200(564:end,:),1);
AST800 = mean(TMat100_800(564:end,:),1);
AST400 = mean(TMat100_400(564:end,:),1);

AST1200 = mean(TMat100_1200(1:564,:),1);
AST800 = mean(TMat100_800(1:564,:),1);
AST400 = mean(TMat100_400(1:564,:),1);

figure,
plot(AST1200,yC)
hold on
plot(AST800,yC)
plot(AST400,yC)
xlabel('Intensity anomaly'); ylabel('Alongshore y (m)')
title(['Intensity anomaly ' startTime ' - ' endTime]);
