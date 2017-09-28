function makeGif(filenames,outputfilename,delaytime)

I=imread(filenames{1});
% I=I(3500:6500,2500:5000,:);
if size(I,3)==1
    I=ind2rgb(round(mat2gray(I)*256),jet(256));
end
[A,map]=rgb2ind(I,256);

imwrite(A,map,outputfilename,'gif','LoopCount',Inf,'DelayTime',delaytime);
for i=2:numel(filenames)
    fprintf('%.0f/%.0f...%s\n',i,numel(filenames),datestr(now));
    I=imread(filenames{i});
%     I=I(3500:6500,2500:5000,:);
    if size(I,3)==1
        I=ind2rgb(round(mat2gray(I)*256),jet(256));
    end
    [A,map]=rgb2ind(I,256);
    imwrite(A,map,outputfilename,'gif','WriteMode','append','DelayTime',delaytime);
end

end