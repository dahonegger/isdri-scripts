function makeRipMovie(startTime, endTime, dataFolder, saveFolder, saveFolderGif)
% makeRipMovie.m
% 9/17/2017

saveFolderPNGs = [saveFolder startTime '-' endTime];
mkdir(saveFolderPNGs)

cd(dataFolder)
cubeListAll = dirname('*_pol.mat');
if ~isequal(startTime(5:8),endTime(5:8))
    days = str2num(startTime(7:8)):str2num(endTime(7:8));
    for d = 2:length(days)
        dataFolder1 = ['F:\guadalupe\processed\' startTime(1:4) '-' startTime(5:6)...
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
    firstFile = ['Guadalupe_2017' firstDay startTime(10:11) '00_pol.mat'];
    lastFile = ['Guadalupe_2017' lastDay endTime(10:11) '00_pol.mat'];
else
    firstDay = num2str(243 + str2num(startTime(7:8)));
    lastDay = num2str(243 + str2num(endTime(7:8)));
    firstFile = ['Guadalupe_2017' firstDay startTime(10:11) '00_pol.mat'];
    lastFile = ['Guadalupe_2017' lastDay endTime(10:11) '00_pol.mat'];
end
firstFileIndex = find(strcmp(firstFile,cubeListAll)==1);
lastFileIndex = find(strcmp(lastFile,cubeListAll)==1);
cubeList = cubeListAll(firstFileIndex:lastFileIndex);


%% Load data from 512 rotation runs
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
    folder = ['F:\guadalupe\processed\' startTime(1:4) '-' num2str(mth,'%02i')...
        '-' num2str(day,'%02i')];
    cd(folder)
    
    if strcmp(cube(20:21),'00')
        load(cubeList{i},'Azi','Rg','results','data','timeInt')
        
        % define time vector
        
        t_dn = datenum([str2num(cube(11:14)),mth,...
            day,str2num(cube(18:19)),0,0])...
            + ((timeInt(1,:) - timeInt(1,1)))/60/60/24;
        t_dv = datevec(t_dn);
        
        % set rotation(so shoreline is parallel to edge of plot)
        rotation = 13;
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg(16:668));
        
        % interpolate onto a smaller cartesian grid
        xC = -800:800;
        yC = -1200:-500;
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        
        tC = zeros(length(xC),length(yC),512);
        for rot = 1:512
            scanClipped = (double(data(16:668,:,rot)));
            tCR = interp2(AZI,RG,scanClipped,aziC',rgC');
            tC(:,:,rot) = tCR';
        end
        
        % run 2 minute moving average
        movingAve = movmean(tC,96,3);
        rate = 8;
        
        % make .pngs
        for s = 1:rate:512
            fig = figure('visible','off');
            pcolor(XX,YY,movingAve(:,:,s))
            shading interp; axis image
            colormap(hot)
            colorbar
            caxis([50 200])
            ttl = sprintf('%d%02i%d%s%d%s%02i%s%02i', t_dv(s,1), t_dv(s,2), t_dv(s,3), ' - ',...
                t_dv(s,4), ':', t_dv(s,5), ':', round(t_dv(s,6)));
            title(ttl)
            ttlFig = sprintf('%s%s%04i',saveFolderPNGs,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
        
    elseif ~strcmp(cube(20:21),'00')
        load(cubeList{i},'Azi','Rg','results','timex','timeInt')
        
        % define time vector
        t_dn = datenum([str2num(cube(11:14)),mth,...
            day,str2num(cube(18:19)),str2num(cube(20:21)),0]);
        t_dv = datevec(t_dn);
        
        % set up domain
        rotation = 13;
        heading = results.heading-rotation;
        [AZI,RG] = meshgrid(Azi,Rg(16:668));
        
        % interpolate onto a smaller cartesian grid
        xC = -800:800;
        yC = -1200:-500;
        [XX,YY] = meshgrid(yC,xC);
        [thC,rgC] = cart2pol(XX,YY);
        aziC = wrapTo360(90 - thC*180/pi - heading);
        scanClipped = (double(timex(16:668,:)));
        tC = interp2(AZI,RG,scanClipped,aziC',rgC');
        
        for rr = 1:8
            fig = figure('visible','off');
            pcolor(XX,YY,tC')
            shading interp; axis image
            colormap(hot)
            colorbar
            caxis([50 200])
            ttl = sprintf('%d%02i%d%s%d%s%02i%s%02i', t_dv(1), t_dv(2), t_dv(3), ' - ',...
                t_dv(4), ':', t_dv(5), ':', round(t_dv(6)));
            title(ttl)
            ttlFig = sprintf('%s%s%04i',saveFolderPNGs,'\Img_',imgNum);
            imgNum=imgNum+1;
            print(fig,ttlFig,'-dpng')
            close all
            clear ttl ttlFig
        end
    end
    clear Azi Rg results data timex timeInt t_dv t_dn tC
end

cd(saveFolderPNGs)
pngs = dirname('*.png');
outputFile = [saveFolderGif '\' startTime '-' endTime '_rips.gif'];
delayTime = 0.03;
makeGif(pngs,outputFile,delayTime)



