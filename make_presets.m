%% Returns the distances to the closest pattern maxima of the actual positions xj and yj
function [presets] = make_presets(imsize, pattern, Cent_G_fwhm, BG_G_fwhm)

% decode the pattern
fx = pattern(1);
x0 = pattern(2);
fy = pattern(3);
y0 = pattern(4);

size_y = imsize(1);
size_x = imsize(2);

%Extract distances in x and y to closest null
[yi,xi] = ndgrid(1:size_y, 1:size_x);
dx = mod(xi - x0, fx);
phase_x = mod(fx/2-x0,fx);
nx = ceil((xi + phase_x)/fx);
nx = nx - (nx(1,1)-1); %Makes sure first square is always nr 1.
h = dx > fx / 2;
dx(h) = dx(h) - fx;

dy = mod(yi - y0, fy);
phase_y = mod(fy/2-y0,fy);
ny = ceil((yi + phase_y)/fy);
ny = ny - (ny(1,1)-1);
h = dy > fy / 2;
dy(h) = dy(h) - fy;
%Absolute distance
dnull = sqrt(dx.^2 + dy.^2);
%Extract number of nulls in each dimension
nulls_x = nx(1,end);
nulls_y = ny(end,1);
%Make template for pinhole/basis matrix
By = size_x*size_y;
Bx = nulls_x*nulls_y;
B_cent = sparse([], [], [], By, Bx, size_x*size_y);
BG1 = sparse([], [], [], By, Bx, size_x*size_y);
BG2 = sparse([], [], [], By, Bx, size_x*size_y);
BG3 = sparse([], [], [], By, Bx, size_x*size_y);
BG4 = sparse([], [], [], By, Bx, size_x*size_y);
BG5 = sparse([], [], [], By, Bx, size_x*size_y);

sigma_cent = Cent_G_fwhm/2.355;
sigma_bg = BG_G_fwhm/2.355;
pi = 3.1416;
%Assign wights to elements in B
h = waitbar(0,'Calculating bases...');
for x = 1:size_x
    waitbar(x/size_x)
    for y = 1:size_y
        d = dnull(y,x);
        g_cent = exp(-d^2/(2*sigma_cent^2));
        bg1 = exp(-d^2/(2*sigma_bg^2));
        bg2 = 1;
%         bg3 = -dx(y,x);
%         bg4 = dy(y,x);
%         bg5 = -dy(y,x);
        %Nulls are ordered first vertically down then horizontally
        null = (nx(y,x)-1)*nulls_y + ny(y,x);
        pixel = (x-1)*size_y+y;
%         if null < 1 || pixel < 1
%             a = 0;
%         end
        B_cent(pixel , null) = g_cent;
        BG1(pixel, null) = bg1;
        BG2(pixel, null) = bg2;
%         BG3(pixel, null) = bg3;
%         BG4(pixel, null) = bg4;
%         BG5(pixel, null) = bg5;
    end
end
close(h)
presets.nulls_x = nulls_x;
presets.nulls_y = nulls_y;
B = [B_cent BG1 BG2];%BG3, BG4, BG5};
Ginv = inv(B'*B);
presets.B = B;
presets.Ginv = Ginv;
end