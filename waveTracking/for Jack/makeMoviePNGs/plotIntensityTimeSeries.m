load('buoyIntensities_9.12.mat');
xlim1 = datenum(2017,09,12,18,00,0); xlim2 = datenum(2017,09,12,22,00,0);
tickspaceMinutes = 12;
%     xlim1 = t(1); xlim2 = t(31);


for i = 8:8
    t = buoyIntensities{i}.t;
    name = buoyIntensities{i}.name;
    
    
    figure;hold on
    subplot(4,1,1)
    plot(t,buoyIntensities{i}.I)
    tick_locations = [xlim1:tickspaceMinutes/24/60:xlim2];
    set(gca,'XTick',tick_locations)
    datetick('x','HH:MM','keepticks')
    axis tight; box on; grid on;
    ylabel('Raw Timex I')
    xlim([xlim1 xlim2])


   title(name{1})
   subplot(4,1,2)
     plot(t,buoyIntensities{i}.I_patch)
     tick_locations = [xlim1:tickspaceMinutes/24/60:xlim2];
    set(gca,'XTick',tick_locations)
    datetick('x','HH:MM','keepticks')
    axis tight; box on; grid on;
    ylabel({'12m x 3^o avg','Raw Timex I'})
    xlim([xlim1 xlim2])

   subplot(4,1,3)
        plot(t,buoyIntensities{i}.Inorm)
        tick_locations = [xlim1:tickspaceMinutes/24/60:xlim2];
    set(gca,'XTick',tick_locations)
    datetick('x','HH:MM','keepticks')
    axis tight; box on; grid on;
    ylabel('Normalized Timex I')
    xlim([xlim1 xlim2])

    subplot(4,1,4)
     plot(t,buoyIntensities{i}.Inorm_patch)
     tick_locations = [xlim1:tickspaceMinutes/24/60:xlim2];
    set(gca,'XTick',tick_locations)
    datetick('x','HH:MM','keepticks')
    axis tight; box on; grid on;
    ylabel({'12m x 3^o avg','Normlalized Timex I'})
    xlabel('time')
    xlim([xlim1 xlim2])

  set(gcf,'Position',[67.4000 41.8000 1.4416e+03 740.8000])
    fname = strcat('D:\guadalupe\postprocessed\rangeFalloffExperiment\TimeSeries\',name,'_zoom.png');
%    print(fname{1},'-dpng','-r500')

%    close all
   
end