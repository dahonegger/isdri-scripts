% plot_anomaly_transects.m
% 1/24/2018
clear variables

startTime = '20171001';
endTime = '20171010';
Loess = 'Loess_1200_1000m\';
distanceFromPI = '200';
baseDir = 'E:\guadalupe\postprocessed\alongshoreTransectMatrix\ANOMALY_TRANSECTS\';

dnStart = datenum([str2num(startTime(1:4)),str2num(startTime(5:6)),str2num(startTime(7:8)),0,0,0]);
dnEnd = datenum([str2num(endTime(1:4)),str2num(endTime(5:6)),str2num(endTime(7:8)),0,0,0]);

addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository
load('C:\Data\ISDRI\isdri-scripts\ripProcessing\transects\cMap.mat')
% matFile = 'E:\guadalupe\processed\2017-09-02\Guadalupe_20172452035_pol.mat';
% matFile2 = 'E:\guadalupe\processed\2017-09-02\Guadalupe_20172452037_pol.mat';
% matFile3 = 'E:\guadalupe\processed\2017-09-02\Guadalupe_20172452039_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-09-05\Guadalupe_20172482149_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-09-07\Guadalupe_20172501821_pol.mat'; % THIS ONE
% matFile = 'E:\guadalupe\processed\2017-09-08\Guadalupe_20172511431_pol.mat';  % THIS ONE
% matFile = 'E:\guadalupe\processed\2017-09-30\Guadalupe_20172730815_pol.mat'; % THIS ONE
matFile = 'E:\guadalupe\processed\2017-10-04\Guadalupe_20172770335_pol.mat'; % THIS ONE
% matFile = 'E:\guadalupe\processed\2017-10-05\Guadalupe_20172780821_pol.mat'; 

load(matFile)
% data1= data; clear data;
% load(matFile2)
% data2 = data; clear data
% load(matFile3)
% data3 = data; clear data

%% load transects
matName = [baseDir Loess 'TMat' distanceFromPI '_all.mat'];
timeMat = [baseDir 'timesAll.mat'];

load(timeMat)
load(matName);
% if str2num(distanceFromPI) == 100; TMat = TMat100; 
% elseif str2num(distanceFromPI) == 150; TMat = TMat150;
% elseif str2num(distanceFromPI) == 200; TMat = TMat200;
% end

t = times(times>=dnStart & times<=dnEnd);
TM = TMat(times>=dnStart & times<=dnEnd,:);

yC = -1000:1000;

AST = mean(TM,1);
[peaks,peakIdx] = findpeaks(AST,'MinPeakWidth',50);
[~,sortedPeakIdx] = sort(peaks,'descend');
maxPeakIdx = sortedPeakIdx(1:3);

figure(1)
subplot(1,2,1)
plot(AST,yC,'b')
hold on
set (gca,'Xdir','reverse')
% plot(AST(peakIdx(maxPeakIdx)),yC(peakIdx(maxPeakIdx)),'ro')
ttl = [startTime ' - ' endTime];
title(['Mean intensity anomaly ' startTime '-' endTime])
xlabel('Intensity anomaly')
ylabel('Alongshore y (m)')
% legend(ttl)

%% radar image
% define parameters
numRots = 200;
startRot = size(data,3) - 201;
% startRot = size(data1,3) - 201;

% define parameters
rotation = 13;
x0 = 0;         % for local
y0 = 0;
axisLimits = [-1500 -500 -1000 1000];

% create timex
clear timex
% timex = mean(data(:,:,startRot:(numRots+startRot)),3);
% timex1 = mean(data1,3);
% timex2 = mean(data2,3);
% timex3 = mean(data3,3);
% timexAll = cat(3,timex1,timex2,timex3);
timex = mean(data,3);
% timex = mean(timexAll,3);
% time = mean(epoch2Matlab(timeInt(1,startRot:(numRots+startRot))));
time = mean(epoch2Matlab(timeInt(1,:)));
dv = datevec(time);

% Convert to world coordinates
heading = results.heading-rotation;
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = (xdom + x0);
ydom = (ydom + y0);
vec = axisLimits(1):axisLimits(2);

% plot
hAxes = subplot(1,2,2);
pcolor(xdom,ydom,timex)
shading flat; axis image;
hold on
axis(axisLimits)
xlim = get( hAxes, 'Xlim' );
% for i = 1:length(peakIdx)
%     plot(xlim,[yC(peakIdx(i)) yC(peakIdx(i))],'b-')
% end
% for i = 1:length(maxPeakIdx)
%     plot(xlim,[yC(peakIdx(maxPeakIdx(i))) yC(peakIdx(maxPeakIdx(i)))],'b-','linewidth',1.5)
% end
colormap(hot)
caxis([30 220])
axis(axisLimits)
xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)');
ttl = [num2str(dv(1)) num2str(dv(2),'%02i') num2str(dv(3),'%02i')...
    ' - ' num2str(dv(4),'%02i') ':' num2str(dv(5),'%02i') ':'...
    num2str(round(dv(6)),'%02i') ' UTC'];
title(ttl)
% colorbar