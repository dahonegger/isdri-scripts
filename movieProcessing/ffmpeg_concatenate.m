function [vid_outpath, ffmpeg_output, ffmpeg_exitcode] = ...
    ffmpeg_speedup(vid1_inpath, vid2_inpath, vid_outpath, varargin)
% FFMPEG_SPEEDUP
% Use ffmpeg to speed up a video file (ffmpeg must support reading and
%  writing the codec used for the file)
%
% Usage:
% [vid_outpath, ffmpeg_output, ffmpeg_exitcode] = ...
%    ffmpeg_speedup(vid_inpath, speed, vid_outpath, varargin)
% 
% Required Inputs:
%   vid_inpath:
%       full or relative path to the video file 
%   speed: Desired output speed. Note this is truncated to nearest 0.1x.
%
% Optional Inputs:
%   vid_outpath:
%       full or relative path to save the new file. Defaults to the input
%       with with <speed>x appended. if you want to use the default but
%       specific more arguments, just put a [] or '' here.
%   'fps', fps:
%       Desired output fps. Default keeps same as input file. Note that
%       this results in decimation of the file in a speedup.
%   'res', resolution:
%       Desired pixel output resolution 'H:V'. -1 for either H or V
%       preserves aspect ratio. Default is '-1:1080'.
%
% Outputs:
%   vid_outpath:
%     Either the auto-generated or manually specifed output video path.
%   ffmpeg_output:
%     command-line output of the ffmpeg command.
%   ffmpeg_exitcode:
%     Exit code of the ffmpeg command. 0 indicates success.
%

ffmpeg_bin = 'C:\ffmpeg\current\bin\ffmpeg.exe';
% speed = round(speed*10)/10;  % Nearest 0.1
[vid1_dir, vid1_name, vid1_ext] = fileparts(vid1_inpath);
[vid2_dir, vid2_name, vid2_ext] = fileparts(vid2_inpath);
if nargin < 3 || isempty(vid_outpath)
    vid_outpath = fullfile(vid_dir, ...
        sprintf('%s_%gx%s', vid_name, speed, vid_ext));
end
fps_str = '';
resolution = '-1:1080';
if ~isempty(varargin)
    i = 1;
    while i < numel(varargin)
        switch varargin{i}
            case 'fps'
                fps_str = sprintf(' -r %g', varargin{i+1});
                i = i + 2;
                continue
            case 'resolution'
                resolution = varargin{i+1};
                i = i + 2;
                continue
        end
    end
end

% generate file list
fid = fopen('vidList.txt','w');
fprintf(fid,'%s%c%s%c\r\n','file ','''',vid1_inpath,'''');
fprintf(fid,'%s%c%s%c\r\n','file ','''',vid2_inpath,'''');
fclose(fid)

% Command is as follows:
% ffmpeg -y -i "<inpath>" [-r <fps>] -filter:v
% ffmpeg -f concat -safe 0 -i mylist.txt -c copy output
%     "setpts=<1/speed>*PTS,scale="<resolution>" "<outpath>"
% 
% -y means always overwrite
% default is to keep the same fps as the input file
% -1 in the resolution spec preserves aspect ratio
ffmpeg_command = sprintf( ...
    '"%s" -f concat -safe 0 -i vidList.txt -c copy "%s"', ...
    ffmpeg_bin, vid_outpath);

[ffmpeg_exitcode, ffmpeg_output] = system(ffmpeg_command, '-echo');
