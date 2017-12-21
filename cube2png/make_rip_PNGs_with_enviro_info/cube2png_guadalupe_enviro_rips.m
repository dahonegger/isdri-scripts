function cube2png_guadalupe_enviro_rips(cubeFile,pngFile)
% Originally 'cube2timex.m' by David Honegger
% Updated by Alex Simpson to show tide, wind, discharge data
% Updated by Annika O'Dea to show waves instead of discharge at the
% Guadalupe Dunes site - zoomed in to focus on rip currents
% 9/19/2017

% User options: leave empty [] for Matlab auto-sets
colorAxLimits           = [10 220]; % This gets updated for bad data periods (~May 28-30)
axisLimits              = [-1200 -500 -800 800]; % in meters
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

% set rotation(so shoreline is parallel to edge of plot)
rotation = 13;
heading = results.heading-rotation;
[AZI,RG] = meshgrid(Azi,Rg(16:668));

% interpolate onto a smaller cartesian grid
xC = -800:800;
yC = -1200:-500;
[XX,YY] = meshgrid(yC,xC);
[thC,rgC] = cart2pol(XX,YY);
aziC = wrapTo360(90 - thC*180/pi - heading);

% Handle long runs (e.g. 18 minutes
if (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 < 142
    tC = interp2(AZI,RG,double(timex(16:668,:)),aziC',rgC');
    timexCell{1} = tC;
    timeIntCell{1} = mean(timeInt);
    pngFileCell{1} = pngFile;
    clear timex
elseif (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 > 142
    load(cubeFile,'data')
    ii = 1;
    if size(data,3) > 64*2
        for i = 1:64:(floor(size(data,3)/64))*64 - 64
            tC = interp2(AZI,RG,double(mean(data(16:668,:,i:i+64),3)),aziC',rgC');
            timexCell{ii} = tC;
            timeIntCell{ii} = timeInt(1,i:i+64);
            [path,fname,ext] = fileparts(pngFile);
            tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
            fname = [fname(1:17),tmp,'_pol_timex'];
            pngFileCell{ii} = fullfile(path,[fname,ext]);
            
            ii = ii+1;
            clear tC
        end
    else
        for i = 1:64:(floor(size(data,3)/64))*64
            tC = interp2(AZI,RG,double(mean(data(16:668,:,i:i+64),3)),aziC',rgC');
            timexCell{ii} = tC;
            timeIntCell{ii} = timeInt(1,i:i+64);
            [path,fname,ext] = fileparts(pngFile);
            tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
            fname = [fname(1:17),tmp,'_pol_timex'];
            pngFileCell{ii} = fullfile(path,[fname,ext]);
            
            ii = ii+1;
            clear tC
        end
    end
end

% find coordinates of MacMahan instruments
latJM = [34.9826 34.981519 34.981131 34.980439 34.98035 34.985969];
lonJM = [-120.657311 -120.651639 -120.650239 -120.647881...
    -120.651719 -120.650319];

[yUTM, xUTM] = ll2UTM(latJM,lonJM);
X_JM = xUTM - results.XOrigin;
Y_JM = yUTM - results.YOrigin;

% rotate onto the same grid
[thJM,rgJM] = cart2pol(X_JM,Y_JM);
aziJM = wrapTo360(-thJM*180/pi + 90 - results.heading);
aziJMC = aziJM - rotation;
thJMC = pi/180*(90 - aziJMC - results.heading);
[xJMC,yJMC] = pol2cart(thJMC,rgJM);

nowTime = epoch2Matlab(nanmean(timeInt(:))); % UTC

% Load wind data from wind station file
[dnWind,magWind,dirWind] = loadWindNDBC('MetData_NDBC46011.txt', nowTime);
dirWindR = dirWind - rotation; % rotate wind to be consistent with rotated domain

% Load wave data from wave station file
[dnWaves,Hs,dirWaves,~,~] = loadWavesNDBC('WaveData_NDBC46011.txt');

% Load tide data from tide station file
[dnTides,waterSurfaceElevation] = loadTidesNOAA('TideData_NOAA9411406.txt');
waterSurfaceElevation(waterSurfaceElevation == -999) = nan;

for IMAGEINDEX = 1:numel(timexCell)
    timex = timexCell{IMAGEINDEX}';
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
    pcolor(XX,YY,timex);
%     pcolor(XX,YY,tC');
    hold on
    shading interp
    axis image
    colormap(hot)
    plot(xJMC,yJMC,'b.','MarkerSize',20)
    if ~isempty(axisLimits)
        axis(axisLimits)
    end
    if ~isempty(colorAxLimits)
        caxis(colorAxLimits)
    end
    grid on
    % axRad.XTick = axRad.XTick(1):2:axRad.XTick(end);
    % axRad.YTick = axRad.YTick(1):2:axRad.YTick(end);
    xlabel('[m]','fontsize',14,'interpreter','latex')
    ylabel('[m]','fontsize',14,'interpreter','latex')
    axRad.TickLabelInterpreter = 'latex';
    runLength = timeInt(end,end)-timeInt(1,1);
    titleLine1 = sprintf('\\makebox[4in][c]{Guadalupe X-band Radar: %2.1f min Exposure}',runLength/60);
    titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s PDT)}',datestr(epoch2Matlab(nanmean(timeInt(:))),'yyyy-mmm-dd HH:MM:SS'),datestr(epoch2Matlab(nanmean(timeInt(:)))-7/24,'HH:MM:SS'));
    % titleLine2 = sprintf('\\makebox[4in][c]{%s UTC (%s EDT)}',datestr(nowTime+4/24,'yyyy-mmm-dd HH:MM:SS'),datestr(nowTime,'HH:MM:SS'));
    title({titleLine1,titleLine2},...
        'fontsize',14,'interpreter','latex');
    
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
    [uWind vWind] = pol2cart((90-dirWindR)*pi/180, 1);
    arrow([uWind vWind],[0 0],'baseangle',45,'width',magWind,'tipangle',25,'facecolor','red','edgecolor','red');
    [uText vText] = pol2cart((90-180-dirWindR)*pi/180,0.28); %position text off tip of arrow
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