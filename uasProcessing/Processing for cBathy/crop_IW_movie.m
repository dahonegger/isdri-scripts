folder = dir('D:\guadalupe\processed\2017-09-12\*.mat');

for i = 420:numel(folder)
baseName = folder(i).name;
load(fullfile('D:\guadalupe\processed\2017-09-12',baseName));


x0 = results.XOrigin;
y0 = results.YOrigin;
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-results.heading);
[xdom,ydom] = pol2cart(TH,RG);
% xdom = xdom + x0;
% ydom = ydom + y0;

figure;hold on
% set(gcf,'visible','off')
pcolor(xdom,ydom,timex)
shading interp; colormap hot; axis image
title(datestr(epoch2Matlab(time(i))))
xlabel('X [m]');ylabel('Y [m]')
xlim([-4060 0])
ylim([-3046 1735])
set(gcf,'PaperPosition', [1.4 3.2 5.8 4.4])

print(['F:\uasData\09.12.17 Guadalupe Dunes (IW+rip)\radar\',baseName,'.png'],'-dpng','-r500')

close all
end