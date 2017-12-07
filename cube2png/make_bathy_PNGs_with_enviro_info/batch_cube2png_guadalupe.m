
%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository

% SUPPORT DATA PATH
% supportDataPath = 'D:\Data\ISDRI\SupportData'; % LENOVO HARD DRIVE

supportDataPath = 'D:\SupportData'; % HUB 


% GITHUB DATA PATH
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %GITHUB REPOSITORY

% MAT FILES LOCATION

baseDir = 'D:\guadalupe\processed\'; % HUB 1

% PNG LOCATION
% saveDir = 'C:\Data\isdri\guadalupe\postprocessed\timex_enviroInfo\'; % Dell#2 HARD DRIVE
saveDir = 'D:\guadalupe\postprocessed\enviroInfoPNGs2\'; % HUB

% rewrite existing files in save directory? true=yes
doOverwrite = false;

% Download new support data files?
downloadWind = false;
downloadWaves = false;

%note: no longer downloading tides, using predicted 2 month record instead
% downloadTides = false; 

%% Prep files
% make save directory
addpath(genpath(supportDataPath)) 

if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

% download environmental files
% WIND: buoy number, save directory, save fname
if downloadWind;fetchWindNDBC(46011,fullfile(supportDataPath,'Wind'),'MetData_NDBC46011.txt'); end 
% WAVES: save directory, save fname 
if downloadWaves; fetchWavesNDBC(46011,fullfile(supportDataPath,'Waves'),'WaveData_NDBC46011.txt');end
% TIDES: save directory, save fname 
% endTime = '20170920'; startTime = '20170829';
% if downloadTides; fetchTidesNOAA(9411406,fullfile(supportDataPath,'tides'),'TideData_NOAA9411406.txt',startTime,endTime);end

%% Process Files 
imgId = 1;
for iDay = 49:length(dayFolder)
        
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    saveDirSub = [saveDir,dayFolder(iDay).name];
    if ~exist(saveDirSub);mkdir(saveDirSub);end
    
        for iRun = 1:length(dayFolder(iDay).polRun)
            
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
                    cube2png_guadalupe_enviro_bathy(cubeName,pngName)
                    fprintf('Done.\n')
%                 catch
%                     fid = fopen(['FAILED_on_file_',pngBaseName,'.txt'], 'wt' );
%                     fclose(fid)
%                 end
                    
            end
            
            imgId = imgId + 1;
          end
       
end
      