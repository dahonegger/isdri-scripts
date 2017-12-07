function [dnTides,WL] = loadTidesNOAA(fname)

% 9/20/2017


fid=fopen(fname);
for i = 1:2
    [~] = fgetl(fid);
end
tline = fgetl(fid);
k=1;
while ~feof(fid)   
 
    tmp = textscan(tline,'%s %05s %01s %5f');
    c1 = tmp{1,1};
    c1 = cell2mat(c1(1));
    c2 = cell2mat(tmp{2});
    dnTides(k) = datenum([str2num(c1(1:4)), str2num(c1(6:7)),...
        str2num(c1(9:10)), str2num(c2(1:2)), str2num(c2(4:5)), 0]);
    if ~isempty(cell2mat(tmp(4)))
        WL(k) = cell2mat(tmp(4));
    else
        WL(k) = -999;
    end

    tline = fgetl(fid);
    k=k+1;
end

fclose(fid);
