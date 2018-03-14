% fixPurisima.m
% This code loops through all the Purisima cubes, fixes the gate delay, and
% saves a new radar cube
% 3/12/2018
clear variables; close all; home

% MAT FILES LOCATION
baseDir = 'E:\purisima\processed\'; % HUB 1
dayFolder = dir([baseDir,'2017*']);

for iDay = 8:length(dayFolder)
    dayFolder(iDay).polRun = dir(fullfile(baseDir,dayFolder(iDay).name,'*_pol.mat'));
    
    for iRun = 1:length(dayFolder(iDay).polRun)
        cubeName = [dayFolder(iDay).folder '\' dayFolder(iDay).name '\' dayFolder(iDay).polRun(iRun).name];
        
        cube = load(cubeName);
        if ~isfield(cube, 'data')
        else
            newcube = fix_purisima_gate_delay(cube);
            
            if ~isempty(newcube)
            Azi = newcube.Azi;
            Azi_oob = newcube.Azi_oob;
            daqConfig = newcube.daqConfig;
            data = newcube.data;
            header = newcube.header;
            interp_opts = newcube.interp_opts;
            location = newcube.location;
            longName = newcube.longName;
            range_pol = newcube.range_pol;
            results = newcube.results;
            Rg = newcube.Rg;
            station = newcube.station;
            time = newcube.time;
            timeInt = newcube.timeInt;
            timex = newcube.timex;
            whencreated = newcube.whencreated;
            
            dayFolderNew = ['E:\purisima\reprocessed\' dayFolder(iDay).name '\'];
            if ~exist(dayFolderNew); mkdir(dayFolderNew); end
            
            saveFile = ['E:\purisima\reprocessed\' dayFolder(iDay).name '\' dayFolder(iDay).polRun(iRun).name];
            
            save(saveFile,'Azi','Azi_oob','daqConfig','data','header','interp_opts',...
                'location','longName','range_pol','results','Rg','station','time','timeInt',...
                'timex','whencreated')
            clearvars -except iRun iDay dayFolder baseDir
            else
                disp(cubeName)
            end
        end
        clear cubeName cube
    end
end



        