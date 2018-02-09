% inSituMeasurements.m
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

%% define radar domain
rotation = 13;

% define cube (if more than 64 rotations)
if size(data,3) > 65
    clear timex
    idx =  187; 
    if idx >= 51
        indices = (idx-50):(idx+50);
    else
        indices = idx:idx+100;
    end
    timex = mean(data(:,:,indices),3);
    timeInt = timeInt(:,indices);
end

% Convert to world coordinates
time = datevec(epoch2Matlab(mean(timeInt(:))));
heading = results.heading-rotation;
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
x0 = results.XOrigin;
y0 = results.YOrigin;
xdom = xdom;
ydom = ydom;

% add MacMahan's instruments
% find coordinates of MacMahan instruments
latJM = [34.9826 34.981519 34.981131 34.980439 34.98035 34.985969];
lonJM = [-120.657311 -120.651639 -120.650239 -120.647881...
    -120.651719 -120.650319];

[yUTM_JM, xUTM_JM] = ll2UTM(latJM,lonJM);
X_JM = xUTM_JM - results.XOrigin;
Y_JM = yUTM_JM - results.YOrigin;

% rotate onto the same grid
[thJM,rgJM] = cart2pol(X_JM,Y_JM);
aziJM = wrapTo360(-thJM*180/pi + 90 - results.heading);
aziJMC = aziJM - rotation;
thJMC = pi/180*(90 - aziJMC - results.heading);
[xJMC,yJMC] = pol2cart(thJMC,rgJM);

%% Redefine time vectors in UTC
dvPDT = datevec(tA);    % tA tB tC and tE are the same
dvUTC = dvPDT;
dvUTC(:,4) = dvPDT(:,4)+7;  % add 7 hours to convert from PDT to UTC   
dnUTC = datenum(dvUTC);
dvUTC = datevec(dnUTC);
clear tA

dvPDT_AQ = datevec(t);    % tA tB tC and tE are the same
dvUTC_AQ = dvPDT_AQ; 
dvUTC_AQ(:,4) = dvPDT_AQ(:,4)+7;  % add 7 hours to convert from PDT to UTC   
dnUTC_AQ = datenum(dvUTC_AQ);
dvUTC_AQ = datevec(dnUTC_AQ);
clear t

%% Rotate velocities into local coordinate system
rot = 13;
R = [cosd(rot) -sind(rot); sind(rot) cosd(rot)];
U = zeros(size(Ue));
V = zeros(size(Un));

for i = 1:size(Ue,2)
    velocity = [Ue(:,i)';Un(:,i)'];
    velR = R*velocity;
    U(:,i) = velR(1,:);
    V(:,i) = velR(2,:);
end

%% plot radar image
fig1 = figure;
fig1.PaperUnits = 'inches';
fig1.PaperPosition = [0 0 4 6];
pcolor(xdom,ydom,timex)
shading flat; axis image
colormap(hot)
colorbar
caxis([20 200])
hold on
plot(xJMC,yJMC,'b.','MarkerSize',20)
axis([-4000 -500 -4000 4000])
ttl = ['Timex ' num2str(time(1)) num2str(time(2),'%02i') num2str(time(3),'%02i')...
    ' ' num2str(time(4),'%02i') ':' num2str(time(5),'%02i')];
title(ttl)
figttl1 = [saveDir 'Radar_largeDomain_' num2str(time(1)) num2str(time(2),'%02i')...
    num2str(time(3),'%02i') '_' num2str(time(4),'%02i') num2str(time(5),'%02i')];

fig2 = figure;
fig2.PaperUnits = 'inches';
fig2.PaperPosition = [0 0 4 6];
pcolor(xdom,ydom,timex)
shading flat; axis image
colormap(hot)
colorbar
caxis([50 230])
hold on
plot(xJMC,yJMC,'b.','MarkerSize',20)
axis([-1500 -500 -1000 1000])
ttl = ['Timex ' num2str(time(1)) num2str(time(2),'%02i') num2str(time(3),'%02i')...
    ' ' num2str(time(4),'%02i') ':' num2str(time(5),'%02i')];
title(ttl)
figttl2 = [saveDir 'Radar_smallDomain_' num2str(time(1)) num2str(time(2),'%02i')...
    num2str(time(3),'%02i') '_' num2str(time(4),'%02i') num2str(time(5),'%02i')];


%% define timme point of interest
d1 = datenum([2017,9,15,15,0,0]);
d2 = datenum([2017,9,16,0,0,0]);

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
fig3 = figure;
fig3.PaperUnits = 'inches';
fig3.PaperPosition = [0 0 9 8];
subplot(4,1,1)
pcolor(dnUTC(idxTChain),zBedA(1:11),tempA(1:11,idxTChain))
hold on
shading flat; hcb =colorbar;
caxis(tempLimits)
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedA(1:11)) max(zBedA(1:11))])
% plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+8),'r')
% plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+8),'y')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
datetick('x','keeplimits')
xlabel('Time'); ylabel('Distance above bed (m)'); 
ttlA = ['Temperature at STRING A (most offshore), ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlA)
xlabel(hcb,'Temperature C')

subplot(4,1,2)
pcolor(dnUTC(idxTChain),zBedB(1:8),tempB(1:8,idxTChain))
shading flat; hcb =colorbar;
hold on
% plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+5),'r')
% plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+5),'y')
caxis(tempLimits)
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedB(1:8)) max(zBedB(1:8))])
datetick('x','keeplimits')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
xlabel('Time'); ylabel('Distance above bed (m)'); 
ttlB = ['Temperature at STRING B (middle, with ADCP), ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlB)
xlabel(hcb,'Temperature C')

subplot(4,1,3)
pcolor(dnUTC(idxTChain),zBedE(1:8),tempE(1:8,idxTChain))
shading flat; hcb =colorbar;
hold on
% plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+5),'r')
% plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+5),'y')
caxis(tempLimits)
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedE(1:8)) max(zBedE(1:8))])
datetick('x','keeplimits')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
xlabel('Time'); ylabel('Distance above bed (m)'); 
ttlB = ['Temperature at STRING E (middle, to south), ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlB)
xlabel(hcb,'Temperature C')

subplot(4,1,4)
pcolor(dnUTC(idxTChain),zBedC(1:6),tempC(1:6,idxTChain))
shading flat; hcb =colorbar;
hold on
% plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+4),'r')
% plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+4),'y')
caxis(tempLimits)
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedC(1:6)) max(zBedC(1:6))])
datetick('x','keeplimits')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
xlabel('Time'); ylabel('Distance above bed (m)'); 
ttlC = ['Temperature at STRING C (most onshore), ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlC)
xlabel(hcb,'Temperature C')
figttl3 = [saveDir 'Temp_' num2str(time(1)) num2str(time(2),'%02i')...
    num2str(time(3),'%02i') '_' num2str(time(4),'%02i') num2str(time(5),'%02i')];

% subplot(3,1,3)
% figure,
% plot(dnUTC_AQ(idxAQ),depth(idxAQ))
% axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 8 13])
% datetick('x','keeplimits')
% % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
% xlabel('Time'); ylabel('Water surface elevation(m)'); 
% title('Water surface elevation at STRING B')
%% velocity figure
fig4 = figure;
fig4.PaperUnits = 'inches';
fig4.PaperPosition = [0 0 9 8];
subplot(3,1,1)
pcolor(dnUTC_AQ(idxAQ),ZBed,U(idxAQ,:)')
shading flat; colorbar; colormap(cMap)
caxis([-0.4 0.4])
axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
datetick('x','keeplimits')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
xlabel('Time'); ylabel('Distance above bed (m)'); 
ttlU = ['U velocity at STRING B, ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlU)

subplot(3,1,2)
pcolor(dnUTC_AQ(idxAQ),ZBed,V(idxAQ,:)')
shading flat; colorbar; colormap(cMap)
caxis([-0.4 0.4])
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
datetick('x','keeplimits')
xlabel('Time'); ylabel('Distance above bed (m)'); 
ttlV = ['V velocity at STRING B, ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlV)

subplot(3,1,3)
pcolor(dnUTC_AQ(idxAQ),ZBed,W(idxAQ,:)')
shading flat; colorbar; colormap(cMap)
caxis([-0.15 0.15])
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
datetick('x','keeplimits')
xlabel('Time'); ylabel('Distance above bed (m)'); 
ttlW = ['W velocity at STRING B, ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlW)
figttl4 = [saveDir 'Velocity_' num2str(time(1)) num2str(time(2),'%02i')...
    num2str(time(3),'%02i') '_' num2str(time(4),'%02i') num2str(time(5),'%02i')];

%% save images
savefig(fig1,[figttl1 '.fig'])
print(fig1,[figttl1 '.png'],'-dpng')

savefig(fig2,[figttl2 '.fig'])
print(fig2,[figttl2 '.png'],'-dpng')

savefig(fig3,[figttl3 '.fig'])
print(fig3,[figttl3 '.png'],'-dpng')

savefig(fig4,[figttl4 '.fig'])
print(fig4,[figttl4 '.png'],'-dpng')
