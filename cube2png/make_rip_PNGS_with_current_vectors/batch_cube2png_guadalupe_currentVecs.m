
%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository
Hub = 'E:\';

% SUPPORT DATA PATH
% supportDataPath = 'D:\Data\ISDRI\SupportData'; % LENOVO HARD DRIVE

supportDataPath = [Hub 'SupportData']; % HUB 

% GITHUB DATA PATH
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %GITHUB REPOSITORY

% MAT FILES LOCATION
baseDir = [Hub 'guadalupe\processed\']; % HUB

% PNG LOCATION
% saveDir = 'C:\Data\ISDRI\postprocessed\ripCurrentTimex_with_Instruments\'; % LENOVO HARD DRIVE
saveDir = [Hub 'guadalupe\postprocessed\ripCurrentTimex_with_currents\']; % HUB

% rewrite existing files in save directory? true=yes
doOverwrite = true;

% Download new support data files?
downloadWind = false;
downloadWaves = false;
downloadTides = false;

%% Prep files
% make save directory
addpath(genpath(supportDataPath)) 

if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

% Load wind data from wind station file
[dnWind,magWind,dirWind] = loadWindNDBC('MetData_NDBC46011.txt');

% Load wave data from wave station file
[dnWaves,Hs,dirWaves,~,~] = loadWavesNDBC_historical('WaveData_NDBC46011.txt');

% Load tide data from tide station file
[dnTides,waterSurfaceElevation] = loadTidesNOAA('TideData_NOAA9411406.txt');
waterSurfaceElevation(waterSurfaceElevation == -999) = nan;

% Load current vectors
[dnUTC_AQ,U,V,W,Zbed,depth] = loadADCP('D:\Data\ISDRI\SupportData\MacMahan\STR3_AQ.mat',4,-13);

for i = 1:size(U,1)
    idx(i) = find(~isnan(U(i,:)),1,'last');
    UUS(i,:) = U(i,(idx(i)-2):idx(i));
    VVS(i,:) = V(i,(idx(i)-2):idx(i));
end

U_surface = mean(UUS,2);
V_surface = mean(VVS,2);

%% Process Files 
imgId = 1;
for iDay = 45:46%length(dayFolder)
        
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    saveDirSub = [saveDir,dayFolder(iDay).name];
    if ~exist(saveDirSub);mkdir(saveDirSub);end
    
        for iRun = 29:length(dayFolder(iDay).polRun)
            if iDay == 48 && iRun == 2
            else
            fprintf('%3.f of %3.f in dir %3.f of %3.f: ',...
                iRun,length(dayFolder(iDay).polRun),...
                iDay,length(dayFolder))
            
            cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
            
            [~,cubeBaseName,~] = fileparts(cubeName);
            
            pngBaseName = sprintf('%s_timex.png',cubeBaseName);
            pngName = fullfile(saveDirSub,pngBaseName);
            
            fileExists = exist(pngName,'file');
            if fileExists && ~doOverwrite
                fprintf('%s exists. Skipping ...\n',pngName)
            else
                fprintf('%s ...',cubeBaseName)
%                 try
                    cube2png_guadalupe_currentVecs(cubeName,pngName,...
                        dnWind,magWind,dirWind,...
                        dnWaves,Hs,...
                        dnTides,waterSurfaceElevation,...
                        dnUTC_AQ,U_surface,V_surface)
                    fprintf('Done.\n')
%                 catch
%                     fid = fopen(['FAILED_on_file_',pngBaseName,'.txt'], 'wt' );
%                     fclose(fid)
%                 end
                    
            end
            
            imgId = imgId + 1;
            end
        end
       
end
      