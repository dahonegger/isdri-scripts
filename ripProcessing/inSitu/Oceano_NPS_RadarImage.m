% Oceano_NPS_RadarImage.m
% This code plots the radar image with the relevant temperature profiles
% from the Oceano array and the NPS array
% 3/9/2018

clear variables; home; close all

%% Add path
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));
addpath(genpath('C:\Data\ISDRI\cBathy'));

%% define time period of interest
startTime = '20170910_0000';       % start on 20h
endTime = '20170912_0000';         % end on 22h
Hub = 'E';
baseDir = [Hub ':\guadalupe\processed\'];

saveFolder = [Hub ':\guadalupe\postprocessed\inSitu\OceanoNPS\' startTime '-' endTime];
mkdir(saveFolder)

%% define figure parameters
colorAxisLimits = [5 100];
XYLimits = [-8500 0; -7000 7000];
% XYLimits = [-1500 -500; -1000 1000];

%% load variables
A = load('E:\supportData\MacMahan\ptsal_tchain_STR3_A.mat');
B = load('E:\supportData\MacMahan\ptsal_tchain_STR3_B.mat');
C = load('E:\supportData\MacMahan\ptsal_tchain_STR3_C.mat');
E = load('E:\supportData\MacMahan\ptsal_tchain_STR3_E.mat');
OC17 = load('E:\supportData\OSUMoorings\OC17S-T_60s.mat');
OC32 = load('E:\supportData\OSUMoorings\OC32S-T_60s.mat');
OC50 = load('E:\supportData\OSUMoorings\OC50-T_60s.mat');

%% redefine variables
AQ = load('E:\supportData\MacMahan\STR3_AQ.mat');
t = AQ.AQ.time_dnum;
depth = AQ.AQ.Depth;
ZBed = AQ.AQ.Zbed;

tA = A.TCHAIN.time_dnum;
tempA = A.TCHAIN.TEMP';
zBedA = A.TCHAIN.ZBEDT;
zBedA(1) = zBedA(2) + (zBedA(2)-zBedA(3));

tB = B.TCHAIN.time_dnum;
tempB = B.TCHAIN.TEMP';
zBedB = B.TCHAIN.ZBEDT;
zBedB_All = repmat(zBedB,[length(tB),1]);

tC = C.TCHAIN.time_dnum;
tempC = C.TCHAIN.TEMP';
zBedC = C.TCHAIN.ZBEDT;
zBedC(1) = zBedC(2) + (zBedC(2)-zBedC(3));

tE = E.TCHAIN.time_dnum;
tempE = E.TCHAIN.TEMP';
zBedE = E.TCHAIN.ZBEDT; % meters above bed
zBedE(1) = zBedE(2) + (zBedE(2)-zBedE(3));
clear A B C E AQ

tOC17 = OC17.dn;
tempOC17 = OC17.temp;
lat17 = OC17.lat;
lon17 = OC17.lon;
zBed17 = OC17.mab; % meters above bed

tOC32 = OC32.dn;
tempOC32 = OC32.temp;
lat32 = OC32.lat;
lon32 = OC32.lon;
zBed32 = OC32.mab; % meters above bed

tOC50 = OC50.dn;
tempOC50 = OC50.temp;
lat50 = OC50.lat;
lon50 = OC50.lon;
zBed50 = OC50.mab; % meters above bed
clear OC17 OC32 OC50

%% Redefine time vectors in UTC
dvPDT_AQ = datevec(t);    % tA tB tC and tE are the same
dvUTC_AQ = dvPDT_AQ;
dvUTC_AQ(:,4) = dvPDT_AQ(:,4)+7;  % add 7 hours to convert from PDT to UTC
dnUTC_AQ = datenum(dvUTC_AQ);
dvUTC_AQ = datevec(dnUTC_AQ);

dvPDT = datevec(tA);    % tA tB tC and tE are the same
dvUTC = dvPDT;
dvUTC(:,4) = dvPDT(:,4)+7;  % add 7 hours to convert from PDT to UTC
dnUTC = datenum(dvUTC);
dvUTC = datevec(dnUTC);
clear tA

depth_tchain = interp1(dnUTC_AQ,depth,dnUTC);
zBedB_All(:,1) = depth_tchain;

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

idxAQ = find(dnUTC_AQ > startdn & dnUTC_AQ < enddn);
idxTChain = find(dnUTC > startdn & dnUTC < enddn);

tempLimits(1) = min(min(tempB(:,idxTChain)));
tempLimits(2) = max(max(tempB(:,idxTChain)));

% find min and max temperature
% minTemp = min([min(min(tempOC50)),min(min(tempOC32)),min(min(tempOC17)),...
%     min(min(tempA)), min(min(tempC))]);
% maxTemp = max([max(max(tempOC50)),max(max(tempOC32)),max(max(tempOC17)),...
%     max(max(tempA)), max(max(tempC))]);
minTemp = 12;
maxTemp = 19;
v = minTemp:2:maxTemp;

[~,firstFileIndex] = min(abs(startdn - dnList));
[~,lastFileIndex] = min(abs(enddn - dnList));

cubeList = cubeListAll(firstFileIndex:lastFileIndex);
cubeName1 = [cubeList(1).folder '\' cubeList(1).name];
load(cubeName1,'timeInt')
timeInt1 = epoch2Matlab(mean(timeInt(1,:)));
cubeNameEnd = [cubeList(end).folder '\' cubeList(end).name];
load(cubeNameEnd,'timeInt')
timeIntEnd = epoch2Matlab(mean(timeInt(1,:)));

%% Load data from 512 rotation runs
rotation = 13; % domain rotation
imgNum = 1;
for iCube = 1:length(cubeList)
    % Load radar data
    
    cubeName = [cubeList(iCube).folder '\' cubeList(iCube).name];
    load(cubeName,'timeInt','results','Azi','Rg')
    
    % Handle long runs (e.g. 18 minutes
    ii = 1;
    if size(timeInt,2) == 64
        if ~exist('timex','var') || isempty(timex)
            load(cubeName,'data','results')
            timex = double(nanmean(data,3));
        else
        end
        timexCell{1} = timex;
        timeIntCell{1} = mean(timeInt);
        %     pngFileCell{1} = pngFile;
        clear timex
    elseif size(timeInt,2) > 64*2
        load(cubeName,'Azi','Rg','results','data','timeInt')
        for iRot = 1:64:(floor(size(data,3)/64))*64 - 64
            timexCell{ii} = double(mean(data(:,:,iRot:iRot+64),3));
            timeIntCell{ii} = timeInt(1,iRot:iRot+64);
            %         [path,fname,ext] = fileparts(pngFile);
            %         tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
            %         fname = [fname(1:17),tmp,'_pol_timex'];
            %         pngFileCell{ii} = fullfile(path,[fname,ext]);
            
            ii = ii+1;
        end
    elseif size(timeInt,2) > 64 && size(timeInt,2) <= 64*2
        load(cubeFile,'data','results','Azi','Rg')
        for iRot = 1:64:(floor(size(data,3)/64))*64    
            timexCell{ii} = double(mean(data(:,:,iRot:iRot+64),3));
            timeIntCell{ii} = timeInt(1,iRot:iRot+64);
            %         [path,fname,ext] = fileparts(pngFile);
            %         tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
            %         fname = [fname(1:17),tmp,'_pol_timex'];
            %         pngFileCell{ii} = fullfile(path,[fname,ext]);
            
            ii = ii+1;
        end
    end
    
    if exist('timexCell') == 0
    else
        
        % Convert to world coordinates
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg);
        TH = pi/180*(90-AZI-heading);
        [xdom,ydom] = pol2cart(TH,RG);
        %     x0 = results.XOrigin;
        %     y0 = results.YOrigin;
        x0 = 0;
        y0 = 0;
        xdom = (xdom + x0);
        ydom = (ydom + y0);
        
        % add MacMahan's instruments
        % find coordinates of MacMahan instruments
        latJM = [34.98152 34.98260 34.98113 34.98035 34.98597];
        lonJM = [-120.65164 -120.65731 -120.65024 -120.65172 -120.65032];
        
        [yUTM_JM, xUTM_JM] = ll2UTM(latJM,lonJM);
        X_JM = xUTM_JM - results.XOrigin;
        Y_JM = yUTM_JM - results.YOrigin;
        
        % rotate JM instruments onto the same grid
        [thJM,rgJM] = cart2pol(X_JM,Y_JM);
        aziJM = wrapTo360(-thJM*180/pi + 90 - results.heading);
        aziJMC = aziJM - rotation;
        thJMC = pi/180*(90 - aziJMC - results.heading);
        [xJMC,yJMC] = pol2cart(thJMC,rgJM);
        
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
        
        % rotate OC instruments onto the same grid
        [thOc,rgOc] = cart2pol(X_Oc,Y_Oc);
        aziOc = wrapTo360(-thOc*180/pi + 90 - results.heading);
        aziOcC = aziOc - rotation;
        thOcC = pi/180*(90 - aziOcC - results.heading);
        [xOcC,yOcC] = pol2cart(thOcC,rgOc);

        for IMAGEINDEX = 1:numel(timexCell)
            clear timex
            timex = timexCell{IMAGEINDEX};
            timeInt = timeIntCell{IMAGEINDEX};
            time = epoch2Matlab(mean(timeInt));
            dv = datevec(time);
           
            
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 20 8];
            
            sub1 = subplot(5,4, [1 5 9 13 17]);
            pcolor(xdom,ydom,timex)
            shading interp; axis image
            hold on
            plot(xJMC(1:4),yJMC(1:4),'b.','MarkerSize',20)
            plot(xOcC,yOcC,'g.','MarkerSize',20)
            colormap(sub1,hot)
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(dv(1)) num2str(dv(2),'%02i') num2str(dv(3),'%02i') ' - ',...
                num2str(dv(4),'%02i') ':', num2str(dv(5),'%02i')...
                ':' num2str(round(dv(6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            
            sub2 = subplot(5,4,[2 3 4]);
            pcolor(tOC50,zBed50,tempOC50)
            shading flat; colorbar;
            hold on
%             contour(tOC50,zBed50,tempOC50,[14, 14],'k')
%             contour(tOC50,zBed50,tempOC50,[16, 16],'k')
%             contour(tOC50,zBed50,tempOC50,[17, 17],'k')
            
            colormap(sub2,brewermap([],'*RdBu'))
            %             caxis([min(min(tempOC50)) max(max(tempOC50))])
            caxis([minTemp maxTemp])
            axis([timeInt1 timeIntEnd 0 max(zBed50)])
            ticks = timeInt1:4/24:timeIntEnd;
            set(gca, 'xtick', ticks);
            datetick('x',15,'keepticks','keeplimits');
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
            %xlabel('Time'); %ylabel('Distance above bed (m)');
            ttl2 = ['Temperature at 50 m contour'];
            title(ttl2)
            
            sub3 = subplot(5,4,[6 7 8]);
            pcolor(tOC32,zBed32,tempOC32)
            shading flat; colorbar;
            hold on
%             contour(tOC50,zBed50,tempOC50,[14, 14],'k')
%             contour(tOC50,zBed50,tempOC50,[16, 16],'k')
% %             contour(tOC50,zBed50,tempOC50,[17, 17],'k')
            colormap(sub3,brewermap([],'*RdBu'))
            %             caxis([min(min(tempOC32)) max(max(tempOC32))])
            caxis([minTemp maxTemp])
            axis([timeInt1 timeIntEnd 0 max(zBed32)])
            ticks = timeInt1:4/24:timeIntEnd;
            set(gca, 'xtick', ticks);
            datetick('x',15,'keepticks','keeplimits');
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            %xlabel('Time'); %ylabel('Distance above bed (m)');
            ttl3 = ['Temperature at 32 m contour'];
            title(ttl3)
            
            sub4 = subplot(5,4,[10 11 12]);
            pcolor(tOC17,zBed17,tempOC17)
            shading flat; colorbar;
            colormap(sub4,brewermap([],'*RdBu'))
            %             caxis([min(min(tempOC17)) max(max(tempOC17))])
            caxis([minTemp maxTemp])
            axis([timeInt1 timeIntEnd 0 max(zBed17)])
            ticks = timeInt1:4/24:timeIntEnd;
            set(gca, 'xtick', ticks);
            datetick('x',15,'keepticks','keeplimits');
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
            % xlabel('Time'); ylabel('Distance above bed (m)');
            ttl4 = ['Temperature at 17 m contour'];
            title(ttl4)
            
            idx = find(dnUTC > timeInt1 & dnUTC < timeIntEnd);
            sub5 = subplot(5,4,[14 15 16]);
            pcolor(dnUTC(idx),zBedA,tempA(:,idx))
            shading flat; colorbar;
            colormap(sub5,brewermap([],'*RdBu'))
            %             caxis([min(min(tempA)) max(max(tempA))])
            caxis([minTemp maxTemp])
            axis([timeInt1 timeIntEnd 0 max(zBedA)])
            ticks = timeInt1:4/24:timeIntEnd;
            set(gca, 'xtick', ticks);
            datetick('x',15,'keepticks','keeplimits');
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
            % xlabel('Time'); ylabel('Distance above bed (m)');
            ttl5 = ['Temperature at STR A'];
            title(ttl5)
            
            sub6 = subplot(5,4,[18 19 20]);
            pcolor(dnUTC(idx),zBedC,tempC(:,idx))
            shading flat; colorbar;
            colormap(sub6,brewermap([],'*RdBu'))
            %             caxis([min(min(tempA)) max(max(tempA))])
            caxis([minTemp maxTemp])
            axis([timeInt1 timeIntEnd 0 max(zBedC)])
            ticks = timeInt1:4/24:timeIntEnd;
            set(gca, 'xtick', ticks);
           datetick('x',15,'keepticks','keeplimits');
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
            xlabel('Time'); %ylabel('Distance above bed (m)');
            ttl6 = ['Temperature at STR C'];
            title(ttl6)
            
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig timex timeInt time dv
        end
    end
    clear timexCell timeIntCell data
end