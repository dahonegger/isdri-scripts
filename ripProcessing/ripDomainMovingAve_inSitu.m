% ripDomainMovingAve_inSitu.m
% 9/17/2017
clear variables; home

%% Add path
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));
addpath(genpath('C:\Data\ISDRI\cBathy'));

%% define time of interest
startTime = {'20171002_1600'};
endTime = {'20171002_2230'};

Hub = 'E';
baseDir = [Hub ':\guadalupe\processed\'];

saveFolder = ['E:\guadalupe\postprocessed\ripVideos\temperatureProfiles\' startTime '-' endTime];
mkdir(saveFolder)

%% define figure parameters
colorAxisLimits = [20 220];
% XYLimits = [-1300 -500; -300 2900];
XYLimits = [-1500 -500; -1000 1000];

%% load variables
rot = 13;
bave = 3;
[dnUTC_AQ,Ubave,Vbave,Wbave,ZBed,depth] = loadADCP('D:\Data\ISDRI\SupportData\MacMahan\STR3_AQ.mat', bave, rot);

for i = 1:size(Ubave,1)
    idx(i) = find(~isnan(Ubave(i,:)),1,'last');
    UUS(i,:) = Ubave(i,(idx(i)-2):idx(i));
    VVS(i,:) = Vbave(i,(idx(i)-2):idx(i));
end

U_surface = mean(UUS,2);
V_surface = mean(VVS,2);

A = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_A');  % Most offshore
B = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_B');  % Middle, with ADCP
C = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_C');  % Most onshore
E = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_E');  % to south
load('C:\Data\ISDRI\isdri-scripts\ripProcessing\transects\cMap.mat')
[dnTides,WL] = loadTidesNOAA('D:\Data\ISDRI\SupportData\Tides\TideData_NOAA9411406.txt');

%% Redefine variables

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
zBedE = E.TCHAIN.ZBEDT;
zBedE(1) = zBedE(2) + (zBedE(2)-zBedE(3));
clear A B C E AQ

%% Redefine time vectors in UTC
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

[~,firstFileIndex] = min(abs(startdn - dnList));
[~,lastFileIndex] = min(abs(enddn - dnList));

cubeList = cubeListAll(firstFileIndex:lastFileIndex);

%% Load data from 512 rotation runs
xCutoff = 1068; % range index for clipped scan
rotation = 13; % domain rotation
imgNum = 1;
for i = 1:length(cubeList)
    % Load radar data
    
    cubeName = [cubeList(i).folder '\' cubeList(i).name];
    load(cubeName,'timeInt')
    if size(timeInt,2) > 512
        load(cubeName,'Azi','Rg','results','data','timeInt')
        
        % define time vector
        timeVec = mean(timeInt);
        t_dn = epoch2Matlab(timeVec);
        t_dv = datevec(t_dn);
        
        % set rotation(so shoreline is parallel to edge of plot)
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg(16:xCutoff));
        
        % interpolate onto a smaller cartesian grid
        xC = XYLimits(2,1):XYLimits(2,2);
        yC = XYLimits(1,1):XYLimits(1,2);
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        
        % cut cube into 3 to make it easier to use
        c3 = round(size(data,3)/3);
        buffer = 45;
        cube1 = data(:,:,(1:c3+buffer));
        cube2 = data(:,:,(c3-buffer):(2*c3+buffer));
        cube3 = data(:,:,(2*c3-buffer):end);
        timeCube1 = t_dv((1:c3+buffer),:);
        timeCube2 = t_dv((c3-buffer):(2*c3+buffer),:);
        timeCube3 = t_dv((2*c3-buffer):end,:);
        tC1 = zeros(length(xC),length(yC),size(cube1,3));
        tC2 = zeros(length(xC),length(yC),size(cube2,3));
        tC3 = zeros(length(xC),length(yC),size(cube3,3));
        for rot = 1:size(cube1,3)
            scanClipped = (double(cube1(16:xCutoff,:,rot)));
            tCR = interp2(AZI,RG,scanClipped,aziC',rgC');
            tC1(:,:,rot) = tCR';
            clear tCR scanClipped
        end
        for rot = 1:size(cube2,3)
            scanClipped = (double(cube2(16:xCutoff,:,rot)));
            tCR = interp2(AZI,RG,scanClipped,aziC',rgC');
            tC2(:,:,rot) = tCR';
            clear tCR scanClipped
        end
        for rot = 1:size(cube3,3)
            scanClipped = (double(cube3(16:xCutoff,:,rot)));
            tCR = interp2(AZI,RG,scanClipped,aziC',rgC');
            tC3(:,:,rot) = tCR';
            clear tCR scanClipped
        end
        
        % run 2 minute moving average
        movingAve1 = movmean(tC1,96,3);
        movingAve2 = movmean(tC2,96,3);
        movingAve3 = movmean(tC3,96,3);
        rate = 8;
        
        % add MacMahan's instruments
        % find coordinates of MacMahan instruments
        latJM = [34.9826 34.981519 34.981131 34.980439 34.98035 34.985969];
        lonJM = [-120.657311 -120.651639 -120.650239 -120.647881...
            -120.651719 -120.650319];
        
        [yUTM_JM, xUTM_JM] = ll2UTM(latJM,lonJM);
        X_JM = xUTM_JM - results.XOrigin;
        Y_JM = yUTM_JM - results.YOrigin;
        
        % rotate onto the same grid
        [thJM,rgJM] = cart2pol(X_JM,Y_JM);
        aziJM = wrapTo360(-thJM*180/pi + 90 - results.heading);
        aziJMC = aziJM - rotation;
        thJMC = pi/180*(90 - aziJMC - results.heading);
        [xJMC,yJMC] = pol2cart(thJMC,rgJM);
        
        % add Oceanus instruments
        % find coordinates of Oceanus instruments
        latOc = [35.004242 35.004128 34.985083 35.005967 34.995867 35.0207...
            35.01995 35.007617 35.00715 34.9974 34.996933 34.9864 34.986...
            34.97535 34.974817];
        lonOc = [-120.646192 -120.646586 -120.662117 -120.655367 -120.661517...
            -120.6637 -120.664483 -120.668 -120.667917 -120.669533 -120.669667...
            -120.67275 -120.672967 -120.675533 -120.67555];
        [yUTM_Oc, xUTM_Oc] = ll2UTM(latOc,lonOc);
        X_Oc = xUTM_Oc - results.XOrigin;
        Y_Oc = yUTM_Oc - results.YOrigin;
        
        % rotate onto the same grid
        [thOc,rgOc] = cart2pol(X_Oc,Y_Oc);
        aziOc = wrapTo360(-thOc*180/pi + 90 - results.heading);
        aziOcC = aziOc - rotation;
        thOcC = pi/180*(90 - aziOcC - results.heading);
        [xOcC,yOcC] = pol2cart(thOcC,rgOc);
        
        
        % make .pngs
        for s = 1:rate:c3
            time = datenum(timeCube1(s,:));
            UNow = interp1(dnUTC_AQ, U_surface, time);
            VNow = interp1(dnUTC_AQ, V_surface,time);
            vMag = sqrt(UNow^2 + VNow^2);
            
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 12 6];
            
            sub1 = subplot(2,3, [1 4]);
            pcolor(XX,YY,movingAve1(:,:,s))
            shading interp; axis image
            hold on
            plot(xJMC(1:3),yJMC(1:3),'b.','MarkerSize',20)
            plot(xJMC(5),yJMC(5),'b.','MarkerSize',20)
            arrow([xJMC(2) yJMC(2)],[(UNow*1000+xJMC(2)) (VNow*1000+yJMC(2))],...
                'Length',3,'Width',15*vMag,'tipangle',20,'facecolor','white','edgecolor','white');
            colormap(sub1,hot)
            %             colorbar
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(timeCube1(s,1)) num2str(timeCube1(s,2),'%02i') num2str(timeCube1(s,3),'%02i') ' - ',...
                num2str(timeCube1(s,4),'%02i') ':', num2str(timeCube1(s,5),'%02i')...
                ':' num2str(round(timeCube1(s,6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            
            sub2 = subplot(2,3,[2 3]);
            pcolor(dnUTC_AQ(idxAQ),ZBed,Ubave(idxAQ,:)')
            shading flat; colorbar; colormap(sub2, cMap)
            caxis([-0.4 0.4])
            axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlU = ['U velocity at STRING B'];
            title(ttlU)
            
            timeMat = repmat(dnUTC(idxTChain),[1,length(zBedB)]);
            sub3 = subplot(2,3,[5 6]);
            pcolor(timeMat',zBedB_All(idxTChain,:)',tempB(:,idxTChain))
            shading flat; hcb =colorbar;
            colormap(sub3, parula);
            hold on
            %             pcolor(dnUTC(idxTChain),depth_tchain,tempB(1,idxTChain))
            % plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+4),'r')
            % plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+4),'y')
            caxis(tempLimits)
            axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 1 max(depth)])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlC = ['Temperature at STRING B'];
            title(ttlC)
            xlabel(hcb,'Temperature C')
            
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
        for s = (buffer+2):rate:(size(cube2,3) - buffer - 2);
            time = datenum(timeCube2(s,:));
            UNow = interp1(dnUTC_AQ, U_surface, time);
            VNow = interp1(dnUTC_AQ, V_surface,time);
            vMag = sqrt(UNow^2 + VNow^2);
            
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 12 6];
            
            sub1 = subplot(2,3, [1 4]);
            pcolor(XX,YY,movingAve2(:,:,s))
            shading interp; axis image
            hold on
            plot(xJMC(1:3),yJMC(1:3),'b.','MarkerSize',20)
            plot(xJMC(5),yJMC(5),'b.','MarkerSize',20)
            %             plot(xOcC,yOcC,'g.','MarkerSize',20)
            arrow([xJMC(2) yJMC(2)],[(UNow*1000+xJMC(2)) (VNow*1000+yJMC(2))],...
                'Length',3,'Width',15*vMag,'tipangle',20,'facecolor','white','edgecolor','white');
            colormap(sub1,hot)
            %             colorbar
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(timeCube2(s,1)) num2str(timeCube2(s,2),'%02i') num2str(timeCube2(s,3),'%02i') ' - ',...
                num2str(timeCube2(s,4),'%02i') ':', num2str(timeCube2(s,5),'%02i')...
                ':' num2str(round(timeCube2(s,6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            
            time = datenum(timeCube2(s,:));
            sub2 = subplot(2,3,[2 3]);
            pcolor(dnUTC_AQ(idxAQ),ZBed,Ubave(idxAQ,:)')
            shading flat; colorbar; colormap(sub2, cMap)
            caxis([-0.4 0.4])
            axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlU = ['U velocity at STRING B'];
            title(ttlU)
            
            timeMat = repmat(dnUTC(idxTChain),[1,length(zBedB)]);
            sub3 = subplot(2,3,[5 6]);
            pcolor(timeMat',zBedB_All(idxTChain,:)',tempB(:,idxTChain))
            shading flat; hcb =colorbar;
            colormap(sub3, parula);
            hold on
            %             pcolor(dnUTC(idxTChain),depth_tchain,tempB(1,idxTChain))
            % plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+4),'r')
            % plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+4),'y')
            caxis(tempLimits)
            axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 1 max(depth)])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlC = ['Temperature at STRING B'];
            title(ttlC)
            xlabel(hcb,'Temperature C')
            
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
        for s = buffer:rate:size(movingAve3,3)
            
            time = datenum(timeCube3(s,:));
            UNow = interp1(dnUTC_AQ, U_surface, time);
            VNow = interp1(dnUTC_AQ, V_surface,time);
            vMag = sqrt(UNow^2 + VNow^2);
            
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 12 6];
            
            sub1 = subplot(2,3, [1 4]);
            pcolor(XX,YY,movingAve3(:,:,s))
            shading interp; axis image
            hold on
            plot(xJMC(1:3),yJMC(1:3),'b.','MarkerSize',20)
            plot(xJMC(5),yJMC(5),'b.','MarkerSize',20)
            arrow([xJMC(2) yJMC(2)],[(UNow*1000+xJMC(2)) (VNow*1000+yJMC(2))],...
                'Length',3,'Width',15*vMag,'tipangle',20,'facecolor','white','edgecolor','white');
            colormap(sub1,hot)
            %             colorbar
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(timeCube3(s,1)) num2str(timeCube3(s,2),'%02i') num2str(timeCube3(s,3),'%02i') ' - ',...
                num2str(timeCube3(s,4),'%02i') ':', num2str(timeCube3(s,5),'%02i')...
                ':' num2str(round(timeCube3(s,6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            
            time = datenum(timeCube3(s,:));
            sub2 = subplot(2,3,[2 3]);
            pcolor(dnUTC_AQ(idxAQ),ZBed,Ubave(idxAQ,:)')
            shading flat; colorbar; colormap(sub2, cMap)
            caxis([-0.4 0.4])
            axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlU = ['U velocity at STRING B'];
            title(ttlU)
            
            timeMat = repmat(dnUTC(idxTChain),[1,length(zBedB)]);
            sub3 = subplot(2,3,[5 6]);
            pcolor(timeMat',zBedB_All(idxTChain,:)',tempB(:,idxTChain))
            shading flat; hcb =colorbar;
            colormap(sub3, parula);
            hold on
            %             pcolor(dnUTC(idxTChain),depth_tchain,tempB(1,idxTChain))
            % plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+4),'r')
            % plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+4),'y')
            caxis(tempLimits)
            axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 1 max(depth)])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlC = ['Temperature at STRING B'];
            title(ttlC)
            xlabel(hcb,'Temperature C')
            
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
    elseif size(timeInt,2) == 512
        load(cubeName,'Azi','Rg','results','data','timeInt')
        
        % define time vector
        timeVec = mean(timeInt);
        t_dn = epoch2Matlab(timeVec);
        t_dv = datevec(t_dn);
        
        % set rotation(so shoreline is parallel to edge of plot)
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg(16:xCutoff));
        
        % interpolate onto a smaller cartesian grid
        xC = XYLimits(2,1):XYLimits(2,2);
        yC = XYLimits(1,1):XYLimits(1,2);
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        
        tC = zeros(length(xC),length(yC),512);
        for rot = 1:512
            scanClipped = (double(data(16:xCutoff,:,rot)));
            tCR = interp2(AZI,RG,scanClipped,aziC',rgC');
            tC(:,:,rot) = tCR';
        end
        
        % run 2 minute moving average
        movingAve = movmean(tC,96,3);
        rate = 8;
        
        % add MacMahan's instruments
        % find coordinates of MacMahan instruments
        latJM = [34.9826 34.981519 34.981131 34.980439 34.98035 34.985969];
        lonJM = [-120.657311 -120.651639 -120.650239 -120.647881...
            -120.651719 -120.650319];
        
        [yUTM_JM, xUTM_JM] = ll2UTM(latJM,lonJM);
        X_JM = xUTM_JM - results.XOrigin;
        Y_JM = yUTM_JM - results.YOrigin;
        
        % rotate onto the same grid
        [thJM,rgJM] = cart2pol(X_JM,Y_JM);
        aziJM = wrapTo360(-thJM*180/pi + 90 - results.heading);
        aziJMC = aziJM - rotation;
        thJMC = pi/180*(90 - aziJMC - results.heading);
        [xJMC,yJMC] = pol2cart(thJMC,rgJM);
        
        % add Oceanus instruments
        % find coordinates of Oceanus instruments
        latOc = [35.004242 35.004128 34.985083 35.005967 34.995867 35.0207...
            35.01995 35.007617 35.00715 34.9974 34.996933 34.9864 34.986...
            34.97535 34.974817];
        lonOc = [-120.646192 -120.646586 -120.662117 -120.655367 -120.661517...
            -120.6637 -120.664483 -120.668 -120.667917 -120.669533 -120.669667...
            -120.67275 -120.672967 -120.675533 -120.67555];
        [yUTM_Oc, xUTM_Oc] = ll2UTM(latOc,lonOc);
        X_Oc = xUTM_Oc - results.XOrigin;
        Y_Oc = yUTM_Oc - results.YOrigin;
        
        % rotate onto the same grid
        [thOc,rgOc] = cart2pol(X_Oc,Y_Oc);
        aziOc = wrapTo360(-thOc*180/pi + 90 - results.heading);
        aziOcC = aziOc - rotation;
        thOcC = pi/180*(90 - aziOcC - results.heading);
        [xOcC,yOcC] = pol2cart(thOcC,rgOc);
        
        % make .pngs
        for s = 1:rate:512
            time = t_dn(s);
            UNow = interp1(dnUTC_AQ, U_surface, time);
            VNow = interp1(dnUTC_AQ, V_surface,time);
            vMag = sqrt(UNow^2 + VNow^2);
            
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 12 6];
            
            sub1 = subplot(2,3, [1 4]);
            pcolor(XX,YY,movingAve(:,:,s))
            shading interp; axis image
            hold on
            plot(xJMC(1:3),yJMC(1:3),'b.','MarkerSize',20)
            plot(xJMC(5),yJMC(5),'b.','MarkerSize',20)
            arrow([xJMC(2) yJMC(2)],[(UNow*1000+xJMC(2)) (VNow*1000+yJMC(2))],...
                'Length',3,'Width',15*vMag,'tipangle',20,'facecolor','white','edgecolor','white');
            colormap(sub1,hot)
            %             colorbar
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(t_dv(s,1)) num2str(t_dv(s,2),'%02i') num2str(t_dv(s,3),'%02i') ' - ',...
                num2str(t_dv(s,4),'%02i') ':', num2str(t_dv(s,5),'%02i')...
                ':' num2str(round(t_dv(s,6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            
            sub2 = subplot(2,3,[2 3]);
            pcolor(dnUTC_AQ(idxAQ),ZBed,Ubave(idxAQ,:)')
            shading flat; colorbar; colormap(sub2, cMap)
            caxis([-0.4 0.4])
            axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlU = ['U velocity at STRING B'];
            title(ttlU)
            
            timeMat = repmat(dnUTC(idxTChain),[1,length(zBedB)]);
            sub3 = subplot(2,3,[5 6]);
            pcolor(timeMat',zBedB_All(idxTChain,:)',tempB(:,idxTChain))
            shading flat; hcb =colorbar;
            colormap(sub3, parula);
            hold on
            %             pcolor(dnUTC(idxTChain),depth_tchain,tempB(1,idxTChain))
            % plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+4),'r')
            % plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+4),'y')
            caxis(tempLimits)
            axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 1 max(depth)])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlC = ['Temperature at STRING B'];
            title(ttlC)
            xlabel(hcb,'Temperature C')
            
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
    elseif size(timeInt,2) > 65 && size(timeInt,2) < 130
        load(cubeName,'Azi','Rg','results','timex','timeInt')
        
        % define time vector
        timeVec = mean(mean(timeInt));
        t_dn = epoch2Matlab(timeVec);
        t_dv = datevec(t_dn);
        
        % set up domain
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg(16:xCutoff));
        
        % interpolate onto a smaller cartesian grid
        xC = XYLimits(2,1):XYLimits(2,2);
        yC = XYLimits(1,1):XYLimits(1,2);
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        scanClipped = (double(timex(16:xCutoff,:)));
        tC = interp2(AZI,RG,scanClipped,aziC',rgC');
        
        % add MacMahan's instruments
        % find coordinates of MacMahan instruments
        latJM = [34.9826 34.981519 34.981131 34.980439 34.98035 34.985969];
        lonJM = [-120.657311 -120.651639 -120.650239 -120.647881...
            -120.651719 -120.650319];
        
        [yUTM_JM, xUTM_JM] = ll2UTM(latJM,lonJM);
        X_JM = xUTM_JM - results.XOrigin;
        Y_JM = yUTM_JM - results.YOrigin;
        
        % rotate onto the same grid
        [thJM,rgJM] = cart2pol(X_JM,Y_JM);
        aziJM = wrapTo360(-thJM*180/pi + 90 - results.heading);
        aziJMC = aziJM - rotation;
        thJMC = pi/180*(90 - aziJMC - results.heading);
        [xJMC,yJMC] = pol2cart(thJMC,rgJM);
        
        % add Oceanus instruments
        % find coordinates of Oceanus instruments
        latOc = [35.004242 35.004128 34.985083 35.005967 34.995867 35.0207...
            35.01995 35.007617 35.00715 34.9974 34.996933 34.9864 34.986...
            34.97535 34.974817];
        lonOc = [-120.646192 -120.646586 -120.662117 -120.655367 -120.661517...
            -120.6637 -120.664483 -120.668 -120.667917 -120.669533 -120.669667...
            -120.67275 -120.672967 -120.675533 -120.67555];
        [yUTM_Oc, xUTM_Oc] = ll2UTM(latOc,lonOc);
        X_Oc = xUTM_Oc - results.XOrigin;
        Y_Oc = yUTM_Oc - results.YOrigin;
        
        % rotate onto the same grid
        [thOc,rgOc] = cart2pol(X_Oc,Y_Oc);
        aziOc = wrapTo360(-thOc*180/pi + 90 - results.heading);
        aziOcC = aziOc - rotation;
        thOcC = pi/180*(90 - aziOcC - results.heading);
        [xOcC,yOcC] = pol2cart(thOcC,rgOc);
        
        for rr = 1:round((size(timeInt,2)/10))
            time = datenum(timeCube1(s,:));
            UNow = interp1(dnUTC_AQ, U_surface, time);
            VNow = interp1(dnUTC_AQ, V_surface,time);
            vMag = sqrt(UNow^2 + VNow^2);
            
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 12 6];
            
            sub1 = subplot(2,3, [1 4]);
            pcolor(XX,YY,movingAve1(:,:,s))
            shading interp; axis image
            hold on
            plot(xJMC(1:3),yJMC(1:3),'b.','MarkerSize',20)
            plot(xJMC(5),yJMC(5),'b.','MarkerSize',20)
            %             plot(xOcC,yOcC,'g.','MarkerSize',20)
            colormap(sub1,hot)
            arrow([xJMC(2) yJMC(2)],[(UNow*1000+xJMC(2)) (VNow*1000+yJMC(2))],...
                'Length',3,'Width',15*vMag,'tipangle',20,'facecolor','white','edgecolor','white');
            %             colorbar
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(timeCube1(s,1)) num2str(timeCube1(s,2),'%02i') num2str(timeCube1(s,3),'%02i') ' - ',...
                num2str(timeCube1(s,4),'%02i') ':', num2str(timeCube1(s,5),'%02i')...
                ':' num2str(round(timeCube1(s,6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            
            time = datenum(timeCube1(s,:));
            sub2 = subplot(2,3,[2 3]);
            pcolor(dnUTC_AQ(idxAQ),ZBed,Ubave(idxAQ,:)')
            shading flat; colorbar; colormap(sub2, cMap)
            caxis([-0.4 0.4])
            axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlU = ['U velocity at STRING B'];
            title(ttlU)
            
            timeMat = repmat(dnUTC(idxTChain),[1,length(zBedB)]);
            sub3 = subplot(2,3,[5 6]);
            pcolor(timeMat',zBedB_All(idxTChain,:)',tempB(:,idxTChain))
            shading flat; hcb =colorbar;
            colormap(sub3, parula);
            hold on
            %             pcolor(dnUTC(idxTChain),depth_tchain,tempB(1,idxTChain))
            % plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+4),'r')
            % plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+4),'y')
            caxis(tempLimits)
            axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 1 max(depth)])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlC = ['Temperature at STRING B'];
            title(ttlC)
            xlabel(hcb,'Temperature C')
            
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
    elseif size(timeInt,2) == 64
        load(cubeName,'Azi','Rg','results','timex','timeInt')
        
        % define time vector
        timeVec = mean(mean(timeInt));
        t_dn = epoch2Matlab(timeVec);
        t_dv = datevec(t_dn);
        
        % set up domain
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg(16:xCutoff));
        
        % interpolate onto a smaller cartesian grid
        xC = XYLimits(2,1):XYLimits(2,2);
        yC = XYLimits(1,1):XYLimits(1,2);
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        scanClipped = (double(timex(16:xCutoff,:)));
        tC = interp2(AZI,RG,scanClipped,aziC',rgC');
        
        % add MacMahan's instruments
        % find coordinates of MacMahan instruments
        latJM = [34.9826 34.981519 34.981131 34.980439 34.98035 34.985969];
        lonJM = [-120.657311 -120.651639 -120.650239 -120.647881...
            -120.651719 -120.650319];
        
        [yUTM_JM, xUTM_JM] = ll2UTM(latJM,lonJM);
        X_JM = xUTM_JM - results.XOrigin;
        Y_JM = yUTM_JM - results.YOrigin;
        
        % rotate onto the same grid
        [thJM,rgJM] = cart2pol(X_JM,Y_JM);
        aziJM = wrapTo360(-thJM*180/pi + 90 - results.heading);
        aziJMC = aziJM - rotation;
        thJMC = pi/180*(90 - aziJMC - results.heading);
        [xJMC,yJMC] = pol2cart(thJMC,rgJM);
        
        % add Oceanus instruments
        % find coordinates of Oceanus instruments
        latOc = [35.004242 35.004128 34.985083 35.005967 34.995867 35.0207...
            35.01995 35.007617 35.00715 34.9974 34.996933 34.9864 34.986...
            34.97535 34.974817];
        lonOc = [-120.646192 -120.646586 -120.662117 -120.655367 -120.661517...
            -120.6637 -120.664483 -120.668 -120.667917 -120.669533 -120.669667...
            -120.67275 -120.672967 -120.675533 -120.67555];
        [yUTM_Oc, xUTM_Oc] = ll2UTM(latOc,lonOc);
        X_Oc = xUTM_Oc - results.XOrigin;
        Y_Oc = yUTM_Oc - results.YOrigin;
        
        % rotate onto the same grid
        [thOc,rgOc] = cart2pol(X_Oc,Y_Oc);
        aziOc = wrapTo360(-thOc*180/pi + 90 - results.heading);
        aziOcC = aziOc - rotation;
        thOcC = pi/180*(90 - aziOcC - results.heading);
        [xOcC,yOcC] = pol2cart(thOcC,rgOc);
        
        for rr = 1:12
            time = t_dn;
            UNow = interp1(dnUTC_AQ, U_surface, time);
            VNow = interp1(dnUTC_AQ, V_surface,time);
            vMag = sqrt(UNow^2 + VNow^2);
            
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 12 6];
            
            sub1 = subplot(2,3, [1 4]);
            pcolor(XX,YY,tC')
            shading interp; axis image
            hold on
            plot(xJMC(1:3),yJMC(1:3),'b.','MarkerSize',20)
            plot(xJMC(5),yJMC(5),'b.','MarkerSize',20)
            arrow([xJMC(2) yJMC(2)],[(UNow*1000+xJMC(2)) (VNow*1000+yJMC(2))],...
                'Length',3,'Width',15*vMag,'tipangle',20,'facecolor','white','edgecolor','white');
            colormap(sub1,hot)
            %             colorbar
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(t_dv(1)) num2str(t_dv(2),'%02i') num2str(t_dv(3),'%02i') ' - ',...
                num2str(t_dv(4),'%02i') ':', num2str(t_dv(5),'%02i')...
                ':' num2str(round(t_dv(6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('Cross-shore x (m)'); ylabel('Alongshore y (m)')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            
            time = t_dn;
            sub2 = subplot(2,3,[2 3]);
            pcolor(dnUTC_AQ(idxAQ),ZBed,Ubave(idxAQ,:)')
            shading flat; colorbar; colormap(sub2, cMap)
            caxis([-0.4 0.4])
            axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlU = ['U velocity at STRING B'];
            title(ttlU)
            
            timeMat = repmat(dnUTC(idxTChain),[1,length(zBedB)]);
            sub3 = subplot(2,3,[5 6]);
            pcolor(timeMat',zBedB_All(idxTChain,:)',tempB(:,idxTChain))
            shading flat; hcb =colorbar;
            colormap(sub3, parula);
            hold on
            %             pcolor(dnUTC(idxTChain),depth_tchain,tempB(1,idxTChain))
            % plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+4),'r')
            % plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+4),'y')
            caxis(tempLimits)
            axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) 1 max(depth)])
            datetick('x','keeplimits')
            y1 = get(gca,'ylim');
            line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
            % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
            xlabel('Time'); ylabel('Distance above bed (m)');
            ttlC = ['Temperature at STRING B'];
            title(ttlC)
            xlabel(hcb,'Temperature C')
            
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
    end
    clear Azi Rg results data timex timeInt t_dv t_dn tC timeCube1 timeCube2 timeCube3 s UNow VNow time
end

% % make movie
% dataFolder = [Hub ':\guadalupe\processed\' startTime(1:4) '-' startTime(5:6)...
%     '-' startTime(7:8)];
% saveFolder = 'C:\Data\ISDRI\postprocessed\ripVideos\';
% saveFolderGif = [Hub ':\gifs'];

% makeRipMovie(startTime, endTime, dataFolder, saveFolder, saveFolderGif)
