[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');

path = strcat(LoadPathName, LoadFileName);
im = double(imread(path));
[xi, yi] = meshgrid(1:size(im, 2), 1:size(im, 1));
xi = xi ./ max(xi(:));
yi = yi ./ max(yi(:));

r = max(- 1 + 2*yi, 0);
g = min(2-2*yi, 2*yi);
b = flipud(r);

im_r = im.*r;
im_g = im.*g;
im_b = im.*b;
im_rgb = cat(3, im_r, im_g, im_b)./255;
