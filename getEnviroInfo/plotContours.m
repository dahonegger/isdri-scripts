function plotContours(depths)

load('bathyContours.mat')

for i = 1:numel(depths)
    tmp = depths(i);
    for n = find(z==tmp) 
       plot(x{n},y{n},'color',[1 1 1],'linewidth',1)
    end
end
end

