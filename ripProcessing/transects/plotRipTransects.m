% plotAlongshoreTransects
% 10/7/2017

clear all; %close all; 

Hub = 'F:\';
files = dir('F:\guadalupe\postprocessed\alongshoreTransectMatrix');
saveDir = [Hub 'guadalupe\postprocessed\alongshoreTransectMatrix'];

startTime = '20170901_0000';
endTime = '20170915_0000';
baseDir = [Hub 'guadalupe\postprocessed\alongshoreTransectMatrix\'];

if strcmp(startTime(7:8),endTime(7:8))
    fn{1} = [baseDir startTime(1:4) '-' startTime(5:6) '-' startTime(7:8) '.mat'];
else
    days = str2num(startTime(7:8)):str2num(endTime(7:8));
    for dd = 1:length(days)
        fn{dd} = [baseDir startTime(1:4) '-' startTime(5:6) '-' num2str(dd,'%02d') '.mat'];
        fn{dd} = [baseDir endTime(1:4) '-' endTime(5:6) '-' num2str(dd,'%02d') '.mat'];
    end
end

dn1 = datenum([str2num(startTime(1:4)) str2num(startTime(5:6)) str2num(startTime(7:8))...
    str2num(startTime(10:11)) str2num(startTime(12:13)) 0]);
dnEnd = datenum([str2num(endTime(1:4)) str2num(endTime(5:6)) str2num(endTime(7:8))...
    str2num(endTime(10:11)) str2num(endTime(12:13)) 0]);

% Load transects
transectMatrix600 = []; timesAll = []; transectMatrix650 = []; transectMatrix700 = [];
for i = 1:numel(fn)
    load(fn{i})
    transectMatrix600 = vertcat(transectMatrix600,txIMat_600);
    transectMatrix650 = vertcat(transectMatrix650,txIMat_650);
    transectMatrix700 = vertcat(transectMatrix700,txIMat_700);
    timesAll = horzcat(timesAll,txDn);
end
times = timesAll(timesAll>dn1 & timesAll<dnEnd);
transectMatrix600 = transectMatrix600(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix650 = transectMatrix650(timesAll>dn1 & timesAll<dnEnd,:);
transectMatrix700 = transectMatrix700(timesAll>dn1 & timesAll<dnEnd,:);

%% Plot transect
fig1=figure;
hold on
% subplot(2,1,1)
pcolor(xC,times,transectMatrix600)
shading flat
colormap hot
datetick('y')
ylabel('Time [UTC]')
xlabel('Y [m]')
caxis([10 230])
title('Alongshore intensity transect x = 600 m')
axis tight
figTitle1 = [saveDir '/' startTime '_' endTime];
print(fig1,figTitle1,'-dpng')

fig2 = figure;
% subplot(2,1,2)
pcolor(xC,times,transectMatrix650)
shading flat
colormap hot
datetick('y')
ylabel('Time [UTC]')
xlabel('Y [m]')
caxis([10 230])
title('Alongshore intensity transect x = 650 m')
axis tight
figTitle2 = [saveDir '/' startTime '_' endTime];
print(fig2,figTitle2,'-dpng')

fig3 = figure;
% subplot(2,1,2)
pcolor(xC,times,transectMatrix700)
shading flat
colormap hot
datetick('y')
ylabel('Time [UTC]')
xlabel('Y [m]')
caxis([10 230])
title('Alongshore intensity transect x = 700 m')
axis tight
figTitle3 = [saveDir '/' startTime '_' endTime];
print(fig3,figTitle3,'-dpng')


