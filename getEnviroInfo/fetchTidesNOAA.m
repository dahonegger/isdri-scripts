function [ ] = fetchTidesNOAA(buoyNum,saveDir,fname,startDate,endDate)
%fetchTidesNOAA - this function saves a .txt file in the given directory
%with tidal information from NOAA Tides and Currents.  The results are
%fixed in UTC and m.


filename = [saveDir,'\',fname];
url = ['https://tidesandcurrents.noaa.gov/api/datagetter?product=water_level&application=NOS.COOPS.TAC.WL&station=',...
    num2str(buoyNum),'&&begin_date=',startDate,'&end_date=',...
    endDate,'&datum=MLLW&units=metric&time_zone=GMT&format=csv'];
websave(filename, url);

end
