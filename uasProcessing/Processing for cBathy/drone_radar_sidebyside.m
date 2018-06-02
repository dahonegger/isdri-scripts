close all; clear all;


drone_figure = openfig('F:\uasData\09.12.17 Guadalupe Dunes (IW+rip)\orthonormal\091217 23.06.19.000.fig');
load('D:\guadalupe\processed\2017-09-12\Guadalupe_20172552315_pol')

drone_xlim = drone_figure.CurrentAxes.XLim;
drone_ylim = drone_figure.CurrentAxes.YLim;

% Convert to world coordinates
    x0 = results.XOrigin;
    y0 = results.YOrigin;
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-results.heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = xdom + x0;
ydom = ydom + y0;

figure;hold on
pcolor(xdom/1000,ydom/1000,timex)
shading interp; colormap hot; axis image
v = [drone_xlim(1) drone_ylim(1);drone_xlim(2) drone_ylim(1);drone_xlim(2) drone_ylim(2);  drone_xlim(1) drone_ylim(2)];
f = [1 2 3 4];
patch('Faces',f,'Vertices',v,'EdgeColor','green','FaceColor','none','LineWidth',2);
box on
xlabel('E [km]'); ylabel('N [km]')
title(datestr(epoch2Matlab(time(1,1))))


%% former pairs 
% drone_figure = openfig('F:\uasData\09.12.17 Guadalupe Dunes (IW+rip)\orthonormal\091217 22.13.21.000.fig');
% load('D:\guadalupe\processed\2017-09-12\Guadalupe_20172552215_pol')

% drone_figure = openfig('F:\uasData\09.12.17 Guadalupe Dunes (IW+rip)\orthonormal\091217 23.06.19.000.fig');
% load('D:\guadalupe\processed\2017-09-12\Guadalupe_20172552319_pol')

% drone_figure = openfig('F:\uasData\09.12.17 Guadalupe Dunes (IW+rip)\orthonormal\091217 22.07.54.000.fig');
% load('D:\guadalupe\processed\2017-09-12\Guadalupe_20172552215_pol')

% drone_figure = openfig('F:\uasData\09.12.17 Guadalupe Dunes (IW+rip)\orthonormal\091217 22.48.10.000.fig');
% load('D:\guadalupe\processed\2017-09-12\Guadalupe_20172552249_pol')
