close all; clear all; 

[num,txt,raw] = xlsread('D:\guadalupe\postprocessed\dailyTransectMatrix\NLIW_Observation_Times_Radar.xlsx');
times30 = datenum(txt(:,1))+7/24;
times50 = datenum(txt(1:16,2))+7/24;

[yTide,dnTide] = loadXTide('Arguello_Point_elevations_2min.txt');


%%

[idxStart idxStart] = min(abs(dnTide-datenum('9/12/17')));
[idxEnd idxEnd] = min(abs(dnTide-datenum('9/26/17')));
times = dnTide(idxStart:idxEnd); elevations = yTide(idxStart:idxEnd);
figure; hold on;
plot(times,elevations)
plot(times30,0,'*r')
plot(times50,0,'*k')
datetick('x','ddd mm/dd')
box on; grid on; axis tight;
ylim([-1 1])


% [idxHT1_30 idxHT1_30] = min(abs(dnTide - times30));
