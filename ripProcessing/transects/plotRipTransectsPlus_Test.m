% plotAlongshoreTransectsPlus
% 1/5/2018
% This code plots the alongshore transect matrices and the associated radar
% imagery

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
Hub = 'E:\';
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository

% file names
startTime = {'20170901_0000','20170910_0000','20170920_0000','20171001_0000'...
    '20171010_0000','20171020_0000'};
endTime = {'20170910_0000','20170920_0000','20171001_0000','20171010_0000'...
    '20171020_0000','20171026_0000'};


for iP = 1:length(startTime);
    if strcmp(startTime{iP}(5:6),endTime{iP}(5:6))
        days = str2num(startTime{iP}(7:8)):str2num(endTime{iP}(7:8));
        months = str2num(startTime{iP}(5:6)).*ones(size(days));
    elseif ~strcmp(startTime{iP}(5:6),endTime{iP}(5:6))
        daysS = str2num(startTime{iP}(7:8)):30;
        daysO = 1:str2num(endTime{iP}(7:8));
        days = [daysS daysO];
        months = [str2num(startTime{iP}(5:6))*ones(1,length(daysS))...
            str2num(endTime{iP}(5:6))*ones(1,length(daysO))];
        clear daysS daysO
    end
    
    % add path to mat files and choose directory for png's
    baseDir = [Hub 'guadalupe\processed\'];
%     saveDir = [Hub 'guadalupe\postprocessed\alongshoreTransectFigures\'...
%         num2str(startTime{iP}(1:4)) num2str(startTime{iP}(5:6),'%02i')...
%         num2str(startTime{iP}(7:8),'%02i') '_' num2str(endTime{iP}(1:4))...
%         num2str(endTime{iP}(5:6),'%02i') num2str(endTime{iP}(7:8),'%02i') '\'];
    matDir = [Hub 'guadalupe\postprocessed\alongshoreTransectMatrix\all_1000\'];
    % matDir = 'C:\Data\ISDRI\postprocessed\alongshoreTransectMatrix\';
    
    %     if exist(saveDir)
    %     else
    %% define domain and rotation
    xCutoff = 1168;
    domainRotation = 13;
    yC = -1000:1000;
    xC = -1200:-500;
    xCMaxI = -1100:-500;
    cAxisLims = [-30 30];
    
    %% Prep files
    % make save directory
%     mkdir(saveDir);
%     mkdir([saveDir '\75']); mkdir([saveDir '\100']);
%     mkdir([saveDir '\150']); mkdir([saveDir '\200']);
%     
    for dd = 1:length(days)
        fn{dd} = [matDir endTime{iP}(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d') '.mat'];
        folderName{dd} = [baseDir endTime{iP}(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d')];
    end
    
    dn1 = datenum([str2num(startTime{iP}(1:4)) str2num(startTime{iP}(5:6)) str2num(startTime{iP}(7:8))...
        str2num(startTime{iP}(10:11)) str2num(startTime{iP}(12:13)) 0]);
    dnEnd = datenum([str2num(endTime{iP}(1:4)) str2num(endTime{iP}(5:6)) str2num(endTime{iP}(7:8))...
        str2num(endTime{iP}(10:11)) str2num(endTime{iP}(12:13)) 0]);
    
    % Load transects
    idxMaxIAll = []; transectMatrix100 = []; timesAll = []; transectMatrix150 = [];...
        transectMatrix200 = []; transectMatrix75 = []; transectMatrix30 = []; transectMatrix0 = [];
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
        transectMatrixFiltered0(t,:) = smooth1d_loess(transectMatrix0(t,:),yC,1200,yC);
        transectMatrixFiltered30(t,:) = smooth1d_loess(transectMatrix30(t,:),yC,1200,yC);
        transectMatrixFiltered75(t,:) = smooth1d_loess(transectMatrix75(t,:),yC,1200,yC);
        transectMatrixFiltered100(t,:) = smooth1d_loess(transectMatrix100(t,:),yC,1200,yC);
        transectMatrixFiltered150(t,:) = smooth1d_loess(transectMatrix150(t,:),yC,1200,yC);
        transectMatrixFiltered200(t,:) = smooth1d_loess(transectMatrix200(t,:),yC,1200,yC);
        
% %         transectMatrixFiltered75(t,:) = smooth1d_loess(transectMatrix75(t,:),yC,1200,yC);
%         transectMatrixFiltered100(t,:) = smooth1d_loess(transectMatrix100(t,:),yC,400,yC);
%         transectMatrixFiltered150(t,:) = smooth1d_loess(transectMatrix150(t,:),yC,400,yC);
%         transectMatrixFiltered200(t,:) = smooth1d_loess(transectMatrix200(t,:),yC,400,yC);
    end
    
    % subtract off smoothed transect to find anomaly
    TMat0 = transectMatrix0 - transectMatrixFiltered0;
    TMat30 = transectMatrix30 - transectMatrixFiltered30;
    TMat75 = transectMatrix75 - transectMatrixFiltered75;
    TMat100 = transectMatrix100 - transectMatrixFiltered100;
    TMat150 = transectMatrix150 - transectMatrixFiltered150;
    TMat200 = transectMatrix200 - transectMatrixFiltered200;
%     load('C:\Data\ISDRI\isdri-scripts\ripProcessing\transects\cMap.mat')
    saveDir = 'E:\guadalupe\postprocessed\alongshoreTransectMatrix\ANOMALY_TRANSECTS\Loess_1200_1000m';
    matName0 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat0.mat'];
    matName30 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat30.mat'];
    matName75 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat075.mat'];
    matName100 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat100.mat'];
    matName150 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat150.mat'];
    matName200 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat200.mat'];
    timeMatName = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_time.mat'];    

    save(matName0,'TMat0')
    save(matName30,'TMat30')
    save(matName75,'TMat75')
    save(matName100,'TMat100')
    save(matName150,'TMat150')
    save(matName200,'TMat200')
%     save(timeMatName,'times')

    clear timeMatName
    clear matName0 matName75 matName30 matName100 matName150 matName200
    
%     %% loop through mat files
%     for iDay = 1:length(days) %loop through days
%         
%         fileList = dir(fullfile(folderName{iDay},'*_pol.mat'));
%         
%         %% loop through all runs for this day
%         for iRun = 1:1:length(fileList) %loop through files to find number of rotations
%             if iP == 5 && iDay == 8 && iRun == 2
%             else
%                 cubeName = fullfile(fileList(iRun).folder,fileList(iRun).name);
%                 load(cubeName,'timeInt');
%                 cubeRots(iRun) = size(timeInt,2);
%                 clear cubeName cubeTimes
%             end
%         end
%         
%         % %     %% loop through all runs for this day
%         % %     for iRun = 1:1:length(fileList) %loop through files
%         % %
%         % %         cubeName = fullfile(fileList(iRun).folder,fileList(iRun).name);
%         % %
%         % %         %% LOAD TIMEX
%         % %         load(cubeName,'Azi','Rg','timex','timeInt','results');
%         % % % %
%         % separate into 448 rotations
%         files448 = [];
%         skip = 0;
%         for iRun = 1:length(fileList)
%             if iP == 5 && iDay == 8 && iRun == 2
%             else
%                 if sum(iRun ~= skip) == length(skip)
%                     
%                     % find number of rotations per file
%                     rotations = cubeRots(iRun);
%                     
%                     % if number of rotations is 64, combine 7 files to get 448
%                     if rotations < 448
%                         if iRun+6 <= length(cubeRots) && sum(cubeRots(iRun:(iRun+6))==64) == 7
%                             for iRun448 = iRun:(iRun+6)
%                                 cubeName = fullfile(fileList(iRun448).folder,fileList(iRun448).name);
%                                 load(cubeName,'Azi','Rg','timex','timeInt','results');
%                                 
%                                 % in case timex variable doesn't exist
%                                 if ~exist('timex','var') || isempty(timex)
%                                     load(cubeName,'data')
%                                     timex = double(mean(data,3));
%                                 else
%                                 end
%                                 
%                                 timeAll(iRun448-iRun+1) = mean(epoch2Matlab(timeInt(:)));
%                                 timexAll(:,:,iRun448-iRun+1) = timex;
%                                 clear timex timeInt
%                             end
%                             
%                             timex448 = mean(timexAll,3);
%                             time448 = mean(timeAll);
%                             skip = (iRun+1):(iRun+6);
%                             clear timexAll timeAll
%                         end
%                         
%                         % if number of rotations is 448
%                     elseif rotations == 448
%                         cubeName = fullfile(fileList(iRun).folder,fileList(iRun).name);;
%                         load(cubeName,'Azi','Rg','timex','timeInt','results');
%                         
%                         % in case timex variable doesn't exist
%                         if ~exist('timex','var') || isempty(timex)
%                             load(cubeName,'data')
%                             timex = double(mean(data,3));
%                         else
%                         end
%                         
%                         time448 = mean(epoch2Matlab(timeInt(:)));
%                         timex448 = timex;
%                         skip = 0;
%                         clear timex
%                         
%                         % if number of rotations is greater than 448 but less than 2*448,
%                         % used only first 448 rotations and ignore the rest
%                     elseif rotations > 448 && rotations < 448*2
%                         cubeName = fullfile(fileList(iRun).folder,fileList(iRun).name);
%                         load(cubeName,'Azi','Rg','data','timeInt','results');
%                         data448 = data(:,:,1:448);
%                         timex448 = mean(data448,3);
%                         timeInt448 = timeInt(:,1:448);
%                         time448 = mean(epoch2Matlab(timeInt448(:)));
%                         clear data448 timeInt448
%                         skip = 0;
%                         
%                         % if number of rotations greater than 2*448, separate into
%                         % multiple timex448 matrices
%                     elseif rotations >= 448*2
%                         load(cubeName,'Azi','Rg','data','timeInt','results');
%                         for RR = 1:floor(size(data,3)/448)
%                             data448 = data(:,:,(1+448*(RR-1)):(448+448*(RR-1)));
%                             timex448(:,:,RR) = mean(data448,3);
%                             timeInt448 = timeInt(:,1:448);
%                             time448(RR) = mean(epoch2Matlab(timeInt448(:)));
%                             clear data448 timeInt448
%                         end
%                         skip = 0;
%                     end
%                     
%                     if exist('Rg')
%                         % set rotation(so shoreline is parallel to edge of plot)
%                         heading = results.heading-domainRotation;
%                         [AZI,RG] = meshgrid(Azi,Rg(16:xCutoff));
%                         
%                         % set up domain
%                         [XX,YY] = meshgrid(xC,yC);
%                         [thC,rgC] = cart2pol(XX,YY);
%                         aziC = wrapTo360(90 - thC*180/pi - heading);
%                         
%                         % set up domain
%                         [XX,YY] = meshgrid(xC,yC);
%                         [thC,rgC] = cart2pol(XX,YY);
%                         aziC = wrapTo360(90 - thC*180/pi - heading);
%                         
%                         % rotate domain
%                         for tt = 1:size(timex448,3)
%                             
%                             % rotate domain
%                             tC = interp2(AZI,RG,double(timex448(16:xCutoff,:,tt)),aziC',rgC');
%                             timeScan = time448(:);
%                             dv = datevec(timeScan);
%                             [~,idx] = min(abs(timeScan - times));
%                             
%                             fig100 = figure('visible','off');
%                             fig100.PaperUnits = 'inches';
%                             fig100.PaperPosition = [0 0 6 4];
%                             subplot(1,2,1)
%                             pcolor(XX,YY,tC')
%                             shading flat; axis image;
%                             colormap(hot)
%                             caxis([10 220])
%                             hold on
%                             plot(xCMaxI(idxMaxI(idx,:)-100),yC,'b')
%                             plot(xCMaxI(idxMaxI(idx,:)),yC,'b')
%                             ttl100 = ['2017-' num2str(months(iDay),'%02d') '-'...
%                                 num2str(days(iDay),'%02d') ' ' num2str(dv(4),'%02d') ':' num2str(dv(5),'%02d') ':' num2str(round(dv(6)),'%02d')];
%                             title(ttl100)
%                             
%                             hold on
%                             s2 = subplot(1,2,2);
%                             pcolor(times,yC,TMat100');
%                             shading flat
%                             hold on
%                             y1 = get(gca,'ylim');
%                             plot([timeScan timeScan],y1,'r','LineWidth',1)
%                             colormap(s2,cMap)
%                             %         colorbar
%                             datetick('x',6)
%                             caxis([cAxisLims(1) cAxisLims(2)])
%                             axis([dn1 dnEnd yC(1) yC(end)])
%                             figttl100 = [saveDir '100\' fileList(iRun).name(1:21) '_100.png'];
%                             ttl100_2 = 'Timestack 100 m from max intensity';
%                             title(ttl100_2)
%                             
%                             fig75 = figure('visible','off');
%                             fig75.PaperUnits = 'inches';
%                             fig75.PaperPosition = [0 0 6 4];
%                             subplot(1,2,1)
%                             pcolor(XX,YY,tC')
%                             shading flat; axis image;
%                             colormap(hot)
%                             caxis([10 220])
%                             hold on
%                             y1 = get(gca,'ylim');
%                             plot(xCMaxI(idxMaxI(idx,:)-75),yC,'b','LineWidth',1)
%                             plot(xCMaxI(idxMaxI(idx,:)),yC,'b','LineWidth',1)
%                             ttl75 = ['2017-' num2str(months(iDay),'%02d') '-'...
%                                 num2str(days(iDay),'%02d') ' ' num2str(dv(4),'%02d') ':' num2str(dv(5),'%02d') ':' num2str(round(dv(6)),'%02d')];
%                             title(ttl75)
%                             
%                             hold on
%                             s22 =subplot(1,2,2);
%                             pcolor(times,yC,TMat75');
%                             shading flat
%                             hold on
%                             colormap(s22,cMap)
%                             %         colorbar
%                             plot([timeScan timeScan],y1,'r','LineWidth',1)
%                             datetick('x',6)
%                             caxis([cAxisLims(1) cAxisLims(2)])
%                             axis([dn1 dnEnd yC(1) yC(end)])
%                             ttl75_2 = 'Timestack 75 m from max intensity';
%                             title(ttl75_2)
%                             figttl75 = [saveDir '75\' fileList(iRun).name(1:21) '_75.png'];
%                             
%                             fig150 = figure('visible','off');
%                             fig150.PaperUnits = 'inches';
%                             fig150.PaperPosition = [0 0 6 4];
%                             subplot(1,2,1)
%                             pcolor(XX,YY,tC')
%                             shading flat; axis image;
%                             colormap(hot)
%                             caxis([10 220])
%                             hold on
%                             y1 = get(gca,'ylim');
%                             plot(xCMaxI(idxMaxI(idx,:)-150),yC,'b','LineWidth',1)
%                             plot(xCMaxI(idxMaxI(idx,:)),yC,'b','LineWidth',1)
%                             ttl150 = ['2017-' num2str(months(iDay),'%02d') '-'...
%                                 num2str(days(iDay),'%02d') ' ' num2str(dv(4),'%02d') ':' num2str(dv(5),'%02d') ':' num2str(round(dv(6)),'%02d')];
%                             title(ttl150)
%                             
%                             hold on
%                             s23 =subplot(1,2,2);
%                             pcolor(times,yC,TMat150');
%                             shading flat
%                             hold on
%                             colormap(s23,cMap)
%                             %         colorbar
%                             plot([timeScan timeScan],y1,'r','LineWidth',1)
%                             datetick('x',6)
%                             caxis([cAxisLims(1) cAxisLims(2)])
%                             axis([dn1 dnEnd yC(1) yC(end)])
%                             ttl150_2 = 'Timestack 150 m from max intensity';
%                             title(ttl150_2)
%                             figttl150 = [saveDir '150\' fileList(iRun).name(1:21) '_150.png'];
%                             
%                             fig200 = figure('visible','off');
%                             fig200.PaperUnits = 'inches';
%                             fig200.PaperPosition = [0 0 6 4];
%                             subplot(1,2,1)
%                             pcolor(XX,YY,tC')
%                             shading flat; axis image;
%                             colormap(hot)
%                             caxis([10 220])
%                             hold on
%                             y1 = get(gca,'ylim');
%                             plot(xCMaxI(idxMaxI(idx,:)-200),yC,'b','LineWidth',1)
%                             plot(xCMaxI(idxMaxI(idx,:)),yC,'b','LineWidth',1)
%                             ttl200 = ['2017-' num2str(months(iDay),'%02d') '-'...
%                                 num2str(days(iDay),'%02d') ' ' num2str(dv(4),'%02d') ':' num2str(dv(5),'%02d') ':' num2str(round(dv(6)),'%02d')];
%                             title(ttl200)
%                             
%                             hold on
%                             s24 = subplot(1,2,2);
%                             pcolor(times,yC,TMat200');
%                             shading flat
%                             hold on
%                             colormap(s24,cMap)
%                             %         colorbar
%                             plot([timeScan timeScan],y1,'r','LineWidth',1)
%                             datetick('x',6)
%                             caxis([cAxisLims(1) cAxisLims(2)])
%                             axis([dn1 dnEnd yC(1) yC(end)])
%                             ttl200_2 = 'Timestack 200 m from max intensity';
%                             title(ttl200_2)
%                             figttl200 = [saveDir '200\' fileList(iRun).name(1:21) '_200.png'];
%                             
%                             %print figs
%                             print(fig100, figttl100, '-dpng')
%                             print(fig75, figttl75, '-dpng')
%                             print(fig150, figttl150, '-dpng')
%                             print(fig200, figttl200, '-dpng')
%                             
%                         end
%                     end
%                     close all; clear Rg
%                 end
%             end
%         end
%         clear cubeRots
%     end
end
% end


    
