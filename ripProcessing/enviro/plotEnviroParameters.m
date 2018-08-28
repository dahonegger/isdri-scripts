%% plotEnviroParameters.m - 

%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository
% SUPPORT DATA PATH
supportDataPath = 'D:\Data\ISDRI\SupportData'; % LENOVO HARD DRIVE

% GITHUB DATA PATH
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %GITHUB REPOSITORY

%% create time series
dn = datenum([2017,08,31,21,0,0]):1/24:datenum([2017,10,26,15,0,0]);
dv = datevec(dn);

load('C:\Data\ISDRI\postprocessed\rips\dv_rips_purisma.mat')
purismaRips = dv_rips;
clear dv_rips
load('C:\Data\ISDRI\postprocessed\rips\dv_rips_guadalupe.mat')
guadalupeRips = dv_rips;
clear dv_rips


%% Load wind data from wind station file
[dnWind,magWind,dirWind] = loadWindNDBC_historical('D:\Data\ISDRI\SupportData\Wind\MetData_NDBC46011.txt');

% Load wave data from wave station file
[dnWaves,Hs,dirWaves,TpAve,TpS] = loadWavesNDBC_historical('D:\Data\ISDRI\SupportData\Waves\WaveData_NDBC46011.txt');

% Load tide data from tide station file
[dnTides,WL] = loadTidesNOAA('D:\Data\ISDRI\SupportData\Tides\TideData_NOAA9411406.txt');
WL(WL == -999) = nan;


%% make rip vector 
ripVecPurisma = NaN(1,length(dn));
ripVecPurisma(purismaRips(:,7)==1) = 1;
ripVecGuadalupe = NaN(1,length(dn));
ripVecGuadalupe(guadalupeRips(:,7)==1) = 1;

tides_dnrips_Purisma = interp1(dnTides,waterSurfaceElevation,dn);
tides_dnrips_Purisma(ripVecPurisma ~= 1) = nan;
tides_dnrips_Guadalupe = interp1(dnTides,waterSurfaceElevation,dn);
tides_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

ripVecPurismaW = NaN(1,length(dnWaves));
ripVecPurismaW(purismaRips(:,7)==1) = 1;
ripVecGuadalupeW = NaN(1,length(dnWaves));
ripVecGuadalupeW(guadalupeRips(:,7)==1) = 1;

waves_dnrips_Purisma = interp1(dnWaves,Hs,dn);
waves_dnrips_Purisma(ripVecPurisma ~= 1) = nan;
waves_dnrips_Guadalupe = interp1(dnWaves,Hs,dn);
waves_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

wavesTpS_dnrips_Purisma = interp1(dnWaves,TpS,dn);
wavesTpS_dnrips_Purisma(ripVecPurisma ~= 1) = nan;
wavesTpS_dnrips_Guadalupe = interp1(dnWaves,TpS,dn);
wavesTpS_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

wavesTpA_dnrips_Purisma = interp1(dnWaves,TpAve,dn);
wavesTpA_dnrips_Purisma(ripVecPurisma ~= 1) = nan;
wavesTpA_dnrips_Guadalupe = interp1(dnWaves,TpAve,dn);
wavesTpA_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

wavesDir_dnrips_Purisma = interp1(dnWaves,dirWaves,dn);
wavesDir_dnrips_Purisma(ripVecPurisma ~= 1) = nan;
wavesDir_dnrips_Guadalupe = interp1(dnWaves,dirWaves,dn);
wavesDir_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

for i = 1:length(dnWind)-2;
    if dnWind(i)==0 && dnWind(i+1)~=0
        dnWind(i) = (dnWind(i+1) + dnWind(i-1))/2;
    elseif dnWind(i)==0 && dnWind(i+1)==0 && dnWind(i+2)~=0
        dnWind(i) = (dnWind(i+2) + dnWind(i-2))/2;
    elseif dnWind(i)==0 && dnWind(i+1)==0 && dnWind(i+2)==0
        dnWind(i) = (dnWind(i+20) + dnWind(i-20))/2;
    elseif dnWind(i) ~=0
        dnWind(i) = dnWind(i);
    end
end

windDir_dnrips_Purisma = interp1(dnWind,dirWind,dn);
windDir_dnrips_Purisma(ripVecPurisma~=1) = nan;
windDir_dnrips_Guadalupe = interp1(dnWind,dirWind,dn);
windDir_dnrips_Guadalupe(ripVecGuadalupe~=1) = nan;

windMag_dnrips_Purisma = interp1(dnWind,magWind,dn);
windMag_dnrips_Purisma(ripVecPurisma~=1) = nan;
windMag_dnrips_Guadalupe = interp1(dnWind,magWind,dn);
windMag_dnrips_Guadalupe(ripVecGuadalupe~=1) = nan;

% find steepness
Hs_TpS = Hs./TpS;
Hs_TpA = Hs./TpAve;
wavesHsTpA_dnrips_Purisma = interp1(dnWaves,Hs_TpA,dn);
wavesHsTpA_dnrips_Purisma(ripVecPurisma ~= 1) = nan;
wavesHsTpA_dnrips_Guadalupe = interp1(dnWaves,Hs_TpA,dn);
wavesHsTpA_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

wavesHsTpS_dnrips_Purisma = interp1(dnWaves,Hs_TpS,dn);
wavesHsTpS_dnrips_Purisma(ripVecPurisma ~= 1) = nan;
wavesHsTpS_dnrips_Guadalupe = interp1(dnWaves,Hs_TpS,dn);
wavesHsTpS_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

%% load rip times
%% plot 1
figure(1)
subplot(2,1,1)
plot(dnTides,waterSurfaceElevation,'b')
hold on
% plot(dn,ripVec,'g.');
% plot(dn,ripVec2,'r.');
plot(dn,tides_dnrips_Guadalupe,'r')
datetick('x',7)
axis([min(dn) max(dn) -0.1 2])
xlabel('WL (m)')
title('Water Surface Elevation from MLLW with Guadalupe rips');

subplot(2,1,2)
plot(dnTides,waterSurfaceElevation,'b')
hold on
% plot(dn,ripVec,'g.');
% plot(dn,ripVec2,'r.');
plot(dn,tides_dnrips_Purisma,'r')
datetick('x',7)
axis([min(dn) max(dn) -0.1 2])
xlabel('WL (m)')
title('Water Surface Elevation from MLLW with Purisma rips');


%% plot 2 
figure(2)
% ripVecGuadalupe(ripVecGuadalupe == 1) = 0.5;
subplot(4,1,1)
plot(dnTides,waterSurfaceElevation,'b')
hold on
% plot(dn,ripVec,'g.');
% plot(dn,ripVec2,'r.');
plot(dn,tides_dnrips_Guadalupe,'r')
datetick('x',7)
axis([min(dn) max(dn) -0.1 2])
ylabel('WL (m)')
title('Water Surface Elevation from MLLW with Guadalupe rips');

subplot(4,1,2)
plot(dnWaves,Hs,'b')
hold on
plot(dn,waves_dnrips_Guadalupe,'r');
datetick('x',7)
axis([min(dn) max(dn) 0 4])
ylabel('Hs (m)')
title('Significant wave height');

% ripVecGuadalupe(ripVecGuadalupe == 0.5) = 17;
subplot(4,1,3)
plot(dnWaves,TpS,'b')
hold on
plot(dnWaves,TpAve,'b')
plot(dn,wavesTpS_dnrips_Guadalupe,'r');
plot(dn,wavesTpA_dnrips_Guadalupe,'r');
datetick('x')
ylabel('Tp (s)')
title('Wave period');
datetick('x',7)
axis([min(dn) max(dn) 2 24])
% legend('Swell','Mean')

% subplot(5,1,4)
% plot(dnWaves,Hs_TpA,'b')
% hold on
% plot(dn,wavesHsTpA_dnrips_Guadalupe,'r');
% % plot(dn,wavesTpA_dnrips_Guadalupe,'r');
% xlabel('Hs/Tp')
% title('Significant wave height over wave period');
% datetick('x',7)
% axis([min(dn) max(dn) 0 1])
% % legend('Swell','Mean')

subplot(4,1,4)
plot(dnWaves, dirWaves)
hold on
plot(dn,wavesDir_dnrips_Guadalupe,'r');
ylabel('Direction (degrees)')
title('Wave direction');
datetick('x',7)
axis([min(dn) max(dn) 0 360])

%% plot 3 Purisma
figure(3)
% ripVecGuadalupe(ripVecGuadalupe == 1) = 0.5;
subplot(4,1,1)
plot(dnTides,waterSurfaceElevation,'b')
hold on
% plot(dn,ripVec,'g.');
% plot(dn,ripVec2,'r.');
plot(dn,tides_dnrips_Purisma,'r')
datetick('x',7)
axis([min(dn) max(dn) -0.1 2])
xlabel('WL (m)')
title('Water Surface Elevation from MLLW with Purisma rips(m)');

subplot(4,1,2)
plot(dnWaves,Hs,'b')
hold on
plot(dn,waves_dnrips_Purisma,'r');
datetick('x',7)
axis([min(dn) max(dn) 0 4])
ylabel('Hs (m)')
title('Significant wave height');

% ripVecGuadalupe(ripVecGuadalupe == 0.5) = 17;
subplot(4,1,3)
plot(dnWaves,TpS,'b')
hold on
plot(dnWaves,TpAve,'b')
plot(dn,wavesTpS_dnrips_Purisma,'r');
plot(dn,wavesTpA_dnrips_Purisma,'r');
datetick('x')
ylabel('Tp (s)')
title('Wave period');
datetick('x',7)
axis([min(dn) max(dn) 2 24])
% legend('Swell','Mean')
% 
% subplot(5,1,4)
% plot(dnWaves,Hs_TpA,'b')
% hold on
% plot(dn,wavesHsTpA_dnrips_Purisma,'r');
% % plot(dn,wavesTpA_dnrips_Guadalupe,'r');
% xlabel('Hs/Tp')
% title('Significant wave height over wave period');
% datetick('x',7)
% axis([min(dn) max(dn) 0 1])
% % legend('Swell','Mean')

subplot(4,1,4)
plot(dnWaves, dirWaves)
hold on
plot(dn,wavesDir_dnrips_Purisma,'r');
ylabel('Direction (degrees)')
title('Wave direction');
datetick('x',7)
axis([min(dn) max(dn) 0 360])
% legend('Swell','Mean')

%% plot 4 wind
dnWind(dnWind == 0) = nan;
figure(4)
subplot(2,1,1)
plot(dnWind,magWind,'b')
hold on
plot(dn,windMag_dnrips_Guadalupe,'r')
title('Wind speed with Guadalupe rips')
ylabel('Wind speed (m/s)')
datetick('x',7)
axis([min(dnWind) max(dnWind) 0 20])

subplot(2,1,2)
plot(dnWind,dirWind)
hold on
plot(dn,windDir_dnrips_Guadalupe,'r')
title('Wind directions with Guadalupe rips')
ylabel('Wind direction (degrees)')
datetick('x',7)
axis([min(dnWind) max(dnWind) 0 360])


dnWind(dnWind == 0) = nan;
figure(5)
subplot(2,1,1)
plot(dnWind,magWind,'b')
hold on
plot(dn,windMag_dnrips_Purisma,'r')
title('Wind speed with Purisma rips')
ylabel('Wind speed (m/s)')
datetick('x',7)
axis([min(dnWind) max(dnWind) 0 20])

subplot(2,1,2)
plot(dnWind,dirWind)
hold on
plot(dn,windDir_dnrips_Purisma,'r')
ylabel('Wind direction (degrees)')
title('Wind direction with Purisma rips')
datetick('x',7)
axis([min(dnWind) max(dnWind) 0 360])

