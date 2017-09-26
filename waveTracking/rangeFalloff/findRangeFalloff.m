function [Imean_smoothed] = findRangeFalloff(timex, Rg, Azi)
%% findRangeFallOff.m
% 09/23/2017

% Convert to world coordinates
aziClipped = Azi(81:261);
rgClipped = Rg(334:end)';
timexClipped = double(timex(334:end,81:261));
% heading = results.heading;
% [AZI,RG] = meshgrid(aziClipped,rgClipped);
% TH = pi/180*(90-AZI-heading);
% [xdom,ydom] = pol2cart(TH,RG);

%%% Find mean intensity at each radial distance from radar
%% Range dependence
I_integratedOverAzi = trapz(aziClipped,timexClipped,2);
Imean_RangeDependent_Data = I_integratedOverAzi/(aziClipped(end)-aziClipped(1));

%% Fit function to range falloff in data
%
% f_r = fittype('b0/(b1+rgClipped^b2)','dependent',...
%     {'Imean_RangeDependent_Data'},'independent',{'rgClipped'},...
%     'coefficients',{'b0','b1','b2'});
% [fit2,gof2,fitinfo2] = fit(rgClipped',Imean_RangeDependent_Data,f_r,...
%     'StartPoint',[350 -315 0.879]);
% Imean_RangeDependent_Fit = fit2.b0./(fit2.b1+rgClipped.^fit2.b2);
% 
% rsquare = sprintf('%s%4.3f','R^2 = ',gof2.rsquare);
% b0 = sprintf('%s%4.3f','b0 = ',fit2.b0);
% b1 = sprintf('%s%4.3f','b1 = ',fit2.b1);
% b2 = sprintf('%s%4.3f','b2 = ',fit2.b2);
% str = {rsquare,b0,b1,b2};
% 
% r2 = gof2.rsquare;

%% Loess smooth 
[Imean_smoothed,~] = smooth1d_loess(Imean_RangeDependent_Data,rgClipped,5000,rgClipped);

% % plot to check
% dim = [.5 .6 .3 .3];
% figure;
% plot(rgClipped,Imean_smoothed,'linewidth',2)
% hold on
% plot(rgClipped,Imean_RangeDependent_Data,'r.')
% xlabel('Range (km)'); ylabel('Mean intensity');
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
% legend('Fit','Data')

%% Find intensity anomaly - no range dependence
% RFOMat = repmat(Imean_Fit',[1,length(aziClipped)]);
% I_RangeIndep = (timexClipped - RFOMat);

% % plot to check
% figure,
% pcolor(xdom,ydom,Imean_RangeIndep)
% shading flat; axis equal
% colorbar
% xlabel('X [m]'); ylabel('Y [m]');
% colormap(hot)


