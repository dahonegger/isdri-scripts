function outpath = uigetpath(path_filter)
[outfile, outdir] = uigetfile(path_filter);
outpath = fullfile(outdir, outfile);
