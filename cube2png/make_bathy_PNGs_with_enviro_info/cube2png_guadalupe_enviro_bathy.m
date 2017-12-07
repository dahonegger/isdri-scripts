function cube2png_guadalupe_enviro(cubeFile,pngFile)
% Originally 'cube2timex.m' by David Honegger 
% Updated by Alex Simpson to show tide, wind, discharge data 
% Updated by Annika O'Dea to show waves instead of discharge at the
% Guadalupe Dunes site
% 9/17/2017

% User options: leave empty [] for Matlab auto-sets
colorAxLimits           = [0 150]; % This gets updated for bad data periods (~May 28-30)
axisLimits              = [-13 5 -12 13]; % Full, In kilometers
plottingDecimation      = [5 1]; % For faster plotting, make this [2 1] or higher

% User overrides: leave empty [] otherwise
userHeading             = [];                      % Use this heading instead of results.heading
userOriginXY            = [0 0];                    % Use this origin for meter-unit scale
userOriginLonLat        = [];   % Use these lat-lon origin coords

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
if (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 < 700
    timexCell{1} = timex;
    timeIntCell{1} = mean(timeInt);
    pngFileCell{1} = pngFile;
elseif (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 > 700
    load(cubeFile,'data')
    ii = 1;
    for i = 1:64:(floor(size(data,3)/64))*64
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
    [lat0,lon0] = UTM2ll(results.YOrigin,results.XOrigin,str2double(results.UTMZone(1:2)));
end

% Convert to world coordinates
[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);
xdom = xdom + x0;
ydom = ydom + y0;

nowTime = epoch2Matlab(nanmean(timeInt(:))); % UTC

% Load wind data from wind station file
[dnWind,magWind,dirWind] = loadWindNDBC('MetData_NDBC46011.txt', nowTime);

% Load wave data from wave station file
[dnWaves,Hs,dirWaves] = loadWavesNDBC('WaveData_NDBC46011.txt');

% Load tide data from tide station file
[dnTides,waterSurfaceElevation] = loadTidesNOAA('TideData_NOAA9411406.txt');
waterSurfaceElevation(waterSurfaceElevation == -999) = nan;

% Load contour file
bathy = load('bathyContours.mat');
for i = 1:numel(bathy.x)
    [bathy.N{i}  bathy.E{i}] = ll2UTM(bathy.y{i}, bathy.x{i});
    bathy.Ykm{i} = (bathy.N{i} - results.YOrigin)./1000;
    bathy.Xkm{i} = (bathy.E{i} - results.XOrigin)./1000;
end

for IMAGEINDEX = 1:numel(timexCell)
    timex = timexCell{IMAGEINDEX};
    timeInt = timeIntCell{IMAGEINDEX}; 
    pngFile = pngFileCell{IMAGEINDEX};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup
fig = figure('visible','off');
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 12.8 7.2];
fig.Units = 'pixels';
fig.Position = [0 0 1280 720];
axRad = axes('position',[-0.1081    0.1167    0.7750    0.8150]);
axTide = axes('position',[0.5419    0.7269    0.4200    0.2053],'fontsize',8);
axWind = axes('position',[0.6696    0.4000    0.1544    0.2547],'fontsize',8);
axWaves = axes('position',[0.5452    0.1358    0.4169    0.2011],'fontsize',8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RADAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axRad)
di = plottingDecimation(1);
dj = plottingDecimation(2);
pcolor(xdom(1:di:end,1:dj:end)/1e3,ydom(1:di:end,1:dj:end)/1e3,...
    timex(1:di:end,1:dj:end));
hold on
shading interp
axis image
colormap(hot)
if ~isempty(axisLimits)
axis(axisLimits)
end
if ~isempty(colorAxLimits)
caxis(colorAxLimits)
end
grid on
axRad.XTick = axRad.XTick(1):2:axRad.XTick(end);
axRad.YTick = axRad.YTick(1):2:axRad.YTick(end);
xlabel('[km]','fontsize',14,'interpreter','latex')
ylabel('[km]','fontsize',14,'interpreter','latex')
axRad.TickLabelInterpreter = 'latex';
runLength = timeInt(end,end)-timeInt(1,1);
titleLine1 = sprintf('\\makebox[4in][c]{Guadalupe X-band Radar: %2.1f min Exposure}',runLength/60);
titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s PDT)}',datestr(epoch2Matlab(nanmean(timeInt(:))),'yyyy-mmm-dd HH:MM:SS'),datestr(epoch2Matlab(nanmean(timeInt(:)))-7/24,'HH:MM:SS'));
% titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s EDT)}',datestr(nowTime+4/24,'yyyy-mmm-dd HH:MM:SS'),datestr(nowTime,'HH:MM:SS'));
title({titleLine1,titleLine2},...
'fontsize',14,'interpreter','latex');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADD BATHY CONTOURS %%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axRad)
depths = [0 -30 -50 -100];
for i = 1:numel(depths)
    tmp = depths(i);
    for n = find(bathy.z==tmp) 
       plot(bathy.Xkm{n},bathy.Ykm{n},'color',[.25 .25 .25],'linewidth',1)
    end
end
text(0,-11.6,'0m','color',[.25 .25 .25],'interpreter','latex')
text(-6,-11.6,'-30m','color',[.25 .25 .25],'interpreter','latex')
text(-8.8,-11.6,'-50m','color',[.25 .25 .25],'interpreter','latex')
text(-12,-11.6,'-100m','color',[.25 .25 .25],'interpreter','latex')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TIDE SIGNAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axTide)
cla(axTide)
hold(axTide,'on')
% h1=plot([nowTime-4 nowTime+4],[0 0],'-','color',[.75 .75 .75]);
h2=plot([nowTime nowTime],[-10 10],'-','color',[.5 .5 .5],'linewidth',2);
xlim([nowTime-4 nowTime+4])
set(axTide,'xtick',fix([nowTime-4:nowTime+4]))
set(axTide,'xticklabel','')
datetick('x','mmm-dd','keeplimits','keepticks')    
hy1 = ylabel('WL [m]','fontsize',11,'interpreter','latex');
tmp1 = get(hy1,'position');
set(hy1,'position',[tmp1(1)+1/50 tmp1(2:3)])
ylim([-1 3])
title('Water surface elevation from MLLW','fontsize',14,'interpreter','latex');
axTide.TickLabelInterpreter = 'latex';
plot(dnTides, waterSurfaceElevation,'k','linewidth',2);    
box on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WIND %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axWind);
cla(axWind)
% Create Circle
th = 0:0.01:3*pi;
xcircle = cos(th);
ycircle = sin(th);
plot(axWind,xcircle,ycircle,'-k','linewidth',1.25);hold on
% plot(axWind,.75*xcircle,.75*ycircle,'-','color',[.5 .5 .5],'linewidth',1.25)
axis image;axis([-1.05 1.05 -1.05 1.05])
[uWind vWind] = pol2cart((90-dirWind)*pi/180, 1); 
arrow([uWind vWind],[0 0],'baseangle',45,'width',magWind,'tipangle',25,'facecolor','red','edgecolor','red');
[uText vText] = pol2cart((90-180-dirWind)*pi/180,0.28); %position text off tip of arrow
text(uText,vText,[num2str(round(magWind,1)),' m/s'],'horizontalalignment','center','interpreter','latex')
set(axWind,'xtick',[],'ytick',[],'xcolor','w','ycolor','w')
title('Wind','fontsize',14,'interpreter','latex')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WAVE HEIGHT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(fig,'currentaxes',axWaves)
cla(axWaves)
hold(axWaves,'on')
plot(dnWaves,Hs,'-k','linewidth',2) % plots wave height
% plot(dnWaves(~isnan(rawWaves)),rawWaves(~isnan(rawWaves)),'-b','linewidth',1)
% plot(dnWaves(~isnan(trWaves)),trWaves(~isnan(trWaves)),'-k','linewidth',2)
plot([nowTime nowTime],[0 4],'-','color',[.5 .5 .5],'linewidth',2);
xlim([nowTime-4 nowTime+4])
ylim([0 4])
set(axWaves,'xtick',fix([nowTime-4:nowTime+4]))
set(axWaves,'xticklabel','')   
datetick('x','mmm-dd','keeplimits','keepticks')    
hy1 = ylabel('Hs [m]','fontsize',11,'interpreter','latex');
tmp1 = get(hy1,'position');
set(hy1,'position',[tmp1(1)+1/50 tmp1(2:3)])
axWaves.TickLabelInterpreter = 'latex';
box on
title('Significant wave height','fontsize',14,'interpreter','latex')
 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE & CLOSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print(fig,'-dpng','-r100',pngFile)
close(fig)

end