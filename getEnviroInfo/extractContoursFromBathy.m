clear all; close all;

[Z, R] = arcgridread('D:\supportData\bathy\port_san_luis_public_mhw.asc');

figure
hold on
xlim([-120.9 -120.6]); ylim([34.9 35.2])
mapshow(zeros(size(Z)),R,'CData',Z,'DisplayType','surface')
% mapshow(Z,R,'DisplayType','surface')

% mapshow(Z, R, 'DisplayType', 'contour', ...
%    'LineColor','black', 'ShowText', 'on');

demcmap(Z)

[C, h] = contourm(Z,R,[0,-10,-20,-30,-40,-50,-60,-70,-80,-90,-100,-110],'ShowText','on','LineColor','k');

[x,y,z] = C2xyz(C);


XOrigin = 715354.239024821;
YOrigin = 3873247.49763499;
addpath('C:\Data\isdri\isdri-scripts\util');
[Lat Lon] = UTM2ll(YOrigin,XOrigin,10);

for n = find(z==0); % only loop through the z = 0 values. 
    plot(x{n},y{n},'r','linewidth',2)
end

for n = find(z==-30); % only loop through the z = 0 values. 
    plot(x{n},y{n},'r','linewidth',2)
end

for n = find(z==-50); % only loop through the z = 0 values. 
    plot(x{n},y{n},'r','linewidth',2)
end
    
for n = find(z==-1000); % only loop through the z = 0 values. 
    plot(x{n},y{n},'r','linewidth',2)
end

xlim([-120.9 -120.6]); ylim([34.9 35.2])

save('bathyContours.mat','x','y','z')

% figure;
% idx1=C<-100; idx2 = C>30 & C<40;
% foo = C(1,idx1(1,:)); foo2 = C(2,idx2(2,:));
% scatter(C(1,idx1(1,:)),C(2,idx2(2,:)))