
%% USER INPUTS
% add paths to ISDRI Data

% GITHUB DATA PATH
addpath(genpath('C:\Users\user\Desktop\isdri-scripts')) %GITHUB REPOSITORY

% MAT FILES LOCATION
% baseDir = 'E:\DAQ-data\processed\'; %CTR HUB
baseDir = 'D:\guadalupe\processed\'; % LENOVO HARD DRIVE

% PNG LOCATION
% saveDir = 'E:\PNGs\timex_enviroInfo5\'; % CTR HUB
saveDir = 'C:\Users\user\Desktop\for_jack\'; % LENOVO HARD DRIVE

% rewrite existing files in save directory? true=yes
doOverwrite = true;



%% Prep files
% make save directory

if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

%% Process Files 
imgId = 1;
for iDay = 11:11
        
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    saveDirSub = [saveDir,dayFolder(iDay).name];
    if ~exist(saveDirSub);mkdir(saveDirSub);end
    
        for iRun = 383:528
            
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
                    cube2png(cubeName,pngName)
                    fprintf('Done.\n')
%                 catch
%                     fid = fopen(['FAILED_on_file_',pngBaseName,'.txt'], 'wt' );
%                     fclose(fid)
%                 end
                    
            end
            
            imgId = imgId + 1;
          end
       
end
      