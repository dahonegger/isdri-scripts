% inSituMeasurements_RadarImage.m
% This code plots the radar image with in situ surface current measurements
% for a given time period.
% 1/10/2018


clear variables; home; close all

%% Add path
addpath(genpath('C:\Data\ISDRI\isdri-scripts'));
addpath(genpath('C:\Data\ISDRI\cBathy'));

%% define time period of interest
startTime = '20171002_1600';
endTime = '20171003_0000';

baseDir = 'E:\guadalupe\processed\';
saveDir = ['E:\guadalupe\postprocessed\inSitu\' startTime '_' endTime '\'];
if ~exist(saveDir); mkdir(saveDir); end;


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

%% load variables
rot = -13;
bave = 3;
[Tbave,Ubave,Vbave,Wbave] = loadADCP('D:\Data\ISDRI\SupportData\MacMahan\STR3_AQ.mat', bave, rot);

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
zBedB(1) = zBedB(2) + (zBedB(2)-zBedB(3));

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

for i = 1:size(U,1)
    idx(i) = find(~isnan(U(i,:)),1,'last');
    UUS(i,:) = U(i,(idx(i)-2):idx(i));
    VVS(i,:) = V(i,(idx(i)-2):idx(i));
end

U_surface = mean(UUS,2);
V_surface = mean(VVS,2);

%% loop through radar images
for i = 1:length(cubeList)
    fn = [cubeList(i).folder '\' cubeList(i).name];

    load(fn,'Azi','Rg','results','timex','timeInt') 
    % define radar domain
    rotation = 13;
    heading = results.heading-rotation;
    [AZI,RG] = meshgrid(Azi,Rg(16:668));
    
    % Handle long runs (e.g. 18 minutes
    ii = 1;
    if size(timeInt,2) == 64
        if ~exist('timex','var') || isempty(timex)
            load(fn,'data')
            timex = double(nanmean(data,3));
        else
        end
        tC = interp2(AZI,RG,double(timex(16:668,:)),aziC',rgC');
        timexCell{1} = tC;
        timeIntCell{1} = mean(timeInt);
        pngFileCell{1} = pngFile;
        clear timex
    elseif size(timeInt,2) > 64*2
        load(fn,'data')
        for i = 1:64:(floor(size(data,3)/64))*64 - 64
            tC = interp2(AZI,RG,double(mean(data(16:668,:,i:i+64),3)),aziC',rgC');
            timexCell{ii} = tC;
            timeIntCell{ii} = timeInt(1,i:i+64);
            [path,fname,ext] = fileparts(pngFile);
            tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
            fname = [fname(1:17),tmp,'_pol_timex'];
            pngFileCell{ii} = fullfile(path,[fname,ext]);
            
            ii = ii+1;
            clear tC
        end
    elseif size(timeInt,2) > 64 && size(timeInt,2) <= 64*2
        load(fn,'data')
        for i = 1:64:(floor(size(data,3)/64))*64
            tC = interp2(AZI,RG,double(mean(data(16:668,:,i:i+64),3)),aziC',rgC');
            timexCell{ii} = tC;
            timeIntCell{ii} = timeInt(1,i:i+64);
            [path,fname,ext] = fileparts(pngFile);
            tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
            fname = [fname(1:17),tmp,'_pol_timex'];
            pngFileCell{ii} = fullfile(path,[fname,ext]);
            
            ii = ii+1;
            clear tC
        end
    end
    
    % Convert to world coordinates
    time = datevec(epoch2Matlab(mean(timeInt(:))));
    heading = results.heading-rotation;
    [AZI,RG] = meshgrid(Azi,Rg);
    TH = pi/180*(90-AZI-heading);
    [xdom,ydom] = pol2cart(TH,RG);
    x0 = results.XOrigin;
    y0 = results.YOrigin;
    xdom = xdom;
    ydom = ydom;
    
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
    
    if exist('timexCell') == 0
    else
        for IMAGEINDEX = 1:numel(timexCell)
            %% plot radar image
            % fig1 = figure;
            % fig1.PaperUnits = 'inches';
            % fig1.PaperPosition = [0 0 4 6];
            % pcolor(xdom,ydom,timex)
            % shading flat; axis image
            % colormap(hot)
            % colorbar
            % caxis([20 200])
            % hold on
            % plot(xJMC,yJMC,'b.','MarkerSize',20)
            % axis([-4000 -500 -4000 4000])
            % ttl = ['Timex ' num2str(time(1)) num2str(time(2),'%02i') num2str(time(3),'%02i')...
            %     ' ' num2str(time(4),'%02i') ':' num2str(time(5),'%02i')];
            % title(ttl)
            % figttl1 = [saveDir 'Radar_largeDomain_' num2str(time(1)) num2str(time(2),'%02i')...
            %     num2str(time(3),'%02i') '_' num2str(time(4),'%02i') num2str(time(5),'%02i')];
            
            fig2 = figure;
            fig2.PaperUnits = 'inches';
            fig2.PaperPosition = [0 0 4 6];
            pcolor(xdom,ydom,timex)
            shading flat; axis image
            colormap(hot)
            colorbar
            caxis([50 230])
            hold on
            plot(xJMC,yJMC,'b.','MarkerSize',20)
            arrow([xJMC(2) yJMC(2)],[(UNow*1000+xJMC(2)) (VNow*1000+yJMC(2))],...
                'Length',7,'Width',30*vMag,'tipangle',30,'facecolor','white','edgecolor','white');
            axis([-1500 -500 -1000 1000])
            ttl = ['Timex ' num2str(time(1)) num2str(time(2),'%02i') num2str(time(3),'%02i')...
                ' ' num2str(time(4),'%02i') ':' num2str(time(5),'%02i')];
            title(ttl)
            figttl2 = [saveDir 'Radar_smallDomain_' num2str(time(1)) num2str(time(2),'%02i')...
                num2str(time(3),'%02i') '_' num2str(time(4),'%02i') num2str(time(5),'%02i')];
            
            
            savefig(fig1,[figttl1 '.fig'])
            print(fig1,[figttl1 '.png'],'-dpng')
            
            savefig(fig2,[figttl2 '.fig'])
            print(fig2,[figttl2 '.png'],'-dpng')
            
        end
    end
end

%% define timme point of interest
d1 = startdn;
d2 = enddn;

idxAQ = find(dnUTC_AQ > d1 & dnUTC_AQ < d2);
idxTChain = find(dnUTC > d1 & dnUTC < d2);
idxTides = find(dnTides > d1 & dnTides < d2);
dv1 = datevec(d1);
dv2 = datevec(d2);

tempLimits(1) = min([min(min(tempA(1:11,idxTChain))),min(min(tempB(:,idxTChain))),...
    min(min(tempC(:,idxTChain))), min(min(tempE(:,idxTChain)))]);
tempLimits(2) = max([max(max(tempA(1:11,idxTChain))),max(max(tempB(:,idxTChain))),...
    max(max(tempC(:,idxTChain))), max(max(tempE(:,idxTChain)))]);

%% temperature figure
fig3 = figure;
fig3.PaperUnits = 'inches';
fig3.PaperPosition = [0 0 9 8];
subplot(4,1,1)
pcolor(dnUTC(idxTChain),zBedA(1:11),tempA(1:11,idxTChain))
hold on
shading flat; hcb =colorbar;
caxis(tempLimits)
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedA(1:11)) max(zBedA(1:11))])
% plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+8),'r')
% plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+8),'y')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
datetick('x','keeplimits')
xlabel('Time'); ylabel('Distance above bed (m)');
ttlA = ['Temperature at STRING A (most offshore), ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlA)
xlabel(hcb,'Temperature C')

subplot(4,1,2)
pcolor(dnUTC(idxTChain),zBedB(1:8),tempB(1:8,idxTChain))
shading flat; hcb =colorbar;
hold on
% plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+5),'r')
% plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+5),'y')
caxis(tempLimits)
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedB(1:8)) max(zBedB(1:8))])
datetick('x','keeplimits')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
xlabel('Time'); ylabel('Distance above bed (m)');
ttlB = ['Temperature at STRING B (middle, with ADCP), ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlB)
xlabel(hcb,'Temperature C')

subplot(4,1,3)
pcolor(dnUTC(idxTChain),zBedE(1:8),tempE(1:8,idxTChain))
shading flat; hcb =colorbar;
hold on
% plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+5),'r')
% plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+5),'y')
caxis(tempLimits)
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedE(1:8)) max(zBedE(1:8))])
datetick('x','keeplimits')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
xlabel('Time'); ylabel('Distance above bed (m)');
ttlB = ['Temperature at STRING E (middle, to south), ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlB)
xlabel(hcb,'Temperature C')

subplot(4,1,4)
pcolor(dnUTC(idxTChain),zBedC(1:6),tempC(1:6,idxTChain))
shading flat; hcb =colorbar;
hold on
% plot(dnUTC_AQ(idxAQ),(depth(idxAQ)-mean(depth(idxAQ))+4),'r')
% plot(dnTides(idxTides),(WL(idxTides)-mean(WL(idxTides))+4),'y')
caxis(tempLimits)
axis([dnUTC(idxTChain(1)) dnUTC(idxTChain(end)) min(zBedC(1:6)) max(zBedC(1:6))])
datetick('x','keeplimits')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
xlabel('Time'); ylabel('Distance above bed (m)');
ttlC = ['Temperature at STRING C (most onshore), ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlC)
xlabel(hcb,'Temperature C')
figttl3 = [saveDir 'Temp_' num2str(time(1)) num2str(time(2),'%02i')...
    num2str(time(3),'%02i') '_' num2str(time(4),'%02i') num2str(time(5),'%02i')];

% subplot(3,1,3)
% figure,
% plot(dnUTC_AQ(idxAQ),depth(idxAQ))
% axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 8 13])
% datetick('x','keeplimits')
% % axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 9])
% xlabel('Time'); ylabel('Water surface elevation(m)');
% title('Water surface elevation at STRING B')
%% velocity figure
fig4 = figure;
fig4.PaperUnits = 'inches';
fig4.PaperPosition = [0 0 9 8];
subplot(3,1,1)
pcolor(dnUTC_AQ(idxAQ),ZBed,U(idxAQ,:)')
shading flat; colorbar; colormap(cMap)
caxis([-0.4 0.4])
axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
datetick('x','keeplimits')
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
% axis([min(dnUTC_AQ(1:50000)) max(dnUTC_AQ(1:50000)) 1 11])
xlabel('Time'); ylabel('Distance above bed (m)');
ttlU = ['U velocity at STRING B, ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlU)

subplot(3,1,2)
pcolor(dnUTC_AQ(idxAQ),ZBed,V(idxAQ,:)')
shading flat; colorbar; colormap(cMap)
caxis([-0.4 0.4])
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
datetick('x','keeplimits')
xlabel('Time'); ylabel('Distance above bed (m)');
ttlV = ['V velocity at STRING B, ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlV)

subplot(3,1,3)
pcolor(dnUTC_AQ(idxAQ),ZBed,W(idxAQ,:)')
shading flat; colorbar; colormap(cMap)
caxis([-0.15 0.15])
y1 = get(gca,'ylim');
line([datenum(time) datenum(time)],y1,'Color','r','LineWidth',1)
axis([dnUTC_AQ(idxAQ(1)) dnUTC_AQ(idxAQ(end)) 1 11])
datetick('x','keeplimits')
xlabel('Time'); ylabel('Distance above bed (m)');
ttlW = ['W velocity at STRING B, ' num2str(dv1(2),'%02i')...
    num2str(dv1(3),'%02i') ' - ' num2str(dv2(2),'%02i') num2str(dv2(3),'%02i')];
title(ttlW)
figttl4 = [saveDir 'Velocity_' num2str(time(1)) num2str(time(2),'%02i')...
    num2str(time(3),'%02i') '_' num2str(time(4),'%02i') num2str(time(5),'%02i')];

%% save images


savefig(fig3,[figttl3 '.fig'])
print(fig3,[figttl3 '.png'],'-dpng')

savefig(fig4,[figttl4 '.fig'])
print(fig4,[figttl4 '.png'],'-dpng')
