[yTide,dnTide] = loadXTide('Arguello_Point_elevations_2min.txt');
figure
hold on
plot(dnTide,yTide)


week1=datenum('2017-09-03 00:00:00','yyyy-mm-dd HH:MM:SS');

for i = 1:numel(weeks);
tmp = dnTide - weeks(i);
[idx idx] = min(abs(tmp));
figure
hold on



week2=datenum('2017-09-01 00:00:00','yyyy-mm-dd HH:MM:SS');