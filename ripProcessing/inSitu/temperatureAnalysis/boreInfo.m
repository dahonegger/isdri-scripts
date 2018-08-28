function [boreHours, boreEndTime, tempDiffMean, tempDiffSurface] = boreInfo(time)
% boreInfo
% 3/14/2018

%% load data
C = load('D:\Data\ISDRI\SupportData\MacMahan\ptsal_tchain_STR3_C');  % Most onshore

tC = C.TCHAIN.time_dnum;
tempC = C.TCHAIN.TEMP';
zBedC = C.TCHAIN.ZBEDT;
zBedC(1) = zBedC(2) + (zBedC(2)-zBedC(3));

%% Redefine time vectors in UTC
dvPDT = datevec(tC);    % tA tB tC and tE are the same
dvUTC = dvPDT;
dvUTC(:,4) = dvPDT(:,4)+7;  % add 7 hours to convert from PDT to UTC
dnUTC = datenum(dvUTC);
dvUTC = datevec(dnUTC);
clear tC

%% find time index
hours = 24;
[~,timeIdx] = min(abs(dnUTC - time));
timeClippedIdx = (timeIdx - hours*3600):timeIdx; % 24 hours before 
timeClipped = dnUTC(timeClippedIdx);

%% find differences between mean temp and bore temp
tBottomSmoothed = movmean(tempC(6,timeClippedIdx),5000);
tNBSmoothed = movmean(tempC(5,timeClippedIdx),5000);
tTopSmoothed = movmean(tempC(1,timeClippedIdx),5000);
tAllSmoothed = movmean(mean(tempC(:,timeClippedIdx)),5000);

diffTempAllBottom = tAllSmoothed - tBottomSmoothed;
diffTempSurfaceBottom = tTopSmoothed - tBottomSmoothed;
diffTAB_demeaned = diffTempAllBottom - mean(diffTempAllBottom);

%% find locations of upcrossings and downcrossings
for i = 1:(length(diffTAB_demeaned)-1)
    upcrossing(i) = diffTAB_demeaned(i+1) > 0 && diffTAB_demeaned(i) < 0;
    downcrossing(i) = diffTAB_demeaned(i+1) < 0 && diffTAB_demeaned(i) > 0;
end
idxUpcrossing = find(upcrossing == 1);
idxDowncrossing = find(downcrossing == 1);

%% find end of bore
% check if last zero crossing is a downcrossing (meaning current time is
% between bores)
if idxUpcrossing(end) < idxDowncrossing(end)
    diffFlipped = fliplr(diffTAB_demeaned(idxUpcrossing(end):idxDowncrossing(end)));
    diffdiffFlipped = movmean(diff(diffFlipped),100);
    idx = find(diffdiffFlipped < 0, 1, 'first');
    idxBoreEnd = idxUpcrossing(end) + length(diffFlipped) - idx;
    
    tempDiffMean = mean(diffTempAllBottom(idxUpcrossing(end):idxDowncrossing(end)));
    tempDiffSurface = mean(diffTempSurfaceBottom(idxUpcrossing(end):idxDowncrossing(end)));
    boreEndTime = timeClipped(idxBoreEnd);
    boreHours = (timeClipped(idxDowncrossing(end)) - timeClipped(idxUpcrossing(end)))*24;
elseif idxUpcrossing(end) >= idxDowncrossing(end)
    tempDiffMean = mean(diffTempAllBottom(idxUpcrossing(end):end));
    tempDiffSurface = mean(diffTempSurfaceBottom(idxUpcrossing(end):end));
    boreEndTime = [];
    boreHours = [];
end

