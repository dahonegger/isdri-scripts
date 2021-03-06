%% plotEnviroParameters.m - 
clear variables; home

%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository
% SUPPORT DATA PATH
supportDataPath = 'D:\Data\ISDRI\SupportData'; % LENOVO HARD DRIVE
Rip = 4;

% GITHUB DATA PATH
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %GITHUB REPOSITORY
addpath(genpath('C:\Data\CTR\ctr-scripts\air_sea'))

%% create time series
% dn = datenum([2017,08,31,21,0,0]):1/24:datenum([2017,10,26,15,0,0]);
% dv = datevec(dn);
load('C:\Data\ISDRI\postprocessed\rips\DataAvailability_Rips_dv.mat')
load('\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\newRipMatrix\rips.mat')
guadalupeRips = dv;
clear dv
% guadalupeRips(4:end,5) = rips(:,2);
load('\\depot\cce_u1\haller\shared\odea\ISDRI\ISDRI\newRipMatrix\NorthCenterSouthRips.mat');
dn = NCSRips(:,1);

%% Load wind and wave info
% APL
load('D:\Data\ISDRI\SupportData\APL_MetStations\APL_time_windSpeed_gustSpeed_windDir.mat')
t_APL = time(1:34585,1);
windMag_APL = 0.44704*time(1:34585,2);
gustMag_APL = 0.44704*time(1:34585,3);
windDir_APL = wrapTo360(180+time(1:34585,4));   % FLIPPED 180 DEGREES
% windDir_APL(windMag_APL == 0) = nan;
% windMag_APL(windMag_APL == 0) = nan;
rotation = 13;
anemometerHeight = 18 + 4.4;
[uw,vw,tx,ty] = calcWindStress(windMag_APL,windDir_APL,rotation,anemometerHeight); %% POSITIVE rotation rotates to left in function

% % from spoondrift
load('D:\Data\ISDRI\SupportData\Spoondrift\SPOT-0014');
t_ISDRI = time;

% from APL met station
load('D:\Data\ISDRI\SupportData\APL_MetStations\APL_time_windSpeed_gustSpeed_windDir.mat');
gustSpeed = 0.44704*time(:,3);  % convert from mph to m/s
magWind_APL = 0.44704*time(:,2);  % convert from mph to m/s

% from NDBC - wind
[dnWind,magWind,dirWind] = loadWindNDBC_historical('D:\Data\ISDRI\SupportData\Wind\MetData_NDBC46011.txt');

% % from NDBC - waves
% [dnWaves,Hs,dirWaves,TpAve,TpS] = loadWavesNDBC_historical('D:\Data\ISDRI\SupportData\Waves\WaveData_NDBC46011.txt');

% from NOAA
[dnTides,WL] = loadTidesNOAA('D:\Data\ISDRI\SupportData\Tides\TideData_NOAA9411406.txt');
WL(WL == -999) = nan;

%% make rip vector 
lowThreshold = 0;
highThreshold = 7;
[lowWindEvents,brightEvents,t_BA,windMag_BA] = windFilter_speed(t_APL,windMag_APL,lowThreshold,highThreshold);
[offshoreEvents,t_BA,windMag_BA,windDir_BA] = windFilter_direction(t_APL,windMag_APL,windDir_APL,anemometerHeight,rotation);

ripVecGuadalupe = NaN(1,length(dn));
ripVecGuadalupe(guadalupeRips(:,5)==2) = 1;
% ripVecGuadalupe(guadalupeRips(:,5)==3|guadalupeRips(:,5)==4|guadalupeRips(:,5)==5) = 1;
% ripVecGuadalupe(NCSRips(:,2)==2) = 1;
% ripVecGuadalupe(guadalupeRips(:,5)==5) = 1;

% tooBright = NaN(1,length(dn));
% tooBright(NCSRips(:,2)==888) = 1;
% idxNonNan = find(~isnan(tooBright));
% diffBright = diff(idxNonNan);
% gaps = find(diffBright>5);
% event = 1;
% for i = 1:length(gaps);
%     if i == 1
%     	brightEvents(event,1) = idxNonNan(1);
%         brightEvents(event,2) = idxNonNan(gaps(1));
%         event = event+1;
%     else 
%         brightEvents(event,1) = idxNonNan(gaps(i-1)+1);
%         brightEvents(event,2) = idxNonNan(gaps(i));
%         event = event+1;
%     end
% end

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

% wavesDir_dnrips_Guadalupe = interp1(dnWaves,dirWaves,dn);
% wavesDir_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

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

% windDirMM_dnrips_Guadalupe = interp1(dnWind_MM,dirWind_MM,dn);
% windDirMM_dnrips_Guadalupe(ripVecGuadalupe~=1) = nan;

windMag_dnrips_Guadalupe = interp1(dnWind,magWind,dn);
windMag_dnrips_Guadalupe(ripVecGuadalupe~=1) = nan;
% 
% windMagMM_dnrips_Guadalupe = interp1(dnWind_MM,magWind_MM,dn);
% windMagMM_dnrips_Guadalupe(ripVecGuadalupe~=1) = nan;

% find direction
meanDir_dnrips_Guadalupe = interp1(t_ISDRI,meanDir,dn);
meanDir_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

meanDirSpr_dnrips_Guadalupe = interp1(t_ISDRI,meanDirSpread,dn);
meanDirSpr_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;
%% load rip times
figure;
subplot(3,1,1)
hold on
% for i = 1:length(brightEvents)
%     boxstart = t_BA(brightEvents(i,1));
%     boxlength = t_BA(brightEvents(i,2))-t_BA(brightEvents(i,1));
%     rectangle('Position',[boxstart -1 boxlength 3],'EdgeColor',[0.8 0.8 0.8],'FaceColor',[0.8 0.8 0.8])
% end
% for i = 1:length(lowWindEvents)
%     boxstart = t_BA(lowWindEvents(i,1));
%     boxlength = t_BA(lowWindEvents(i,2))-t_BA(lowWindEvents(i,1));
%     rectangle('Position',[boxstart -1 boxlength 3],'EdgeColor',[0.8 0.8 0.8],'FaceColor',[0.8 0.8 0.8])
% end
% for i = 1:length(offshoreEvents)
%     boxstart = t_BA(offshoreEvents(i,1));
%     boxlength = t_BA(offshoreEvents(i,2))-t_BA(offshoreEvents(i,1));
%     rectangle('Position',[boxstart -1 boxlength 3],'EdgeColor',[0.8 0.8 0.8],'FaceColor',[0.8 0.8 0.8])
% end
plot(dnTides,WL,'b')
hold on
% plot(dn, tooBright,'-g','linewidth',2)
% plot(dn,ripVec,'g.');
% plot(dn,ripVec2,'r.');
plot(dn,tides_dnrips_Guadalupe,'r','Linewidth',1.5)
axis([datenum([2017,9,7,0,0,0]) datenum([2017,10,26,0,0,0]) -0.1 2])
datetick('x','keeplimits')
ylabel('WL (m)')
title('Water Surface Elevation from MLLW');
box on
% % % % % 
% % % % % % figure;
% % % % % subplot(3,1,2)
% % % % % % plot(dnWaves,Hs,'b')
% % % % % plot(t_ISDRI,Hm0,'b')
% % % % % hold on
% % % % % % plot(dn,waves_dnrips_Guadalupe,'r','Linewidth',1.5)
% % % % % plot(dn,waves_dnrips_Guadalupe_ISDRI,'r','Linewidth',1.5)
% % % % % axis([datenum([2017,9,7,0,0,0]) datenum([2017,10,26,0,0,0]) 0 5])
% % % % % datetick('x','keeplimits')
% % % % % ylabel('Hs (m)')
% % % % % title('Significant wave height from SPOT-0014');
% % % % % 
% % % % % % ripVecGuadalupe(ripVecGuadalupe == 0.5) = 17;
% % % % % subplot(3,1,3)
% % % % % % plot(dnWaves,TpS,'b')
% % % % % plot(t_ISDRI,Tp,'b')
% % % % % hold on
% % % % % plot(dn,wavesTpS_dnrips_Guadalupe_ISDRI,'r','Linewidth',1.5)
% % % % % % plot(dnWaves,TpAve,'b')
% % % % % % plot(dn,wavesTpS_dnrips_Guadalupe,'r','Linewidth',1.5)
% % % % % % plot(dn,wavesTpA_dnrips_Guadalupe,'r','Linewidth',1.5)
% % % % % datetick('x')
% % % % % ylabel('Tp (s)'); xlabel('Date')
% % % % % title('Wave period from SPOT-0014');
% % % % % axis([datenum([2017,9,7,0,0,0]) datenum([2017,10,26,0,0,0]) 2 24])
% % % % % datetick('x','keeplimits')
% % % % % % legend('Swell','Mean')
% 

subplot(3,1,2)
plot(t_ISDRI,meanDirSpread,'b')
% plot(t_ISDRI,(meanDirSpread),'b')
hold on
plot(dn,meanDirSpr_dnrips_Guadalupe,'r','Linewidth',1.5)
% plot(dn,(meanDirSpr_dnrips_Guadalupe),'r');
% ylabel('Mean direcitonal spread (degrees)')
title('Mean directional spread, from SPOT-0014');
axis([datenum([2017,9,7,0,0,0]) datenum([2017,10,26,0,0,0]) 0 70])
% axis([datenum([2017,9,7,0,0,0]) datenum([2017,10,26,0,0,0]) 0 60])
datetick('x','keeplimits')

subplot(3,1,3)
plot(t_ISDRI,(meanDir-270-rotation),'b')
% plot(t_ISDRI,(meanDirSpread),'b')
hold on
plot(dn,(meanDir_dnrips_Guadalupe-270-rotation),'r','Linewidth',1.5)
% plot(dn,(meanDirSpr_dnrips_Guadalupe),'r');
% xlabel('Date'); ylabel('MWD (degrees)')
xlabel('Date');
title('Mean wave direction from shore normal, from SPOT-0014');
axis([datenum([2017,9,7,0,0,0]) datenum([2017,10,26,0,0,0]) -50 50])
% axis([datenum([2017,9,7,0,0,0]) datenum([2017,10,26,0,0,0]) 0 60])
datetick('x','keeplimits')

%% plot 4 wind
% % dnWind(dnWind == 0) = nan;
% % figure(4)
% % subplot(2,1,1)
% % % plot(dnWind,magWind,'g')
% % plot(dnWind_MM,magWind_MM,'b')
% % hold on
% % plot(dn, 10*tooBright,'-g','linewidth',2)
% % % plot(time(:,1),magWind_APL,'r')
% % % plot(dn,windMag_dnrips_Guadalupe,'r')
% % plot(dn,windMagMM_dnrips_Guadalupe,'r','Linewidth',1.5)
% % title('Wind speed with Guadalupe rips')
% % ylabel('Wind speed (m/s)')
% % datetick('x',7)
% % axis([datenum([2017,9,7,0,0,0]) datenum([2017,10,26,0,0,0]) 0 15])
% % 
% % subplot(2,1,2)
% % % plot(dnWind,dirWind)
% % plot(dnWind_MM,wrapTo360(dirWind_MM-13),'b')
% % hold on
% % % plot(dn,windDir_dnrips_Guadalupe,'r')
% % plot(dn,wrapTo360(windDirMM_dnrips_Guadalupe-13),'r','Linewidth',1.5)
% % title('Wind directions with Guadalupe rips')
% % ylabel('Wind direction (degrees)')
% % datetick('x',7)
% % axis([datenum([2017,9,7,0,0,0]) datenum([2017,10,26,0,0,0]) 0 360])