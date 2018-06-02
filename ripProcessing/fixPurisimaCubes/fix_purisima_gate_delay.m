function newcube = fix_purisima_gate_delay(cube)
newcube = cube;

true_gate_delay = -126;  % empirically determined
old_gate_delay = cube.header.gateDelay;
% In ReadBin, donut is the first index kept, so we'll call the last index
% thrown out donut2.
donut2 = -(true_gate_delay - old_gate_delay);

if donut2 > 0
    % Make adjustments and save the donut
    newcube.data(1:donut2, :, :) = [];
    newcube.timex(1:donut2, :) = [];
    newcube.Rg(end-donut2+1:end) = [];
    newcube.results.doughnut = donut2 + 1;
    
    % Some file don't have the right collections value
    if cube.daqConfig.collections < 1
        newcube.daqConfig.collections = size(cube.data, 2);
    end
    if cube.header.collections < 1
        newcube.header.collections = size(cube.data, 2);
    end
    if cube.header.collectionsMod < 1
        newcube.header.collectionsMod = size(cube.data, 2);
    end
elseif donut2 < 0
%     error('Not ready to handle this case...');
    disp('Not ready to handle this case...');
    %     datasz = size(cube.data);
    %     extra_data = zeros([-donut2, datasz(2:3)], 'like', cube.data);
    %     newcube.data = [extra_data; cube.data];
    %     newcube.timex = [extra_data(:, :, 1); newcube.timex];
    %     new_ranges = (length(cube.Rg) + (1:-donut2))*2.998;
    %     new_Rgs = real(sqrt(new_ranges.^2 - cube.results.ZOrigin^2));
    newcube = [];
end
