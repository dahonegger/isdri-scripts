clear all; close all;
addpath(genpath('C:\Data\isdri\isdri-scripts'))

folder = dir('D:\guadalupe\processed\2017-09-12\*.mat');

for i = 420:numel(folder)
baseName = folder(i).name;
pngFile = baseName;
load(fullfile('D:\guadalupe\processed\2017-09-12',baseName));


% Handle long runs (e.g. 18 minutes
if (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 < 142
    timexCell{1} = timex;
    timeIntCell{1} = mean(timeInt);
    pngFileCell{1} = pngFile;
elseif (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 > 142
%     load(cubeFile,'data')
    ii = 1;
    for i = 1:64:(floor(size(data,3)/64))*64 - 64
        timexCell{ii} = double(mean(data(:,:,i:i+64),3));
        timeIntCell{ii} = timeInt(1,i:i+64);
        [path,fname,ext] = fileparts(pngFile);
        tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
        fname = [fname(1:17),tmp,'_pol'];
        pngFileCell{ii} = fullfile(path,[fname,ext]);
        ii = ii+1;
    end
end


x0 = results.XOrigin;
y0 = results.YOrigin;
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-results.heading);
[xdom,ydom] = pol2cart(TH,RG);
% xdom = xdom + x0;
% ydom = ydom + y0;


% find coordinates of Oceanus instruments
latOc = [35.00258 35.00163 35.01176 35.01115 34.9902 34.98947 35.00908 34.98753...
    35.02070 35.01995 35.00762 35.00715 34.99740 34.99693 34.98640 34.98600...
    34.97535 34.97482 34.99587 35.00597 34.98508 35.004242 35.004128];
lonOc = [-120.72263 -120.72283 -120.700133 -120.700333 -120.70285 -120.70277 -120.68142...
    -120.68477 -120.66370 -120.66448 -120.66800 -120.66792 -120.66953 -120.66967...
    -120.67275 -120.67297 -120.67553 -120.67555 -120.66152 -120.65537 -120.66212...
    -120.646192 -120.646586];

[xUTM_Oc, yUTM_Oc] = ll2utm(latOc,lonOc);
X_Oc = xUTM_Oc - results.XOrigin;
Y_Oc = yUTM_Oc - results.YOrigin;

%  Now NPS array
latNPS = [34.9826, 34.98152, 34.98113, 34.98035];
lonNPS = [-120.65731, -120.65164, -120.65024, -120.65172]; 
[xUTM_NPS, yUTM_NPS] = ll2utm(latNPS, lonNPS); 
X_NPS = xUTM_NPS - results.XOrigin;
Y_NPS = yUTM_NPS - results.YOrigin;


for IMAGEINDEX = 1:numel(timexCell)
    timex = timexCell{IMAGEINDEX};
    timeInt = timeIntCell{IMAGEINDEX}; 
    pngFile = pngFileCell{IMAGEINDEX};

figure;hold on
set(gcf,'visible','off')
pcolor(xdom,ydom,timex)
plot(X_Oc(1:2:end),Y_Oc(1:2:end),'g.','MarkerSize',15)
plot(X_NPS,Y_NPS,'w.','MarkerSize',10)
shading interp; colormap hot; axis image
title([datestr(epoch2Matlab(timeInt(1))),' UTC'])
xlabel('X [m]');ylabel('Y [m]')
xlim([-6060 0])
ylim([-3546 4735])
box on
set(gcf,'PaperPosition', [1.4 3.2 5.8 4.4])

print(['D:\guadalupe\postprocessed\Reading_Group_Figures\Sep11_IW_event\',pngFile,'.png'],'-dpng','-r500')


end
close all
end