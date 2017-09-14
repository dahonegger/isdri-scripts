
% add paths to CTR HUB Support Data and GitHub Repository
addpath(genpath('E:\guadalupe\processed')) %CTR HUB 
addpath(genpath('C:\Users\user\Desktop\isdri-scripts')) %github repository

% add path to mat files and choose directory for png's   
baseDir = 'E:\guadalupe\processed\';
saveDir = 'C:\Users\user\Desktop\waveTracking\';


output_fname = 'rangeTransects_lat_lon.mat';

%% Prep files
% make save directory
if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);
% initialize transect matrix & time vector
% txIMat_full = zeros(4079,1); % <--- shouldn't be hard coded
txIMat_full = [];
txDn_full = [];
txLat_full = [];
txLon_full = [];


%% loop through mat files
% for iDay = 1:length(dayFolder)%loop through days
for iDay = 8:9 %loop through days
        dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));

   for iRun = 1:1:length(dayFolder(iDay).polRun) %loop through files
% iRun = 1;
        cubeName = fullfile(baseDir,dayFolder(iDay).name,dayFolder(iDay).polRun(iRun).name);
  
%% LOAD TIMEX
load(cubeName,'Azi','Rg','timex','timeInt','results');
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

% choose degrees to average over
desiredStartAngle = 270;    
desiredAngles = 1; %degrees 

% grab these angles from intensity
[idx idx] = min(abs(THdeg(1,:) - desiredStartAngle));

if iDay == 9 && iRun == 1
     fig=figure;hold on;hp = pcolor(lon,lat,timex);shading flat;axis image;colormap(hot);caxis([0 200])
     plot(lon(:,idx),lat(:,idx),'-w')
     title([datestr(results.start_time.dateNum-7./24),' PST'])
      box on; grid on;
     xlabel('Lon');ylabel('Lat')
    
else
end

% use for averaging multiple azi's
% angles = [idx:1:idx+desiredAngles./mean(diff(Azi))];
% txI = mean(double(timex(:,angles)),2);

% for no averaging:
txI = timex(:,idx);
txLon = lon(:,idx);
txLat = lat(:,idx);
% txDnMat = mean(epoch2Matlab(timeInt(angles,:)),1);

txIMat(:,iRun) = txI';
txDn(iRun) = mean(epoch2Matlab(timeInt(:)));



   end

txIMat_full = horzcat(txIMat_full,double(txIMat));
txDn_full = horzcat(txDn_full,txDn);
txLat_full = txLon;
txLon_full = txLat;

disp([num2str(iRun),' of ', num2str(length(dayFolder(iDay).polRun)),' run. ',num2str(iDay),' of ',num2str(length(dayFolder)),' day.'])

end

txIMat_full = txIMat_full(:,2:end);
txDn_full = txDn_full(2:end);
transectMat = txIMat_full;
save(fullfile(saveDir,output_fname),'transectMat','txDn_full','Rg','txLon_full','txLat_full','-v7.3')
