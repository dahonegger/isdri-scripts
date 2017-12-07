function [xoRunup, xoRunupErr, yRunup] = runupEdgeDetect(I,xM,yM,xoRunupOld,gaussFiltWidth,iPlot,saveFig,figName)
% identify cross-shore location of the vegetation line on the dune
% Inputs
% I - grayscale image to digitize off of...usually brightest
% xM - FRF cross-shore coordinates of image
% yM - FRF along-shore coordinates of image
% xoRunupOld - vector of FRF cross-shore coordinates of the prior time's
% max runup line
% iPlot - 'On' or 'Off' ##plot flag, iplot = 1 plot, else no plot
% saveFig - saves the figure or not
%
%%written by Meg Palmsten, NRL for dune vegetation
%%edited by Kate Brodie, FRF for max runup line

%first make anything true black (nans white)
I(I==0)=1;

% try a Scharr kernel to identify the edge
Hx= [1;0;-1]*[3 10 3];
IHx = conv2(I,Hx);

%trim the edges because the convolution made it bigger by one pixel on each
%side of the image
IHx = IHx(2:end-1,2:end-1);

% first  pixel and last pixel have edge effects, set value of 1st 
% pixel to the value of the last 1 so it doesn't mess up veg line
% detection
IHx(end,:) = 0;
IHx(1,:) = 0;
% define a Gaussian function
 fun = @(beta,xShore)beta(1)*exp(-(xShore).^2/beta(2));
 
 % make a Gaussian window that is centered around the previous position of
 % the dune to reduce noise
 % if we don't have a guess, have the user coarsely digitize
if isempty(xoRunupOld)
    f=figure;
    imagesc(yM,xM,I)
    [yoRunupDig,xoRunupDig] = ginput(); % digitize the dune veg line
    %check to make sure there are no duplicate points in y
    [yoRunupDig,uniqueIND,~]=unique(yoRunupDig);
    xoRunupDig=xoRunupDig(uniqueIND);
    xoRunupOld = interp1(yoRunupDig, xoRunupDig, yM,'linear','extrap');
    close(f)
end
   
    for ii = 1:size(IHx,2)
    gaussWindow(:,ii) = fun([1 gaussFiltWidth],xM-xoRunupOld(ii));
    end

IHxWindowed = -IHx.*gaussWindow;

% use a lowest cost path algorithm to find the minimum path through the
% filtered image, this should detect the vegetation line.
IHxWindowed(isnan(IHxWindowed))=0;
[Y2,iRunup]=shortestPathStep2(IHxWindowed,1);

% step through each along shore position and fit an Gaussian to the
% convolved image to try and get an error estimate
for ii = 1:size(IHxWindowed,2)
    % find the digitized dune line
    [IHxMax] = -IHxWindowed(iRunup(ii),ii);
    
    % make a guess at a coeffient
    if exist('coefEst')
        betaInitial = coefEst(ii-1,2);
        if betaInitial < 0.5 || betaInitial>20;
            betaInitial = 0.5;  %SB  This prevents solution from artifically locking up in a narrow gaussian width
        end
    else
        betaInitial = 0.5;
    end
    try
        coefEst(ii,:) = nlinfit(xM-xM(iRunup(ii)),-IHxWindowed(:,ii),fun,[IHxMax,betaInitial]);
    catch % try decreasing by a factor of 10 of the previous value
        try
            coefEst(ii,:) = nlinfit(xM-xM(iRunup(ii)),-IHxWindowed(:,ii),fun,[IHxMax,betaInitial/10]);
        catch % try increasing by a factor of 10 of the previous value
            try
                coefEst(ii,:) = nlinfit(xM-xM(iRunup(ii)),-IHxWindowed(:,ii),fun,[IHxMax,betaInitial.*10]);
            catch
                try
                coefEst(ii,:) = nlinfit(xM-xM(iRunup(ii)),-IHxWindowed(:,ii),fun,[IHxMax,betaInitial/100]);
                catch
                try
                    % try increasing by a factor of 10 of the previous value
                coefEst(ii,:) = nlinfit(xM-xM(iRunup(ii)),-IHxWindowed(:,ii),fun,[IHxMax,betaInitial.*100]);
                catch % if none of these work, just give up and make error = 20
                    try
                        coefEst(ii,:) = [coefEst(ii-1,1) 20];
                    catch
                        coefEst(ii,:) = [20 20];
                    end
                end
                end
            end
        end
    end
end

% find crosshore position of vegetation line
xoRunup = xM(iRunup);
xoRunupErr = coefEst(:,2);
yRunup = yM;

% constrain error 
xoRunupErr(xoRunupErr <1) = 1;
xoRunupErr(xoRunupErr >20) = 20;

% plot results

if strcmp(iPlot,'On')||strcmp(iPlot,'Off')
    fig=figure('Visible', iPlot);
    subplot(3,1,1)
    imagesc(yM,xM,I); colormap 'gray'
    hold on
    plot(yM,xoRunup)
   ylim([50 150])
    %title(datestr(epoch2Matlab(time)))  % There is no 'time'
    colormap gray
    grid on
    
    subplot(3,1,2)
    imagesc(yM,xM,IHx); colormap 'gray'
    hold on
    plot(yM,xoRunup)
    plot(yM,xoRunupOld,'m')
    ylim([50 150])
    subplot(3,1,3)
    imagesc(yM,xM,-IHxWindowed); colormap 'gray'
    hold on
    plot(yM,xoRunup)
    plot(yM,xoRunupOld,'m')
    ylim([50 150])
    if saveFig==1
        print(fig, figName, '-dpng')
    end
    close(fig)
    %    pause
end
end

 