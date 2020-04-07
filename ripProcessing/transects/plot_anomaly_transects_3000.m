% plot_anomaly_transects.m
% 1/24/2018
clear variables

startTime = '20170901';
endTime = '20170910';
filter = 'doubleMovingAverage_3000m\';
distanceFromPI = 5; % 1=0m; 2=25m; 3=50m; 4=75m; 5=100m; 6=150 m
filtSize = '800';
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
matFile = 'E:\guadalupe\processed\2017-09-07\Guadalupe_20172501847_pol.mat';    % this is the one used for ONR meeting
% matFile = 'E:\guadalupe\processed\2017-09-06\Guadalupe_20172492255_pol.mat'; 
% matFile = 'E:\guadalupe\processed\2017-09-08\Guadalupe_20172511431_pol.mat';  % THIS ONE
% matFile = 'E:\guadalupe\processed\2017-09-30\Guadalupe_20172730815_pol.mat'; % THIS ONE
% matFile = 'E:\guadalupe\processed\2017-10-04\Guadalupe_20172770335_pol.mat'; % THIS ONE
% matFile = 'E:\guadalupe\processed\2017-10-05\Guadalupe_20172780821_pol.mat'; 

load(matFile)

%% load transects
matName = [baseDir filter startTime '_' endTime '_AST_' filtSize '.mat'];
load(matName);

yC = -3000:3000;

figure(1)
subplot(2,1,1)
plot(yC,AST(distanceFromPI,:), 'k')
hold on
plot(yC,zeros(size(yC)),'k-.')
% set (gca,'Xdir','reverse')
% plot(AST(peakIdx(maxPeakIdx)),yC(peakIdx(maxPeakIdx)),'ro')
ttl = [startTime ' - ' endTime];
title(['Mean intensity anomaly ' startTime '-' endTime])
ylabel('Intensity anomaly')
xlabel('Alongshore y (m)')
% legend(ttl)

%% radar image
% define parameters
numRots = 64;
% startRot = size(data,3) - 201;
startRot = 64*6;

% define parameters
rotation = 13;
x0 = 0;         % for local
y0 = 0;
axisLimits = [-3000 3000 -1500 -500 ];

% create timex
clear timex
% timex = mean(data(:,:,startRot:(numRots+startRot)),3);
% timex1 = mean(data1,3);
% timex2 = mean(data2,3);
% timex3 = mean(data3,3);
% timexAll = cat(3,timex1,timex2,timex3);
if size(data,3)>64
    timex = mean(data(:,:,startRot:(startRot+numRots)),3);
    time = mean(epoch2Matlab(timeInt(1,startRot:(startRot+numRots))));
else
    timex = mean(data,3);
    time = mean(epoch2Matlab(timeInt(1,:)));
end
% timex = mean(timexAll,3);
% time = mean(epoch2Matlab(timeInt(1,startRot:(numRots+startRot))));
% time = mean(epoch2Matlab(timeInt(1,:)));
dv = datevec(time);
% 
% Convert to world coordinates
heading = results.heading-rotation;
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = (xdom + x0);
ydom = (ydom + y0);
vec = axisLimits(1):axisLimits(2);

% plot
hAxes = subplot(2,1,2);
pcolor(ydom,xdom,timex)
shading flat; axis image;
hold on
set (gca,'Ydir','reverse')
axis(axisLimits)
xlim = get( hAxes, 'Xlim' );
% for i = 1:length(peakIdx)
%     plot(xlim,[yC(peakIdx(i)) yC(peakIdx(i))],'b-')
% end
% for i = 1:length(maxPeakIdx)
%     plot(xlim,[yC(peakIdx(maxPeakIdx(i))) yC(peakIdx(maxPeakIdx(i)))],'b-','linewidth',1.5)
% end
colormap(hot)
caxis([10 150])
axis(axisLimits)
ylabel('Cross-shore x (m)'); xlabel('Alongshore y (m)');
ttl = [num2str(dv(1)) num2str(dv(2),'%02i') num2str(dv(3),'%02i')...
    ' - ' num2str(dv(4),'%02i') ':' num2str(dv(5),'%02i') ':'...
    num2str(round(dv(6)),'%02i') ' UTC'];
title(ttl)
% colorbar