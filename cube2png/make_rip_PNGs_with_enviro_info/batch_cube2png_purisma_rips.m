%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository

% SUPPORT DATA PATH
supportDataPath = 'E:\supportData\'; % LENOVO HARD DRIVE
% supportDataPath = 'E:\SupportData'; %CTR HUB

% GITHUB DATA PATH
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %GITHUB REPOSITORY

% MAT FILES LOCATION
baseDir = 'E:\purisima\processed\'; % HUB 1

% PNG LOCATION
saveDir = 'E:\purisima\postprocessed\rip_enviro_info\'; % HUB

% rewrite existing files in save directory? true=yes
doOverwrite = false;

% Download new support data files?
downloadWind = true;
downloadWaves = false;
downloadTides = false;

%% Prep files
% make save directory
addpath(genpath(supportDataPath))

if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

% download environmental files
% WIND: buoy number, save directory, save fname
if downloadWind; fetchWindNDBC(46011,fullfile(supportDataPath,'Wind'),'MetData_NDBC46011.txt'); end
% WAVES: save directory, save fname
if downloadWaves; fetchWavesNDBC(46011,fullfile(supportDataPath,'Waves'),'WaveData_NDBC46011.txt');end
% TIDES: save directory, save fname
endTime = '20171115'; startTime = '20171029';
if downloadTides; fetchTidesNOAA(9411406,fullfile(supportDataPath,'Tides'),'TideData_NOAA9411406.txt',startTime,endTime);end

%% Process Files
imgId = 1;
for iDay = 9:length(dayFolder)
    if iDay == 9 || iDay == 28 
    else
        dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
        saveDirSub = [saveDir,dayFolder(iDay).name];
        if ~exist(saveDirSub);mkdir(saveDirSub);end
        
        for iRun = 99:length(dayFolder(iDay).polRun)
            
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
                cube2png_purisima_enviro_rips(cubeName,pngName)
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
      