close all; clear all;

% load time stack
load('2017-09-10_timestack.mat')

% plot time stack
[Time,Range] = meshgrid(txDn,Rg);
h=figure; hold on;
set(h,'units','inches')
set(h,'position',[0.8083 2.9917 13.7250 4.3750])
pcolor(Range,Time,txIMat)
shading interp
colormap hot
box on
set(gca,'xdir','reverse')
xlim([0 7000])
ylim([datenum('09-10 18:00','mm-dd HH:MM'), datenum('09-11 00:00','mm-dd HH:MM')])
datetick('y','mm-dd HH:MM')
axis tight
xlim([0 9000])
caxis([0 150])
ylabel('Time [Hr]'); xlabel('Range [km]')

% plot bathy 
% hold on
% for i = 1:numel(Zbathy)
%     plot([Rbathy(i) Rbathy(i)],[txDn(1) txDn(end)],'-c')
%     tx = text(Rbathy(i),txDn(150),[num2str(Zbathy(i)), ' m depth'],'color','c','verticalalignment','bottom');
%     set(tx,'Rotation',90)
% end

%% clicking out speeds
[x y] = ginput(10);

for j = 1:2:numel(x)-1
    hold on
    plot([x(j) x(j+1)],[y(j) y(j+1)],'-w','linewidth',3)
    numer = abs(x(j+1) - x(j)); %meters
    denom = (y(j+1) - y(j)).*24.*60.*60; %seconds
    velocity = numer./denom;
    text(((x(j)+x(j+1))/2), ((y(j)+y(j+1))/2),[num2str(round(velocity,2)),' m/s'],'color','w','horizontalalignment','left','verticalalignment','top','fontsize',14);
end 

%% radon transform?
%trim off high intensities
trim_mat = txIMat(500:end,:);
figure;imagesc(trim_mat)
colormap hot

theta = -90:90;
[R,xp] = radon(trim_mat,theta);
figure; hold on
imagesc(theta,xp,R)
colormap hot

Rfilt = R;
Rfilt(R<=0.5*max(R(:))) = 0;
figure; hold on
imagesc(theta,xp,Rfilt)
colormap hot

I2 = iradon(Rfilt,theta);
figure;
imshow(I2)