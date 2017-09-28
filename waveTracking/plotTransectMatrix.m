% plotDailyTransectMatrix.m
% 9/27/2017

clear all; %close all; 

<<<<<<< HEAD

startTime = '20170921_1800';
endTime = '20170922_1200';
baseDir = 'E:\guadalupe\postprocessed\dailyTransectMatrix\falloffCorrected\';
=======
% times in UTC
startTime = '20170915_1400';
endTime = '20170916_1330';
baseDir = 'E:\guadalupe\postprocessed\dailyTransectMatrix\';
>>>>>>> e0754db503d5b2d133aa8db279b898111de695c7

if strcmp(startTime(7:8),endTime(7:8))
    fn{1} = [baseDir startTime(1:4) '-' startTime(5:6) '-' startTime(7:8) '.mat'];
else
    fn{1} = [baseDir startTime(1:4) '-' startTime(5:6) '-' startTime(7:8) '.mat'];
    fn{2} = [baseDir endTime(1:4) '-' endTime(5:6) '-' endTime(7:8) '.mat'];
end

dn1 = datenum([str2num(startTime(1:4)) str2num(startTime(5:6)) str2num(startTime(7:8))...
    str2num(startTime(10:11)) str2num(startTime(12:13)) 0]);
dnEnd = datenum([str2num(endTime(1:4)) str2num(endTime(5:6)) str2num(endTime(7:8))...
    str2num(endTime(10:11)) str2num(endTime(12:13)) 0]);

% Load transects
transectMatrix = []; timesAll = []; txLon_full = []; txLat_full = [];
for i = 1:numel(fn)
    load(fn{i})
    transectMatrix = horzcat(transectMatrix,txIMat);
    txLon_full = horzcat(txLon_full,txLon);
    txLat_full = horzcat(txLat_full,txLat);
    timesAll = horzcat(timesAll,txDn);
end
times = timesAll(timesAll>dn1 & timesAll<dnEnd);
transectMatrix = transectMatrix(:,timesAll>dn1 & timesAll<dnEnd);

% find edge
[edges,threshOut] = edge(transectMatrix,'canny');
edges2 = edge(transectMatrix, 'canny', [threshOut(1)*2.5, threshOut(2)*2.5]);
figure,
pcolor(times,Rg,double(edges2))
shading flat

%% Plot transect
fig3=figure;
hold on
pcolor(times,txLon',transectMatrix)
shading flat
colormap hot
datetick('x','mm/dd HH:MM','keepticks')
set(gca,'Ydir','reverse')
xlabel('Time [UTC]')
ylabel('X [m]')
% xlim([0 11000])
axis tight
hold on

%% add contour locations
contours = load([baseDir 'contour_pts.mat']);
plot([dn1,dnEnd],[contours.cont30.Position(1) contours.cont30.Position(1)])
plot([dn1,dnEnd],[contours.cont50.Position(1) contours.cont50.Position(1)])
% plot([dn1,dnEnd],[contours.cont100.Position(1) contours.cont100.Position(1)])

%%
% [x y] = ginput(10); 
% 
% %% find indices 
% % first axis limits:
% [axislimit axislimit] = min(abs(Rg-11000));
% 
% for i = 1:2:numel(x)-1
% [a1x a1x]= min(abs(Rg-x(i))); [a1y a1y] = min(abs(times-y(i))); 
% [a2x a2x] = min(abs(Rg- x(i+1))); [a2y a2y] = min(abs(times-y(i+1))); 
% avel = (Rg(a1x)-Rg(a2x))/((times(a2y)-times(a1y))*24*60*60);
% a1x = PlotLon(a1x); a1y = times(a1y); a2x = PlotLon(a2x); a2y = times(a2y);
% 
% Xindices(i) = a1x; Xindices(i+1) = a2x;
% Yindices(i) = a1y; Yindices(i+1) = a2y;
% speed(i) = round(avel,2);
% speed(i+1) = 0;
% 
% end
% 
% % depth contour
% long30m = dms2degrees([120, 41, 6]);
% long50m = dms2degrees([120, 43, 19]);
% 
% %%
% fig2=figure;
% set(fig2,'position',[0081.8   0149.0    1268.0    0612.8])
% axLong = axes('position',[0.1003    0.2285    0.8637    0.7050]);
% axRange = axes('position',[0.1003    0.1058    0.8637    0.0396]);
% 
% set(fig2,'currentaxes',axLong)
% hold on
% pcolor(PlotLon,plotDN_lon,transectMat(:,380:923))
% shading flat
% colormap hot
% caxis([0 200])
% datetick('y','mm/dd HH:MM')
% xlabel('Longitude [West]')
% ylabel('Time [PST]')
% set(gca,'XDir','reverse')
% axis tight
% title(['Intensity thru time along Latitude = ',num2str(mean(txLon_full))])
% 
% for i = 1:2:numel(Xindices)-1
% plot([Xindices(i) Xindices(i+1)],[Yindices(i) Yindices(i+1)],'-w'); text(((Xindices(i)+Xindices(i+1))/2), ((Yindices(i)+Yindices(i+1))/2),[num2str(speed(i)),' m/s'],'color','w','horizontalalignment','left','verticalalignment','top');
% end 
% 
% hold on
% plot([long30m long30m],[times(1) times(end)],'-c')
% tx1 = text(long30m,times(440),'30 m depth','color','c','verticalalignment','bottom'); set(tx1,'Rotation',90)
% plot([long50m long50m],[times(1) times(end)],'-c')
% tx2 = text(long50m,times(440),'50 m depth','color','c','verticalalignment','bottom');set(tx2,'Rotation',90)
% 
% set(fig2,'currentaxes',axRange)
% plot([Rg(1) Rg(end)],[1 1],'-w')
% ylim([0 1])
% set(gca,'XDir','reverse')
% % xlim([0 11000])
% xlabel('Range [m]')
% axis tight
% % set(axRange,'color','none')
% set(axRange,'ytick',[])
% box off