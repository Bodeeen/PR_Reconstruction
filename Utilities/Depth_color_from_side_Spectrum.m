[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');

path = strcat(LoadPathName, LoadFileName);
im = double(imread(path))./256;
[xi, yi] = meshgrid(1:size(im, 2), 1:size(im, 1));

xi = xi ./ max(xi(:));
yi = yi ./ max(yi(:));

y4 = 4*yi;

z = zeros(size(im));
o = ones(size(im));

r=min(max(min(y4-1.5,-y4+4.5),z),o); 
g=min(max(min(y4-0.5,-y4+3.5),z),o); 
b=min(max(min(y4+0.5,-y4+2.5),z),o); 

im_r = im.*r;
im_g = im.*g;
im_b = im.*b;
im_rgb = cat(3, im_r, im_g, im_b);
% im_rgb = flipud(im_rgb);
imwrite(im_rgb, 'ZX_rgb.tiff')
