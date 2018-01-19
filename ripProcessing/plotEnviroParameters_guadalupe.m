%% plotEnviroParameters_guadalupe.m - 

clear variables
%% USER INPUTS
% add paths to CTR HUB Support Data and GitHub Repository
% SUPPORT DATA PATH
supportDataPath = 'D:\Data\ISDRI\SupportData'; % LENOVO HARD DRIVE

% GITHUB DATA PATH
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %GITHUB REPOSITORY

%% create time series
load('C:\Data\ISDRI\postprocessed\rips\DataAvailability_Rips_dv.mat')
guadalupeRips = dv;
clear dv


%% Load wind data from wind station file
[dnWind,magWind,dirWind] = loadWindNDBC_historical('D:\Data\ISDRI\SupportData\Wind\MetData_NDBC46011.txt');

% Load wave data from wave station file
[dnWaves,Hs,dirWaves,TpAve,TpS] = loadWavesNDBC_historical('D:\Data\ISDRI\SupportData\Waves\WaveData_NDBC46011.txt');

% Load tide data from tide station file
[dnTides,WL] = loadTidesNOAA('D:\Data\ISDRI\SupportData\Tides\TideData_NOAA9411406.txt');
WL(WL == -999) = nan;

%% Load data from MacMahan instruments
load('D:\Data\ISDRI\SupportData\MacMahan\STR3_AQ.mat')
A = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_A');  % Most offshore 
B = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_B');  % Middle, with ADCP       
C = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_C');  % Most onshore
E = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_E');  % to south
load('C:\Data\ISDRI\isdri-scripts\ripProcessing\transects\cMap.mat')

%% Redefine variables
t = AQ.time_dnum;
depth = AQ.Depth;
ZBed = AQ.Zbed;
Un = AQ.Un;
Ue = AQ.Ue;
W = AQ.W;

tA = A.TCHAIN.time_dnum;
tempA = A.TCHAIN.TEMP';
zBedA = A.TCHAIN.ZBEDT;
zBedA(1) = zBedA(2) + (zBedA(2)-zBedA(3));

tB = B.TCHAIN.time_dnum;
tempB = B.TCHAIN.TEMP';
zBedB = B.TCHAIN.ZBEDT;
zBedB(1) = zBedB(2) + (zBedB(2)-zBedB(3));

tC = C.TCHAIN.time_dnum;
tempC = C.TCHAIN.TEMP';
zBedC = C.TCHAIN.ZBEDT;
zBedC(1) = zBedC(2) + (zBedC(2)-zBedC(3));

tE = E.TCHAIN.time_dnum;
tempE = E.TCHAIN.TEMP';
zBedE = E.TCHAIN.ZBEDT;
zBedE(1) = zBedE(2) + (zBedE(2)-zBedE(3));
clear A B C E AQ

%% Redefine time vectors in UTC
dvPDT = datevec(tA);    % tA tB tC and tE are the same
dvUTC = dvPDT;
dvUTC(:,4) = dvPDT(:,4)+7;  % add 7 hours to convert from PDT to UTC   
dnUTC = datenum(dvUTC);
dvUTC = datevec(dnUTC);

dvPDT_AQ = datevec(t);    % tA tB tC and tE are the same
dvUTC_AQ = dvPDT_AQ; 
dvUTC_AQ(:,4) = dvPDT_AQ(:,4)+7;  % add 7 hours to convert from PDT to UTC   
dnUTC_AQ = datenum(dvUTC_AQ);
dvUTC_AQ = datevec(dnUTC_AQ);

%% Rotate velocities into local coordinate system
rot = -13;
R = [cosd(rot) -sind(rot); sind(rot) cosd(rot)];

for i = 1:size(Ue,2)
    velocity = [Ue(:,i) Un(:,i)];
    velR = velocity*R;
    U(:,i) = velR(:,1);
    V(:,i) = velR(:,2);
end

%% make rip vector 
ripVecGuadalupe = NaN(1,length(dn));
ripVecGuadalupe(guadalupeRips(:,5)==2) = 1;

tides_dnrips_Guadalupe = interp1(dnTides,WL,dn);
tides_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

waves_dnrips_Guadalupe = interp1(dnWaves,Hs,dn);
waves_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

wavesTpS_dnrips_Guadalupe = interp1(dnWaves,TpS,dn);
wavesTpS_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

wavesTpA_dnrips_Guadalupe = interp1(dnWaves,TpAve,dn);
wavesTpA_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

wavesDir_dnrips_Guadalupe = interp1(dnWaves,dirWaves,dn);
wavesDir_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

% for i = 1:length(dnWind)-2
%     if dnWind(i)==0 && dnWind(i+1)~=0
%         dnWind(i) = (dnWind(i+1) + dnWind(i-1))/2;
%     elseif dnWind(i)==0 && dnWind(i+1)==0 && dnWind(i+2)~=0
%         dnWind(i) = (dnWind(i+2) + dnWind(i-2))/2;
%     elseif dnWind(i)==0 && dnWind(i+1)==0 && dnWind(i+2)==0
%         dnWind(i) = (dnWind(i+20) + dnWind(i-20))/2;
%     elseif dnWind(i) ~=0
%         dnWind(i) = dnWind(i);
%     end
% end

windDir_dnrips_Guadalupe = interp1(dnWind,dirWind,dn);
windDir_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

windMag_dnrips_Guadalupe = interp1(dnWind,magWind,dn);
windMag_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

% find steepness
Hs_TpS = Hs./TpS;
Hs_TpA = Hs./TpAve;
wavesHsTpA_dnrips_Guadalupe = interp1(dnWaves,Hs_TpA,dn);
wavesHsTpA_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

wavesHsTpS_dnrips_Guadalupe = interp1(dnWaves,Hs_TpS,dn);
wavesHsTpS_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

%% load rip times
%% plot 1
% figure(1)
% plot(dnTides,WL,'b')
% hold on
% % plot(dn,ripVec,'g.');
% % plot(dn,ripVec2,'r.');
% plot(dn,tides_dnrips_Guadalupe,'r')
% datetick('x',7)
% axis([min(dn) max(dn) -0.1 2])
% xlabel('WL (m)')
% title('Water Surface Elevation from MLLW with Guadalupe rips');

%% plot 2
% define timme point of interest
d1 = datenum([2017,9,15,0,0,0]);
d2 = datenum([2017,9,31,0,0,0]);

idxAQ = find(dnUTC_AQ > d1 & dnUTC_AQ < d2);
idxTChain = find(dnUTC > d1 & dnUTC < d2);
idxTides = find(dnTides > d1 & dnTides < d2);
dv1 = datevec(d1);
dv2 = datevec(d2);

tempLimits(1) = min([min(min(tempA(1:11,idxTChain))),min(min(tempB(:,idxTChain))),...
    min(min(tempC(:,idxTChain))), min(min(tempE(:,idxTChain)))]);
tempLimits(2) = max([max(max(tempA(1:11,idxTChain))),max(max(tempB(:,idxTChain))),...
    max(max(tempC(:,idxTChain))), max(max(tempE(:,idxTChain)))]);

%% temperature figure
% fig2 = figure(2);
% fig2.PaperUnits = 'inches';
% fig2.PaperPosition = [0 0 9 8];
% subplot(4,1,1)
% pcolor(dnUTC(idxTChain),zBedA(1:11),tempA(1:11,idxTChain))
% hold on
% plot(dnTides,(WL - mean(WL)+8),'b')
% plot(dn,(tides_dnrips_Guadalupe - mean(WL) + 8),'r','LineWidth',2)
% shading flat; hcb =colorbar;
% caxis(tempLimits)
% axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedA(1:11)) max(zBedA(1:11))])
% y1 = get(gca,'ylim');
% % line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% datetick('x','keeplimits')
% xlabel('Time'); ylabel('Distance above bed (m)'); 
% ttlA = ['Temperature at STRING A (most offshore), ' num2str(dv1(2),'%02i')...
%     num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
% title(ttlA)
% xlabel(hcb,'Temperature C')
% 
% subplot(4,1,2)
% pcolor(dnUTC(idxTChain),zBedB(1:8),tempB(1:8,idxTChain))
% shading flat; hcb =colorbar;
% hold on
% plot(dnTides,(WL - mean(WL)+5),'b')
% plot(dn,(tides_dnrips_Guadalupe - mean(WL) + 5),'r','LineWidth',2)
% caxis(tempLimits)
% axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedB(1:8)) max(zBedB(1:8))])
% datetick('x','keeplimits')
% y1 = get(gca,'ylim');
% % line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
% xlabel('Time'); ylabel('Distance above bed (m)'); 
% ttlB = ['Temperature at STRING B (middle, with ADCP), ' num2str(dv1(2),'%02i')...
%     num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
% title(ttlB)
% xlabel(hcb,'Temperature C')

fig2 = figure;
fig2.PaperUnits = 'inches';
fig2.PaperPosition = [0 0 9 8];
subplot(4,1,1)
% pcolor(dnUTC(idxTChain),zBedE(1:8),tempE(1:8,idxTChain))
pcolor(dnUTC_AQ(idxAQ),ZBed,U(idxAQ,:)')
shading flat; colormap(cMap)
caxis([-0.4 0.4])
hold on
plot(dnTides,(WL - mean(WL)+5),'b')
plot(dn,(tides_dnrips_Guadalupe - mean(WL) + 5),'r','LineWidth',2)
% caxis(tempLimits)
caxis([-0.4 0.4])
% axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedE(1:8)) max(zBedE(1:8))])
axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
datetick('x',6,'keeplimits')
y1 = get(gca,'ylim');
% line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
% xlabel('Time'); 
ylabel('Distance above bed (m)'); 
% ttlB = ['Temperature at STRING E (middle, to south), ' num2str(dv1(2),'%02i')...
%     num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
ttlB = ['U velocity at string B, ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlB)
% xlabel(hcb,'Temperature C')

subplot(4,1,2)
% pcolor(dnUTC(idxTChain),zBedC(1:6),tempC(1:6,idxTChain))
pcolor(dnUTC_AQ(idxAQ),ZBed,V(idxAQ,:)')
shading flat; colormap(cMap)
hold on
plot(dnTides,(WL - mean(WL) + 4),'b')
plot(dn,(tides_dnrips_Guadalupe - mean(WL) + 4),'r','LineWidth',2)
% caxis(tempLimits)
caxis([-0.4 0.4])
axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
% axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedC(1:6)) max(zBedC(1:6))])
datetick('x',6,'keeplimits')
y1 = get(gca,'ylim');
% line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
% xlabel('Time'); 
ylabel('Distance above bed (m)'); 
% ttlC = ['Temperature at STRING C (most onshore), ' num2str(dv1(2),'%02i')...
%     num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
ttlB = ['V velocity at string B, ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlB)
% xlabel(hcb,'Temperature C')

subplot(4,1,3)
plot(dnWaves,Hs,'b')
hold on
plot(dn,waves_dnrips_Guadalupe,'r','LineWidth',2);
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 0 4])
datetick('x',6,'keeplimits')
ylabel('Hs (m)')
title('Significant wave height');

% ripVecGuadalupe(ripVecGuadalupe == 0.5) = 17;
subplot(4,1,4)
plot(dnWaves,TpS,'g')
hold on
plot(dnWaves,TpAve,'b')
plot(dn,wavesTpS_dnrips_Guadalupe,'r','LineWidth',2);
plot(dn,wavesTpA_dnrips_Guadalupe,'r','LineWidth',2);
ylabel('Tp (s)'); xlabel('Time')
title('Wave period');
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 2 24])
datetick('x',6,'keeplimits')
legend('Swell Tp','Mean Tp')
% legend('Swell','Mean')
% 
% 
% %% plot 3
% figure(3)
% % ripVecGuadalupe(ripVecGuadalupe == 1) = 0.5;
% subplot(4,1,1)
% plot(dnTides,WL,'b')
% hold on
% % plot(dn,ripVec,'g.');
% % plot(dn,ripVec2,'r.');
% plot(dn,tides_dnrips_Guadalupe,'r')
% datetick('x',7)
% axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) -0.1 2])
% ylabel('WL (m)')
% title('Water Surface Elevation from MLLW with Guadalupe rips');
% 
% subplot(4,1,2)
% plot(dnWaves,Hs,'b')
% hold on
% plot(dn,waves_dnrips_Guadalupe,'r');
% datetick('x',7)
% axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 0 4])
% ylabel('Hs (m)')
% title('Significant wave height');
% 
% % ripVecGuadalupe(ripVecGuadalupe == 0.5) = 17;
% subplot(4,1,3)
% plot(dnWaves,TpS,'b')
% hold on
% plot(dnWaves,TpAve,'b')
% plot(dn,wavesTpS_dnrips_Guadalupe,'r');
% plot(dn,wavesTpA_dnrips_Guadalupe,'r');
% datetick('x')
% ylabel('Tp (s)')
% title('Wave period');
% datetick('x',7)
% axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 2 24])
% % legend('Swell','Mean')
% 
% % subplot(5,1,4)
% % plot(dnWaves,Hs_TpA,'b')
% % hold on
% % plot(dn,wavesHsTpA_dnrips_Guadalupe,'r');
% % % plot(dn,wavesTpA_dnrips_Guadalupe,'r');
% % xlabel('Hs/Tp')
% % title('Significant wave height over wave period');
% % datetick('x',7)
% % axis([min(dn) max(dn) 0 1])
% % % legend('Swell','Mean')
% 
% subplot(4,1,4)
% plot(dnWaves, dirWaves)
% hold on
% plot(dn,wavesDir_dnrips_Guadalupe,'r');
% ylabel('Direction (degrees)')
% title('Wave direction');
% datetick('x',7)
% axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 0 360])
% 
% 
% %% plot 4 wind
% dnWind(dnWind == 0) = nan;
% figure(4)
% subplot(2,1,1)
% plot(dnWind,magWind,'b')
% hold on
% plot(dn,windMag_dnrips_Guadalupe,'r')
% title('Wind speed with Guadalupe rips')
% ylabel('Wind speed (m/s)')
% datetick('x',7)
% axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 0 20])
% 
% subplot(2,1,2)
% plot(dnWind,dirWind)
% hold on
% plot(dn,windDir_dnrips_Guadalupe,'r')
% title('Wind directions with Guadalupe rips')
% ylabel('Wind direction (degrees)')
% datetick('x',7)
% axis(dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 0 360])
% 
