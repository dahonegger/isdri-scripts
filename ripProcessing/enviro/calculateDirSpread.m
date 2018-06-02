%% calculateDirSpread.m - 
clear variables

% load spoondrift variables
load('D:\Data\ISDRI\SupportData\Spoondrift\SPOT-0014');

% Convert to cartesian convention
thetaMean = 270 - meanDir;

deltaF = f(2)-f(1);

a11 = trapz(f,a1,2);
b11 = trapz(f,b1,2);
a22 = trapz(f,a2,2);
b22 = trapz(f,b2,2);

% a11 = mean(a1,2);
% b11 = mean(b1,2);
% a22 = mean(a2,2);
% b22 = mean(b2,2);

% method 1:
sigma2 = sqrt(2.*(1 - (a1.*cosd(thetaMean) + b1.*sind(thetaMean))));
ss22 = mean(sigma2,2);
delf = f(2)-f(1);
ss2 = trapz(f,sigma2')/delf;

% method 2: 
sigma22 = 0.5.*(1 - (a2.*cosd(2*thetaMean) + b2.*sind(2*thetaMean)));
sigmaV2 = sqrt(sigma22);
ss22_2 = mean(sigma22,2);
delf = f(2)-f(1);
ss2_2 = trapz(f,sigma22')/delf;
