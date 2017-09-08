close all; clear all;

[yTide,dnTide] = loadXTide('Arguello_Point_elevations_2min.txt');


sunday=datenum('2017-09-03 00:00:00','yyyy-mm-dd HH:MM:SS');
for i = 1:8
[idxStart idxStart] = min(abs(dnTide-sunday));
[idxEnd idxEnd] = min(abs(dnTide-(sunday+6)));

figure(i); hold on;
plot(dnTide(idxStart:idxEnd),yTide(idxStart:idxEnd))
datetick('x','ddd mm/dd')
box on; grid on; axis tight;
ylim([-0.9 0.9])
% set(gca,'xtick',[dnTide(idxStart):0.5:dnTide(idxEnd)])


sunday = sunday+7;
end



% week2=datenum('2017-09-01 00:00:00','yyyy-mm-dd HH:MM:SS');