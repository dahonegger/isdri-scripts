% ripDomainMovingAve_Purisima.m
% 3/2/2018
clear variables; home

addpath(genpath('C:\Data\ISDRI\isdri-scripts'));
addpath(genpath('C:\Data\ISDRI\cBathy'));

%% define time of interest
startTime = '20171020_1200';
endTime = '20171021_0000';

Hub = 'E';
baseDir = [Hub ':\purisima\processed\'];

saveFolder = [Hub ':\purisima\postprocessed\ripVideos\' startTime '-' endTime];
mkdir(saveFolder)

%% define figure parameters
colorAxisLimits = [75 170];
% XYLimits = [707 720 3842 3856];
XYLimits = [-2500 -350; -1000 5000];

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
    dd = datevec(doy2date(str2num(cubeListAll(i).name(14:16)),2017));
    dnList(i) = datenum([dd(1), dd(2), dd(3),...
        str2num(cubeListAll(i).name(17:18)),...
        str2num(cubeListAll(i).name(19:20)),0]);
end

startdn = datenum([str2num(startTime(1:4)),str2num(startTime(5:6)),...
    str2num(startTime(7:8)),str2num(startTime(10:11)),str2num(startTime(12:13)),0]);
enddn = datenum([str2num(endTime(1:4)),str2num(endTime(5:6)),...
    str2num(endTime(7:8)),str2num(endTime(10:11)),str2num(endTime(12:13)),0]);

[~,firstFileIndex] = min(abs(startdn - dnList));
[~,lastFileIndex] = min(abs(enddn - dnList));

cubeList = cubeListAll(firstFileIndex:lastFileIndex);

%% Load data from 512 rotation runs
rotation = 18;
imgNum = 1;
for i = 1:length(cubeList)
    % Load radar data
    cubeName = [cubeList(i).folder '\' cubeList(i).name]; dayNum = str2num(cubeList(i).name(14:16));
    load(cubeName,'Azi','Rg','results','timex','timeInt')
    
    % define time vector
    timeVec = mean(timeInt);
    
    % set up domain
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg(18:end));
        
        % interpolate onto a smaller cartesian grid
        xC = XYLimits(2,1):XYLimits(2,2);
        yC = XYLimits(1,1):XYLimits(1,2);
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        scanClipped = timex(18:end,:);
        tC = interp2(AZI,RG,scanClipped,aziC',rgC');

    % make .pngs
        t_dv = datevec(epoch2Matlab(mean(timeInt(1,:))));
        
        fig = figure('visible','off');
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0 0 6 6];
%         pcolor(xdom/1000,ydom/1000,timex');
        pcolor(XX,YY,tC');
        hold on
%         plot(UTME/1000,UTMN/1000,'b*')
        shading interp
        axis image
        colormap(hot)
        colorbar
        caxis(colorAxisLimits)
        axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
        xlabel('Cross-shore x (m)');ylabel('Alongshore y (m)');
        ttl = sprintf('%d%02i%d%s%d%s%02i%s%02i%s', t_dv(1), t_dv(2), t_dv(3), ' - ',...
            t_dv(4), ':', t_dv(5), ':', round(t_dv(6)), ' UTC');
        title(ttl)
        ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
        imgNum=imgNum+1;
        print(fig,ttlFig,'-dpng')

        close all
        clear ttl ttlFig
%     end
    clear Azi Rg results data timex timeInt t_dv t_dn tC
end

% % make movie
% dataFolder = [Hub ':\purisima\processed\' startTime(1:4) '-' startTime(5:6)...
%     '-' startTime(7:8)];
% saveFolder = 'C:\Data\ISDRI\postprocessed\ripVideos\';
% saveFolderGif = [Hub ':\gifs'];

% makeRipMovie(startTime, endTime, dataFolder, saveFolder, saveFolderGif)
