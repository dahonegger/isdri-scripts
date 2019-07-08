%% ripMovie_64rot_timex:
% 4/20/2018

%% Add path
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));
addpath(genpath('C:\Data\ISDRI\cBathy'));

%% define time of interest
% startTime = '20171006_2100';
% endTime = '20171007_0300';
startTime = '20170914_1400';
endTime = '20170914_1800';

Hub = 'E';
baseDir = [Hub ':\guadalupe\processed\'];
saveFolder = ['E:\guadalupe\postprocessed\ripVideos\' startTime '-' endTime '_2'];
mkdir(saveFolder)

%% define figure parameters
colorAxisLimits = [5 200];
% XYLimits = [-1300 -500; -300 2900];
XYLimits = [-2000 -500; -1000 1000];
% XYLimits = [-2500 -500; -3000 3000];%
% XYLimits = [-7100 2400; -6700 7200];


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

for iCube = 1:length(cubeListAll);
    dd = datevec(doy2date(str2num(cubeListAll(iCube).name(15:17)),2017));
    dnList(iCube) = datenum([dd(1), dd(2), dd(3),...
        str2num(cubeListAll(iCube).name(18:19)),...
        str2num(cubeListAll(iCube).name(20:21)),0]);
end

startdn = datenum([str2num(startTime(1:4)),str2num(startTime(5:6)),...
    str2num(startTime(7:8)),str2num(startTime(10:11)),str2num(startTime(12:13)),0]);
enddn = datenum([str2num(endTime(1:4)),str2num(endTime(5:6)),...
    str2num(endTime(7:8)),str2num(endTime(10:11)),str2num(endTime(12:13)),0]);

[~,firstFileIndex] = min(abs(startdn - dnList));
[~,lastFileIndex] = min(abs(enddn - dnList));

cubeList = cubeListAll(firstFileIndex:lastFileIndex);

%% Load data from 512 rotation runs
% xCutoff = 1068; % range index for clipped scan
% xCutoff = 1335; % range index for clipped scan
xMin = 16;
% xMin = 1;
% xCutoff = 1668; % range index for clipped scan % 5 km

cubeName = [cubeList(1).folder '\' cubeList(1).name];
load(cubeName,'Azi','Rg','results','timex','timeInt') % 6/16/17 with new process scheme, 'timex' available
    
xCutoff = min(abs(Rg - 7000)); % range index for clipped scan % 5 km
% rotation = 0; % NO ROTATION
% rotation = 12; % domain rotation (large domain only)
rotation = 13; % domain rotation 13 for small domain
imgNum = 1;
for iCube = 1:length(cubeList)
    % Load radar data
    cubeName = [cubeList(iCube).folder '\' cubeList(iCube).name];
    load(cubeName,'Azi','Rg','results','timex','timeInt') % 6/16/17 with new process scheme, 'timex' available
    
    % set rotation(so shoreline is parallel to edge of plot)
    heading = results.heading-rotation;
    [~,xCutoff] = min(abs(Rg - 7000));
    [AZI,RG] = meshgrid(Azi,Rg(xMin:xCutoff));

    if rotation == 0
        ii = 1;
        if size(timeInt,2) == 64
            clear timex
            load(cubeName,'data')
            timex = double(mean(data(1:xCutoff,:,:),3));
            timexCell{1} = timex;
            timeIntCell{1} = mean(timeInt);
            clear timex
        elseif size(timeInt,2) > 64*2
            load(cubeName,'data')
            for iRot = 1:64:(floor(size(data,3)/64))*64 - 64
              
                timexCell{ii} = double(mean(data(1:xCutoff,:,iRot:iRot+64),3));
                timeIntCell{ii} = timeInt(1,iRot:iRot+64);
                tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
                
                ii = ii+1;
                clear tC
            end
        elseif size(timeInt,2) > 64 && size(timeInt,2) <= 64*2
            load(cubeName,'data')
            for iRot = 1:64:(floor(size(data,3)/64))*64
               
                timexCell{ii} = double(mean(data(1:xCutoff,:,iRot:iRot+64),3));
                timeIntCell{ii} = timeInt(1,iRot:iRot+64);
                tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
                
                ii = ii+1;
                clear tC
            end
        end
        TH = pi/180*(90-AZI-heading);
        [XX,YY] = pol2cart(TH,RG);
        
    else
        
        % interpolate onto a smaller cartesian grid
        xC = XYLimits(2,1):XYLimits(2,2);
        yC = XYLimits(1,1):XYLimits(1,2);
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        
        % Handle long runs (e.g. 18 minutes
        ii = 1;
        if size(timeInt,2) == 64
            if ~exist('timex','var') || isempty(timex)
                load(cubeName,'data')
                timex = double(nanmean(data,3));
            else
            end
            tC = interp2(AZI,RG,double(timex(xMin:xCutoff,:)),aziC',rgC');
            timexCell{1} = tC;
            timeIntCell{1} = mean(timeInt);
            clear timex
        elseif size(timeInt,2) > 64*2
            load(cubeName,'data')
            for iRot = 1:64:(floor(size(data,3)/64))*64 - 64
                tC = interp2(AZI,RG,double(mean(data(xMin:xCutoff,:,iRot:iRot+64),3)),aziC',rgC');
                timexCell{ii} = tC;
                timeIntCell{ii} = timeInt(1,iRot:iRot+64);
                tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
                
                ii = ii+1;
                clear tC
            end
        elseif size(timeInt,2) > 64 && size(timeInt,2) <= 64*2
            load(cubeName,'data')
            for iRot = 1:64:(floor(size(data,3)/64))*64
                tC = interp2(AZI,RG,double(mean(data(xMin:xCutoff,:,iRot:iRot+64),3)),aziC',rgC');
                timexCell{ii} = tC;
                timeIntCell{ii} = timeInt(1,iRot:iRot+64);
                tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
                
                ii = ii+1;
                clear tC
            end
        end
    end
    
    if exist('timexCell') == 0
    else
        
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
        
        
        for IMAGEINDEX = 1:numel(timexCell)
            timex = timexCell{IMAGEINDEX}';
            timeInt = timeIntCell{IMAGEINDEX};
            t_dv = datevec(epoch2Matlab(timeInt(1)));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 5 6];
            pcolor(XX,YY,timex)
            shading interp; axis image
            colormap(hot)
            colorbar
            hold on
            %             plot(xJMC(1:3),yJMC(1:3),'b.','MarkerSize',20)
            %             plot(xJMC(5),yJMC(5),'b.','MarkerSize',20)
            %             plot(xOcC,yOcC,'g.','MarkerSize',20)
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(t_dv(1)) num2str(t_dv(2),'%02i') num2str(t_dv(3),'%02i') ' - ',...
                num2str(t_dv(4),'%02i') ':', num2str(t_dv(5),'%02i')...
                ':' num2str(round(t_dv(6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
            clear timex timeInt t_dv
        end
    end
    clear timexCell
end

  