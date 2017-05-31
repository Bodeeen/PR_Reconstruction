% Short script for reconstructing a single bead scan. Simply gets the total
% signal from each frame and reshapes into square image.
[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');
N = 0;

path = strcat(LoadPathName, LoadFileName);

data = load_image_stack(path);

data(:,:,1) = data(:,:,2);
data(:,:,end+1) = data(:,:,end);
trace = mean(mean(data, 2), 1);

imside = sqrt(size(data, 3));

im = reshape(trace, [imside imside]);
im(:,1:2:end,:) = flipud(im(:,1:2:end,:));
im = im - min(im(:));
im = im/max(im(:));
% figure
% imshow(im, [])

savename = strsplit(path, '.');
savename = savename{1};
savename = strcat(savename, '.tiff');
imwrite(im, savename);
