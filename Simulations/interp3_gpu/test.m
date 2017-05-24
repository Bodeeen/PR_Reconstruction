[x, y, z, v] = flow(100);
[xi, yi, zi] = meshgrid(.1:.025:10, -3:.025:3, -3:.025:3);
v2 = interp3_gpu(x(1, :, 1), y(:, 1, 1), z(1, 1, :), v, xi, yi, zi);
figure('color', [1 1 1]);
slice(xi,yi,zi,double(v2),[6 9.5],2,[-2 .2]);
shading flat;
daspect([1 1 1]);
colormap(jet(256));
