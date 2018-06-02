%% plotEnviroParameters.m - 
clear variables; home

%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository
% SUPPORT DATA PATH
supportDataPath = 'D:\Data\ISDRI\SupportData'; % LENOVO HARD DRIVE

% GITHUB DATA PATH
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %GITHUB REPOSITORY

%% create time series
% dn = datenum([2017,08,31,21,0,0]):1/24:datenum([2017,10,26,15,0,0]);
% dv = datevec(dn);
load('C:\Data\ISDRI\postprocessed\rips\DataAvailability_Rips_dv.mat')
load('\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\newRipMatrix\rips.mat')
guadalupeRips = dv;
clear dv
guadalupeRips(4:end,5) = rips(:,2);

%% Load wind and wave info
% % from spoondrift
% load('D:\Data\ISDRI\SupportData\Spoondrift\SPOT-0014');
% t_ISDRI = time;

% from APL met station
load('D:\Data\ISDRI\SupportData\APL_MetStations\APL_time_windSpeed_gustSpeed_windDir.mat');
gustSpeed = 0.44704*time(:,3);  % convert from mph to m/s
magWind_APL = 0.44704*time(:,2);  % convert from mph to m/s
% dirWind_APL = time(:,4);
% dnWind_APL = time(:,1); clear time
% magWind_APL_Average = movmean(magWind_APL,30);
% dirWind_APL(dirWind_APL == 0) = nan;
% dirWind_APL_rad = degtorad(dirWind_APL);
% dW = unwrap(dirWind_APL_rad(1:34585));
% dW_average_rad = movmean(dW,30,'omitnan');
% dW_average = wrapTo360(rad2deg(dW_average_rad));
% load('D:\Data\ISDRI\SupportData\SIO_Mini_Met_Buoy\Mini_Met_Innershelf.mat')
% % direction - degrees coming from, compass heading and declination, 10
% % minute vector averaged
% dnWind_MM = MiniMet.TimeAvg;
% magWind_MM = MiniMet.AvgWindSpeed;
% dirWind_MM = MiniMet.VectorAvgWindDir;

% from NDBC - wind
[dnWind,magWind,dirWind] = loadWindNDBC_historical('D:\Data\ISDRI\SupportData\Wind\MetData_NDBC46011.txt');

% from NDBC - waves
[dnWaves,Hs,dirWaves,TpAve,TpS] = loadWavesNDBC_historical('D:\Data\ISDRI\SupportData\Waves\WaveData_NDBC46011.txt');

% from NOAA
[dnTides,WL] = loadTidesNOAA('D:\Data\ISDRI\SupportData\Tides\TideData_NOAA9411406.txt');
WL(WL == -999) = nan;

%% make rip vector 
ripVecGuadalupe = NaN(1,length(dn));
% ripVecGuadalupe(guadalupeRips(:,5)==2) = 1;
ripVecGuadalupe(guadalupeRips(:,5)==3|guadalupeRips(:,5)==4) = 1;

tooBright = NaN(1,length(dn));
tooBright(rips(:,3)==3|rips(:,3)==2) = 1;

tides_dnrips_Guadalupe = interp1(dnTides,WL,dn);
tides_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

waves_dnrips_Guadalupe_ISDRI = interp1(t_ISDRI,Hm0,dn);
waves_dnrips_Guadalupe_ISDRI(ripVecGuadalupe ~= 1) = nan;

wavesTpS_dnrips_Guadalupe_ISDRI = interp1(t_ISDRI,Tp,dn);
wavesTpS_dnrips_Guadalupe_ISDRI(ripVecGuadalupe ~= 1) = nan;
% 
% waves_dnrips_Guadalupe = interp1(dnWaves,Hs,dn);
% waves_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;
% 
% wavesTpS_dnrips_Guadalupe = interp1(dnWaves,TpS,dn);
% wavesTpS_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;
% 
% wavesTpA_dnrips_Guadalupe = interp1(dnWaves,TpAve,dn);
% wavesTpA_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

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

windDir_dnrips_Guadalupe = interp1(dnWind,dirWind,dn);
windDir_dnrips_Guadalupe(ripVecGuadalupe~=1) = nan;

windDirMM_dnrips_Guadalupe = interp1(dnWind_MM,dirWind_MM,dn);
windDirMM_dnrips_Guadalupe(ripVecGuadalupe~=1) = nan;

windMag_dnrips_Guadalupe = interp1(dnWind,magWind,dn);
windMag_dnrips_Guadalupe(ripVecGuadalupe~=1) = nan;

windMagMM_dnrips_Guadalupe = interp1(dnWind_MM,magWind_MM,dn);
windMagMM_dnrips_Guadalupe(ripVecGuadalupe~=1) = nan;

% find steepness
Hs_TpS = Hs./TpS;
Hs_TpA = Hs./TpAve;

wavesHsTpA_dnrips_Guadalupe = interp1(dnWaves,Hs_TpA,dn);
wavesHsTpA_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

wavesHsTpS_dnrips_Guadalupe = interp1(dnWaves,Hs_TpS,dn);
wavesHsTpS_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

%% load rip times

figure(2)
% ripVecGuadalupe(ripVecGuadalupe == 1) = 0.5;
subplot(3,1,1)
plot(dnTides,WL,'b')
hold on
plot(dn, tooBright,'-g','linewidth',2)
% plot(dn,ripVec,'g.');
% plot(dn,ripVec2,'r.');
plot(dn,tides_dnrips_Guadalupe,'r','Linewidth',1.5)
datetick('x',7)
axis([min(dn) max(dn) -0.1 2])
ylabel('WL (m)')
title('Water Surface Elevation from MLLW');

subplot(3,1,2)
% plot(dnWaves,Hs,'b')
plot(t_ISDRI,Hm0,'b')
hold on
% plot(dn,waves_dnrips_Guadalupe,'r','Linewidth',1.5)
plot(dn,waves_dnrips_Guadalupe_ISDRI,'r','Linewidth',1.5)
datetick('x',7)
axis([min(dn) max(dn) 0 6])
ylabel('Hs (m)')
title('Significant wave height');

% ripVecGuadalupe(ripVecGuadalupe == 0.5) = 17;
subplot(3,1,3)
% plot(dnWaves,TpS,'b')
plot(t_ISDRI,Tp,'b')
hold on
plot(dn,wavesTpS_dnrips_Guadalupe_ISDRI,'r','Linewidth',1.5)
% plot(dnWaves,TpAve,'b')
% plot(dn,wavesTpS_dnrips_Guadalupe,'r','Linewidth',1.5)
% plot(dn,wavesTpA_dnrips_Guadalupe,'r','Linewidth',1.5)
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

%% plot 4 wind
dnWind(dnWind == 0) = nan;
figure(4)
subplot(2,1,1)
% plot(dnWind,magWind,'g')
plot(dnWind_MM,magWind_MM,'b')
hold on
plot(dn, 10*tooBright,'-g','linewidth',2)
% plot(time(:,1),magWind_APL,'r')
% plot(dn,windMag_dnrips_Guadalupe,'r')
plot(dn,windMagMM_dnrips_Guadalupe,'r','Linewidth',1.5)
title('Wind speed with Guadalupe rips')
ylabel('Wind speed (m/s)')
datetick('x',7)
axis([datenum([2017,9,1,0,0,0]) datenum([2017,10,26,0,0,0]) 0 15])

subplot(2,1,2)
% plot(dnWind,dirWind)
plot(dnWind_MM,wrapTo360(dirWind_MM-13),'b')
hold on
% plot(dn,windDir_dnrips_Guadalupe,'r')
plot(dn,wrapTo360(windDirMM_dnrips_Guadalupe-13),'r','Linewidth',1.5)
title('Wind directions with Guadalupe rips')
ylabel('Wind direction (degrees)')
datetick('x',7)
axis([datenum([2017,9,1,0,0,0]) datenum([2017,10,26,0,0,0]) 0 360])