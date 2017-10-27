% ripTransects.m
% 10/7/2017

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
HubNew = 'F:\';
HubOld = 'E:\';
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository

% add path to mat files and choose directory for png's
baseDir = [HubOld 'guadalupe\processed\'];
saveDir = [HubNew 'guadalupe\postprocessed\alongshoreTransectMatrix\'];

%% Prep files
% make save directory
if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);
dayFolderSave = dir([saveDir,'2017*']);

%initialize variables
txIMat_75 = [];
txIMat_100 = [];
txIMat_150 = [];
txIMat_200 = [];
txDn = [];
idxMaxI = [];

% set up domain
yC = -800:800;
xC = -1100:-500;
xCutoff = 1168;
domainRotation = 13;
rotations = 256;

%% loop through mat files
numDays = numel(dayFolder)-numel(dayFolderSave);
for iDay = 2 + numel(dayFolder)-numDays:numel(dayFolder) %loop through days
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    output_fname =   num2str(dayFolder(iDay).name);
    
    %% loop through all runs for this day
    for iRun = 1:1:length(dayFolder(iDay).polRun) %loop through files to find number of rotations
        cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
        load(cubeName,'timeInt');
        cubeRots(iRun) = size(timeInt,2);
        clear cubeName timeInt
    end
    
    % separate into 448 rotations
    files448 = [];
    skip = 0;
    for iRun = 1:length(cubeRots)
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
                        [~, MIC] = max(tC(401:551,iY));
                        MI = MIC+400;
                        idxMaxIntensity(iY) = MI;
                        clear MI
                    end
                    
                    % loess smooth output
                    idxSmoothedMI = smooth1d_loess(idxMaxIntensity,yC,800,yC);
                    idxSmoothedMaxIntensity = round(idxSmoothedMI);
                    
                    % find intensity at locations 100, 150, and 200 m from location of maximum intensity
                    for iY = 1:length(yC)
                        T75(iY) = tC(idxSmoothedMaxIntensity(iY)-75,iY);
                        T100(iY) = tC(idxSmoothedMaxIntensity(iY)-100,iY);
                        T150(iY) = tC(idxSmoothedMaxIntensity(iY)-150,iY);
                        T200(iY) = tC(idxSmoothedMaxIntensity(iY)-200,iY);
                    end
                    
                    txIMat_75 = vertcat(txIMat_75,T75);
                    txIMat_100 = vertcat(txIMat_100,T100);
                    txIMat_150 = vertcat(txIMat_150,T150);
                    txIMat_200 = vertcat(txIMat_200,T200);
                    idxMaxI = vertcat(idxMaxI,idxSmoothedMaxIntensity);
                    txDn = horzcat(txDn,time448);
                    clear T75 T100 T150 T200 idxMaxIntensity
                end
            end
        end
    end
    save(fullfile(saveDir,output_fname),'txIMat_75','txIMat_100','txIMat_150','txIMat_200','txDn','yC','idxMaxI','-v7.3')
    
    disp([num2str(iRun),' of ', num2str(length(dayFolder(iDay).polRun)),' run. ',num2str(iDay),' of ',num2str(length(dayFolder)),' day.'])
    clearvars -except baseDir saveDir dayFolder dayFolderSave numDays domainRotation yC xC xCutoff
    txIMat_75 = []; txIMat_100 = []; txIMat_150 = []; txIMat_200 = []; txDn = []; idxMaxI = [];
%     
end
