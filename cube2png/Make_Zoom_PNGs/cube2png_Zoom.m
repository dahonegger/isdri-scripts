function cube2png_Zoom(cubeFile,pngFile)
% Originally 'cube2timex.m' by David Honegger 
% Updated by Alex Simpson to show tide, wind, discharge data 
addpath(genpath('C:\Users\user\Desktop\isdri-scripts\util'))
% User options: leave empty [] for Matlab auto-sets
colorAxLimits           = [15 225]; 
axisLimits              = [-7 7 -7 7]; % Full, In kilometers
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

if (epoch2Matlab(timeInt(numel(timeInt)))-epoch2Matlab(timeInt(1))).*24.*60.*60 < 120
%%%% PLOT %%%%%
% setup
fig = figure('visible','off');
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 10];
fig.Units = 'pixels';
fig.Position = [106.6000  155.4000  575.2000  596.0000];
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
colormap(hot)
if ~isempty(axisLimits)
axis(axisLimits)
end
if ~isempty(colorAxLimits)
caxis(colorAxLimits)
end
grid on
axRad.XTick = axRad.XTick(1):0.5:axRad.XTick(end);
axRad.YTick = axRad.YTick(1):0.5:axRad.YTick(end);
xlabel('[km]','fontsize',14,'interpreter','latex')
ylabel('[km]','fontsize',14,'interpreter','latex')
axRad.TickLabelInterpreter = 'latex';
runLength = timeInt(end,end)-timeInt(1,1);
titleLine1 = sprintf('\\makebox[4in][c]{Guadalupe X-band Radar: %2.1f min Exposure}',runLength/60);
titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s PDT)}',datestr(epoch2Matlab(nanmean(timeInt(:))),'yyyy-mmm-dd HH:MM:SS'),datestr(epoch2Matlab(nanmean(timeInt(:)))-7/24,'HH:MM:SS'));
% titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s EDT)}',datestr(nowTime+4/24,'yyyy-mmm-dd HH:MM:SS'),datestr(nowTime,'HH:MM:SS'));
title({titleLine1,titleLine2},...
'fontsize',14,'interpreter','latex');
xlim([-2.2 0]); ylim([-2.2 2.2])
print(fig,'-dpng','-r100',pngFile)
close(fig)

else
    load(cubeFile,'data')
    for i = 1:8
        tmp = data(:,:,((i-1)*64)+1:i*64);
        timex = double(mean(tmp,3));
        
        
        %%%% PLOT %%%%%
% setup
fig = figure('visible','off');
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 10];
fig.Units = 'pixels';
fig.Position = [106.6000  155.4000  575.2000  596.0000];
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
colormap(hot)
if ~isempty(axisLimits)
axis(axisLimits)
end
if ~isempty(colorAxLimits)
caxis(colorAxLimits)
end
grid on
axRad.XTick = axRad.XTick(1):0.5:axRad.XTick(end);
axRad.YTick = axRad.YTick(1):0.5:axRad.YTick(end);
xlabel('[km]','fontsize',14,'interpreter','latex')
ylabel('[km]','fontsize',14,'interpreter','latex')
axRad.TickLabelInterpreter = 'latex';
runLength = timeInt(end,end)-timeInt(1,1);
titleLine1 = sprintf('\\makebox[4in][c]{Guadalupe X-band Radar: %2.1f min Exposure}',1.4);
titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s PDT)}',datestr(epoch2Matlab(nanmean(timeInt(1,((i-1)*64)+1:i*64))),'yyyy-mmm-dd HH:MM:SS'),datestr(epoch2Matlab(nanmean(timeInt(1,((i-1)*64)+1:i*64)))-7/24,'HH:MM:SS'));
% titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s EDT)}',datestr(nowTime+4/24,'yyyy-mmm-dd HH:MM:SS'),datestr(nowTime,'HH:MM:SS'));
title({titleLine1,titleLine2},...
'fontsize',14,'interpreter','latex');
xlim([-2.2 0]); ylim([-2.2 2.2])
[a, b, c] = fileparts(pngFile);
newFname = fullfile(a,[b,num2str(i),c]);
print(fig,'-dpng','-r100',newFname)
close(fig)

        
    end
    
    end
end

