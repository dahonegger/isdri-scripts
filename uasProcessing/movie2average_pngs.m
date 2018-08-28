close all; clear all;
tic
%% USER DEFINED PARAMETERS
fname = 'E:\ctr\uas\20171791107.MOV';
fps = 1; % e.g. 2 = 2Hz sampling
s_avg=30; % sample rate within averaging window
Tavg=4; % time window to avg over, e.g. 10 = 10 seconds
startTime = 45; % seconds into movie you want to start
endTime = 45.6; % seconds into movie you want to stop
%%
addpath('E:\ctr\uas')
videoObject = VideoReader(fname);
numberOfFrames = videoObject.NumberOfFrames;
vidHeight = videoObject.Height;
vidWidth = videoObject.Width;
toc

startFrame = round(startTime.*videoObject.FrameRate); 	
endFrame = round(endTime.*videoObject.FrameRate);
df = round(videoObject.FrameRate./fps);
df_avg=round(videoObject.FrameRate./s_avg);

sum = zeros(vidHeight,vidWidth,3,'single');
numFrames = round((endFrame-startFrame)/df)+1
whichFrame = 1;

for i = startFrame:df:endFrame
frame = single(read(videoObject,i));
sum = sum+frame;
%fileID = ['frame',num2str(i),'.mat'];
frame_cache=zeros(vidHeight,vidWidth,3,'single');
frame_smooth=zeros(vidHeight,vidWidth,3,'single');

num_avg_frames=Tavg*s_avg;
win_halfsize=round(num_avg_frames/2);
for j=i-win_halfsize:df_avg:i+win_halfsize
    frame_cache = frame_cache+single(read(videoObject,j));
   % j
end
toc
frame_smooth=uint8(frame_cache./num_avg_frames);
fig=figure(whichFrame);
%fig=figure(1);
fig.Name=['fig' num2str(whichFrame)];
imagesc(frame_smooth)
%fig.PaperUnits='inches';
%fig.PaperPosition=[0 0 8 4.5];
%truesize(fig)
%print(['T4b\' fig.Name],'-dpng','-r300')

fprintf('completed frame %d of %d\n',whichFrame,numFrames)
% %truesize(fig)
%print(['29Hz\' fig.Name],'-dpng')
whichFrame = whichFrame+1;
end
average = sum./(whichFrame-1); 
figure(whichFrame+1)
imagesc(uint8(frame))
title('last frame')
toc
figure(whichFrame+2)
imagesc(uint8(average));
title('average over 1Hz frames')

%I=rgb2gray(frame_smooth);
I=frame_smooth(:,:,3);
[BW,thresh]=edge(I,'sobel',0.048);
figure(k)
imshow(BW)

% Turn edge detection image into a plot.
%[row, col] = find(BW);
    % If the above is plotted the image will be flipped around horizontal
    % axis since image origin is in upper left corner and plot origin is in
    % lower left corner.  Multiply "row" by -1.
%figure
%plot (col, (row.*-1), '.')
%title 'Plotted Edge Detection Results'
% 
% % convert logicals to doubles 
% BW = BW + 0;  % change BW1 to whatever your logical matrix is
% % define the area of interest (only include areas where the front is
% % located. this doesn't need to be super precise, it is just to remove 
% % points really far away that will throw off the fit).
% cutoffy = [700 1200];
% cutoffx = [1 3840];
% BW = BW(cutoffy(1):cutoffy(2),cutoffx(1):cutoffx(2));
% 
% % define window off of best fit line
% window = 300;   % Anything more than 300 vertical bins away from the best fit 
%                 % line will be removed
% 
% % define grid
% [yS,xS] = size(BW);
% xV = 1:xS;
% yV = 1:yS;
% 
% % redefine logical matrix as x, y coordinates
% [y,x] = find(BW == 1);
% 
% % fit line
% p = polyfit(x,y,1);
% line = p(1)*xV + p(2);
% 
% % remove points more than 300 vertical bins from line 
% yFiltered = y;
% xFiltered = x;
% for i = 1:length(xV)
%     xFiltered(x == xV(i) & y > (line(i) + window)) = nan;
%     xFiltered(x == xV(i) & y < (line(i) - window)) = nan;
%     yFiltered(x == xV(i) & y > (line(i) + window)) = nan;
%     yFiltered(x == xV(i) & y < (line(i) - window)) = nan;
% end
% 
% xFiltered(isnan(xFiltered)) = [];
% yFiltered(isnan(yFiltered)) = [];
% 
% % smooth using a loess filter
% smoothedCurve = smooth1d_loess(yFiltered,xFiltered,3000,xV);
% 
% % plot to check
% figure,
% hold on
% plot(x,y,'.b')      % all points
% plot(xFiltered,yFiltered,'.r')    % points remaining after filtering
% plot(xV,smoothedCurve,'k')  % smoothed curve
% h = legend('All points','Filtered points','Filtered curve');
% xlabel('X'); ylabel('Y'); title('Filtered front edge')

