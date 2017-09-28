
baseDir = 'E:\uasData\09.27.17 Guadalupe (rips)';
files = dir(fullfile(baseDir,'*.MP4'));
speed = 20;

for i = 1:numel(files)
    vid_inpath = fullfile(baseDir,files(i).name);
    [saveDir, nameBase, nameExt] = fileparts(vid_inpath);
    vid_outpath = fullfile(saveDir,[nameBase,'_20x',nameExt]);
    [vid_outpath, ffmpeg_output, ffmpeg_exitcode] = ffmpeg_speedup(vid_inpath, speed, vid_outpath);
end