% plotAlongshoreTransectsPlus
% 10/7/2017

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
Hub = 'F:\';
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository

% add path to mat files and choose directory for png's
baseDir = [Hub 'guadalupe\processed\'];
saveDir = [Hub 'guadalupe\postprocessed\alongshoreTransectFigures\'];
matDir = [Hub 'guadalupe\postprocessed\alongshoreTransectMatrix\'];

%% Prep files
% make save directory
if ~exist(saveDir);mkdir(saveDir);end

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
    folderName{dd} = [baseDir startTime(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d')];
    folderName{dd} = [baseDir endTime(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d')];
end

dn1 = datenum([str2num(startTime(1:4)) str2num(startTime(5:6)) str2num(startTime(7:8))...
    str2num(startTime(10:11)) str2num(startTime(12:13)) 0]);
dnEnd = datenum([str2num(endTime(1:4)) str2num(endTime(5:6)) str2num(endTime(7:8))...
    str2num(endTime(10:11)) str2num(endTime(12:13)) 0]);

% Load transects
transectMatrix600 = []; timesAll = []; transectMatrix650 = []; transectMatrix700 = [];
for i = 1:numel(fn)
    load(fn{i})
    transectMatrix600 = vertcat(transectMatrix600,txIMat_600);
    transectMatrix650 = vertcat(transectMatrix650,txIMat_650);
    transectMatrix700 = vertcat(transectMatrix700,txIMat_700);
    timesAll = horzcat(timesAll,txDn);
end
times = timesAll(timesAll>dn1 & timesAll<dnEnd);
transectMatrix600 = transectMatrix600(timesAll>dn1 & timesAll<dnEnd,1001:3001);
transectMatrix650 = transectMatrix650(timesAll>dn1 & timesAll<dnEnd,1001:3001);
transectMatrix700 = transectMatrix700(timesAll>dn1 & timesAll<dnEnd,1001:3001);
xC = -1000:1000;

transectMatrixFiltered600 = zeros(size(transectMatrix600));
transectMatrixFiltered650 = zeros(size(transectMatrix650));
transectMatrixFiltered700 = zeros(size(transectMatrix700));
for t = 1:length(times);
    transectMatrixFiltered600(t,:) = smooth1d_loess(transectMatrix600(t,:),xC,1000,xC);
    transectMatrixFiltered650(t,:) = smooth1d_loess(transectMatrix650(t,:),xC,1000,xC); 
    transectMatrixFiltered700(t,:) = smooth1d_loess(transectMatrix700(t,:),xC,1000,xC);
end    
TMat600 = transectMatrix600 - transectMatrixFiltered600;
TMat650 = transectMatrix650 - transectMatrixFiltered650;
TMat700 = transectMatrix700 - transectMatrixFiltered700;

%% loop through mat files
for iDay = 1:length(days) %loop through days
    
    fileList = dir(fullfile(folderName{days(iDay)},'*_pol.mat'));

    %% loop through all runs for this day
    for iRun = 1:1:length(fileList) %loop through files
        
        cubeName = fullfile(fileList(iRun).folder,fileList(iRun).name);
        
        %% LOAD TIMEX
        load(cubeName,'Azi','Rg','timex','timeInt','results');
        
        % in case timex variable doesn't exist
        if ~exist('timex','var') || isempty(timex)
            load(cubeName,'data')
            timex = double(mean(data,3));
        else
        end
        
        timeScanStart = timeInt(1,1);
        % set rotation(so shoreline is parallel to edge of plot)
        rotation = 13;
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg(16:1168));
        
        % find indices of relevant alongshore transects
        x600 = 301;
        x650 = 251;
        x700 = 201;
        
        % set up domain
        xC = -1000:1000;
        yC = -1200:-500;
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        
        % rotate domain
        tC = interp2(AZI,RG,double(timex(16:1168,:)),aziC',rgC');
        timeScan = mean(epoch2Matlab(timeInt(:)));
        dv = datevec(timeScan);
        
        fig650 = figure('visible','off');
        fig650.PaperUnits = 'inches';
        fig650.PaperPosition = [0 0 6 4];
        subplot(1,2,1)
        pcolor(XX,YY,tC')
        shading flat; axis image;
        colormap(hot)
        caxis([10 220])
        hold on
        y1 = get(gca,'ylim');
        plot([-650 -650],y1,'b','LineWidth',1)
        ttl650 = ['2017-' num2str(months(iDay),'%02d') '-'...
            num2str(days(iDay),'%02d') ' ' num2str(dv(4),'%02d') ':' num2str(dv(5),'%02d') ':' num2str(round(dv(6)),'%02d')];
        title(ttl650)
        
        hold on
        s2 = subplot(1,2,2);
        pcolor(times,xC,TMat650');
        shading flat
        hold on
        plot([timeScan timeScan],y1,'r','LineWidth',1)
        colormap(s2,cMap)
%         colorbar
        datetick('x',6)
        caxis([-50 50])
        axis([dn1 dnEnd xC(1) xC(end)])
        figttl650 = [saveDir fileList(iRun).name(1:21) '_650.png'];
        ttl650_2 = 'Timestack x = 650 m';
        title(ttl650_2)
        
        fig700 = figure('visible','off');
        fig700.PaperUnits = 'inches';
        fig700.PaperPosition = [0 0 6 4];
        subplot(1,2,1)
        pcolor(XX,YY,tC')
        shading flat; axis image;
        colormap(hot)
        caxis([10 220])
        hold on
        y1 = get(gca,'ylim');
        plot([-700 -700],y1,'b','LineWidth',1)
        ttl700 = ['2017-' num2str(months(iDay),'%02d') '-'...
            num2str(days(iDay),'%02d') ' ' num2str(dv(4),'%02d') ':' num2str(dv(5),'%02d') ':' num2str(round(dv(6)),'%02d')];
        title(ttl700)
        
        hold on
        s2 =subplot(1,2,2);
        pcolor(times,xC,TMat700');
        shading flat
        hold on
        colormap(s2,cMap)
%         colorbar
        plot([timeScan timeScan],y1,'r','LineWidth',1)
        datetick('x',6)
        caxis([-20 20])
        axis([dn1 dnEnd xC(1) xC(end)])
        ttl700_2 = 'Timestack x = 700 m';
        title(ttl700_2)
        figttl700 = [saveDir fileList(iRun).name(1:21) '_700.png'];
        
        % print figs
        print(fig650, figttl650, '-dpng')
        print(fig700, figttl700, '-dpng')
        
        close all
    end
end

