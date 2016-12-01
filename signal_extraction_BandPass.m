function [central_signal bg_signal] = signal_extraction(data, pattern, diff_lim_px, objp, shiftp, W, activation_size_px)
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


%% data parameters
size_y = size(data, 1);
size_x = size(data, 2);
nframes = size(data, 3);

% decode the pattern
fy = pattern(1);
y0 = pattern(2);
fx = pattern(3);
x0 = pattern(4);

%Make image of distances to closest null in x, y and in absolut distances
[dnull, dy ,dx, nulls_y, nulls_x, B_cent, B_bg] = make_presets(size_y, size_x, fy, y0, fx, x0, diff_lim_px);
nnulls = size(B_cent,2);
cmat_cent = zeros(nnulls,nframes);
cmat_bg = zeros(nnulls,nframes);
%Calculate weights to correct for different pinholes having
%different "sum under gaussians"
W_cent = 1./sum(B_cent, 1)';
W_cent = W_cent ./ mean(W_cent);
W_bg = 1./sum(B_bg, 1)';
W_bg = W_bg ./ mean(W_bg);

h = waitbar(0,'Pinholing...');
for i = 1:nframes
    waitbar(i/nframes);
    frame = data(:,:,i);
    f = double(reshape(frame,[numel(frame), 1]));
    cmat_cent(:,i) = W_cent.*(B_cent'*f);
    cmat_bg(:,i) = W_bg.*(B_bg'*f);
    
end
close(h)

central_signal = cmat2image(cmat_cent, nulls_y, nulls_x); 
bg_signal = cmat2image(cmat_bg, nulls_y, nulls_x); 

end

%% Returns the distances to the closest pattern maxima of the actual positions xj and yj
function [dnull, dy, dx, nulls_y, nulls_x, B_cent, B_bg] = make_presets(size_y, size_x, fy, y0, fx, x0, diff_lim_px)
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
B_bg = sparse([], [], [], By, Bx, size_x*size_y);

sigma_cent = diff_lim_px/2.355;
sigma_bg = sqrt(2)*sigma_cent;
pi = 3.1416;
%Assign wights to elements in B
h = waitbar(0,'Calculating bases...');
for x = 1:size_x
    waitbar(x/size_x)
    for y = 1:size_y
        d = dnull(y,x);
        g_cent = 1/sqrt(2*sigma_cent^2*pi)*exp(-d^2/(2*sigma_cent^2));
        g_bg = 1/sqrt(2*sigma_bg^2*pi)*exp(-d^2/(2*sigma_bg^2));
        %Nulls are ordered first vertically down then horizontally
        null = (nx(y,x)-1)*nulls_y + ny(y,x);
        pixel = (x-1)*size_y+y;
%         if null < 1 || pixel < 1
%             a = 0;
%         end
        B_cent(pixel , null) = g_cent;
        B_bg(pixel, null) = g_bg;
    end
end
close(h)
end

function reconstructed = cmat2image(cmat, nulls_y, nulls_x)
    fr_p_line = sqrt(size(cmat, 2));
    nnulls = nulls_y*nulls_x;
    subsquares = zeros(fr_p_line, fr_p_line, nnulls);
    for i = 1:nnulls
        subsquare = reshape(cmat(i,:), fr_p_line, fr_p_line);
        subsquare(:,1:2:end) = flipud(subsquare(:,1:2:end));
        subsquare = rot90(subsquare,2);
        subsquares(:,:,i) = subsquare;
    end
    reconstructed = zeros((nulls_y-2)*fr_p_line, nulls_x*fr_p_line);
    yind = 1;
    xind = 1;

    for x = 1:nulls_x
        for y = 1:nulls_y
            xr = xind:xind+fr_p_line-1;
            yr = yind:yind+fr_p_line-1;
            reconstructed(yr, xr) = subsquares(:,:,(x-1)*nulls_y + y);
            yind = yind + fr_p_line;
        end
        yind = 1;
        xind = xind + fr_p_line;
    end
    %%Handle the sometimes not representable frame values
    %Make image w/o the frame
    wo_frame = reconstructed(1+fr_p_line+1:end-fr_p_line, 1+fr_p_line:end-fr_p_line);
    minvalue = min(wo_frame(:));
    maxvalue = max(wo_frame(:));

    reconstructed = wo_frame;
end

function shifted_im = shift_columns(im, pixels, columns_per_square)

    x_coords = 1:size(im, 2);

    x_coords = mod(x_coords, columns_per_square);
    selection_bool = mod(x_coords, 2) == 0;

    selection = im(:, selection_bool);

    size_selection_y = size(selection, 1);
    size_selection_x = size(selection, 2);
    [yi xi] = ndgrid(1:size_selection_y, 1:size_selection_x);

    yi_shifted = yi + pixels;

    shifted_selection = interp2(selection, xi, yi_shifted);
    shifted_selection(isnan(shifted_selection)) = min(im(:));
    im(:,selection_bool) = shifted_selection;
    shifted_im = im;

end









