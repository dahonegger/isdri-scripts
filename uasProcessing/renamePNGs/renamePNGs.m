close all; clear all;

imDir = 'F:\uasData\10.23.17 Guadalupe (cBathy)\cBathy\DJI_0006 thru DJI_0009\';
addpath(genpath(imDir))
fileList = dir([imDir,'*.png']);

for imId = 1:numel(fileList)
    imName = fileList(imId).name; %access file name
    imRename = ['frame',num2str(imId,'%04d'),'.png'];
    movefile(fullfile(imDir,imName),fullfile('F:\uasData\10.23.17 Guadalupe (cBathy)\cBathy\renamed',imRename))
    fprintf('renamed %d of %d \n',imDir,numel(fileList))
    
    
end