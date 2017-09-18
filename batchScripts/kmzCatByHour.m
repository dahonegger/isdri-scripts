%% Get Files
scrDir = fullfile('/nfs','depot','cce_u1','haller','shared','RADAR_DATA','ISDRI','isdri-scripts');
% scrDir = fullfile(depotDir,'haller','shared','honegger','radar','usrs','connecticut','ctr-scripts');
% inputDir = fullfile(atticDir,'hallerm','RADAR_DATA','CTR','site_push','kmz',filesep);
inputDir = fullfile('/nfs','attic','hallerm2','isdri','guadalupe','site_push','kmz',filesep);

addpath(genpath(scrDir));
files = getFiles(inputDir);


% kmzStackBase = fullfile('C:','Data','CTR','kmzStackByHour');
% kmzStackBase = files(1).folder;
kmzStackBase = fullfile('/nfs','attic','hallerm2','isdri','guadalupe','site_push','kmzStack',filesep);
% if ~exist(kmzStackBase,'dir');mkdir(kmzStackBase);end


clear yyyy ddd HH
id0 = 11;
for i = 1:numel(files)
    yyyy(i) = str2double(files(i).name(id0+(0:3)));
    ddd(i) = str2double(files(i).name(id0+(4:6)));
    HH(i) = str2double(files(i).name(id0+(7:8)));
end

dn = datenum([yyyy(:) 0*ddd(:)+1 ddd(:) HH(:) 0*HH(:) 0*HH(:)]);
dv = datevec(dn);

[uniqueHrs] = unique(HH);

for i = 1:numel(uniqueHrs)
    idx = find(HH==uniqueHrs(i));
    files2stacker = files(idx);
    
    
    kmzStackName = sprintf('Guadalupe_%sHR%s_UTC',datestr(dn(idx(1)),'yyyy-mm-dd'),datestr(dn(idx(1)),'HH'));
    
    kmzStackFile = fullfile(kmzStackBase,[kmzStackName,'.kmz']);
    
    kmzConcatenate(files2stacker,kmzStackFile)
end
