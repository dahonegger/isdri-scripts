close all; clear all; 
% baseFolder = 'F:\uasData\10.23.17 Guadalupe (cBathy)\cBathy\DJI_0006 thru DJI_0009\';
baseFolder = 'F:\uasData\10.19.17 Guadalupe (cBathy)\cBathy\DHI_0003 thru DJI_0005\';
addpath(genpath(baseFolder))
fileList = dir([baseFolder,'*.mat']);

for matFile = 2:numel(fileList)
    fname = fileList(matFile).name;
    load(fname);
    for i = 1:size(layer1,3)
        tmp(:,:,1) = uint8(layer1(:,:,i));
        tmp(:,:,2) = uint8(layer2(:,:,i));
        tmp(:,:,3) = uint8(layer3(:,:,i));
        
        fig=figure; hold on
        set(gcf,'visible','off')
        imagesc(x,y,tmp); %imagesc needs 3 layers(r,g,b) in uint8 format
        title({['cBathy Footage from Guadalupe'],[datestr(frameTimes(i))]})
        xlabel('X [meters]');ylabel('Y [meters]');
        axis image
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0 0 4 4];
        saveName = datestr(frameTimes(i),'mmddyy HH.MM.SS.FFF');
        print([baseFolder,saveName,'.png'],'-dpng','-r300')
        close all
    end
end

%%

close all; clear all; 
baseFolder = 'F:\uasData\10.23.17 Guadalupe (cBathy)\cBathy\DJI_0006 thru DJI_0009\';
% baseFolder = 'F:\uasData\10.19.17 Guadalupe (cBathy)\cBathy\DHI_0003 thru DJI_0005\';
addpath(genpath(baseFolder))
fileList = dir([baseFolder,'*.mat']);

for matFile = 1:numel(fileList)
    fname = fileList(matFile).name;
    load(fname);
    for i = 1:size(layer1,3)
        tmp(:,:,1) = uint8(layer1(:,:,i));
        tmp(:,:,2) = uint8(layer2(:,:,i));
        tmp(:,:,3) = uint8(layer3(:,:,i));
        
        fig=figure; hold on
        set(gcf,'visible','off')
        imagesc(x,y,tmp); %imagesc needs 3 layers(r,g,b) in uint8 format
        title({['cBathy Footage from Guadalupe'],[datestr(frameTimes(i))]})
        xlabel('X [meters]');ylabel('Y [meters]');
        axis image
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0 0 4 4];
        saveName = datestr(frameTimes(i),'mmddyy HH.MM.SS.FFF');
        print([baseFolder,saveName,'.png'],'-dpng','-r300')
        close all
    end
end