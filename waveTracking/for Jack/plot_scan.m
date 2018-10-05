close all; clear all;

%% load and prep radar scan
load('D:\guadalupe\processed\2017-09-10\Guadalupe_20172532015_pol.mat')
addpath('C:\Users\user\Desktop')
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-results.heading);
[xdom,ydom] = pol2cart(TH,RG);

x0 = results.XOrigin;     % for UTC
y0 = results.YOrigin;


pngFile = 'tmp';
if (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 < 142
    timexCell{1} = timex;
    timeIntCell{1} = mean(timeInt);
    pngFileCell{1} = pngFile;
elseif (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 > 142
    load(cubeFile,'data')
    ii = 1;
    for i = 1:64:(floor(size(data,3)/64))*64 - 64
        timexCell{ii} = double(mean(data(:,:,i:i+64),3));
        timeIntCell{ii} = timeInt(1,i:i+64);
        [path,fname,ext] = fileparts(pngFile);
        tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
        fname = [fname(1:17),tmp,'_pol_timex'];
        pngFileCell{ii} = fullfile(path,[fname,ext]);
        ii = ii+1;
    end
end


% xdom = (xdom + x0);
% ydom = (ydom + y0);

%% add Oceanus instruments
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

%% load bathy info 
bathy = load('contours_for_Jack.mat');
for i = 1:numel(bathy.x)
    [bathy.E{i}  bathy.N{i}] = ll2utm(bathy.y{i}, bathy.x{i});
    bathy.Ykm{i} = (bathy.N{i} - results.YOrigin)./1000;
    bathy.Xkm{i} = (bathy.E{i} - results.XOrigin)./1000;
end


%% make plot

figure; hold on

% radar
pcolor(xdom./1000,ydom./1000,timex)
shading interp
colormap hot
axis image
caxis([0 150])
% plot oceano array
plot(X_Oc./1000,Y_Oc./1000,'g.','MarkerSize',10)

% plot bathy
depths = [0 -10 -17 -25 -32 -40 -50];
for i = 1:numel(depths)
    tmp = depths(i);
    for n = find(bathy.z==tmp) 
       plot(bathy.Xkm{n},bathy.Ykm{n},'color',[.25 .25 .25],'linewidth',.8)
    end
end
% text(0,-11.6,'0m','color',[.25 .25 .25],'interpreter','latex')
% text(-6.2,-11.6,'-30m','color',[.25 .25 .25],'interpreter','latex')
text(-9,-11.6,'-50m','color',[.25 .25 .25],'interpreter','latex')
% text(-12,-11.6,'-100m','color',[.25 .25 .25],'interpreter','latex')

xlim([-13 5]); ylim([-12 13])

% plot(xdom(:,155),ydom(:,155),'-c')

runLength = timeInt(end,end)-timeInt(1,1);
titleLine1 = sprintf('\\makebox[4in][c]{Guadalupe X-band Radar: %2.1f min Exposure}',runLength/60);
titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s PDT)}',datestr(epoch2Matlab(nanmean(timeInt(:))),'yyyy-mmm-dd HH:MM:SS'),datestr(epoch2Matlab(nanmean(timeInt(:)))-7/24,'HH:MM:SS'));
% titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s EDT)}',datestr(nowTime+4/24,'yyyy-mmm-dd HH:MM:SS'),datestr(nowTime,'HH:MM:SS'));
title({titleLine1,titleLine2},...
'fontsize',10,'interpreter','latex');
box on
xlabel('X [km]','interpreter','latex');ylabel('Y [km]','interpreter','latex')

