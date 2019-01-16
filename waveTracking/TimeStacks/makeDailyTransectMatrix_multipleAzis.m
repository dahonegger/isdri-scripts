% makeDailyTransectMatrix.m 
% Makes daily matrices of a single cross-shore intensity transect
% 9/21/2017

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
addpath(genpath('E:\guadalupe\processed')) %CTR HUB
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository
addpath(genpath('Y:\shared\simpsale\MATLAB'))

% add path to mat files and choose directory for png's
baseDir = 'D:\guadalupe\processed\';
saveDir = 'Y:\shared\simpsale\MATLAB\ISDRI\TimeStack_mat_files\';

load([baseDir,'2017-09-10\Guadalupe_20172531939_pol.mat'])

%% azimuth transect = 1, anything else gives interpolate option
transectType = 1;

%% for azi index option
% choose azimuth index
if transectType == 1
    desiredAziIdx = 175;
    % now plot to check 
    plotGuad(Azi,Rg,timex,results.heading,results.XOrigin,results.YOrigin)
    [AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-results.heading);
[xdom,ydom] = pol2cart(TH,RG);
    plot(xdom(:,desiredAziIdx),ydom(:,desiredAziIdx),'-c')

    pause
else

%% for clicking transect ends 
    plotGuad(Azi,Rg,timex,results.heading,results.XOrigin,results.YOrigin)
    
    [x1 y1] = ginput(1);
    plot(x1,y1,'.w','markersize',20)
    [x2 y2] = ginput(1);
    plot(x2,y2,'.w','markersize',20)
    plot([x1 x2],[y1 y2],'-w','linewidth',2)
    Xall = linspace(x1,x2,1000).*1000;
    Yall = linspace(y1,y2,1000).*1000;
    [TXazi, TXrg] = cart2pol(Xall,Yall);
    TXazi = mod(90-results.heading - 180/pi*TXazi,360);
    
    [AZI_grid,RG_grid] = ndgrid(Azi,Rg);
    gInt = griddedInterpolant(AZI_grid,RG_grid,single(timex'));
    transectI = gInt(Xall,Yall);
    
end
%% Prep files
% make save directory
if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);
% dayFolderSave = dir([saveDir,'2017*']);

%initialize variables
txIMat = [];
txDn = [];

%% loop through mat files
% numDays = numel(dayFolder)-numel(dayFolderSave);
for iDay = 11:11
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    output_fname =   [num2str(dayFolder(iDay).name),num2str(desiredAziIdx)];
    
    %% loop through all runs for this day
    for iRun = 300:528 %loop through files
        
        cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
        
        %% LOAD TIMEX
        load(cubeName,'Azi','Rg','timex','timeInt','results');        
       
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

        %% for azimuth index 
        % grab these angles from intensity
       if transectType == 1
        if (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 < 120
            txI = double(timex(:,desiredAziIdx));
            txIMat = horzcat(txIMat,txI);
            txDn = horzcat(txDn,mean(epoch2Matlab(timeInt(:))));
            
        elseif (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 > 120
            for ii = 1:8
                txI = timexCell{ii}(:,desiredAziIdx);
                txIMat = horzcat(txIMat,txI);
                txDn = horzcat(txDn, epoch2Matlab(mean(timeInt(1,((ii-1)*64 + 1):((ii)*64)))));
            end
        end
        
        txLon = lon(:,desiredAziIdx);
        txLat = lat(:,desiredAziIdx);
        
       else 
        %% for interpolate option
        
        
       end
       
    %% move on   
    end
    
    save(fullfile(saveDir,output_fname),'txIMat','txDn','Rg','txLon','txLat','-v7.3')
    
%     disp([num2str(iRun),' of ', num2str(length(dayFolder(iDay).polRun)),' run. ',num2str(iDay),' of ',num2str(length(dayFolder)),' day.'])
    clearvars -except baseDir saveDir desiredStartAngle dayFolder dayFolderSave numDays
    txIMat = []; txDn = [];   
end
