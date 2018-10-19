% makeDailyTransectMatrix.m 
% Makes daily matrices of a single cross-shore intensity transect
% 9/21/2017

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
addpath(genpath('E:\guadalupe\processed')) %CTR HUB
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository

% add path to mat files and choose directory for png's
baseDir = 'E:\guadalupe\processed\';
saveDir = 'E:\guadalupe\postprocessed\dailyTransectMatrix\';

% choose degrees for transect
desiredStartAngle = 270;

%% Prep files
% make save directory
if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);
dayFolderSave = dir([saveDir,'2017*']);

%initialize variables
txIMat = [];
txDn = [];

%% loop through mat files
numDays = numel(dayFolder)-numel(dayFolderSave);
for iDay = 2+numel(dayFolder)-numDays:numel(dayFolder)%loop through days
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    output_fname =   num2str(dayFolder(iDay).name);
    
    %% loop through all runs for this day
    for iRun = 1:1:length(dayFolder(iDay).polRun) %loop through files
        
        cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
        
        %% LOAD TIMEX
        load(cubeName,'Azi','Rg','timex','timeInt','results');
        
%         [rangeFalloff, r2] = findRangeFalloff(timex, Rg, Azi);
        
        % handle the 512 rotation collections: turn into 64 rot averages
        if (epoch2Matlab(timeInt(numel(timeInt)))-epoch2Matlab(timeInt(1))).*24.*60.*60 > 120
            load(cubeName,'data')
            for i = 1:8
                tmp = data(:,:,((i-1)*64)+1:i*64);
                timexCell{i} = double(mean(tmp,3));
            end
        else
        end
        
        % in case timex variable doesn't exist
        if ~exist('timex','var') || isempty(timex)
            load(cubeName,'data')
            timex = double(mean(data,3));
        else
        end
        
        [AZI,RG] = meshgrid(Azi,Rg);
        TH = pi/180*(90-AZI-results.heading);
        THdeg = wrapTo360(AZI+results.heading);
        [X,Y] = pol2cart(TH,RG);
        X = X+results.XOrigin;
        Y = Y+results.YOrigin;
        [lat, lon] = UTM2ll(Y,X,10);

        % grab these angles from intensity
        [idx idx] = min(abs(THdeg(1,:) - desiredStartAngle));
        
        if (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 < 120
            txI = double(timex(:,idx));
            txIMat = horzcat(txIMat,txI);
            txDn = horzcat(txDn,mean(epoch2Matlab(timeInt(:))));
            
        elseif (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 > 120
            for ii = 1:8
                txI = timexCell{ii}(:,idx);
                txIMat = horzcat(txIMat,txI);
                txDn = horzcat(txDn, epoch2Matlab(mean(timeInt(1,((ii-1)*64 + 1):((ii)*64)))));
            end
        end
        
        txLon = lon(:,idx);
        txLat = lat(:,idx);
        
    end
    
    save(fullfile(saveDir,output_fname),'txIMat','txDn','Rg','txLon','txLat','-v7.3')
    
    disp([num2str(iRun),' of ', num2str(length(dayFolder(iDay).polRun)),' run. ',num2str(iDay),' of ',num2str(length(dayFolder)),' day.'])
    clearvars -except baseDir saveDir desiredStartAngle dayFolder dayFolderSave numDays
    txIMat = []; txDn = [];   
end
