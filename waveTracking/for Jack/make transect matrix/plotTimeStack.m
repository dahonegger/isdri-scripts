close all; clear all;

% load time stack
load('2017-09-10_timestack.mat')

% plot time stack
[Time,Range] = meshgrid(txDn,Rg);
h=figure; hold on;
set(h,'units','inches')
set(h,'position',[0.8083 2.9917 13.7250 4.3750])
pcolor(Range,Time,txIMat)
shading interp
colormap hot
box on
set(gca,'xdir','reverse')
xlim([0 7000])
ylim([datenum('09-10 18:00','mm-dd HH:MM'), datenum('09-11 00:00','mm-dd HH:MM')])
datetick('y','mm-dd HH:MM')
axis tight
xlim([0 9000])
caxis([0 150])
ylabel('Time [Hr]'); xlabel('Range [km]')

% plot bathy 
hold on
for i = 1:numel(Zbathy)
    plot([Rbathy(i) Rbathy(i)],[txDn(1) txDn(end)],'-c')
    tx = text(Rbathy(i),txDn(150),[num2str(Zbathy(i)), ' m depth'],'color','c','verticalalignment','bottom');
    set(tx,'Rotation',90)
end

