% plot_anomaly_transects.m
% 1/24/2018


addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository
load('C:\Data\ISDRI\isdri-scripts\ripProcessing\transects\cMap.mat')

%% load transects
startTime = '20171010';
endTime = '20171020';

baseDir = 'E:\guadalupe\postprocessed\alongshoreTransectMatrix\ANOMALY_TRANSECTS\';
Loess = 'Loess_800\';
matName100 = [baseDir Loess startTime '_' endTime '_TMat100.mat'];
matName150 = [baseDir Loess startTime '_' endTime '_TMat150.mat'];
matName200 = [baseDir Loess startTime '_' endTime '_TMat200.mat'];
timeMat = [baseDir startTime '_' endTime '_time.mat'];

load(timeMat)
load(matName200)

yC = -800:800;
% AST = mean(TMat200(260:end,:) ,1);
AST = mean(TMat200 ,1);

figure(1)
plot(AST,yC)
hold on
ttl = [startTime ' - ' endTime];
title('Average intensity anomaly')
xlabel('Intensity anomaly')
ylabel('Alongshore y (m)')
% legend(ttl)


% % figure,
% % pcolor(times,yC,TMat100')
% % shading flat
% % colormap(cMap)
% % caxis([-80 80])
% % datetick('x')
% % colorbar
% % caxis([-100 100])
% % xlabel('Time'); ylabel('Alongshore y (m)')
% % ttl = [startTime ' - ' endTime ', 100 m from peak intensity'];
% % title(ttl)
% % 
% % %% 
% % id = 309;
% % MASK1 = datenum([dv(id,1),dv(id,2),dv(id,3),dv(id,4),dv(id,5),dv(id,6)]);
% % id = id+1;
% % MASK2 = datenum([dv(id,1),dv(id,2),dv(id,3),dv(id,4),dv(id,5),dv(id,6)]);
% % timeMask = MASK1:1/24:MASK2;
% % yMask = zeros(length(yC),length(timeMask));
% % hold on
% % pcolor(timeMask,yC,yMask)
% % shading flat
% % xlabel('Time')
