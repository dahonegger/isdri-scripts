function [ rgFunction ] = findAzimuthalRfalloff( IrgVec,range,pngFile )
%FINDAZIMUTHALRFALLOFF Summary of this function goes here
%   Detailed explanation goes here

% f_r = fittype('b0./(b1+range^b2)','dependent',...
%     {'IrgVec'},'independent',{'range'},...
%     'coefficients',{'b0','b1','b2'});
% % [fit2,gof2,fitinfo2] = fit(range',IrgVec,f_r,...
% %     'StartPoint',[50 0 1]);
% [fit2,gof2,fitinfo2] = fit(range',IrgVec,f_r);
% 
% rgFunction = fit2.b0./(fit2.b1+range.^fit2.b2);

modelfun = @(b,range)b(1)./(b(2)+range.^b(3));
mdl = fitnlm(range,IrgVec,modelfun,[.1 -1 .005]);
% mdl = nlinfit(range,IrgVec,modelfun,[200 -200 .5]);

beta = mdl.Coefficients.Estimate;

rgFunction = beta(1)./(beta(2)+range.^beta(3));




% figure;hold on;
% set(gcf,'visible','off')
% plot(range,IrgVec,'.k')
% plot(range,rgFunction,'-r')
% box on
% xlabel('range');
% ylabel('I')
% legend('timex intensity','fit')
% % xlim([0 13000])
% % ylim([5 50])
% if exist('pngFile') == 1 
% print(['D:\guadalupe\postprocessed\rangeFalloffExperiment\',pngFile,'.png'],'-dpng','-r500')
% else
% end

% normalize
timexNorm = IrgVec'.*(1./rgFunction).*(1./mean(IrgVec(:)));


end

