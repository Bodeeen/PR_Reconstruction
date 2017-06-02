function [presets] = make_presets(imsize, pattern, base_preset, ssrot, flip_ss, simp_pin)

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

sigma_cent = base_preset(1)/2.355;

pi = 3.1416;

nr_bases = size(nonzeros(base_preset), 1);

g_cent = exp(-dnull.^2/(2.*sigma_cent^2));

%Nulls are ordered first vertically down then horizontally
null = (nx-1).*nulls_y + ny;
pixel = (xi-1)*size_y+yi;
h = waitbar(0,'Calculating bases...');
B_cent = sparse([], [], [], By, Bx, By);


for i = 1:By
    B_cent(pixel(i) , null(i)) = g_cent(i);       
end
bsum = sum(B_cent, 1);
if simp_pin
    for i = 1:Bx
        B_cent(:,i) = B_cent(:,i)./bsum(i);
    end
end

B = B_cent;

waitbar(1/nr_bases)
if base_preset(2) ~= 0
    sigma_bg = base_preset(2)/2.355;
    BG1 = sparse([], [], [], By, Bx, size_x*size_y);
    bg1 = exp(-dnull.^2/(2.*sigma_bg^2));
    for i = 1:numel(xi)
        BG1(pixel(i) , null(i)) = bg1(i);
    end
    B = [B BG1];
end
waitbar(2/nr_bases)
%Make constant bg (this is also used for error calculation which is why it
%is always created.
BG2 = sparse([], [], [], By, Bx, size_x*size_y);
for i = 1:numel(xi)
    BG2(pixel(i) , null(i)) = 1;
end
if base_preset(3) ~= 0
    B = [B BG2];
end
waitbar(3/nr_bases)
close(h)
presets.null_im = null;
presets.nulls_x = nulls_x;
presets.nulls_y = nulls_y;
presets.dx = dx;
presets.dy = dy;
presets.dnull = dnull;
presets.null = null;
presets.pixel = pixel;
Ginv = inv(B'*B);
presets.B = B;
presets.SS_const_base = BG2;
presets.Ginv = Ginv;
presets.ssrot = ssrot;
presets.flip_ss = flip_ss;
presets.simp_pin = simp_pin;
end