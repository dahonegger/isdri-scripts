function [dnWaves,Hs,dirWaves] = loadWavesNDBC(fname)
%loadWindNDBC loads and reads .txt file of NDBC met data
%   file e.g. http://www.ndbc.noaa.gov/data/realtime2/44039.spec

%  input variables: 
    %   fname: file name (possibly 'WaveData_NDBC44039.txt')
     
%  output variables:
    %   dnWaves: datenum time (UTC)
    %   HsWaves: significant wave height (m)
    %   dirWaves: direction of waves (cardinal degrees wind is coming from)

% Alex Simpson 6/17/17
% Adapted for wave data by Annika O'Dea 9/17/2107

fid=fopen(fname);
for i = 1:2
    [~] = fgetl(fid);
end
tline = fgetl(fid);
k=1;
while ~feof(fid)   
 
    tmp = textscan(tline,'%4f %02d %02d %02d %02d %f %f %f %f %f %s %s %s %f %f');
    dnWaves(k) = datenum(double([(cell2mat(tmp(1))) cell2mat(tmp(2)) cell2mat(tmp(3))...
       cell2mat(tmp(4)) cell2mat(tmp(5)) 0])); %UTC
    Hs(k) = double(cell2mat(tmp(6)));
    if ~isempty(double(cell2mat(tmp(15))))
        dirWaves(k) = double(cell2mat(tmp(15)));
    else 
        dirWaves(k) = nan;
    end
    tline = fgetl(fid);
    k=k+1;
end

fclose(fid);



