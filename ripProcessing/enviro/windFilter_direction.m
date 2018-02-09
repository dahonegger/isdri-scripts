function [offshoreEvents,t_BA,windMag_BA,windDir_BA] = windFilter_direction(dn,...
    windMag,windDir,anemometerHeight,rotation)
%% windFilter

%% band-average to at least 10 minute (depends on sampling frequency)
dt = (dn(2) - dn(1))*24*60; % in minutes

if dt < 10
    windMag_BA = zeros(size(dn));
    windDir_BA = zeros(size(dn));
    t_BA = zeros(size(dn));
    dirWind_rad = degtorad(windDir);
    dW = unwrap(dirWind_rad);
    
    bave = ceil(10/dt);
    
    for ir = 1:bave:(length(dn) - bave + 1)
        t_BA(ir) = mean(dn(ir:(ir+bave-1)));
        windMag_BA(ir) = mean(windMag(ir:(ir+bave-1)));
        windDir_BA(ir) = mean(dW(ir:(ir+bave-1)));
    end
    dW_BA = dW(1:bave:end);
    windDir_BA = wrapTo360(rad2deg(dW_BA));
    t_BA = t_BA(1:bave:end);
    windMag_BA = windMag_BA(1:bave:end);
else
    t_BA = dn;
    windMag_BA = windMag;
    windDir_BA = windMag;
end


%% calculate wind stress
[~,~,tx,~] = calcWindStress(windMag_BA,windDir_BA,rotation,anemometerHeight); %% POSITIVE rotation rotates to left in function

%% find high wind times
timesOffshore = t_BA;
timesOffshore(tx > -0.02) = nan;
timesOffshore(isnan(tx)) = nan;

%% find events
idxOffshore = find(~isnan(timesOffshore));
diffOffshore = diff(idxOffshore);
gaps = find(diffOffshore>5);
event = 1;
for i = 1:length(gaps);
    if i == 1
    	offshoreEvents(event,1) = idxOffshore(1);
        offshoreEvents(event,2) = idxOffshore(gaps(1));
        event = event+1;
    else 
        offshoreEvents(event,1) = idxOffshore(gaps(i-1)+1);
        offshoreEvents(event,2) = idxOffshore(gaps(i));
        event = event+1;
    end
end

offshoreEvents(event,1) = idxOffshore(gaps(end)+1);
offshoreEvents(event,2) = idxOffshore(end);
clear event
