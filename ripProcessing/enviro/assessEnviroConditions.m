%%% assessEnviroConditions.m
% 2/28/2018

clear variables; home

%% USER INPUTS
% GITHUB DATA PATH
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %GITHUB REPOSITORY
addpath('D:\Data\ISDRI\SupportData\APL_MetStations')

%% Load wind and wave info
% APL
load('D:\Data\ISDRI\SupportData\APL_MetStations\InnerShelf_Met_Chevron_Sep2017.mat')
t_APL = met.time;
windMag_APL = met.windspd;  % convert from mph
gustMag_APL = met.windspd_gust;
windDir_APL = met.winddirT;

% from spoondrift
load('D:\Data\ISDRI\SupportData\Spoondrift\SPOT-0014');
t_ISDRI = time;

% % from NDBC - wind
% [dnWind,magWind,dirWind] = loadWindNDBC_historical('D:\Data\ISDRI\SupportData\Wind\MetData_NDBC46011.txt');

% from NOAA
[t_tides,WL] = loadTidesNOAA('D:\Data\ISDRI\SupportData\Tides\TideData_NOAA9411406.txt');
WL(WL == -999) = nan;

%% time point of interest
tpoiStart = datenum([2017,10,21,12,50,0]);
tpoiEnd = datenum([2017,10,21,20,0,0]);

idx_APL = find(t_APL >= tpoiStart & t_APL <= tpoiEnd);
idx_ISDRI = find(t_ISDRI >= tpoiStart & t_ISDRI <= tpoiEnd);
idx_WL = find(t_tides >= tpoiStart & t_tides <= tpoiEnd);

Hm0_tpoi = Hm0(idx_ISDRI);
Tp_tpoi = Tp(idx_ISDRI);
meanDir_tpoi = meanDir(idx_ISDRI);
meanDirSpread_tpoi = meanDirSpread(idx_ISDRI);
windMag_tpoi = windMag_APL(idx_APL);
windDir_tpoi = windDir_APL(idx_APL);
WL_tpoi = WL(idx_WL);


