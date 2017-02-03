
% [LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');
N = 0;
% 
% path = strcat(LoadPathName, LoadFileName);
for i = 0:100:2000
    N = N + 1;
    path = strcat('E:\Tempesta\DefaultDataFolder\2017-02-03\OFF_stack\Z_stack_OFF_Z', num2str(i), '_rec.hdf5');
    data = load_image_stack(path);

    data(:,:,1) = data(:,:,2);
    data(:,:,end+1) = data(:,:,end);
    trace = mean(mean(data, 2), 1);

    imside = sqrt(size(data, 3));

    im = reshape(trace, [imside imside]);
    im(:,1:2:end,:) = flipud(im(:,1:2:end,:));
    im = im - min(im(:));
    im = im/max(im(:));

    imstack(:,:,N) = im;
end

h5create('3Dbeadscan.h5','/data', [imside imside size(imstack, 3)])
h5write('3Dbeadscan.h5','/data', imstack);