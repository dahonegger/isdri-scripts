function [Tbave,Ubave,Vbave,Wbave] = loadADCP(fname, bave, rot)
% 1/19/2018

%% load data
load(fname)

%% Redefine variables
t = AQ.time_dnum;
depth = AQ.Depth;
ZBed = AQ.Zbed;
Un = AQ.Un;
Ue = AQ.Ue;
W = AQ.W;

dvPDT_AQ = datevec(t);    % tA tB tC and tE are the same
dvUTC_AQ = dvPDT_AQ; 
dvUTC_AQ(:,4) = dvPDT_AQ(:,4)+7;  % add 7 hours to convert from PDT to UTC   
dnUTC_AQ = datenum(dvUTC_AQ);
dvUTC_AQ = datevec(dnUTC_AQ);


%% define rotation

R = [cosd(rot) -sind(rot); sind(rot) cosd(rot)];

for i = 1:size(Ue,2)
    velocity = [Ue(:,i) Un(:,i)];
    velR = velocity*R;
    U(:,i) = velR(:,1);
    V(:,i) = velR(:,2);
end

%% band average to a different frequency

Ubave = zeros(size(U));
Vbave = zeros(size(V));
Wbave = zeros(size(W));
Tbave = zeros(size(dnUTC_AQ));
if bave == 1    % leave at 30 seconds
else
    for ir = 1:bave:(size(U,1) - bave + 1);
        Tbave(ir) = mean(dnUTC_AQ(ir:(ir+bave-1)));
    end
    for ic = 1:size(U,2)
        for ir = 1:bave:(size(U,1) - bave + 1);
            Ubave(ir,ic) = mean(U(ir:(ir+bave-1),ic));
            Vbave(ir,ic) = mean(V(ir:(ir+bave-1),ic));
            Wbave(ir,ic) = mean(W(ir:(ir+bave-1),ic));
            
        end
    end
end
Tbave = Tbave(1:bave:end);
Ubave = Ubave(1:bave:end,:);
Vbave = Vbave(1:bave:end,:);
Wbave = Wbave(1:bave:end,:);
end



