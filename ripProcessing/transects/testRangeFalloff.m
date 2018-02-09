% testRangeFalloff

load('E:\guadalupe\processed\2017-09-01\Guadalupe_20172440000_pol.mat');
load('E:\guadalupe\postprocessed\alongshoreTransectMatrix\2017-09-01.mat')

[Imean_smoothed,range] = findRangeFalloff(timex, Rg, Azi);

%% find rg of each location
xCMaxI = -1100:-500;
yC = -800:800;
xTran = xCMaxI(idxMaxI);
xTran1 = xTran(1,:);
RgTran = sqrt((xTran1+100).^2 + yC.^2);

for i = 1:length(RgTran)
    [~,idxRg1] = min(abs((RgTran(i) - range)));
    idxRg(i) = idxRg1;
    clear idxRg1
end

for yy = 1:length(yC)
    TMat100_rangeCorrected(yy) = txIMat_100(1,yy) - Imean_smoothed(idxRg(yy));
end

figure,
plot(yC,txIMat_100(1,:))
hold on
plot(yC,TMat100_rangeCorrected)


plot(xCMaxI(idxMaxI(idx,:)),yC,'b')