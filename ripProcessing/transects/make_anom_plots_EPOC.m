%% make_anom_plots
% 5/2/2018

clear variables

startTime1 = '20170901';
endTime1 = '20170910';
startTime2 = '20171001';
endTime2 = '20171010';

filter = 'doubleMovingAverage_3000m\';
distanceFromPI = 5; % 1=0m; 2=25m; 3=50m; 4=75m; 5=100m; 6=150 m
SZEdge = 7;
filtSize = '800';
baseDir = 'E:\guadalupe\postprocessed\alongshoreTransectMatrix\ANOMALY_TRANSECTS\';

dnStart1 = datenum([str2num(startTime1(1:4)),str2num(startTime1(5:6)),str2num(startTime1(7:8)),0,0,0]);
dnEnd1 = datenum([str2num(endTime1(1:4)),str2num(endTime1(5:6)),str2num(endTime1(7:8)),0,0,0]);
dnStart2 = datenum([str2num(startTime2(1:4)),str2num(startTime2(5:6)),str2num(startTime2(7:8)),0,0,0]);
dnEnd2 = datenum([str2num(endTime2(1:4)),str2num(endTime2(5:6)),str2num(endTime2(7:8)),0,0,0]);

addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository
load('C:\Data\ISDRI\isdri-scripts\ripProcessing\transects\cMap.mat')
matFile1 = 'E:\guadalupe\processed\2017-09-07\Guadalupe_20172501847_pol.mat';    % this is the one used for ONR meeting
matFile2 = 'E:\guadalupe\processed\2017-10-04\Guadalupe_20172770335_pol.mat'; % THIS ONE

%% load transects
matName1 = [baseDir filter startTime1 '_' endTime1 '_AST_' filtSize '.mat'];
load(matName1);
AST1 = AST; clear AST;
matName2 = [baseDir filter startTime2 '_' endTime2 '_AST_' filtSize '.mat'];
load(matName2);
AST2 = AST; clear AST;

yC = -3000:3000;
xC = -1100:-500;

%% radar image
load(matFile1)
data1 = data; clear data;
timeInt1 = timeInt; clear timeInt;

load(matFile2)
data2 = data; clear data;
timeInt2 = timeInt; clear timeInt;

% define parameters
numRots = 64;
startRot = 64*6;

rotation = 13;
x0 = 0;         % for local
y0 = 0;
axisLimits = [-1500 -500 -1000 1000 ];

clear timex
if size(data1,3)>64
    timex1 = mean(data1(:,:,startRot:(startRot+numRots)),3);
    time1 = mean(epoch2Matlab(timeInt1(1,startRot:(startRot+numRots))));
else
    timex1 = mean(data1,3);
    time1 = mean(epoch2Matlab(timeInt1(1,:)));
end
if size(data2,3)>64
    timex2 = mean(data2(:,:,startRot:(startRot+numRots)),3);
    time2 = mean(epoch2Matlab(timeInt2(1,startRot:(startRot+numRots))));
else
    timex2 = mean(data2,3);
    time2 = mean(epoch2Matlab(timeInt2(1,:)));
end

dv1 = datevec(time1);
dv2 = datevec(time2);

% Convert to world coordinates
heading = results.heading-rotation;
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = (xdom + x0);
ydom = (ydom + y0);
vec = axisLimits(1):axisLimits(2);

%% find peaks
[peaks1,peakIdx1] = findpeaks(AST1(distanceFromPI,:),'MinPeakWidth',50);
[~,sortedPeakIdx1] = sort(peaks1,'descend');
maxPeakIdx1 = sortedPeakIdx1(1:6);

[peaks2,peakIdx2] = findpeaks(AST2(distanceFromPI,:),'MinPeakWidth',50);
[~,sortedPeakIdx2] = sort(peaks2,'descend');
maxPeakIdx2 = sortedPeakIdx2(1:9);

% plot
figure(1)
subplot(1,2,1)
plot(AST1(distanceFromPI,:),yC, 'b','LineWidth',2)
hold on
plot(zeros(size(yC)),yC,'k-.')
plot(AST1(distanceFromPI,peakIdx1(maxPeakIdx1)),yC(peakIdx1(maxPeakIdx1)),'ro')
% set (gca,'Xdir','reverse')
% plot(AST(peakIdx(maxPeakIdx)),yC(peakIdx(maxPeakIdx)),'ro')
ttl = [startTime1 ' - ' endTime1];
title(['Mean intensity anomaly ' startTime1 '-' endTime1])
xlabel('Intensity anomaly')
ylabel('Alongshore y (m)')
set(gca,'Xdir','reverse')
% legend(ttl)

hAxes = subplot(1,2,2);
pcolor(xdom,ydom,timex1)
shading flat; axis image;
hold on
% set (gca,'Ydir','reverse')
axis(axisLimits)
ylim = get( hAxes, 'Ylim' );
% plot(yC,xC(round(AST1(SZEdge,:))),'b','LineWidth',2)
% plot(yC,xC(round(AST1(SZEdge,:)))-100,'b','LineWidth',2)
for i = 1:length(maxPeakIdx1)
    plot([yC(peakIdx1(maxPeakIdx1(i))) yC(peakIdx1(maxPeakIdx1(i)))],ylim,'b-','linewidth',1.5)
end

colormap(hot)
caxis([10 150])
axis(axisLimits)
ylabel('Cross-shore x (m)'); xlabel('Alongshore y (m)');
ttl = [num2str(dv1(1)) num2str(dv1(2),'%02i') num2str(dv1(3),'%02i')...
    ' - ' num2str(dv1(4),'%02i') ':' num2str(dv1(5),'%02i') ':'...
    num2str(round(dv1(6)),'%02i') ' UTC'];
title(ttl)
% colorbar


% plot
figure(2)
subplot(1,2,1)
plot(AST2(distanceFromPI,:),yC,'b','LineWidth',2)
hold on
plot(AST2(distanceFromPI,peakIdx2(maxPeakIdx2)),yC(peakIdx2(maxPeakIdx2)),'ro')
plot(zeros(size(yC)),yC,'k-.')
ttl = [startTime2 ' - ' endTime2];
title(['Mean intensity anomaly ' startTime2 '-' endTime2])
xlabel('Intensity anomaly')
ylabel('Alongshore y (m)')
set(gca,'Xdir','reverse')
axis([-15 15 -1000 1000])
% legend(ttl)

hAxes = subplot(1,2,2);
pcolor(xdom,ydom,timex2)
shading flat; axis image;
hold on
% plot(yC,xC(round(AST2(SZEdge,:))),'b','LineWidth',2)
% plot(yC,xC(round(AST2(SZEdge,:)))-100,'b','LineWidth',2)
axis(axisLimits)
xlim = get( hAxes, 'Xlim' );
for i = 1:length(maxPeakIdx2)
    plot(xlim, [yC(peakIdx2(maxPeakIdx2(i))) yC(peakIdx2(maxPeakIdx2(i)))],'b-','linewidth',1.5)
end
% set (gca,'Ydir','reverse')

colormap(hot)
caxis([30 210])
axis(axisLimits)
ylabel('Cross-shore x (m)'); xlabel('Alongshore y (m)');
ttl = [num2str(dv2(1)) num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')...
    ' - ' num2str(dv2(4),'%02i') ':' num2str(dv2(5),'%02i') ':'...
    num2str(round(dv2(6)),'%02i') ' UTC'];
title(ttl)
% colorbar


% plot
figure(3)
subplot(2,1,1)
plot(yC,AST1(distanceFromPI,:).*1.5,'b','LineWidth',2)
hold on
plot(yC,AST2(distanceFromPI,:),'k','LineWidth',2)
legend('Sept 1-10','Oct 1-10')
plot(yC,zeros(size(yC)),'k-.')
ttl = [startTime2 ' - ' endTime2];
title(['Mean intensity anomaly ' startTime2 '-' endTime2])
ylabel('Intensity anomaly')
xlabel('Alongshore y (m)')
% legend(ttl)

hAxes = subplot(2,1,2);
pcolor(ydom,xdom,timex2)
shading flat; axis image;
hold on
% plot(yC,xC(round(AST2(SZEdge,:))),'b','LineWidth',2)
% plot(yC,xC(round(AST2(SZEdge,:)))-100,'b','LineWidth',2)
set (gca,'Ydir','reverse')
axis(axisLimits)
xlim = get( hAxes, 'Xlim' );
colormap(hot)
caxis([10 150])
axis(axisLimits)
ylabel('Cross-shore x (m)'); xlabel('Alongshore y (m)');
ttl = [num2str(dv2(1)) num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')...
    ' - ' num2str(dv2(4),'%02i') ':' num2str(dv2(5),'%02i') ':'...
    num2str(round(dv2(6)),'%02i') ' UTC'];
title(ttl)
% colorbar