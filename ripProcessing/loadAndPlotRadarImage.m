% loadAndPlotRadarImage.m

clear variables
addpath(genpath('C:\Data\ISDRI\isdri-scripts'))
wholeDomain = 0;
smallDomain = 1;

% Load file
matFile = 'E:\guadalupe\processed\2017-10-18\Guadalupe_20172910030_pol.mat';
load(matFile)

% define parameters
numRots = 200;
% startRot = size(data,3) - 201;
startRot = 150;

%% whole domain
if wholeDomain == 1
    rotation = 0;
    x0 = results.XOrigin;     % for UTC
    y0 = results.YOrigin;
    
    % create timex
    clear timex
    timex = mean(data(:,:,startRot:(numRots+startRot)),3);
    time = mean(epoch2Matlab(timeInt(1,startRot:(numRots+startRot))));
    dv = datevec(time);
    
    % Convert to world coordinates
    heading = results.heading-rotation;
    [AZI,RG] = meshgrid(Azi,Rg);
    TH = pi/180*(90-AZI-heading);
    [xdom,ydom] = pol2cart(TH,RG);
    
    xdom = (xdom + x0)/1000;
    ydom = (ydom + y0)/1000;
    
    % plot
    figure,
    pcolor(xdom,ydom,timex)
    shading flat; axis image;
    colormap(hot)
    caxis([0 200])
    % axis([713.5 715.2 3871.7 3875.0])
    xlabel('Eastings (km)'); ylabel('Northings (km)');
    ttl = [num2str(dv(1)) num2str(dv(2),'%02i') num2str(dv(3),'%02i')...
        ' - ' num2str(dv(4),'%02i') ':' num2str(dv(5),'%02i') ':'...
        num2str(round(dv(6)),'%02i') ' UTC'];
    title(ttl)
    colorbar
end
if smallDomain == 1
    %% small domain
    % define parameters
    rotation = 13;
    x0 = 0;         % for local
    y0 = 0;
    axisLimits = [-1500 -500 -1000 1000];
    
    % create timex
    if size(data,3) > 65
    clear timex
    timex = mean(data(:,:,startRot:(numRots+startRot)),3);
    time = mean(epoch2Matlab(timeInt(1,startRot:(numRots+startRot))));
    dv = datevec(time);
    end
    
    time = mean(epoch2Matlab(timeInt(1,:)));
    dv = datevec(time);
    
    % Convert to world coordinates
    heading = results.heading-rotation;
    [AZI,RG] = meshgrid(Azi,Rg);
    TH = pi/180*(90-AZI-heading);
    [xdom,ydom] = pol2cart(TH,RG);
    xdom = (xdom + x0);
    ydom = (ydom + y0);
    
    % plot
    figure,
    pcolor(xdom,ydom,timex)
    shading flat; axis image;
    colormap(hot)
    caxis([0 200])
    axis(axisLimits)
    xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)');
    ttl = [num2str(dv(1)) num2str(dv(2),'%02i') num2str(dv(3),'%02i')...
        ' - ' num2str(dv(4),'%02i') ':' num2str(dv(5),'%02i') ':'...
        num2str(round(dv(6)),'%02i') ' UTC'];
    title(ttl)
    colorbar
end