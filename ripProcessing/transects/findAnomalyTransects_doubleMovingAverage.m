% findAnomalyTransects.m
% 5/1/2018
% This code read in the intensity transects for each day and saves an
% anomaly transect

close all; clear all;

%% User inputs
% add paths to ISDRI HUB Support Data and GitHub Repository
Hub = 'E:\';
addpath(genpath('C:\Data\ISDRI\isdri-scripts')) %github repository
saveDir = 'E:\guadalupe\postprocessed\alongshoreTransectMatrix\ANOMALY_TRANSECTS\doubleMovingAverage_3000m\';

% add path to mat files and choose directory for png's
baseDir = [Hub 'guadalupe\processed\'];
matDir = [Hub 'guadalupe\postprocessed\alongshoreTransectMatrix\all_3000\'];

% file names
startTime = {'20170901_0000','20171001_0000'};
endTime = {'20170910_0000','20171010_0000'};

for iP = 1:length(startTime);
    if strcmp(startTime{iP}(5:6),endTime{iP}(5:6))
        days = str2num(startTime{iP}(7:8)):str2num(endTime{iP}(7:8));
        months = str2num(startTime{iP}(5:6)).*ones(size(days));
    elseif ~strcmp(startTime{iP}(5:6),endTime{iP}(5:6))
        daysS = str2num(startTime{iP}(7:8)):30;
        daysO = 1:str2num(endTime{iP}(7:8));
        days = [daysS daysO];
        months = [str2num(startTime{iP}(5:6))*ones(1,length(daysS))...
            str2num(endTime{iP}(5:6))*ones(1,length(daysO))];
        clear daysS daysO
    end
    
    for dd = 1:length(days)
        fn{dd} = [matDir endTime{iP}(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d') '.mat'];
        folderName{dd} = [baseDir endTime{iP}(1:4) '-' num2str(months(dd),'%02d') '-' num2str(days(dd),'%02d')];
    end
    
    
    %% load intensity transects
    
    dn1 = datenum([str2num(startTime{iP}(1:4)) str2num(startTime{iP}(5:6)) str2num(startTime{iP}(7:8))...
        str2num(startTime{iP}(10:11)) str2num(startTime{iP}(12:13)) 0]);
    dnEnd = datenum([str2num(endTime{iP}(1:4)) str2num(endTime{iP}(5:6)) str2num(endTime{iP}(7:8))...
        str2num(endTime{iP}(10:11)) str2num(endTime{iP}(12:13)) 0]);
    
    % Load transects
    idxMaxIAll = []; timesAll = []; transectMatrix0 = [];transectMatrix25 = [];...
        transectMatrix50 = []; transectMatrix75 = []; transectMatrix100 = []; transectMatrix150 = [];
    for i = 1:numel(fn)
        load(fn{i})
        transectMatrix0 = vertcat(transectMatrix0,txIMat);
        transectMatrix25 = vertcat(transectMatrix25,txIMat_25);
        transectMatrix50 = vertcat(transectMatrix50,txIMat_50);
        transectMatrix75 = vertcat(transectMatrix75,txIMat_75);
        transectMatrix100 = vertcat(transectMatrix100,txIMat_100);
        transectMatrix150 = vertcat(transectMatrix150,txIMat_150);
        idxMaxIAll = vertcat(idxMaxIAll, idxMaxI);
        timesAll = horzcat(timesAll,txDn);
    end
    
    times = timesAll(timesAll>dn1 & timesAll<dnEnd);
    transectMatrix0 = transectMatrix0(timesAll>dn1 & timesAll<dnEnd,:);
    transectMatrix25 = transectMatrix25(timesAll>dn1 & timesAll<dnEnd,:);
    transectMatrix50 = transectMatrix50(timesAll>dn1 & timesAll<dnEnd,:);
    transectMatrix75 = transectMatrix75(timesAll>dn1 & timesAll<dnEnd,:);
    transectMatrix100 = transectMatrix100(timesAll>dn1 & timesAll<dnEnd,:);
    transectMatrix150 = transectMatrix150(timesAll>dn1 & timesAll<dnEnd,:);
    clear idxMaxI; idxMaxI = idxMaxIAll(timesAll>dn1 & timesAll<dnEnd,:);
    
    % smooth transects using a double moving average
    filtSize = [100;200;300;400;500;600;700;800;900;1000;1100];
    
    for FS = 1:length(filtSize);
        transectMatrixFiltered0 = movmean(transectMatrix0,filtSize(FS),2);
        transectMatrixFiltered0 = movmean(transectMatrixFiltered0,filtSize(FS),2);
        transectMatrixFiltered25 = movmean(transectMatrix25,filtSize(FS),2);
        transectMatrixFiltered25 = movmean(transectMatrixFiltered25,filtSize(FS),2);
        transectMatrixFiltered50 = movmean(transectMatrix50,filtSize(FS),2);
        transectMatrixFiltered50 = movmean(transectMatrixFiltered50,filtSize(FS),2);
        transectMatrixFiltered75 = movmean(transectMatrix75,filtSize(FS),2);
        transectMatrixFiltered75 = movmean(transectMatrixFiltered75,filtSize(FS),2);
        transectMatrixFiltered100 = movmean(transectMatrix100,filtSize(FS),2);
        transectMatrixFiltered100 = movmean(transectMatrixFiltered100,filtSize(FS),2);
        transectMatrixFiltered150 = movmean(transectMatrix150,filtSize(FS),2);
        transectMatrixFiltered150 = movmean(transectMatrixFiltered150,filtSize(FS),2);

        % subtract off smoothed transect to find anomaly
        TMat0 = transectMatrix0 - transectMatrixFiltered0;
        TMat25 = transectMatrix25 - transectMatrixFiltered25;
        TMat50 = transectMatrix50 - transectMatrixFiltered50;
        TMat75 = transectMatrix75 - transectMatrixFiltered75;
        TMat100 = transectMatrix100 - transectMatrixFiltered100;
        TMat150 = transectMatrix150 - transectMatrixFiltered150;
        
        % find mean
        AST0 = mean(TMat0,1);
        AST25 = mean(TMat25,1);
        AST50 = mean(TMat50,1);
        AST75 = mean(TMat75,1);
        AST100 = mean(TMat100,1);
        AST150 = mean(TMat150,1);
        AST_index = mean(idxMaxI,1);
        
        AST = vertcat(AST0,AST25,AST50,AST75,AST100,AST150,AST_index);
        matName = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_AST_' num2str(filtSize(FS)) '.mat'];
        save(matName,'AST')
        
        %     matName0 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat0.mat'];
        %     matName25 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat25.mat'];
        %     matName50 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat50.mat'];
        %     matName75 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat75.mat'];
        %     matName100 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat100.mat'];
        %     matName150 = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_TMat150.mat'];
        %     timeMatName = [saveDir startTime{iP}(1:8) '_' endTime{iP}(1:8) '_time.mat'];
        %
        %     save(matName0,'TMat0')
        %     save(matName25,'TMat25')
        %     save(matName50,'TMat50')
        %     save(matName75,'TMat75')
        %     save(matName100,'TMat100')
        %     save(matName150,'TMat150')
        %     save(timeMatName,'times')
        
        clear timeMatName
        %     clear matName0 matName25 matName50 matName75 matName100 matName150
        clear AST matName
    end
    
end



