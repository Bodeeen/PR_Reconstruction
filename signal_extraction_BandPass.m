function [central_signal B] = signal_extraction(data, pattern, diff_lim_px, objp, shiftp, W, activation_size_px)
% Given the pattern period and offset as well as the output pixel length
% and the scanning pixel length it constructs the central and peripheral
% signal frames as used in the publication: 'Nanoscopy with more than a
% hundred thousand "doughnuts"' by Andriy Chmyrov et al., to appear in
% Nature Methods, 2013
%
% pattern is the periods and offsets of the on-switched regions

%% error checks
assert(nargin == 7)

%Presets
bp_fac = 0.6;

%% data parameters
size_y = size(data, 1);
size_x = size(data, 2);
nframes = size(data, 3);
nsteps = sqrt(nframes);

% decode the pattern
fy = pattern(1);
y0 = pattern(2);
fx = pattern(3);
x0 = pattern(4);

%Make image of distances to closes null in x, y and in absolut distances
[dnull, dy ,dx, B] = make_presets(size_y, size_x, fy, y0, fx, x0, diff_lim_px, bp_fac);

for i = 1:nframes
    frame = data(:,:,i);
    f = reshape(frame,[numel(frame), 1]);
    c = B'*f;
    
end
end

%% Returns the distances to the closest pattern maxima of the actual positions xj and yj
function [dnull, dy, dx, B] = make_presets(size_y, size_x, fy, y0, fx, x0, diff_lim_px, bp_fac)
%Extract distances in x and y to closest null
[yi,xi] = ndgrid(1:size_y, 1:size_x);
dx = mod(xi - x0, fx);
nx = floor((xi+3*fx/2+x0)/fx);
h = dx > fx / 2;
dx(h) = dx(h) - fx;

dy = mod(yi - y0, fy);
ny = floor((yi+3*fy/2+y0)/fy);
h = dy > fy / 2;
dy(h) = dy(h) - fy;
%Absolute distance
dnull = sqrt(dx.^2 + dy.^2);
%Extract number of nulls in each dimension
nulls_x = 2 + floor((size(dx,2) - x0)/fx);
nulls_y = 2 + floor((size(dx,1) - y0)/fy);
%Make template for pinhole/basis matrix
B = sparse(zeros(size_x*size_y, nulls_x*nulls_y));

sigma_sig = diff_lim_px/2.355;
sigma_bg = sqrt(2)*sigma_sig;
pi = 3.1416;
%Assign wights to elements in B
for x = 1:size_x
    for y = 1:size_y
        d = dnull(y,x);
        g_sig = 1/sqrt(2*sigma_sig^2*pi)*exp(-d^2/(2*sigma_sig^2));
        g_bg = 1/sqrt(2*sigma_bg^2*pi)*exp(-d^2/(2*sigma_bg^2));
        w = g_sig - bp_fac*g_bg;
        %Nulls are ordered first vertically down then horizontally
        null = (nx(y,x)-1)*nulls_y + ny(y,x);
        B((x-1)*size_y+y, null) = w;
    end
end
 
end











