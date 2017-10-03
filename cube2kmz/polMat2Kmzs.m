function polMat2Kmzs(cubeName,kmzName,tAvg,tDecim,doBilateralFilter)
%
% This function reads a radar cube (e.g. Cube = load(cubeName);) and writes
% KMZ files of the cube data as defined by nFrames and nGap (see below for
% definitions)
% 
% INPUT:
% cubeName [string]: Filename of cube to process
% kmzName  [string]: Filename of kmz to write (if only one file).
% If more than one file needs to be written, it is assumed that the 
% filename has the form "*20yydddHHMM*.kmz" and the start time is filled in
% appropriately
% tAvg     [scalar]: Time width (in seconds) of averaging filter (default =
% 80sec)
% tDecim   [scalar]: Decimation time (in seconds) of the output files
% (default = 120sec)
% 
% NOTES:
% The full path is to be used for both the cubeName and the kmzName, e.g.,
%
% >> cubeName = '/path/to/cube1400010.mat';
% >> kmzName  = '/path/to/kmzdir/kmz1400010.kmz';
%
%
% This script INCLUDES:
% lltoUTM.m
% UTMtoll.m
% epoch2Matlab.m
%
% !!! This script requires the GoogleEarth toolbox available on the Matlab 
% File Exchange !!!
%
% If the toolbox has been patched appropriately, then the kmz generated by this 
% script can be overlain on Google Maps in html. To verify, check that the
% ge_groundoverlay.m script header has the line:
% ==> This script is API FRIENDLY <==
%
% 2017-09-28 David Honegger



%% User options %%
radarLatitude      = [];%41.271735; %41.271747; % Leave blank [] to use UTM coordinates in Cube.results
radarLongitude     = [];%-72.343475; % Leave blank [] to use UTM coordinates in Cube.results
heading            = [];%282.5;         % If cube's internal heading is wrong, apply this heading instead
maxHeading         = 359;         % Set maximum heading value (clockwise from North) for footprint
rangeDecimation    = 2;           % Decimate ranges by this factor to speed up interpolation to Cartesian
cartGrid_dx        = 15;          % kmz requires cartesian grid - this is spatial resolution
cartGrid_dy        = 15;          % kmz requires cartesian grid - this is spatial resolution
colorAxisLimits    = [0 225];    % caxis
if nargin < 5
    doBilateralFilter  = false;       % Choose to apply bilateral filter
end
bfLimits           = [50 250];    % caxis limits if bilateral filter is applied

%% Defaults
if ~exist('tAvg','var') || isempty(tAvg)
    tAvg = 80;
end
if ~exist('tDecim','var') || isempty(tDecim)
    tDecim = 120;
end


%% Brief prepwork %%
% Add GE Toolbox to path if it isn't there
if ~exist('ge_output', 'file')
        toolboxPath = fullfile(pwd,'googleEarth_toolbox');
    if ~exist(toolboxPath,'dir')
        disp('Google Earth Toolbox is not in path.')
        toolboxPath = uigetdir(pwd,'Select Google Earth Toolbox Directory');
    end
    origPath = path;
    addpath(toolboxPath)
    addedToPath = true;
    fprintf('Temporarily adding Local Google Earth Toolbox to Matlab path.\n')
else
    addedToPath = false;
end

% Create output directory if it doesn't exist
[outputDirectory,kmzNameStr,~] = fileparts(kmzName);
if ~exist(outputDirectory,'dir') && ~isempty(outputDirectory)
    mkdir(outputDirectory)
end


%% Load data %%
[~,namestr,~] = fileparts(cubeName);
fprintf('Loading %s:\n',namestr)
load(cubeName, 'Rg', 'Azi', 'timex', 'header' , 'results', 'timeInt')

% Cube stats
rotationPeriod = mean(diff(timeInt(1,:))); % Rotation period
runLength      = results.RunLength;
numRotations   = header.rotations;

% Determine what gets loaded and whether it's a multi-file output
if runLength < tAvg-rotationPeriod/2
	tAvg = runLength;
    % Run length is too small or averaging window is too large
    warnmsg = sprintf('Fewer rotations in the provided cube than the requested filter width. Changing filter width to be %f sec, the length of the recording.',runLength);
    warning(warnmsg)
end
	
if abs(tAvg-runLength) < rotationPeriod/2
    % Then the cube is the same size as the filter width and only the timex needs to be loaded
    if ~exist('timex','var') || isempty(timex) % What if the timex didn't exist in this cube?
        load(cubeName,'data')
        timex = double(mean(data,3));
    else
        timex = double(timex);
    end
    multiFile = false; % Only writing one KMZ file
else
    % Then the whole cube must be loaded
    load(cubeName,'data')
    multiFile = true;
end

% Read user heading if entered
if isempty(heading)
    heading = results.heading;
end  

%% Interpolation from radar grid to regular cartesian geographic grid %%
% Only use non-zero ground ranges
iMinRg = find(Rg>0,1,'first');
Rg = Rg(iMinRg:end);

% Convert radar coords to geographic coords
[AZI,RG] = meshgrid(90-Azi-(heading),Rg);
% [xRadarGrid,yRadarGrid] = pol2cart(AZI*pi/180,RG);
if isempty(radarLatitude*radarLongitude)
    xutmOrigin = results.XOrigin;
    yutmOrigin = results.YOrigin;
    zone = results.UTMZone;
    [radarLatitude,radarLongitude] = UTMtoll(yutmOrigin,xutmOrigin,str2double(zone(1:2)));
else
    [yutmOrigin,xutmOrigin,zone] = lltoUTM(radarLatitude,radarLongitude);
end
% xRadarGrid = xRadarGrid + xutmOrigin;
% yRadarGrid = yRadarGrid + yutmOrigin;
% [Lats,Lons] = UTMtoll(yRadarGrid,xRadarGrid,str2double(zone(1:2)));

%%% Determine output grid (uses mapping toolbox)
max_r = max(Rg);
[~, West] = enu2geodetic(-max_r, 0, 0, radarLatitude, radarLongitude, 0, wgs84Ellipsoid);
[~, East] = enu2geodetic(max_r, 0, 0, radarLatitude, radarLongitude, 0, wgs84Ellipsoid);
[South, ~] = enu2geodetic(0, -max_r, 0, radarLatitude, radarLongitude, 0, wgs84Ellipsoid);
[North, ~] = enu2geodetic(0, max_r, 0, radarLatitude, radarLongitude, 0, wgs84Ellipsoid);
num_lons = ceil((2*max_r)/cartGrid_dx);
num_lats = ceil((2*max_r)/cartGrid_dy);
lons = linspace(West, East, num_lons);
lats = linspace(South, North, num_lats);
[lon_grid, lat_grid] = meshgrid(lons, lats);
% Convert grid to enu, then polar, then to azimuths relative to heading 0
% [x_grid, y_grid] = geodetic2enu(lat_grid, lon_grid, 0, radarLatitude, radarLongitude, 0,...
%                                 wgs84Ellipsoid);
[northing_grid,easting_grid] = lltoUTM(lat_grid,lon_grid);
x_grid = easting_grid - xutmOrigin;
y_grid = northing_grid - yutmOrigin;
[phi_grid, r_grid] = cart2pol(x_grid, y_grid);
azi_grid = 90 - phi_grid*180/pi;
% azi0_grid = mod(azi_grid - (headingOffset + results.heading), 360);
azi0_grid = mod(azi_grid - results.heading, 360);





if multiFile
    % Figure out which rotations to use
    runTime = timeInt(1,:)-timeInt(1,1); % Start times of all rotations
    startTimeIdealVec = 0:tDecim:runLength; % Vector of (ideal) start times
    [~,startRotVec] = min(abs(startTimeIdealVec(:)'-runTime(:))); % Compare start vectors in array form to find the ones that match
    startTimeVec = runTime(startRotVec);
    endTimeIdealVec = startTimeIdealVec + tAvg; % Vector of (ideal) end times
    [~,endRotVec] = min(abs(endTimeIdealVec(:)'-runTime(:))); % Compare end vectors in array form to find the ones that match
    endTimeVec = runTime(endRotVec);
    badIdx = find( (endTimeVec-startTimeVec) < (tAvg - rotationPeriod/2) );
    startTimeVec(badIdx) = [];
    startRotVec(badIdx)  = [];
    endTimeVec(badIdx)   = [];
    endRotVec(badIdx)    = [];
    
    % Figure out naming scheme
    yrInd = strfind(kmzNameStr,'20');
    yrInd = yrInd(1); % The yyyydddHHMM string starts here
    MMInd = yrInd + 10; % The yyyydddHHMM string ends here
    
    % Loop thru files
    for iFile = 1:length(startTimeVec)
        thisRotationVec = startRotVec(iFile):endRotVec(iFile);
        thisData = double(mean(data(iMinRg:end,:,thisRotationVec),3));
        kmzData = interp2(Azi(:)', Rg(:), thisData, azi0_grid, r_grid, 'linear', NaN);
        thisStartDateNum = results.start_time.dateNum + startTimeVec(iFile)/86400;
        thisEndDateNum = results.start_time.dateNum + endTimeVec(iFile)/86400;
        if numel(kmzNameStr)>(MMInd+1)
            thisKmzNameStr = [kmzNameStr(1:yrInd-1),dn2trizna(thisStartDateNum),kmzNameStr(MMInd+1:end)];
        else
            thisKmzNameStr = [kmzNameStr(1:yrInd-1),dn2trizna(thisStartDateNum)];
        end
        fprintf('Writing kmz: %.f rot mean (%s to %s).\n',numel(thisRotationVec),datestr(thisStartDateNum,'yyyy-mm-dd HH:MM:SS'),datestr(thisEndDateNum,'yyyy-mm-dd HH:MM:SS'))
        kmzGen(lons,lats,kmzData,colorAxisLimits,thisStartDateNum,mean([thisStartDateNum,thisEndDateNum]),thisEndDateNum,outputDirectory,thisKmzNameStr,doBilateralFilter)
    end
else
    
    % Get time information
    minTime  = epoch2Matlab(min(timeInt(:)));
    meanTime = epoch2Matlab(mean(timeInt(:)));
    maxTime  = epoch2Matlab(max(timeInt(:)));


    % Interpolate to regular cartesian grid
    fprintf('Interpolating to Lat/Lon grid. ')
    timex = double(timex(iMinRg:end, :, :));
    kmzData = interp2(Azi, Rg, timex, azi0_grid, r_grid, 'linear', NaN);
    
    fprintf('Writing kmz: %.f rot mean (%s to %s).\n',numRotations,datestr(minTime,'yyyy-mm-dd HH:MM:SS'),datestr(maxTime,'yyyy-mm-dd HH:MM:SS'))

    kmzGen(lons,lats,kmzData,colorAxisLimits,minTime,meanTime,maxTime,outputDirectory,kmzNameStr,doBilateralFilter)

end
    
if addedToPath
    path(origPath)
end

fprintf('Done.\n')

end



%% Generate KMZ function

function kmzGen(lons,lats,kmzData,colorAxisLimits,minTime,meanTime,maxTime,outputDirectory,kmzNameStr,doBilateralFilter)

% Bilateral Filter
if doBilateralFilter
    fprintf('Applying bilateral filter. ')
    kmzData = bfWrapper(kmzData);
    colorAxisLimits = bfLimits;
end

% Create temporary working folder
folderID = randi(1e4,1);
folderName = sprintf('temp%05.f',folderID);
mkdir(folderName)

% Move to working folder
cwd = pwd;
cd(folderName)

% Create kml
fprintf('Writing PNG Overlay. ')

if ~exist(fullfile(pwd, 'files'), 'dir')
    mkdir('files');
end
% !!!!!!!!!!!!!!!!
utcOffset = -7/24;
% !!!!!!!!!!!!!!!!
kmlStr{1} = ge_imagesc(...
            lons,lats,flipud(kmzData),...
                'altitude',5,...
                'altitudeMode','relativeToGround',...
                'drawOrder',10,...
                'cLimHigh',colorAxisLimits(2),...
                'cLimLow',colorAxisLimits(1),...
                'colorMap','hot',...
                'crispFactor',2,...
                'description','',...
                'nanValue',-1,...
                'visibility',1,...
                'name',sprintf('Guadalupe X-band Radar: %s Local',datestr(meanTime+utcOffset,'yyyy-mmm-dd HH:MM:SS')),...
                'imgURL',['files/',kmzNameStr,'.png'],...
                'timeSpanStart',datestr(minTime,'yyyy-mm-ddTHH:MM:SSZ'),...
                'timeSpanStop',datestr(maxTime,'yyyy-mm-ddTHH:MM:SSZ'));

                
fprintf('Writing kml file. ')
ge_output([kmzNameStr,'.kml'],cell2mat(kmlStr))

% Zip to kmz
fprintf('Zipping to kmz. ')
zip(kmzNameStr,{[kmzNameStr,'.kml'],'files'})
% Move the file with operating system commands
src = sprintf('%s.zip',kmzNameStr);
dest = sprintf('%s.kmz',fullfile(outputDirectory,kmzNameStr));
if isunix
    eval(['! mv ',src,' ',dest])
else
    eval(['! move ',src,' ',dest])
end
% movefile([kmzNameStr,'.zip'],fullfile(outputDirectory,[kmzNameStr,'.kmz']))

% Move out of working folder
cd(cwd)
pause(0.5)
if isunix
    eval(['! rm -rf ',folderName])
else
    rmdir(folderName,'s')
end
pause(0.5)

end

function str = dn2trizna(dateNum)
    dv = datevec(dateNum);
    dv(2:3) = 1;
    ddd = floor(dateNum - datenum(dv) + 1);
    str = sprintf('%s%.f%s',datestr(dateNum,'yyyy'),ddd,datestr(dateNum,'HHMM'));
end


function [UTMNorthing, UTMEasting, UTMZone] = lltoUTM(Lat, Long)
%%function [UTMNorthing, UTMEasting, UTMZone] = lltoutm(Lat, Long, refellip, a, eccSquared)
%%	lltoutm.c
%%  Consolidated  29,August 2006.  B. Woodward
%%	14 April 1999
%%	T. C. Lippmann
%%
%%	lat = latitude in fraction deg.
%%	lon = longitude in fraction deg. (West of Grenwich are negative!)
%%	refellip = ref. ellipsoid identifier (see refellip_menu.m)
%%	a = Equatorial Radius (optional)
%%	eccSquared = eccentricity squared (optional)
%%
%%	if a and eccSquared are included, then refellip is ignored and a & eccSquared are
%% 	used for the radius and eccentricity squared
%%
%%	utmNorthings = Northings (in fraction meters)
%%	utmEastings = Eastings (or Westings if lon negative) (in fraction meters)
%%	utmZ = zone (ie, 10T)
%%
%%	Program to convert lat-lon data to UTM coordinates.
%%	Uses subroutine written by Chuck Gantz downloaded from the
%%	GPSy web site.  
%%
%%	Note:  Westings have negative longitudes.
%%

%%%%%%%%  CONSTANTS  %%%%%%%%%
deg2rad = pi/180;
rad2deg = 180/pi;
ellipsoidName = 'WGS-84';
a = 6378137;
eccSquared = 0.00669438;
k0 = 0.9996;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	LatRad = Lat*deg2rad;
	LongRad = Long*deg2rad;

        LongOrigin = zeros(size(Long));
	dy = find(Long > -6 & Long <= 0);
        LongOrigin(dy) = -3; 
	dy = find(Long < 6 & Long > 0);
        LongOrigin(dy) = 3; 
        dy = find(abs(Long) >= 6);
        LongOrigin(dy) = sign(Long(dy)).*floor(abs(Long(dy))/6)*6 + 3*sign(Long(dy));
	LongOriginRad = LongOrigin * deg2rad;

	%% compute the UTM Zone and Grid from the latitude and longitude*/
	UTMZone = sprintf('%d%c', floor((Long(1) + 180)/6) + 1, UTMLetterDesignator(Lat(1)));
	
	eccPrimeSquared = (eccSquared)./(1-eccSquared);

	N = a./sqrt(1-eccSquared.*sin(LatRad).*sin(LatRad));
	T = tan(LatRad).*tan(LatRad);
	C = eccPrimeSquared.*cos(LatRad).*cos(LatRad);
	A = cos(LatRad).*(LongRad-LongOriginRad);

	M = a.*((1 - eccSquared/4 - 3*eccSquared*eccSquared/64- 5*eccSquared*eccSquared*eccSquared/256).*LatRad ...
	    - (3*eccSquared/8 + 3*eccSquared*eccSquared/32 + 45*eccSquared*eccSquared*eccSquared/1024).*sin(2*LatRad) ...
	    + (15*eccSquared*eccSquared/256 + 45*eccSquared*eccSquared*eccSquared/1024).*sin(4*LatRad) ...
	    - (35*eccSquared*eccSquared*eccSquared/3072).*sin(6*LatRad));
	
	UTMEasting = (k0.*N.*(A+(1-T+C).*A.*A.*A/6 ...
			+ (5-18.*T+T.*T+72.*C-58.*eccPrimeSquared).*A.*A.*A.*A.*A/120) ...
			+ 500000.0);

	UTMNorthing = (k0.*(M+N.*tan(LatRad).*(A.*A/2+(5-T+9.*C+4.*C.*C).*A.*A.*A.*A/24 ...
			+ (61-58.*T+T.*T+600.*C-330.*eccPrimeSquared).*A.*A.*A.*A.*A.*A/720)));

	dy = find(Lat < 0);
        UTMNorthing(dy) = UTMNorthing(dy) + 10000000.0; %%10000000 meter offset for southern hemisphere*/
return;
end

function [LetterDesignator] = UTMLetterDesignator(Lat)
%%function [letdes] = UTMLetterDesignator(Lat)
%%This routine determines the correct UTM letter designator for the given latitude
%%returns 'Z' if latitude is outside the UTM limits of 80N to 80S
%% //Written by Chuck Gantz- chuck.gantz@globalstar.com

        if((80 >= Lat) & (Lat > 72)) LetterDesignator = 'X';
        else if((72 >= Lat) & (Lat > 64)) LetterDesignator = 'W'; 
        else if((64 >= Lat) & (Lat > 56)) LetterDesignator = 'V'; 
        else if((56 >= Lat) & (Lat > 48)) LetterDesignator = 'U'; 
        else if((48 >= Lat) & (Lat > 40)) LetterDesignator = 'T'; 
        else if((40 >= Lat) & (Lat > 32)) LetterDesignator = 'S'; 
        else if((32 >= Lat) & (Lat > 24)) LetterDesignator = 'R'; 
        else if((24 >= Lat) & (Lat > 16)) LetterDesignator = 'Q'; 
        else if((16 >= Lat) & (Lat > 8)) LetterDesignator = 'P'; 
        else if(( 8 >= Lat) & (Lat > 0)) LetterDesignator = 'N'; 
        else if(( 0 >= Lat) & (Lat > -8)) LetterDesignator = 'M'; 
        else if((-8>= Lat) & (Lat > -16)) LetterDesignator = 'L'; 
        else if((-16 >= Lat) & (Lat > -24)) LetterDesignator = 'K'; 
        else if((-24 >= Lat) & (Lat > -32)) LetterDesignator = 'J'; 
        else if((-32 >= Lat) & (Lat > -40)) LetterDesignator = 'H'; 
        else if((-40 >= Lat) & (Lat > -48)) LetterDesignator = 'G'; 
        else if((-48 >= Lat) & (Lat > -56)) LetterDesignator = 'F'; 
        else if((-56 >= Lat) & (Lat > -64)) LetterDesignator = 'E'; 
        else if((-64 >= Lat) & (Lat > -72)) LetterDesignator = 'D'; 
        else if((-72 >= Lat) & (Lat > -80)) LetterDesignator = 'C'; 
        else LetterDesignator = 'Z'; %%This is here as an error flag 
				     %%to show that the Latitude is 
				     %%outside the UTM limits
	end; end; end; end; end; end; end; end; end; end;
	end; end; end; end; end; end; end; end; end; end;
return;
end

function[Lat, Long] = UTMtoll(UTMNorthing, UTMEasting, ZoneNumber)
%%%%%%%%  CONSTANTS  %%%%%%%%%
deg2rad = pi/180;
rad2deg = 180/pi;
ellipsoidName = 'WGS-84';
a = 6378137;
eccSquared = 0.00669438;
k0 = 0.9996;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	e1 = (1-sqrt(1-eccSquared))/(1+sqrt(1-eccSquared));

	x = UTMEasting - 500000.0; %%//remove 500,000 meter offset for longitude
	y = UTMNorthing;

	NorthernHemisphere = 1;  %%//point is in northern hemisphere

	LongOrigin = (ZoneNumber - 1)*6 - 180 + 3;  %%//+3 puts origin in middle of zone

	eccPrimeSquared = (eccSquared)/(1-eccSquared);

	M = y ./ k0;
	mu = M/(a*(1-eccSquared/4-3*eccSquared*eccSquared/64-5*eccSquared*eccSquared*eccSquared/256));

	phi1Rad = mu	+ (3*e1/2-27*e1*e1*e1/32)*sin(2*mu) ...
				+ (21*e1*e1/16-55*e1*e1*e1*e1/32)*sin(4*mu)...
				+(151*e1*e1*e1/96)*sin(6*mu);
	phi1 = phi1Rad*180/pi;

	N1 = a./sqrt(1-eccSquared.*sin(phi1Rad).*sin(phi1Rad));
	T1 = tan(phi1Rad).*tan(phi1Rad);
	C1 = eccPrimeSquared.*cos(phi1Rad).*cos(phi1Rad);
	R1 = a.*(1-eccSquared)./((1-eccSquared.*sin(phi1Rad).*sin(phi1Rad)).^1.5);
	D = x./(N1.*k0);

	Lat = phi1Rad - (N1.*tan(phi1Rad)./R1).*(D.*D./2-(5+3.*T1+10.*C1-4.*C1.*C1-9.*eccPrimeSquared).*D.*D.*D.*D./24 ...
                        +(61+90.*T1+298.*C1+45.*T1.*T1-252.*eccPrimeSquared-3.*C1.*C1).*D.*D.*D.*D.*D.*D./720);
	Lat = Lat * 180/pi;

	Long = (D-(1+2.*T1+C1).*D.*D.*D./6+(5-2.*C1+28.*T1-3.*C1.*C1+8.*eccPrimeSquared+24.*T1.*T1) ...
                         .*D.*D.*D.*D.*D./120)./cos(phi1Rad);
	Long = LongOrigin + Long * 180/pi;
    
end

function [datenumTime] = epoch2Matlab(unixTime)
%%% epoch2Matlab
%%% Input a unix timestamp and receive a MATLAB datenum in UTC.
datenumTime = NaN*zeros(size(unixTime));
for i = 1:size(unixTime,1)
    for j = 1:size(unixTime,2)
        datenumTime(i,j) = datenum([1970,1,1,0,0,unixTime(i,j)]);
    end
end
end
