% droneRadarOverlap_singleImage.m
% 09/25/2017
clear variables

addpath(genpath('C:\Data\ISDRI\isdri-scripts'))

% inputs
Hub = 'F:\';
JPGdate = '091117';
JPGname = 'DJI_0045';
radarDataLocation = [Hub 'guadalupe\processed'];
folderName = ' Guadalupe Dunes (rips)\Footage\';
imgJpg = [Hub 'uasData\' JPGdate(1:2) '.' JPGdate(3:4) '.' JPGdate(5:6) folderName JPGname '.jpg'];
domainSize = [-500 500; -200 -500];  % row 1: as values added to drone location.
                                     % row 2: xs values added to drone
                                     % location (2,1); (2,2) is a fixed
                                     % value
coastOrientation = 'horizontal';                                   
xCutoff = 1168; % 3500 m offshore 
rotation = 13; % change to 13 if you want the shoreline to be parallel to the edge of domain

% fetch image details
[imageLat,imageLon,imageTime] = getJPGlatlon(imgJpg);
% imageLat = 34.982063;
% imageLon = -120.658191;
% imageTime = '2017:09:12 15:12:00';

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

radarFile = [radarFolder '\' dirRadarFolder(idx).name];

% load radar cube
load(radarFile,'Azi','Rg','timex','data','timeInt','results');

[AZI,RG] = meshgrid(Azi,Rg(16:xCutoff));
TH = pi/180*(90-AZI-results.heading);
THdeg = wrapTo360(AZI+results.heading);
[X,Y] = pol2cart(TH,RG);
X = X+results.XOrigin;
Y = Y+results.YOrigin;

% find index of location of drone
[lat, lon] = UTM2ll(Y,X,10);
sumDiff = abs(lat - imageLat) + abs(lon - imageLon);
idx = find(sumDiff == min(min(sumDiff)));
xDrone = X(idx)-results.XOrigin;
yDrone = Y(idx)-results.YOrigin;
[thDrone,rgDrone] = cart2pol(xDrone,yDrone);

% rotate scan
headingR = results.heading-rotation;
thDroneC = pi/180*(rotation) + thDrone;
[xDroneC,yDroneC] = pol2cart(thDroneC,rgDrone);

% interpolate onto a smaller cartesian grid
xC = (yDroneC+domainSize(1,1)):(yDroneC+domainSize(1,2));
yC = (xDroneC+domainSize(2,1)):domainSize(2,2);
[XX,YY] = meshgrid(yC,xC);
[thC,rgC] = cart2pol(XX,YY);
aziC = wrapTo360(90 - thC*180/pi - headingR);
scanClipped = (double(timex(16:xCutoff,:)));
tC = interp2(AZI,RG,scanClipped,aziC',rgC');

dv1 = datevec(epoch2Matlab(timeInt(1,1)));

figure,
pcolor(XX,YY,tC')
shading interp; axis image
colormap(hot)
hold on
plot(xDroneC,yDroneC,'g*')
if strcmp(coastOrientation,'horizontal'); view([270 90]); end
colorbar
caxis([0 200])
xlabel('X (m)'); ylabel('Y (m)');
ttl = [num2str(dv1(1)) num2str(dv1(2),'%02i') num2str(dv1(3),'%02i') ' '...
    num2str(dv1(4),'%02i'),':', num2str(dv1(5),'%02i')];
title(ttl)
