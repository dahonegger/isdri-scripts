%% Get Files
if ispc
    attic = '\\attic.engr.oregonstate.edu\hallerm2';
else
    attic = '/nfs/attic/hallerm2';
end

% kmzConcatenate
addpath(fullfile('..','kmzConcatenate'));
addpath(fullfile('..','util'));
datestr_3dago = datestr(timezone_convert(now-3, [], 'UTC'), 'yyyy-mm-dd');

kmzBase = fullfile(attic,'isdri','guadalupe','site_push','kmz');
kmzStackBase = fullfile(attic,'isdri','guadalupe','site_push','kmzStack');
if ~exist(kmzStackBase,'dir');mkdir(kmzStackBase);end

dayDirs = dir(fullfile(kmzBase, '20*-*-*'));

% Get existing kmzStack files
exgKmzDayStacks = dir(fullfile(kmzStackBase, 'kmzStack_20*-*-*.kmz'));

for i = 1:numel(dayDirs)
    fprintf('Stacking %s...', dayDirs(i).name);
    dayDir = dayDirs(i).name;
    dayKmzs = dir(fullfile(kmzBase, dayDir, '*.kmz'));
    if isempty(dayKmzs)
        fprintf('Day empty.\n');
        continue
    end
    stackName = ['kmzStack_', dayDir, '.kmz'];
    if ismember(stackName, {exgKmzDayStacks.name}) && strlte(dayDir, datestr_3dago)
        fprintf('Exists.\n');
        continue
    end
    kmzConcatenate(dayKmzs,fullfile(kmzStackBase,stackName))
    fprintf('Done.\n')
end
