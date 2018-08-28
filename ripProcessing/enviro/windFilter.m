function [lowWindEvents,highWindEvents,t_BA,windMag_BA] = windFilter_speed(dn,windMag,lowThreshold,highThreshold,)
%% windFilter

%% band-average to at least 10 minute (depends on sampling frequency)
dt = (dn(2) - dn(1))*24*60; % in minutes

if dt < 10
    windMag_BA = zeros(size(dn));
    t_BA = zeros(size(dn));
    
    bave = ceil(10/dt);
    
    for ir = 1:bave:(length(dn) - bave + 1)
        t_BA(ir) = mean(dn(ir:(ir+bave-1)));
        windMag_BA(ir) = mean(windMag(ir:(ir+bave-1)));
    end
    t_BA = t_BA(1:bave:end);
    windMag_BA = windMag_BA(1:bave:end);
else
    t_BA = dn;
    windMag_BA = windMag;
end

%% find high wind times
timesHighWinds = t_BA;
timesHighWinds(windMag_BA < highThreshold) = nan;
timesHighWinds(isnan(windMag_BA)) = nan;

%% find low wind times
timesLowWinds = t_BA;
timesLowWinds(windMag_BA > lowThreshold) = nan;
timesLowWinds(isnan(windMag_BA)) = nan;

%% find events
idxHighWinds = find(~isnan(timesHighWinds));
diffHighWind = diff(idxHighWinds);
gaps = find(diffHighWind>5);
event = 1;
for i = 1:length(gaps);
    if i == 1
    	highWindEvents(event,1) = idxHighWinds(1);
        highWindEvents(event,2) = idxHighWinds(gaps(1));
        event = event+1;
    else 
        highWindEvents(event,1) = idxHighWinds(gaps(i-1)+1);
        highWindEvents(event,2) = idxHighWinds(gaps(i));
        event = event+1;
    end
end

highWindEvents(event,1) = idxHighWinds(gaps(end)+1);
highWindEvents(event,2) = idxHighWinds(end);
clear event

idxLowWinds = find(~isnan(timesLowWinds));
diffLowWind = diff(idxLowWinds);
gapsLow = find(diffLowWind>5);
event = 1;
for i = 1:length(gapsLow);
    if i == 1
    	lowWindEvents(event,1) = idxLowWinds(1);
        lowWindEvents(event,2) = idxLowWinds(gapsLow(1));
        event = event+1;
    else 
        lowWindEvents(event,1) = idxLowWinds(gapsLow(i-1)+1);
        lowWindEvents(event,2) = idxLowWinds(gapsLow(i));
        event = event+1;
    end
end

lowWindEvents(event,1) = idxLowWinds(gapsLow(end)+1);
lowWindEvents(event,2) = idxLowWinds(end);

%% remove single indices
for i = 1:length(highWindEvents)
    if highWindEvents(i,2) - highWindEvents(i,1) <= 2
        highWindEvents(i,1) = nan;
    end
end
for i = 1:length(lowWindEvents)
    if lowWindEvents(i,2) - lowWindEvents(i,1) <= 2
        lowWindEvents(i,1) = nan;
    end
end
highWindEvents(isnan(highWindEvents(:,1)),:) = [];
lowWindEvents(isnan(lowWindEvents(:,1)),:) = [];

%% calculate wind stress

