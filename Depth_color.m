[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');

path = strcat(LoadPathName, LoadFileName);
im = double(load_image_stack(path));
fr_str = inputdlg('Choose frames');
split = strsplit(fr_str{1}, '-');
Start = str2double(split{1});
End = str2double(split{2});
im = im(:,:,Start:End);
[xi, yi, zi] = meshgrid(0:size(im, 2)-1, 0:size(im, 1)-1, 0:size(im, 3)-1);
xi = xi ./ max(xi(:));
yi = yi ./ max(yi(:));
zi = zi ./ max(zi(:));

z = 4*zi;

zr = zeros(size(im));
o = ones(size(im));
r=min(max(-z+2,zr),o); 
g=min(max(min(z,-z+4),zr),o); 
b=min(max(z-2,zr),o); 



im_r = im.*r;
im_g = im.*g;
im_b = im.*b;

max_colored = zeros(size(im, 1), size(im, 2), 3);

for y = 1:size(im, 1)
    for x = 1:size(im,2)
        z = find(im(y,x,:) == max(im(y,x,:)));
        z = z(1);
        int = im(y,x,z);
        col = [max(im_r(y,x,:)) max(im_g(y,x,:)) max(im_b(y,x,:))];
        max_colored(y,x,:) = int*col;
    end
end

h5create('Depth_color.h5','/data', size(max_colored))
h5write('Depth_color.h5','/data', max_colored)
% max_colored = max_colored - min(max_colored(:));
% max_colored = max_colored ./ max(max_colored(:));

% imwrite(max_colored, 'Max_colored.tif')
