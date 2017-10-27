
% list path and files you wish to concatenate
baseDir = 'F:\uasData\10.23.17 Guadalupe (cBathy)';
file1 = 'DJI_0029_DJI_0030_DJI_0031.MP4';
file2 = 'DJI_0032.MP4';

%% 
vid1_inpath = fullfile(baseDir,file1);
vid2_inpath = fullfile(baseDir,file2);

[saveDir1, nameBase1, nameExt1] = fileparts(vid1_inpath);
[saveDir2, nameBase2, nameExt2] = fileparts(vid2_inpath);

 vid_outpath = fullfile(baseDir,[nameBase1,'_',nameBase2,nameExt1]);
 [vid_outpath, ffmpeg_output, ffmpeg_exitcode] = ffmpeg_concatenate(vid1_inpath,vid2_inpath,vid_outpath);
