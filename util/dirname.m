function imnames = dirname(foldername, returnFolders)
%% This function returns a cell array of files using the dir command
% This just makes it easier so you dont have to write a for loop to extract
% the filenames into a cell array
if nargin==1
    returnFolders=0;
end

contents = dir(foldername);
if ~isdir(foldername)
    foldername = fileparts(foldername);
end
imnames = [];
numgoodfiles=0;

for i=1:numel(contents)
    if returnFolders && contents(i).isdir && ~strcmp(contents(i).name,'.') && ~strcmp(contents(i).name,'..')
        numgoodfiles = numgoodfiles + 1;
        imnames{numgoodfiles} = fullfile(foldername, contents(i).name);
        
    elseif ~returnFolders && ~contents(i).isdir 
        numgoodfiles = numgoodfiles+1;
        imnames{numgoodfiles} = fullfile(foldername, contents(i).name);
    end
end


end