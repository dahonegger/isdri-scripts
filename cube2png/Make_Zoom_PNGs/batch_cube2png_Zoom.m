
%% USER INPUTS
% add paths to ISDRI Data

% GITHUB DATA PATH
addpath(genpath('C:\Users\user\Desktop\isdri-scripts'))%GITHUB REPOSITORY
addpath(genpath('C:\Data\ISDRI\isdri-scripts'))

% MAT FILES LOCATION
% baseDir = 'E:\DAQ-data\processed\'; %CTR HUB
baseDir = 'F:\guadalupe\processed\'; % LENOVO HARD DRIVE

% PNG LOCATION
% saveDir = 'E:\PNGs\timex_enviroInfo5\'; % CTR HUB
saveDir = 'F:\guadalupe\postprocessed\ZoomPNGs\'; 

% rewrite existing files in save directory? true=yes
doOverwrite = false;



%% Prep files
% make save directory

if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

%% Process Files 
imgId = 1;
% for iDay = 1:length(dayFolder)
for iDay = 12:12
        
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    saveDirSub = [saveDir,dayFolder(iDay).name];
    if ~exist(saveDirSub);mkdir(saveDirSub);end
    
%         for iRun = 1:length(dayFolder(iDay).polRun)
            for iRun = 450:length(dayFolder(iDay).polRun)
            
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
                    cube2png_Zoom(cubeName,pngName)
                    fprintf('Done.\n')
%                 catch
%                     fid = fopen(['FAILED_on_file_',pngBaseName,'.txt'], 'wt' );
%                     fclose(fid)
%                 end
                    
            end
            
            imgId = imgId + 1;
          end
       
end
      