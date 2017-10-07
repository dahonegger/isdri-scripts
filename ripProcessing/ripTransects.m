% ripTransects.m
% 10/7/2017

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
addpath(genpath('E:\guadalupe\processed')) %CTR HUB
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository

% add path to mat files and choose directory for png's
Hub = 'E:\';
baseDir = [Hub 'guadalupe\processed\'];
saveDir = [Hub 'guadalupe\postprocessed\alongshoreTransectMatrix\'];

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
        
        % set rotation(so shoreline is parallel to edge of plot)
        rotation = 14.5;
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg(16:1168));
                
        % find indices of relevant alongshore transects
        x600 = 301;
        x700 = 201;
        x800 = 101;
        
        % set up domain
        xC = -2000:2000;
        yC = -900:-500;
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        
        if (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 < 120
            % rotate domain
            tC = interp2(AZI,RG,double(timex(16:1168,:)),aziC',rgC');
            
            % grab transects from grid
            T600 = tC(x600,:);
            T700 = tC(x700,:);
            T800 = tC(x800,:);
            txIMat_600 = horzcat(txIMat_600,T600);
            txIMat_700 = horzcat(txIMat_700,T700);
            txIMat_800 = horzcat(txIMat_800,T800);
            txDn = horzcat(txDn,mean(epoch2Matlab(timeInt(:))));
            
        elseif (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 > 120
            for ii = 1:8
                % rotate domain
                tC = interp2(AZI,RG,double(timexCell{ii}(16:1168,:)),aziC',rgC');
            
                T600 = tC(x600,:);
                T700 = tC(x700,:);
                T800 = tC(x800,:);
                txIMat_600 = horzcat(txIMat_600,T600);
                txIMat_700 = horzcat(txIMat_700,T700);
                txIMat_800 = horzcat(txIMat_800,T800);
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

