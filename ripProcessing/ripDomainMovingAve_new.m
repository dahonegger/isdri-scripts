% ripDomainMovingAve.m
% 9/17/2017
clear variables; home

addpath(genpath('C:\Data\ISDRI\isdri-scripts'));

%% define time of interest
startTime = '20171017_1615';
endTime = '20171018_0230';

saveFolder = ['C:\Data\ISDRI\postprocessed\ripVideos3\' startTime '-' endTime];
mkdir(saveFolder)

%% define figure parameters
colorAxisLimits = [30 220];
% XYLimits = [-1300 -500; -300 2900];
XYLimits = [-1300 -500; -700 1200];

%% make list of cubes
Hub = 'E'; 
dataFolder = [Hub ':\guadalupe\processed\' startTime(1:4) '-' startTime(5:6)...
    '-' startTime(7:8)];
cd(dataFolder)
cubeListAll = dirname('*_pol.mat');
if ~isequal(startTime(5:8),endTime(5:8))
    days = str2num(startTime(7:8)):str2num(endTime(7:8));
    for d = 2:length(days)
        dataFolder1 = [Hub ':\guadalupe\processed\' startTime(1:4) '-' startTime(5:6)...
            '-' sprintf('%02i',days(2))];
        cd(dataFolder1)
        cL = dirname('*_pol.mat');
        cubeListAll = [cubeListAll cL];
        clear dataFolder1 pL
    end
end

if str2num(startTime(5:6)) == 9
    firstDay = num2str(243 + str2num(startTime(7:8)));
    lastDay = num2str(243 + str2num(endTime(7:8)));
    firstFile = ['Guadalupe_2017' firstDay startTime(10:11)...
        startTime(12:13) '_pol.mat'];
    lastFile = ['Guadalupe_2017' lastDay endTime(10:11)...
        endTime(12:13) '00_pol.mat'];
else
    firstDay = num2str(273 + str2num(startTime(7:8)));
    lastDay = num2str(273 + str2num(endTime(7:8)));
    firstFile = ['Guadalupe_2017' firstDay startTime(10:11)...
        startTime(12:13) '_pol.mat'];
    lastFile = ['Guadalupe_2017' lastDay endTime(10:11)...
        endTime(12:13) '_pol.mat'];
end
firstFileIndex = find(strcmp(firstFile,cubeListAll)==1);
lastFileIndex = find(strcmp(lastFile,cubeListAll)==1);
cubeList = cubeListAll(firstFileIndex:lastFileIndex);

%% Load data from 512 rotation runs
xCutoff = 1068; % range index for clipped scan
rotation = 13; % domain rotation
imgNum = 1;
for i = 1:length(cubeList)
    % Load radar data
    cube = cubeList{i}; dayNum = str2num(cube(15:17));
    if dayNum < 273
        day = dayNum - 243;
        mth = 9;
    else
        day = dayNum - 273;
        mth = 10;
    end
    folder = [Hub ':\guadalupe\processed\' startTime(1:4) '-' num2str(mth,'%02i')...
        '-' num2str(day,'%02i')];
    cd(folder)
    
    load(cubeList{i},'timeInt')
    if size(timeInt,2) > 130
        load(cubeList{i},'Azi','Rg','results','data','timeInt')
        
        % define time vector
        timeVec = mean(timeInt);
        t_dn = epoch2Matlab(timeVec);
        t_dv = datevec(t_dn);
%         t_dn = datenum([str2num(cube(11:14)),mth,...
%             day,str2num(cube(18:19)),0,0])...
%             + ((timeInt(1,:) - timeInt(1,1)))/60/60/24;
%         t_dv = datevec(t_dn);
        
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
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 4 6];
            pcolor(XX,YY,movingAve1(:,:,s))
            shading interp; axis image
            hold on
%             plot(xJMC,yJMC,'b.','MarkerSize',20)
%             plot(xOcC,yOcC,'g.','MarkerSize',20)
            colormap(hot)
            colorbar
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(timeCube1(s,1)) num2str(timeCube1(s,2),'%02i') num2str(timeCube1(s,3),'%02i') ' - ',...
                num2str(timeCube1(s,4),'%02i') ':', num2str(timeCube1(s,5),'%02i')...
                ':' num2str(round(timeCube1(s,6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('X [m]'); ylabel('Y [m]')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
        for s = (buffer+2):rate:(size(cube2,3) - buffer - 2);
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 4 6];
            pcolor(XX,YY,movingAve2(:,:,s))
            shading interp; axis image
            hold on
%             plot(xJMC,yJMC,'b.','MarkerSize',20)
%             plot(xOcC,yOcC,'g.','MarkerSize',20)
            colormap(hot)
            colorbar
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(timeCube2(s,1)) num2str(timeCube2(s,2),'%02i') num2str(timeCube2(s,3),'%02i') ' - ',...
                num2str(timeCube2(s,4),'%02i') ':', num2str(timeCube2(s,5),'%02i')...
                ':' num2str(round(timeCube2(s,6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('X [m]'); ylabel('Y [m]')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
        for s = buffer:rate:size(movingAve3,3)
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 4 6];
            pcolor(XX,YY,movingAve3(:,:,s))
            shading interp; axis image
            hold on
%             plot(xJMC,yJMC,'b.','MarkerSize',20)
%             plot(xOcC,yOcC,'g.','MarkerSize',20)
            colormap(hot)
            colorbar
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(timeCube3(s,1)) num2str(timeCube3(s,2),'%02i') num2str(timeCube3(s,3),'%02i') ' - ',...
                num2str(timeCube3(s,4),'%02i') ':', num2str(timeCube3(s,5),'%02i')...
                ':' num2str(round(timeCube3(s,6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('X [m]'); ylabel('Y [m]')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
    elseif size(timeInt,2) > 65 && size(timeInt,2) < 130
        load(cubeList{i},'Azi','Rg','results','timex','timeInt')
        
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
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 4 6];
            pcolor(XX,YY,tC')
            shading interp; axis image
            colormap(hot)
            colorbar
            hold on
%             plot(xJMC,yJMC,'b.','MarkerSize',20)
%             plot(xOcC,yOcC,'g.','MarkerSize',20)
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(t_dv(1)) num2str(t_dv(2),'%02i') num2str(t_dv(3),'%02i') ' - ',...
                num2str(t_dv(4),'%02i') ':', num2str(t_dv(5),'%02i')...
                ':' num2str(round(t_dv(6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('X [m]'); ylabel('Y [m]')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
    elseif size(timeInt,2) == 64
        load(cubeList{i},'Azi','Rg','results','timex','timeInt')
        
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
        
        for rr = 1:6
            fig = figure('visible','off');
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 4 6];
            pcolor(XX,YY,tC')
            shading interp; axis image
            colormap(hot)
            colorbar
            hold on
%             plot(xJMC,yJMC,'b.','MarkerSize',20)
%             plot(xOcC,yOcC,'g.','MarkerSize',20)
            caxis([colorAxisLimits(1) colorAxisLimits(2)])
            axis([XYLimits(1,1) XYLimits(1,2) XYLimits(2,1) XYLimits(2,2)])
            ttl = [num2str(t_dv(1)) num2str(t_dv(2),'%02i') num2str(t_dv(3),'%02i') ' - ',...
                num2str(t_dv(4),'%02i') ':', num2str(t_dv(5),'%02i')...
                ':' num2str(round(t_dv(6)),'%02i') ' UTC'];
            title(ttl)
            xlabel('X [m]'); ylabel('Y [m]')
            ttlFig = sprintf('%s%s%04i',saveFolder,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
    end
    clear Azi Rg results data timex timeInt t_dv t_dn tC timeCube1 timeCube2 timeCube3 s
end

% % make movie
% dataFolder = [Hub ':\guadalupe\processed\' startTime(1:4) '-' startTime(5:6)...
%     '-' startTime(7:8)];
% saveFolder = 'C:\Data\ISDRI\postprocessed\ripVideos\';
% saveFolderGif = [Hub ':\gifs'];

% makeRipMovie(startTime, endTime, dataFolder, saveFolder, saveFolderGif)
