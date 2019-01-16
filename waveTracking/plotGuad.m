function plotGuad( Azi,Rg,timex,heading,XOrigin,YOrigin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[AZI,RG] = meshgrid(Azi,Rg);
TH = pi/180*(90-AZI-heading);
[xdom,ydom] = pol2cart(TH,RG);

latOc = [35.00258 35.00163 35.01176 35.01115 34.9902 34.98947 35.00908 34.98753...
    35.02070 35.01995 35.00762 35.00715 34.99740 34.99693 34.98640 34.98600...
    34.97535 34.97482 34.99587 35.00597 34.98508 35.004242 35.004128];
lonOc = [-120.72263 -120.72283 -120.700133 -120.700333 -120.70285 -120.70277 -120.68142...
    -120.68477 -120.66370 -120.66448 -120.66800 -120.66792 -120.66953 -120.66967...
    -120.67275 -120.67297 -120.67553 -120.67555 -120.66152 -120.65537 -120.66212...
    -120.646192 -120.646586];

[xUTM_Oc, yUTM_Oc] = ll2UTM(latOc,lonOc);
X_Oc = xUTM_Oc - XOrigin;
Y_Oc = yUTM_Oc - YOrigin;

%% load bathy info 
% bathy = load('contours_for_Jack.mat');
% for i = 1:numel(bathy.x)
%     [bathy.E{i}  bathy.N{i}] = ll2UTM(bathy.y{i}, bathy.x{i});
%     bathy.Ykm{i} = (bathy.N{i} - YOrigin)./1000;
%     bathy.Xkm{i} = (bathy.E{i} - XOrigin)./1000;
% end


%% make plot

figure; hold on

% radar
pcolor(xdom./1000,ydom./1000,timex)
shading interp
colormap hot
axis image
caxis([0 110])
% plot oceano array
plot(X_Oc./1000,Y_Oc./1000,'g.','MarkerSize',10)

% plot bathy
% depths = [0 -10 -17 -25 -32 -40 -50];
% for i = 1:numel(depths)
%     tmp = depths(i);
%     for n = find(bathy.z==tmp) 
%        plot(bathy.Xkm{n},bathy.Ykm{n},'color',[.25 .25 .25],'linewidth',.8)
%     end
% end
% text(-9,-11.6,'-50m','color',[.25 .25 .25],'interpreter','latex')
xlim([-13 5]); ylim([-12 13])
box on

end

