%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository
% SUPPORT DATA PATH
supportDataPath = 'D:\Data\ISDRI\SupportData'; % LENOVO HARD DRIVE
% supportDataPath = 'E:\SupportData'; %CTR HUB 

% GITHUB DATA PATH
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %GITHUB REPOSITORY

% MAT FILES LOCATION
baseDir = 'F:\guadalupe\processed\'; % HUB 1

% PNG LOCATION
saveDir = 'C:\Data\ISDRI\postprocessed\ripCurrentTimex_enviroInfo\'; % LENOVO HARD DRIVE

% rewrite existing files in save directory? true=yes
doOverwrite = false;

% Download new support data files?
downloadWind = true;
downloadWaves = true;
downloadTides = true;

%% create time series
dn = datenum([2017,09,01,0,0,0]):1/24:datenum([2017,09,22,19,0,0]);
dv = datevec(dn);
load('C:\Data\ISDRI\postprocessed\rips\dv_rips.mat')
%% Prep files
% make save directory
addpath(genpath(supportDataPath)) 

if ~exist(saveDir);mkdir(saveDir);end
dayFolder = dir([baseDir,'2017*']);

%% download environmental files
% WIND: buoy number, save directory, save fname
if downloadWind;fetchWindNDBC(46011,fullfile(supportDataPath,'Wind'),'MetData_NDBC46011.txt'); end 
% WAVES: save directory, save fname 
if downloadWaves; fetchWavesNDBC(46011,fullfile(supportDataPath,'Waves'),'WaveData_NDBC46011.txt');end
% TIDES: save directory, save fname 
endTime = '20170924'; startTime = '20170829';
if downloadTides; fetchTidesNOAA(9411406,fullfile(supportDataPath,'Tides'),'TideData_NOAA9411406.txt',startTime,endTime);end

%% Load wind data from wind station file
[dnWind,magWind,dirWind] = loadWindNDBC('MetData_NDBC46011.txt');

% Load wave data from wave station file
[dnWaves,Hs,dirWaves,TpAve,TpS] = loadWavesNDBC('WaveData_NDBC46011.txt');

% Load tide data from tide station file
[dnTides,waterSurfaceElevation] = loadTidesNOAA('TideData_NOAA9411406.txt');
waterSurfaceElevation(waterSurfaceElevation == -999) = nan;


%% make rip vector 
ripVec = NaN(1,length(dn));
ripVec(dv_rips(:,7)==1) = 1;
ripVec2 = NaN(1,length(dn));
ripVec2(dv_rips(:,7)==2) = 1;

tides_dnrips = interp1(dnTides,waterSurfaceElevation,dn);
tides_dnrips(ripVec ~= 1) = nan;

%% load rip times
figure,
subplot(3,1,1)
plot(dnTides,waterSurfaceElevation,'b')
hold on
% plot(dn,ripVec,'g.');
% plot(dn,ripVec2,'r.');
plot(dn,tides_dnrips,'r')
datetick('x',7)
axis([min(dn) max(dn) -0.1 2])
xlabel('WL (m)')
title('Water Surface Elevation from MLLW (m)');

ripVec(ripVec == 1) = 0.5;
subplot(3,1,2)
plot(dnWaves,Hs)
hold on
plot(dn,ripVec,'go');
datetick('x',7)
axis([min(dn) max(dn) 0 4])
xlabel('Hs (m)')
title('Significant wave height (m)');

ripVec(ripVec == 0.5) = 17;
subplot(3,1,3)
plot(dnWaves,TpS)
hold on
plot(dnWaves,TpAve)
plot(dn,ripVec,'go');
datetick('x')
xlabel('Tp (s)')
title('Wave period (m)');
datetick('x',7)
axis([min(dn) max(dn) 5 18])
legend('Swell','Mean')
