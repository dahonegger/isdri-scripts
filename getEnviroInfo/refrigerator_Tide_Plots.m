close all; clear all;

[yTide,dnTide] = loadXTide('Arguello_Point_Sep3_2mos.txt');

dnTide = dnTide - 7/24; %convert to PDT

sunday=datenum('2017-09-03 00:00:00','yyyy-mm-dd HH:MM:SS');
for i = 1:8
[idxStart idxStart] = min(abs(dnTide-sunday));
[idxEnd idxEnd] = min(abs(dnTide-(sunday+7)));
elevations = yTide(idxStart:idxEnd);
times = dnTide(idxStart:idxEnd);

[pks,locs] = findpeaks(elevations);
[dips,dipslocs] = findpeaks(-1*elevations);
dips = -1*dips;

figure(i); hold on;
foo = gcf;
foo.Position = [0041.0    0313.8    1481.6    0443.2];
plot(times,elevations)
datetick('x','ddd mm/dd')
box on; grid on; axis tight;
ylim([-.1 1.8])
% set(gca,'xtick',[dnTide(idxStart):0.5:dnTide(idxEnd)])
for ii = 1:numel(pks)
    tx1=text(times(locs(ii)),elevations(locs(ii)),[num2str(pks(ii))]);
    tx1.HorizontalAlignment='center';tx1.VerticalAlignment='top';
    tx2=text(times(locs(ii)),elevations(locs(ii)),[datestr(times(locs(ii)),'mm-dd HH:MM')]);
    tx2.HorizontalAlignment='center';tx2.VerticalAlignment='bottom';
end
for jj = 1:numel(dips)    
    tx3=text(times(dipslocs(jj)),elevations(dipslocs(jj)),[num2str(dips(jj))]);
    tx3.HorizontalAlignment='center';tx3.VerticalAlignment='top';
    tx4=text(times(dipslocs(jj)),elevations(dipslocs(jj)),[datestr(times(dipslocs(jj)),'mm-dd HH:MM')]);
    tx4.HorizontalAlignment='center';tx4.VerticalAlignment='bottom';
end
ax=gca; ax.Position=[0.0491    0.1100    0.9212    0.8150];
print(foo,'-dpng','-r100',['tides_',num2str(i)])
close(foo)

sunday = sunday+7;
end



% week2=datenum('2017-09-01 00:00:00','yyyy-mm-dd HH:MM:SS');