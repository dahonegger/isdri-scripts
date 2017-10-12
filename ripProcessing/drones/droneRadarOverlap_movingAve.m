% droneRadarOverlap

clear variables;

addpath(genpath('C:\Data\ISDRI\isdri-scripts'))

% inputs
Hub = 'F:\';
JPGdate = '091217';
JPGname = 'DJI_0071';
radarDataLocation = [Hub 'guadalupe\processed'];
folderName = ' Guadalupe Dunes (IW+rip)\Footage\';
imagePng = [Hub 'uasData\' JPGdate(1:2) '.' JPGdate(3:4) '.' JPGdate(5:6) folderName JPGname '.jpg'];
domainSize = [-500 2000; -500 -500];  % row 1: as values added to drone location.
                                    % row 2: xs values added to drone location (2,1);
                                    % fixed xs value(2,2)

saveFolder = ['C:\Data\ISDRI\postprocessed\ripDrone\' JPGdate '_' JPGname];
mkdir(saveFolder)

% fetch image details
[imageLat,imageLon,imageTime] = getJPGlatlon(imagePng);

% find closest radar image
image_dn = datenum([str2num(imageTime(1:4)), str2num(imageTime(6:7)),...
    str2num(imageTime(9:10)), (str2num(imageTime(12:13))+7),...
    str2num(imageTime(15:16)), str2num(imageTime(18:19))]);

radarFolder = [radarDataLocation '\' imageTime(1:4) '-'...
    imageTime(6:7) '-' imageTime(9:10)];

dirRadarFolder = dir(fullfile(radarFolder,'*_pol.mat'));
radarFolder_dn = zeros(1, length(dirRadarFolder));
for i = 1:length(radarFolder_dn)
    fn = dirRadarFolder(i).name;
    if str2num(fn(15:17)) < 273; mth = 9; day = str2num(fn(15:17)) - 243;
    elseif str2num(fn(15:17)) >= 273; mth = 10; day = str2num(fn(15:17)) - 273;
    end
    radarFolder_dn(i) = datenum([str2num(fn(11:14)), mth, day,...
        str2num(fn(18:19)), str2num(fn(20:21)), 0]);
    clear fn
end

[~,idx] = min(abs(radarFolder_dn - image_dn));
tC = [];
dn = [];
for iRun = 1:7;
    
    if idx > 3 && idx < length(radarFolder_dn) - 4
        startIdx = idx - 2;
    elseif idx <= 2 % THIS WILL BE THE 512 - NEED TO CODE ALTERNATIVE
        startIdx = 1;
    elseif idx >= length(radarFolder_dn) - 4
        startIdx = length(radarFolder_dn) - 7;
    end
    
    radarFile = [radarFolder '\' dirRadarFolder((startIdx + iRun - 1)).name];
    
    % load radar cube
    load(radarFile,'Azi','Rg','timex','data','timeInt','results');
    
    % time
    dn1 = epoch2Matlab(timeInt(1,:));
    
    [AZI,RG] = meshgrid(Azi,Rg(16:668));
    TH = pi/180*(90-AZI-results.heading);
    THdeg = wrapTo360(AZI+results.heading);
    [X,Y] = pol2cart(TH,RG);
    X = X+results.XOrigin;
    Y = Y+results.YOrigin;
    
    % find index of location of drone
    [lat, lon] = UTM2ll(Y,X,10);
    sumDiff = abs(lat - imageLat) + abs(lon - imageLon);
    idxMin = find(sumDiff == min(min(sumDiff)));
    xDrone = X(idxMin)-results.XOrigin;
    yDrone = Y(idxMin)-results.YOrigin;
    
    [thDrone,rgDrone] = cart2pol(xDrone,yDrone);
    aziDrone = wrapTo360(-thDrone*180/pi + 90 - results.heading);
    
    % interpolate onto a smaller cartesian grid
    rotation = 13;
    headingR = results.heading-rotation;
    aziDroneC = aziDrone - rotation;
    thDroneC = pi/180*(90-aziDroneC-results.heading);
    [xDroneC,yDroneC] = pol2cart(thDroneC,rgDrone);
    xC = (yDroneC+domainSize(1,1)):(yDroneC+domainSize(1,2));
    yC = (xDroneC+domainSize(2,1)):domainSize(2,2);
    [XX,YY] = meshgrid(yC,xC);
    [thC,rgC] = cart2pol(XX,YY);
    aziC = wrapTo360(90 - thC*180/pi - headingR);
    
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
    
    scanClipped = (double(data(16:668,:,:)));
    
    % build cube
    for rot = 1:size(scanClipped,3);
        tC1(:,:,rot) = interp2(AZI,RG,scanClipped(:,:,rot),aziC',rgC');
    end
    tC = cat(3,tC,tC1);
    dn = [dn dn1];
    clear tC1 dn1
end

% moving average
tCAve = movmean(tC,65,3);
rate = 4;
imgNum = 1;
dv = datevec(dn);

for s = 1:rate:size(tCAve,3)
    fig = figure('visible','off');
    pcolor(XX,YY,tCAve(:,:,s)')
    shading interp; axis image
    hold on
    plot(xJMC,yJMC,'b.','MarkerSize',20)
    colormap(hot)
    colorbar
    caxis([50 200])
    hold on
    plot(xDroneC,yDroneC,'g*')
    xlabel('X (m)'); ylabel('Y (m)');
    view([270 90])
    ttl = [num2str(dv(s,1)) num2str(dv(s,2),'%02i') num2str(dv(s,3),'%02i') ' '...
        num2str(dv(s,4),'%02i'),':', num2str(dv(s,5),'%02i'),':',num2str(round(dv(s,6)),'%02i')];
    title(ttl)
    ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
    imgNum=imgNum+1;
    print(fig,ttlFig,'-dpng')
    close all
    clear ttl ttlFig
end

% make single PNG overlapping with JPG


cd(saveFolder)
pngs = dirname('*.png');
outputFile = [saveFolder '\' JPGdate '_' JPGname '.gif'];

delayTime = 0.03;
makeGif(pngs,outputFile,delayTime)