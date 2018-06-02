% XSTranMatrix.m

clear variables; home

%% Add path
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));
addpath(genpath('C:\Data\ISDRI\cBathy'));

%% define time of interest
% % startTime = '20170923_0500';
% % endTime = '20170923_0730';
startTime = '20170908_0000';
endTime = '20170908_2351';

Hub = 'E';
baseDir = [Hub ':\guadalupe\processed\'];
% saveFolder = ['E:\guadalupe\postprocessed\xsTran\' startTime '-' endTime];
% mkdir(saveFolder)
xC = -1000:1000;
yC = -1200:-500;
XSTranLoc = 0;

%% define figure parameters
colorAxisLimits = [20 220];
% XYLimits = [-1300 -500; -300 2900];
XYLimits = [-1500 -500; -1000 1000];

%% make list of cubes
dataFolder = [baseDir startTime(1:4) '-' startTime(5:6)...
    '-' startTime(7:8)];
% create list of file names
dvdays = datevec(datenum([str2num(startTime(1:4)),str2num(startTime(5:6)),...
    str2num(startTime(7:8)),0,0,0]):datenum([str2num(endTime(1:4)),...
    str2num(endTime(5:6)),str2num(endTime(7:8)),0,0,0]));
days = datevec2doy(dvdays);
dv = datevec(doy2date(days,2017*ones(size(days))));
dv(1,4) = str2num(startTime(10:11));
dv(end,4) = str2num(endTime(10:11));

cubeListAll = [];
for d = 1:length(days)
    dataFolder = [baseDir num2str(dv(d,1)) '-' num2str(dv(d,2),'%02i') '-'...
        num2str(dv(d,3),'%02i') '\'];
    cubeList1 = dir(fullfile(dataFolder,'*_pol.mat'));
    cubeListAll = [cubeListAll; cubeList1];
    clear cubeList1
end

for i = 1:length(cubeListAll);
    dd = datevec(doy2date(str2num(cubeListAll(i).name(15:17)),2017));
    dnList(i) = datenum([dd(1), dd(2), dd(3),...
        str2num(cubeListAll(i).name(18:19)),...
        str2num(cubeListAll(i).name(20:21)),0]);
end

startdn = datenum([str2num(startTime(1:4)),str2num(startTime(5:6)),...
    str2num(startTime(7:8)),str2num(startTime(10:11)),str2num(startTime(12:13)),0]);
enddn = datenum([str2num(endTime(1:4)),str2num(endTime(5:6)),...
    str2num(endTime(7:8)),str2num(endTime(10:11)),str2num(endTime(12:13)),0]);

[~,firstFileIndex] = min(abs(startdn - dnList));
[~,lastFileIndex] = min(abs(enddn - dnList));

cubeList = cubeListAll(firstFileIndex:lastFileIndex);

%% Load data from 512 rotation runs
xCutoff = 1068; % range index for clipped scan
rotation = 13; % domain rotation
transectAll = [];  timeAll = []; % initialize variables
for i = 1:length(cubeList)
    % Load radar data
    
    cubeName = [cubeList(i).folder '\' cubeList(i).name];
    load(cubeName,'Azi','Rg','results','timex','timeInt')
    
    % define time vector
    timeVec = mean(timeInt);
    t_dn = epoch2Matlab(timeVec);
    t_dv = datevec(t_dn);
    
    % set rotation(so shoreline is parallel to edge of plot)
    heading = results.heading-rotation;
    [AZI,RG] = meshgrid(Azi,Rg(16:668));
    
    % interpolate onto a smaller cartesian grid

    [~,XSTranIdx] = min(abs(xC - XSTranLoc));
    [XX,YY] = meshgrid(yC,xC);
    [thC,rgC] = cart2pol(XX,YY);
    aziC = wrapTo360(90 - thC*180/pi - heading);
    
    % Handle long runs
    ii = 1;
    if size(timeInt,2) == 64
        if ~exist('timex','var') || isempty(timex)
            load(cubeName,'data')
            timex = double(nanmean(data,3));
        else
        end
        tC = interp2(AZI,RG,double(timex(16:668,:)),aziC',rgC');
        timexCell{1} = tC;
        timeIntCell{1} = mean(timeInt);
        clear timex
    elseif size(timeInt,2) > 64*2
        load(cubeName,'data')
        for i = 1:64:(floor(size(data,3)/64))*64 - 64
            tC = interp2(AZI,RG,double(mean(data(16:668,:,i:i+64),3)),aziC',rgC');
            timexCell{ii} = tC;
            timeIntCell{ii} = timeInt(1,i:i+64);
            ii = ii+1;
            clear tC
        end
    elseif size(timeInt,2) > 64 && size(timeInt,2) <= 64*2
        load(cubeName,'data')
        for i = 1:64:(floor(size(data,3)/64))*64
            tC = interp2(AZI,RG,double(mean(data(16:668,:,i:i+64),3)),aziC',rgC');
            timexCell{ii} = tC;
            timeIntCell{ii} = timeInt(1,i:i+64);        
            ii = ii+1;
            clear tC
        end
    end
    
    if exist('timexCell') == 0
    else
        %% find cross-shore transect
        for IMAGEINDEX = 1:numel(timexCell)
            timex = timexCell{IMAGEINDEX}';
            timeInt = timeIntCell{IMAGEINDEX};
            time = epoch2Matlab(mean(timeInt));
            transect = squeeze(timex(XSTranIdx,:,:))';
            transectAll = [transectAll transect];
            timeAll = [timeAll time];
        end
    end
    clear Rg Azi cubeName results timex timeInt data timeInt timexCell timeIntCell
end

figure,
pcolor(timeAll,XX(1,:),transectAll)
shading flat
colormap(hot)