% velocities.m
% 1/10/2018

clear variables; home; close all

%% Add path
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));

%% load variables
load('D:\Data\ISDRI\SupportData\MacMahan\STR3_AQ.mat')
A = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_A');  % Most offshore 
B = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_B');  % Middle, with ADCP       
C = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_C');  % Most onshore
E = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_E');  % to south
load('C:\Data\ISDRI\isdri-scripts\ripProcessing\transects\cMap.mat')
[dnTides,WL] = loadTidesNOAA('D:\Data\ISDRI\SupportData\Tides\TideData_NOAA9411406.txt');

%% load mat file
load('E:\guadalupe\processed\2017-09-15\Guadalupe_20172581915_pol.mat')
saveDir = ['E:\guadalupe\postprocessed\inSitu\Sept15\'];
if ~exist(saveDir); mkdir(saveDir); end

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

%% create time series
load('C:\Data\ISDRI\postprocessed\rips\DataAvailability_Rips_dv.mat')
guadalupeRips = dv;
clear dv

ripVecGuadalupe = NaN(1,length(dn));
ripVecGuadalupe(guadalupeRips(:,5)==2) = 1;

tides_dnrips_Guadalupe = interp1(t,depth,dn);
tides_dnrips_Guadalupe(ripVecGuadalupe ~= 1) = nan;

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

% % band average over 3 adjacent bands
% bave = 3;
% ki=1;
% dk=floor(bave/2);
% Uba = zeros(floor(length(U)/bave),size(U,2));
% for c = 1:size(U,2)
% for kk=1+dk : bave : length(U)-dk      
%         jj = kk-dk:kk+dk;
%         Uba(ki,c) = sum(U(jj,c)) ./ bave;
%         ki = ki+1;
%         if ki == floor(length(U)/bave)
%             ki = 1;
%         end
% end
% end
% ki = 1;
% for kk=1+dk : bave : length(U)-dk      
%         jj = kk-dk:kk+dk;
%         tba(ki) = sum(t(jj)) ./ bave;
%         ki = ki+1;
% end

%% find surface velocities
% first - just average of surface bins
UU1 = nanmean(U(:,14:20),2);

% second - find surface, find mean of top 3 bins from this
for i = 1:size(U,1)
    idx(i) = find(~isnan(U(i,:)),1,'last');
    UUS(i,:) = U(i,(idx(i)-2):idx(i));
end

UU2 = mean(UUS,2);

figure,
ax1 = subplot(2,1,1);
plot(t,depth)
hold on
plot(dn,tides_dnrips_Guadalupe,'r','LineWidth',2)
datetick('x')

ax2 = subplot(2,1,2);
plot(t,UU1,'r')
hold on
plot(t,UU2,'b')
datetick('x')

linkaxes([ax1,ax2],'x')

