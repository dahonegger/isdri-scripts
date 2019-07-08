% ripTransect_fromPeakGradient.m
% 1/5/2018
% This code finds the peak gradient, smooths it using a moving average,
% and then finds the intensity a given distance from that line.

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
Hub = 'E:\';
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository

% add path to mat files and choose directory for png's
baseDir = [Hub 'guadalupe\processed\'];
saveDir = [Hub 'guadalupe\postprocessed\alongshoreTransectMatrix\all_3000\'];

%% Prep files
% make save directory
if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);
dayFolderSave = dir([saveDir,'2017*']);

%initialize variables
txIMat = [];
txIMat_30 = [];
txIMat_75 = [];
txIMat_100 = [];
txIMat_150 = [];
txIMat_200 = [];
txDn = [];
idxMaxI = [];

% set up domain
yC = -3000:3000;
xC = -1100:-500;
xCutoff = 1668;
domainRotation = 12;
% rotations = 256;

%% loop through mat files
numDays = numel(dayFolder)-numel(dayFolderSave);%% STOPPED AT 19, RESTARTED AT 32, STOPPED AT 55
for iDay = 55:numel(dayFolder);%%%2 + numel(dayFolder)-numDays:numel(dayFolder) %loop through days
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    output_fname =   num2str(dayFolder(iDay).name);
    
    %% loop through all runs for this day
    for iRun = 1:1:length(dayFolder(iDay).polRun) %loop through files to find number of rotations
        if iDay == 48 && iRun == 2
        else
            cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
            load(cubeName,'timeInt');
            cubeRots(iRun) = size(timeInt,2);
            clear cubeName timeInt
        end
    end
    
    % separate into 448 rotations
    files448 = [];
    skip = 0;
    for iRun = 1:length(cubeRots)
        if iDay == 48 && iRun == 2
        else
            if sum(iRun ~= skip) == length(skip)
                
                % find number of rotations per file
                rotations = cubeRots(iRun);
                
                % if number of rotations is 64, combine 7 files to get 448
                if rotations < 448
                    if iRun+6 <= length(cubeRots) && sum(cubeRots(iRun:(iRun+6))==64) == 7
                        for iRun448 = iRun:(iRun+6)
                            cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun448).name);
                            load(cubeName,'Azi','Rg','timex','timeInt','results');
                            
                            % in case timex variable doesn't exist
                            if ~exist('timex','var') || isempty(timex)
                                load(cubeName,'data')
                                timex = double(mean(data,3));
                            else
                            end
                            
                            timeAll(iRun448-iRun+1) = mean(epoch2Matlab(timeInt(:)));
                            timexAll(:,:,iRun448-iRun+1) = timex;
                            clear timex timeInt
                        end
                        
                        timex448 = mean(timexAll,3);
                        time448 = mean(timeAll);
                        skip = (iRun+1):(iRun+6);
                        clear timexAll timeAll
                    end
                    
                    % if number of rotations is 448
                elseif rotations == 448
                    cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun448).name);
                    load(cubeName,'Azi','Rg','timex','timeInt','results');
                    
                    % in case timex variable doesn't exist
                    if ~exist('timex','var') || isempty(timex)
                        load(cubeName,'data')
                        timex = double(mean(data,3));
                    else
                    end
                    
                    time448 = mean(epoch2Matlab(timeInt(:)));
                    timex448 = timex;
                    skip = 0;
                    clear timex
                    
                    % if number of rotations is greater than 448 but less than 2*448,
                    % used only first 448 rotations and ignore the rest
                elseif rotations > 448 && rotations < 448*2
                    cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
                    load(cubeName,'Azi','Rg','data','timeInt','results');
                    data448 = data(:,:,1:448);
                    timex448 = mean(data448,3);
                    timeInt448 = timeInt(:,1:448);
                    time448 = mean(epoch2Matlab(timeInt448(:)));
                    clear data448 timeInt448
                    skip = 0;
                    
                    % if number of rotations greater than 2*448, separate into
                    % multiple timex448 matrices
                elseif rotations >= 448*2
                    load(cubeName,'Azi','Rg','data','timeInt','results');
                    for RR = 1:floor(size(data,3)/448)
                        data448 = data(:,:,(1+448*(RR-1)):(448+448*(RR-1)));
                        timex448(:,:,RR) = mean(data448,3);
                        timeInt448 = timeInt(:,1:448);
                        time448(RR) = mean(epoch2Matlab(timeInt448(:)));
                        clear data448 timeInt448
                    end
                    skip = 0;
                end
                
                if exist('Rg')
                    % set rotation(so shoreline is parallel to edge of plot)
                    heading = results.heading-domainRotation;
                    [AZI,RG] = meshgrid(Azi,Rg(16:xCutoff));
                    
                    % set up domain
                    [XX,YY] = meshgrid(xC,yC);
                    [thC,rgC] = cart2pol(XX,YY);
                    aziC = wrapTo360(90 - thC*180/pi - heading);
                    
                    % rotate domain
                    for tt = 1:size(timex448,3)
                        tC = interp2(AZI,RG,double(timex448(16:xCutoff,:,tt)),aziC',rgC');
                        
                        % find location of maximum intensity at each alongshore
                        % location
                        for iY = 1:length(yC)
                            if iY <= 1000
                                firstDiff = diff(tC,1,1);
                                [~, MIC] = max(firstDiff(221:381,iY));
                                MI = MIC+220;
                                idxMaxGradient(iY) = MI;
                                clear MI
                            elseif iY > 1000 && iY <= 2000
                                 firstDiff = diff(tC,1,1);
                                [~, MIC] = max(firstDiff(221:421,iY));
                                MI = MIC+220;
                                idxMaxGradient(iY) = MI;
                                clear MI
                            else
                                firstDiff = diff(tC,1,1);
                                [~, MIC] = max(firstDiff(321:481,iY));
                                MI = MIC+320;
                                idxMaxGradient(iY) = MI;
                                clear MI
                            end
                        end

                        
                        % smooth output
                        % idxSmoothedMI = smooth1d_loess(idxMaxIntensity,yC,800,yC);
                        idxSmoothedMI = movmean(movmean(idxMaxGradient,800),800);
                        idxSmoothedMaxGradient = round(idxSmoothedMI);
                        
                        % find intensity at locations 100, 150, and 200 m from location of maximum intensity
                        for iY = 1:length(yC)
                            TT(iY) = tC(idxSmoothedMaxGradient(iY),iY);
                            T25(iY) = tC(idxSmoothedMaxGradient(iY)-25,iY);
                            T50(iY) = tC(idxSmoothedMaxGradient(iY)-50,iY);
                            T75(iY) = tC(idxSmoothedMaxGradient(iY)-75,iY);
                            T100(iY) = tC(idxSmoothedMaxGradient(iY)-100,iY);
                            T150(iY) = tC(idxSmoothedMaxGradient(iY)-150,iY);
                        end
                        
                        txIMat = vertcat(txIMat,TT);
                        txIMat_25 = vertcat(txIMat,T25);
                        txIMat_50 = vertcat(txIMat,T50);
                        txIMat_75 = vertcat(txIMat_75,T75);
                        txIMat_100 = vertcat(txIMat_100,T100);
                        txIMat_150 = vertcat(txIMat_150,T150);
                        idxMaxI = vertcat(idxMaxI,idxSmoothedMaxGradient);
                        txDn = horzcat(txDn,time448);
                        clear T25 T50 T75 T100 T150 idxMaxIntensity
                    end
                end
            end
        end
    end
    save(fullfile(saveDir,output_fname),'txIMat','txIMat_25','txIMat_50','txIMat_75','txIMat_100','txIMat_150','txDn','yC','idxMaxI','-v7.3')
    
    disp([num2str(iRun),' of ', num2str(length(dayFolder(iDay).polRun)),' run. ',num2str(iDay),' of ',num2str(length(dayFolder)),' day.'])
    clearvars -except baseDir saveDir dayFolder dayFolderSave numDays domainRotation yC xC xCutoff
    txIMat = []; txIMat_25 = []; txIMat_50 = []; txIMat_75 = []; txIMat_100 = []; txIMat_150 = []; txDn = []; idxMaxI = [];
    %
end
