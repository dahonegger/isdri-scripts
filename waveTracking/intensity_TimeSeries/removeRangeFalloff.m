clear all; close all;

% method = 2;
%method = 1 for azi-by-azi function fitting
%method = 2 for azi-integrated function fitting

addpath(genpath('C:\Data\isdri\isdri-scripts'))
folder = dir('D:\guadalupe\processed\2017-09-10\*.mat');

%% Buoy Data
% Oceanus Array
latOc = [35.00258 35.00163 35.01176 35.01115 34.9902 34.98947 35.00908 34.98753...
    35.02070 35.01995 35.00762 35.00715 34.99740 34.99693 34.98640 34.98600...
    34.97535 34.97482 34.99587 35.00597 34.98508 35.004242 35.004128];
lonOc = [-120.72263 -120.72283 -120.700133 -120.700333 -120.70285 -120.70277 -120.68142...
    -120.68477 -120.66370 -120.66448 -120.66800 -120.66792 -120.66953 -120.66967...
    -120.67275 -120.67297 -120.67553 -120.67555 -120.66152 -120.65537 -120.66212...
    -120.646192 -120.646586];
% latOc = latOc([1,3,5,7,8,9,11,13,15,17,19,20,21,22]); %indices of non-reduntant points
% lonOc = lonOc([1,3,5,7,8,9,11,13,15,17,19,20,21,22]);
latOc = latOc([5,7,8,9,11,13,15,17,19,20,21,22]); %indices of non-reduntant points
lonOc = lonOc([5,7,8,9,11,13,15,17,19,20,21,22]);
% namesOC = {'OC50-A.T','OC40N-A.T','OC40S-A.T','OC32N-T','OC32S-T','OC25NA-A.T','OC25NB-A.T','OC25M-A.T',...
%     'OC25SB-A.T','OC25SA-A.T','OC20-A','OC17N-T','OC17S-T','OC10N-A.T'};
namesOC = {'OC40S-A.T','OC32N-T','OC32S-T','OC25NA-A.T','OC25NB-A.T','OC25M-A.T',...
    'OC25SB-A.T','OC25SA-A.T','OC20-A','OC17N-T','OC17S-T'};

[xUTM_Oc, yUTM_Oc] = ll2utm(latOc,lonOc);
% X_Oc = xUTM_Oc - results.XOrigin;
% Y_Oc = yUTM_Oc - results.YOrigin;

%  Now NPS array
latNPS = [34.9826, 34.98152, 34.98113, 34.98035];
lonNPS = [-120.65731, -120.65164, -120.65024, -120.65172];
namesNPS = {'STR3A-T','STR3B-A.T','STR3C-T','STR3E-T'};
[xUTM_NPS, yUTM_NPS] = ll2utm(latNPS, lonNPS);
% X_NPS = xUTM_NPS - results.XOrigin;
% Y_NPS = yUTM_NPS - results.YOrigin;

%% Initialize buoy data structure
for i = 1:numel(namesOC)
    buoyIntensities{i}.name = namesOC(i);
end
for i = 1:numel(namesNPS)
    init = numel(namesOC);
    buoyIntensities{i+init}.name = namesNPS(i);
end


%% loop through mat files
timexCount = 1;
for matFileIdx = 370:numel(folder) %loop through mat files
    baseName = folder(matFileIdx).name;
    pngFile = baseName;
    load(fullfile('D:\guadalupe\processed\2017-09-10',baseName));
    
    % Handle long runs (e.g. 18 minutes
    if (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 < 142
        timexCell{1} = timex;
        timeIntCell{1} = mean(timeInt);
        pngFileCell{1} = pngFile;
    elseif (epoch2Matlab(timeInt(end))-epoch2Matlab(timeInt(1))).*24.*60.*60 > 142
        %     load(cubeFile,'data')
        ii = 1;
        for i = 1:64:(floor(size(data,3)/64))*64 - 64
            timexCell{ii} = double(mean(data(:,:,i:i+64),3));
            timeIntCell{ii} = timeInt(1,i:i+64);
            [path,fname,ext] = fileparts(pngFile);
            tmp = datestr(epoch2Matlab(mean(timeIntCell{ii})),'HHMM');
            fname = [fname(1:17),tmp,'_pol'];
            pngFileCell{ii} = fullfile(path,[fname,ext]);
            ii = ii+1;
        end
    end
    
    
    x0 = results.XOrigin;
    y0 = results.YOrigin;
    [AZI,RG] = meshgrid(Azi,Rg);
    TH = pi/180*(90-AZI-results.heading);
    [xdom,ydom] = pol2cart(TH,RG);
    % xdom = xdom + x0; %convert to utm
    % ydom = ydom + y0;
    
    %handle buoy coords
    X_Oc = xUTM_Oc - results.XOrigin;
    Y_Oc = yUTM_Oc - results.YOrigin;
    X_NPS = xUTM_NPS - results.XOrigin;
    Y_NPS = yUTM_NPS - results.YOrigin;
    
    
    for IMAGEINDEX = 1:numel(timexCell)
        timex = timexCell{IMAGEINDEX};
        timeInt = timeIntCell{IMAGEINDEX};
        pngFile = pngFileCell{IMAGEINDEX};
        
        %% DO RANGE FALLOFF
        rgIdxCrop = [350:numel(Rg)-2000];
        azIdxCrop = [70:numel(Azi)-70];
        
        timexCrop = double(timex(rgIdxCrop,azIdxCrop));
        RgCrop = Rg(rgIdxCrop);
        AziCrop = Azi(azIdxCrop);
        
        [AZICrop,RGCrop] = meshgrid(AziCrop,RgCrop);
        THCrop = pi/180*(90-AZICrop-results.heading);
        [xdomCrop,ydomCrop] = pol2cart(THCrop,RGCrop);
        
        
        % figure; hold on;
        % pcolor(AziCrop,RgCrop,timexCrop);shading interp; colormap hot
        % can either feed this a single azimuth, or integrated over all azi
%         timexCropNorm = zeros(size(timexCrop));
%         for i = 1:size(timexCrop,2)
%             IrgVec = timexCrop(:,i);
%             aziPngFile = ['aziIdx',num2str(i)];
%             timexRgFunction = findAzimuthalRfalloff(IrgVec,RgCrop); %will give normalized range vector
%             timexNorm = (IrgVec' - timexRgFunction)./timexRgFunction;
%             timexCropNorm(:,i) = timexNorm;
%         end
        
%         figure(1); hold on;
%         set(gcf,'visible','off')
%         subplot(2,2,1)
%         pcolor(AziCrop,RgCrop,timexCrop); shading interp; colormap hot
%         title('raw timex')
%         colorbar
%         caxis([0 255])
%         axis tight      
%         subplot(2,2,2); hold on;
%         pcolor(AziCrop,RgCrop,timexCropNorm); shading interp; colormap hot
%         title('homogenized timex azi-by-azi')
%         colorbar
%         caxis([0 3])
%         axis tight
       
        
        int_over_azi = trapz(AziCrop,timexCrop,2)./(AziCrop(end)-AziCrop(1));
        timexRgFunction = findAzimuthalRfalloff(int_over_azi,RgCrop);
        timexCropNorm2 = zeros(size(timexCrop));
        for i = 1:size(timexCrop,2)
            IrgVec = timexCrop(:,i);
            timexNorm = (IrgVec' - timexRgFunction)./timexRgFunction;
            timexCropNorm2(:,i) = timexNorm;
        end
        
        figure; hold on;
%         set(gcf,'visible','off')
        plot(RgCrop,int_over_azi,'.k')
        plot(RgCrop,timexRgFunction,'-r')
        box on; axis tight;
        xlabel('Range [m]')
        ylabel('I')
        title(datestr(epoch2Matlab(timeInt(1))))
%         print(['D:\guadalupe\postprocessed\rangeFalloffExperiment\Frame_Rg_Functions\',pngFile,'.png'],'-dpng','-r500')

        
%         subplot(2,2,3); hold on;
%         pcolor(AziCrop,RgCrop,timexCropNorm2); shading interp; colormap hot
%         title('homogenized timex azi-integrated')
%         colorbar
%         caxis([0 3])
%         axis tight
%         
%         subplot(2,2,4); hold on;
%         pcolor(AziCrop,RgCrop,timexCropNorm2-timexCropNorm); shading interp; colormap hot
%         title('difference between methods')
%         colorbar
%         caxis([-.5 .5])
%         axis tight
%         
        
%         print(['D:\guadalupe\postprocessed\rangeFalloffExperiment\frame-by-frame comparison2\',pngFile,'.png'],'-dpng','-r500')
        
        
        %% save buoy data
        
        for i = 1:numel(namesOC)
            D = sqrt((xdomCrop - X_Oc(i)).^2 + (ydomCrop - Y_Oc(i)).^2);
            [rowOc_tmp, colOc_tmp] = find(D==min(D(:)));
            rowOc(i) = rowOc_tmp; colOc(i) = colOc_tmp;
            colOc(i) = colOc(i)+4; %shift location by 3 azi to move off buoy reflection
            if i == 1
                rowOc(i) = rowOc(i)-6;
                colOc(i) = colOc(i)-2;
            else; end
            if i == 8
                rowOc(i) = rowOc(i)-20;
            else; end
            if i == 11
                colOc(i) = colOc(i)+3;
            else; end
            Itmp_norm = timexCropNorm2(rowOc(i), colOc(i));
            Itmp = timexCrop(rowOc(i),colOc(i));
            buoyIntensities{i}.Inorm(timexCount) = Itmp_norm;
            buoyIntensities{i}.I(timexCount) = Itmp;
            buoyIntensities{i}.Inorm_patch(timexCount) = mean(mean(timexCropNorm2(rowOc(i)-2:rowOc(i)+2, colOc(i)-2:colOc(i)+2)));
            buoyIntensities{i}.I_patch(timexCount) = mean(mean(timexCrop(rowOc(i)-2:rowOc(i)+2, colOc(i)-2:colOc(i)+2)));           
            buoyIntensities{i}.X(timexCount) = xdomCrop(rowOc(i), colOc(i))+x0;
            buoyIntensities{i}.Y(timexCount) = ydomCrop(rowOc(i), colOc(i))+y0;
            buoyIntensities{i}.t(timexCount) = epoch2Matlab(timeInt(1));
        end
        
        for i = 1:numel(namesNPS)
            D = sqrt((xdomCrop - X_NPS(i)).^2 + (ydomCrop - Y_NPS(i)).^2);
            [rowNPS(i), colNPS(i)] = find(D==min(D(:)));
            colNPS(i) = colNPS(i); %shift location by 3 azi to move off buoy reflection
            Itmp_norm = timexCropNorm2(rowNPS(i), colNPS(i));
            Itmp = timexCrop(rowNPS(i), colNPS(i));
            init = numel(namesOC);
            buoyIntensities{i+init}.Inorm(timexCount) = Itmp_norm;
            buoyIntensities{i+init}.Inorm_patch(timexCount) = mean(mean(timexCropNorm2(abs(rowNPS(i)-2):rowNPS(i)+2, abs(colNPS(i)-2):colNPS(i)+2)));
            buoyIntensities{i+init}.I(timexCount) = Itmp;
            buoyIntensities{i+init}.I_patch(timexCount) = mean(mean(timexCrop(abs(rowNPS(i)-2):rowNPS(i)+2, abs(colNPS(i)-2):colNPS(i)+2)));           
            buoyIntensities{i+init}.X(timexCount) = xdomCrop(rowNPS(i), colNPS(i))+x0;
            buoyIntensities{i+init}.Y(timexCount) = ydomCrop(rowNPS(i), colNPS(i))+y0;
            buoyIntensities{i+init}.t(timexCount) = epoch2Matlab(timeInt(1));
            
        end
        
        
%% plot
        figure;hold on
%         set(gcf,'visible','off')
        % pcolor(xdom,ydom,timex)
        % pcolor(xdom(330:end,60:end-60),ydom(330:end,60:end-60),timex(330:end,60:end-60)); shading interp; colormap hot;axis image;
        pcolor(xdomCrop,ydomCrop,timexCropNorm2)
%         plot(X_Oc,Y_Oc,'c.','MarkerSize',10)
%         plot(X_NPS,Y_NPS,'g.','MarkerSize',10)
        for i = 1:numel(rowOc)
            plot(xdomCrop(rowOc(i),colOc(i)),ydomCrop(rowOc(i),colOc(i)),'c.','markersize',10)
        end
        for i = 1:1
            plot(xdomCrop(rowNPS(i),colNPS(i)),ydomCrop(rowNPS(i),colNPS(i)),'g.','markersize',10)
        end
        for i = 1:numel(X_Oc)-1
            text(X_Oc(i),Y_Oc(i),namesOC{i},'color','c','fontsize',6)
        end
        for i = 1:1
            text(X_NPS(i),Y_NPS(i),namesNPS{i},'color','g','fontsize',6)
        end
        shading interp; colormap hot; axis image
        title([datestr(epoch2Matlab(timeInt(1))),' UTC'])
        xlabel('X [m]');ylabel('Y [m]')
        colorbar; caxis([0 3])
        % xlim([-6060 0])
        % ylim([-3546 4735])
        box on
        set(gcf,'Position',[605 73 580 678.4000])
        set(gcf,'PaperPosition', [1.4 3.2 5.8 4.4])
        
        print(['D:\guadalupe\postprocessed\rangeFalloffExperiment\Normalized_pngs\',pngFile,'.png'],'-dpng','-r500')
        
        
%% update counter

        timexCount = timexCount+1;

    end
        clear timexCell;
        clear timeIntCell;
        clear pngFileCell;
    
        close all
        disp([num2str(timexCount),' out of ',num2str(numel(folder)-370),'370 done.'])
end

save('buoyIntensities_9.10.mat','buoyIntensities')