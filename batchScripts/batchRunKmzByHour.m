dirs = dir(fullfile('/nfs','attic','hallerm2','isdri','guadalupe','site_push','kmz'));
dirs = dirs(3:end);


for i = 5:length(dirs)
    indir = fullfile(dirs(i).folder,dirs(i).name);
%     
%     cmd = sprintf('matlab -nosplash -nodesktop -r "kmzCatByHour(''%s'');exit;" &',indir);
%     
%     disp(cmd)
%     eval(['!',cmd])
%     
%     pause(5)
%     
%     
    kmzCatByHour(indir)
end