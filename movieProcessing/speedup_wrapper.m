
<<<<<<< HEAD
clear all; close all;
baseDir = 'D:\uasData\10.6.17 Guadalupe (rips + PR)';
=======
baseDir = 'F:\uasData\10.11.17 Guadalupe (big rip + PR)';
>>>>>>> ripProcessing
files = dir(fullfile(baseDir,'*.MP4'));
speed = 20;

for i = numel(files)-3:numel(files)
    vid_inpath = fullfile(baseDir,files(i).name);
    [saveDir, nameBase, nameExt] = fileparts(vid_inpath);
    vid_outpath = fullfile(saveDir,[nameBase,'_20x',nameExt]);
    [vid_outpath, ffmpeg_output, ffmpeg_exitcode] = ffmpeg_speedup(vid_inpath, speed, vid_outpath);
end