
baseDir = 'F:\uasData\10.17.17 Guadalupe (Sounder transects)';
files = dir(fullfile(baseDir,'*.MP4'));
speed = 20;

for i = numel(files):-1:1
    vid_inpath = fullfile(baseDir,files(i).name);
    [saveDir, nameBase, nameExt] = fileparts(vid_inpath);
    vid_outpath = fullfile(saveDir,[nameBase,'_20x',nameExt]);
    [vid_outpath, ffmpeg_output, ffmpeg_exitcode] = ffmpeg_speedup(vid_inpath, speed, vid_outpath);
end