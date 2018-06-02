%% nearshoreTidalBore.m - This code finds the arrival time of nearshore bores
%% 3/13/2017

clear variables; close all; home

%% Add path
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));
addpath(genpath('C:\Data\ISDRI\cBathy'));

C = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_C');  % Most onshore

tC = C.TCHAIN.time_dnum;
tempC = C.TCHAIN.TEMP';
zBedC = C.TCHAIN.ZBEDT;
zBedC(1) = zBedC(2) + (zBedC(2)-zBedC(3));

%% Redefine time vectors in UTC
dvPDT = datevec(tC);    % tA tB tC and tE are the same
dvUTC = dvPDT;
dvUTC(:,4) = dvPDT(:,4)+7;  % add 7 hours to convert from PDT to UTC
dnUTC = datenum(dvUTC);
dvUTC = datevec(dnUTC);
clear tC

%% separate into several chunks for plotting

sept1_15 = find(dnUTC > datenum([2017,9,1,0,0,0]) & dnUTC < datenum([2017,9,15,0,0,0]));
sept15_oct1 = find(dnUTC > datenum([2017,9,15,0,0,0]) & dnUTC < datenum([2017,10,1,0,0,0]));
oct1_15 = find(dnUTC > datenum([2017,10,1,0,0,0]) & dnUTC < datenum([2017,10,15,0,0,0]));
oct15_30 = find(dnUTC > datenum([2017,10,15,0,0,0]) & dnUTC < datenum([2017,10,30,0,0,0]));


%% find peaks
clear pksLoc pks
tBottomSmoothed = movmean(tempC(6,:),5000);
tNBSmoothed = movmean(tempC(5,:),5000);
tTopSmoothed = movmean(tempC(1,:),5000);
tAllSmoothed = movmean(mean(tempC),5000);

diffMeanBottom = tAllSmoothed - tBottomSmoothed;
diffTopBottom = tTopSmoothed - tBottomSmoothed;
diffNBBottom = tNBSmoothed - tBottomSmoothed;
[pks,pksLoc] = findpeaks(diffMeanBottom,dnUTC,'MinPeakDistance',0.25,'MinPeakHeight',0.5,'MinPeakWidth',0.05);

figure,
% plot(dnUTC,tBottomSmoothed)
plot(dnUTC,diffMeanBottom)
hold on
plot(dnUTC,diffTopBottom)
plot(dnUTC,diffNBBottom)
% plot(dnUTC,tAllSmoothed)
plot(pksLoc,pks,'r*')
axis([dnUTC(sept1_15(1)) dnUTC(sept1_15(end)) -0.5 3])
datetick('x','keeplimits')

figure,
pcolor(dnUTC(sept1_15) ,zBedC, tempC(:,sept1_15))
shading flat; 
hold on
plot(pksLoc*ones(size(zBedC)), zBedC,'k-','linewidth',2)
axis([dnUTC(sept1_15(1)) dnUTC(sept1_15(end)) 1.5 8])
colormap(brewermap([],'*RdBu'))
datetick('x','keeplimits')
xlabel('Time'); ylabel('Elevation above bed (m)')
colorbar
caxis([14 19])
