% loadAndPlotRadarImage.m

clear variables
addpath(genpath('C:\Data\ISDRI\isdri-scripts'))
wholeDomain = 0;    % 1 if you want a plot of the entire domain
localOrUTM = 'UTM'; % 'local' or 'UTM' 
smallDomain = 1;    % 1 if you want a plot of a smaller, rotated domain for rips

% Load file
% matFile = 'E:\guadalupe\processed\2017-10-05\Guadalupe_20172780200_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-09-05\Guadalupe_20172481000_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-09-15\Guadalupe_20172580227_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-09-15\Guadalupe_20172580351_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-09-10\Guadalupe_20172532300_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-10-10\Guadalupe_20172832240_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-09-24\Guadalupe_20172672100_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-10-19\Guadalupe_20172920100_pol.mat';
% matFile = 'E:\guadalupe\processed\2017-10-22\Guadalupe_20172950600_pol.mat';
matFile = 'E:\guadalupe\processed\2017-09-12\Guadalupe_20172552300_pol.mat';
load(matFile)

% define parameters
% numRots = size(data,3)-1;
numRots = 64;
startRot = 200;

% add MacMahan's instruments
% find coordinates of MacMahan instruments
latJM = [34.98152 34.98260 34.98113 34.98035 34.98597];
lonJM = [-120.65164 -120.65731 -120.65024 -120.65172 -120.65032];

[yUTM_JM, xUTM_JM] = ll2UTM(latJM,lonJM);
X_JM = xUTM_JM - results.XOrigin;
Y_JM = yUTM_JM - results.YOrigin;

% add Oceanus instruments
% find coordinates of Oceanus instruments
latOc = [35.00258 35.00163 35.01176 35.01115 34.9902 34.98947 35.00908 34.98753...
    35.02070 35.01995 35.00762 35.00715 34.99740 34.99693 34.98640 34.98600...
    34.97535 34.97482 34.99587 35.00597 34.98508 35.004242 35.004128];
lonOc = [-120.72263 -120.72283 -120.700133 -120.700333 -120.70285 -120.70277 -120.68142...
    -120.68477 -120.66370 -120.66448 -120.66800 -120.66792 -120.66953 -120.66967...
    -120.67275 -120.67297 -120.67553 -120.67555 -120.66152 -120.65537 -120.66212...
    -120.646192 -120.646586];

[yUTM_Oc, xUTM_Oc] = ll2UTM(latOc,lonOc);
X_Oc = xUTM_Oc - results.XOrigin;
Y_Oc = yUTM_Oc - results.YOrigin;

%% whole domain
if wholeDomain == 1
    rotation = 0;
    if strcmp(localOrUTM,'local')
        x0 = 0;
        y0 = 0;
    else  
        x0 = results.XOrigin;     % for UTC
        y0 = results.YOrigin;
    end

    % create timex
    if size(data,3) > 65
        clear timex
        timex = mean(data(:,:,startRot:(numRots+startRot)),3);
        time = mean(epoch2Matlab(timeInt(1,startRot:(numRots+startRot))));
        dv = datevec(time);
    else
        time = mean(epoch2Matlab(timeInt(1,:)));
        dv = datevec(time);
    end
    
    % Convert to world coordinates
    heading = results.heading-rotation;
    [AZI,RG] = meshgrid(Azi,Rg);
    TH = pi/180*(90-AZI-heading);
    [xdom,ydom] = pol2cart(TH,RG);
    
    xdom = (xdom + x0);
    ydom = (ydom + y0);
    
    % rotate JM instruments onto the same grid
    [thJM,rgJM] = cart2pol(X_JM,Y_JM);
    aziJM = wrapTo360(-thJM*180/pi + 90 - results.heading);
    aziJMC = aziJM - rotation;
    thJMC = pi/180*(90 - aziJMC - results.heading);
    [xJMC,yJMC] = pol2cart(thJMC,rgJM); 
    xJMC = (xJMC + x0);
    yJMC = (yJMC + y0);
    
    % rotate OC instruments onto the same grid
    [thOc,rgOc] = cart2pol(X_Oc,Y_Oc);
    aziOc = wrapTo360(-thOc*180/pi + 90 - results.heading);
    aziOcC = aziOc - rotation;
    thOcC = pi/180*(90 - aziOcC - results.heading);
    [xOcC,yOcC] = pol2cart(thOcC,rgOc);
    xOcC = (xOcC + x0);
    yOcC = (yOcC + y0);
    
    % plot
    figure,
    pcolor(xdom/1000,ydom/1000,timex)
    shading flat; axis image;
    hold on
    plot(xJMC/1000,yJMC/1000,'b.','MarkerSize',10)
    plot(xOcC/1000,yOcC/1000,'b.','MarkerSize',10)
    if strcmp(localOrUTM,'local')
        xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)');
    else
        xlabel('Eastings (km)'); ylabel('Northings (km)');
    end
    colormap(hot)
    caxis([0 150])
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
    else
        time = mean(epoch2Matlab(timeInt(1,:)));
        dv = datevec(time);
    end
    
    % Convert to world coordinates
    heading = results.heading-rotation;
    [AZI,RG] = meshgrid(Azi,Rg);
    TH = pi/180*(90-AZI-heading);
    [xdom,ydom] = pol2cart(TH,RG);
    xdom = (xdom + x0);
    ydom = (ydom + y0);
    
    % rotate JM instruments onto the same grid
    [thJM,rgJM] = cart2pol(X_JM,Y_JM);
    aziJM = wrapTo360(-thJM*180/pi + 90 - results.heading);
    aziJMC = aziJM - rotation;
    thJMC = pi/180*(90 - aziJMC - results.heading);
    [xJMC,yJMC] = pol2cart(thJMC,rgJM);
    
    % rotate OC instruments onto the same grid
    [thOc,rgOc] = cart2pol(X_Oc,Y_Oc);
    aziOc = wrapTo360(-thOc*180/pi + 90 - results.heading);
    aziOcC = aziOc - rotation;
    thOcC = pi/180*(90 - aziOcC - results.heading);
    [xOcC,yOcC] = pol2cart(thOcC,rgOc);
    
    % plot
    figure,
    pcolor(xdom,ydom,timex)
    shading flat; axis image;
    hold on
%     plot(xJMC,yJMC,'b.','MarkerSize',20)
    plot(xJMC(1:4),yJMC(1:4),'b.','MarkerSize',20)

    plot(xOcC,yOcC,'g.','MarkerSize',20)
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