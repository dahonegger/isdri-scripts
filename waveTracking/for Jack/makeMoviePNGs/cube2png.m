function cube2png(cubeFile,pngFile)
% Originally 'cube2timex.m' by David Honegger 
% Updated by Alex Simpson to show tide, wind, discharge data 
addpath(genpath('C:\Users\user\Desktop\isdri-scripts\util'))
% User options: leave empty [] for Matlab auto-sets
colorAxLimits           = [0 150]; 
axisLimits              = [-13 5 -12 13];% Full, In kilometers
plottingDecimation      = [5 1]; % For faster plotting, make this [2 1] or higher

% User overrides: leave empty [] otherwise
userHeading             = [];                      % Use this heading instead of results.heading
userOriginXY            = [0 0];                    % Use this origin for meter-unit scale
userOriginLonLat        = [34.75884 -120.63052];   % Use these lat-lon origin coords

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOAD DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load radar data
load(cubeFile,'Azi','Rg','results','timex','timeInt') % 6/16/17 with new process scheme, 'timex' available
% [a, MSGID] = lastwarn();warning('off', MSGID);
if ~exist('timex','var') || isempty(timex)
    load(cubeFile,'data')
    timex = double(nanmean(data,3));
else
end

% Handle long runs (e.g. 18 minutes
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

    
% Implement user overrides
if ~isempty(userHeading)
    heading = userHeading;
else
    heading = results.heading;
end
if ~isempty(userOriginXY)
    x0 = userOriginXY(1);
    y0 = userOriginXY(2);
else
    x0 = results.XOrigin;
    y0 = results.YOrigin;
end
if ~isempty(userOriginLonLat)
    lon0 = userOriginLonLat(1);
    lat0 = userOriginLonLat(2);
else
    [lat0,lon0] = UTMtoll(results.YOrigin,results.XOrigin,str2double(results.UTMZone(1:2)));
end

% Convert to world coordinates
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = xdom + x0;
ydom = ydom + y0;

nowTime = epoch2Matlab(nanmean(timeInt(:))); % UTC
if nowTime < datenum(2017,05,26,20,0,0)
    colorAxLimits = [10 125]; % for before uniform brighness increase
elseif nowTime >= datenum(2017,05,26,20,0,0) && nowTime < datenum(2017,05,29,20,0,0)
    colorAxLimits = [25 190];
elseif nowTime >= datenum(2017,05,29,20,0,0) && nowTime < datenum(2017,05,31,0,0,0)
    return
else
end

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
bathy = load('bathyContours.mat');
% for i = 1:numel(bathy.x)
%     [bathy.E{i}  bathy.N{i}] = ll2utm(bathy.y{i}, bathy.x{i});
%     bathy.Ykm{i} = (bathy.N{i} - results.YOrigin)./1000;
%     bathy.Xkm{i} = (bathy.E{i} - results.XOrigin)./1000;
% end

bathy = load('contours_for_Jack.mat');
for i = 1:numel(bathy.x)
    [bathy.E{i}  bathy.N{i}] = ll2utm(bathy.y{i}, bathy.x{i});
    bathy.Ykm{i} = (bathy.N{i} - results.YOrigin)./1000;
    bathy.Xkm{i} = (bathy.E{i} - results.XOrigin)./1000;
end


%% %% PLOT %%%%%
for IMAGEINDEX = 1:numel(timexCell)
    timex = timexCell{IMAGEINDEX};
    timeInt = timeIntCell{IMAGEINDEX}; 
    pngFile = pngFileCell{IMAGEINDEX};
% setup
fig = figure('visible','off');
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12.8 7.2];
fig.Units = 'pixels';
fig.Position = [106  156 576  596];
axRad = axes('position',[0.1140    0.0980    0.7842    0.8061]);
% axTide = axes('position',[0.5419    0.7269    0.4200    0.2053],'fontsize',8);
%%%% SAVE & CLOSE %%%%

set(fig,'currentaxes',axRad)
di = plottingDecimation(1);
dj = plottingDecimation(2);
pcolor(xdom(1:di:end,1:dj:end)/1e3,ydom(1:di:end,1:dj:end)/1e3,...
    timex(1:di:end,1:dj:end));
hold on
shading interp
axis image
plot(xdom(:,155),ydom(:,155),'-c')
colormap(hot)
if ~isempty(axisLimits)
axis(axisLimits)
end
if ~isempty(colorAxLimits)
caxis(colorAxLimits)
end
grid on
% axRad.XTick = axRad.XTick(1):0.5:axRad.XTick(end);
% axRad.YTick = axRad.YTick(1):0.5:axRad.YTick(end);
xlabel('[km]','fontsize',14,'interpreter','latex')
ylabel('[km]','fontsize',14,'interpreter','latex')
axRad.TickLabelInterpreter = 'latex';
runLength = timeInt(end,end)-timeInt(1,1);
titleLine1 = sprintf('\\makebox[4in][c]{Guadalupe X-band Radar: %2.1f min Exposure}',runLength/60);
titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s PST)}',datestr(epoch2Matlab(nanmean(timeInt(:))),'yyyy-mmm-dd HH:MM:SS'),datestr(epoch2Matlab(nanmean(timeInt(:)))-7/24,'HH:MM:SS'));
% titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s EDT)}',datestr(nowTime+4/24,'yyyy-mmm-dd HH:MM:SS'),datestr(nowTime,'HH:MM:SS'));
title({titleLine1,titleLine2},...
'fontsize',14,'interpreter','latex');

% add array and bathy
plot(X_Oc./1000,Y_Oc./1000,'g.','MarkerSize',20)

% plot bathy
depths = [0 -10 -17 -25 -32 -40 -50];
for i = 1:numel(depths)
    tmp = depths(i);
    for n = find(bathy.z==tmp) 
       plot(bathy.Xkm{n},bathy.Ykm{n},'color',[.25 .25 .25],'linewidth',1)
    end
end


% text(0,-11.6,'0m','color',[.25 .25 .25],'interpreter','latex')
% text(-6,-11.6,'-30m','color',[.25 .25 .25],'interpreter','latex')
text(-8.8,-11.6,'-50m','color',[.25 .25 .25],'interpreter','latex')
% text(-12,-11.6,'-100m','color',[.25 .25 .25],'interpreter','latex')

print(fig,'-dpng','-r100',pngFile)
close(fig)
end
