
% list path and files you wish to concatenate
baseDir = 'E:\uasData\09.27.17 Guadalupe (rips)';
file1 = 'DJI_0092_20x.MP4';
file2 = 'DJI_0093_20x.MP4';

%% 
vid1_inpath = fullfile(baseDir,file1);
vid2_inpath = fullfile(baseDir,file2);

[saveDir1, nameBase1, nameExt1] = fileparts(vid1_inpath);
[saveDir2, nameBase2, nameExt2] = fileparts(vid2_inpath);

 vid_outpath = fullfile(baseDir,[nameBase1,'_',nameBase2,'_concatenate',nameExt1]);
 
 [vid_outpath, ffmpeg_output, ffmpeg_exitcode] = ffmpeg_concatenate(vid1_inpath,vid2_inpath,vid_outpath);
