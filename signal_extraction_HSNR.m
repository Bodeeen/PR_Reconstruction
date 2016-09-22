 function [central_signal peripheral_signal] = signal_extraction(data, pattern, objp, shiftp, W, activation_size_px)
% Given the pattern period and offset as well as the output pixel length
% and the scanning pixel length it constructs the central and peripheral
% signal frames as used in the publication: 'Nanoscopy with more than a
% hundred thousand "doughnuts"' by Andriy Chmyrov et al., to appear in
% Nature Methods, 2013
%
% pattern is the periods and offsets of the on-switched regions

%% error checks
assert(nargin == 6)

%%Scan directions

%% data parameters
dx = size(data, 1);
dy = size(data, 2);
nframes = size(data, 3);
nsteps = sqrt(nframes);

pinhole_shrink_fac = (W/activation_size_px);

% decode the pattern
fy = pattern(1);
y0 = pattern(2);
fx = pattern(3);
x0 = pattern(4);

%% object positions in image so that they are always in the scanned regions
%NOTE: These depend on scanning directions
[yi, xi] = object_positions([1, dx], [1, dy], objp);


central_signal = 0;
central_signal_weights = 0;
peripheral_signal = 0;
peripheral_signal_weights = 0;

half_x = round(fx / 2 / objp); % half_x/half_y here is the distance (in upsampled pixels) between
half_y = round(fy / 2 / objp); % a minima and a maxima in the different dimensions.

%% Copute pattern values in units of upsampled pixels
dx_up = size(xi, 2);
dy_up = size(xi, 1);
x0_up = x0/objp;
y0_up = y0/objp;
fx_up = fx/objp;
fy_up = fy/objp;

%% Calculate distances of each pixel to nearest activation center and
%  from this compute central and peripheral weights. central_weights
%  contains a gaussian window for each activation spot.
[t2max] = object_distances(dx_up, dy_up, fx_up, x0_up, fy_up, y0_up);
c = 2*(W/2.35)^2;
central_wmax = exp(-(t2max.^2/c));
periph_wmax = circshift(central_wmax, [-half_x, -half_y]);

%% Activation gaussian is the 2D gaussian that corresponds in size to the
%  activation spot. Used to recontrucs the image.
act_gauss_size = 1+2*round(activation_size_px/objp);
activation_gaussian = Gausskern(act_gauss_size, round(activation_size_px/objp));

dist_first_cent_x = x0_up;
dist_first_cent_y = y0_up;

dist_first_periph_x = x0_up + (-1)^(floor(x0_up/(fx_up/2))) * fx_up/2;
dist_first_periph_y = y0_up + (-1)^(floor(y0_up/(fy_up/2))) * fy_up/2;

%% Calculate number of activation spots in each dimension to use for 
%  reconstruction
num_cent_px = floor((size(xi,2) - dist_first_periph_x) / (fx_up));
num_cent_py = floor((size(xi,1) - dist_first_periph_y) / (fy_up));

%% Calculate number of peripheral spots in each dimension to use for 
%  reconstruction
num_periph_px = floor((size(xi,2) - dist_first_cent_x) / fx_up);
num_periph_py = floor((size(xi,1) - dist_first_cent_y) / fy_up);

%Frame pixels
frame_pix = 5*act_gauss_size;

%% Allocate matrices for central signal and central weights
central_signal = zeros(size(xi, 1) + 2*frame_pix, size(xi, 2)+ 2*frame_pix);
peripheral_signal = zeros(size(central_signal));
weights = zeros(size(xi, 1) + 2*frame_pix, size(xi, 2)+ 2*frame_pix);

% Initiate values to store the corners of the reconstructed image
min_sx = 100;
min_sy = 100;
max_ex = 0;
max_ey = 0;

% loop (attention, the scanning direction of our microscope is hardcoded
h = waitbar(0,'Extracting signal...');
for kx = 0 : nsteps - 1
    shift_x = -(kx * shiftp) / objp;
    dir = (-1)^kx;
    off = mod(kx,2);
    for ky = 0 : nsteps - 1
        waitbar((kx*nsteps + ky)/(nsteps^2))
        %% Unidirectional scan
%         shift_x = -(kx * shiftp) / objp;
        %% Bidirectional scan
        shift_y = off*(nsteps - 1)*shiftp/objp + dir * ky * shiftp/objp;
        
        % get frame number and frame
        kf = ky + 1 + nsteps * kx;
        frame = data(:, :, kf);
        % Upsampling
        est = interpn(frame, yi, xi, 'nearest');
        est(isnan(est)) = 0;
        est = max(est, 0); 
        central_est = central_wmax .* est;
        periph_est = periph_wmax .* est;
        
        % Allocate matrix for storing coefficients (signal from each
        % activation spot)
        coeffs_central = zeros(num_cent_py + 2, num_cent_px + 2);
        coeffs_peripheral = zeros(num_periph_py + 2, num_periph_px + 2);
        
        % Find start and end pixel in each dimension defining the area
        % from where to extract signal
        pixy_s = 1; % Start y
        pixy_e = size(central_est, 1); % End y
        pixx_s = 1; %Start x
        pixx_e = size(central_est, 2); % End x
        
        % Loop over each pixel in frame and assign value to correct
        % coefficient
        for pixy = pixy_s:pixy_e
            for pixx = pixx_s:pixx_e
                % Determine witch central coefficient the pixel belongs to (x and y)
                cy = 2 + floor((pixy - dist_first_periph_y)/fy_up);
                cx = 2 + floor((pixx - dist_first_periph_x)/fx_up);
                % Determine witch peripheral coefficient the pixel belongs to (x and y)
                py = 2 + floor((pixy - dist_first_cent_y)/fy_up);
                px = 2 + floor((pixx - dist_first_cent_x)/fx_up);
                % Add pixel value to coefficient
                coeffs_central(cy,cx) = coeffs_central(cy,cx) + central_est(pixy,pixx);
                coeffs_peripheral(py,px) = coeffs_peripheral(py,px) + periph_est(pixy,pixx);
                
            end
        end
        
        coeffs_periph_summed = (coeffs_peripheral + ...
            circshift(coeffs_peripheral, [0 -1]) + ...
            circshift(coeffs_peripheral, [-1 0]) + ...
            circshift(coeffs_peripheral, [-1 -1])) / 4;
        
        % Loop over all coefficients and multiply each coefficient with a 
        % correctly shifted activation gaussian
        for cy = 2:num_cent_py + 1
            for cx = 2:num_cent_px + 1
                % Determine correct area for activation gaussian to be
                % placed in 
                sy = frame_pix + ceil(shift_y + (cy-2)*fy_up);
                ey = round(sy + act_gauss_size - 1);
                sx = frame_pix + ceil((nsteps-1)*shiftp/objp + shift_x + (cx-2)*fx_up);
                ex = round(sx + act_gauss_size - 1);

                % Add signal and wights
                signal_c = coeffs_central(cy,cx);
                signal_p = coeffs_periph_summed(cy-1, cx-1);
                central_signal(sy:ey, sx:ex) = central_signal(sy:ey, sx:ex) + signal_c*activation_gaussian;
                peripheral_signal(sy:ey, sx:ex) = peripheral_signal(sy:ey, sx:ex) + signal_p*activation_gaussian;
                weights(sy:ey, sx:ex) = weights(sy:ey, sx:ex) + activation_gaussian;
            end
        end
%         imshow(central_signal(100:400, 100:400) ./ weights(100:400, 100:400), [])
%         drawnow
        
    end
end
%% Find corners
min_sx = frame_pix + round(act_gauss_size/2);
min_sy = frame_pix + round(act_gauss_size/2);
max_ex = round(frame_pix - act_gauss_size/2 + ceil((num_cent_px-1)*fx_up));
max_ey = round(frame_pix - act_gauss_size/2 + ceil((nsteps-1)*shiftp/objp + (num_cent_py-1)*fy_up));

close (h)
% normalize by weights
central_signal = central_signal ./ weights;
central_signal = central_signal(min_sy+5:max_ey-5, min_sx+5:max_ex-5);
central_signal(isnan(central_signal)) = 0;

peripheral_signal = peripheral_signal ./ weights;
peripheral_signal = peripheral_signal(min_sy+5:max_ey-5, min_sx+5:max_ex-5);


end

%% Returns the corresponding image positions for the signal in the first
% camera frame (no scanning shift yet), so that no point of the grid of the
% output signal frame is shifted out completely during the scan
function [xi, yi] = object_positions(ix, iy, sp)
% ix(1) < n1 * sp; ix(2) > n2 * sp
n1 = floor(ix(1) / sp);
n2 = ceil(ix(2) / sp);

% iy(1) < m1 * sp; iy(2) > m2 * sp
m1 = floor(iy(1) / sp);
m2 = ceil(iy(2) / sp);

% make grid
[xi, yi] = ndgrid((n1 : n2) * sp, (m1 : m2) * sp);
end

%% Returns the distances to the closest pattern maxima of the actual positions xj and yj
function [t2max] = object_distances(size_x, size_y, fx, x0, fy, y0)
[y x] = ndgrid(1:size_y, 1:size_x);
txmax = mod(x - x0, fx);
h = txmax > fx / 2;
txmax(h) = txmax(h) - fx;

tymax = mod(y - y0, fy);
h = tymax > fy / 2;
tymax(h) = tymax(h) - fy;

t2max = sqrt(txmax.^2 + tymax.^2);

txmin = mod(x - x0 + fx/2, fx);
h = txmin > fx / 2;
txmin(h) = txmin(h) - fx;

tymin = mod(y - y0 + fy/2, fy);
h = tymin > fy / 2;
tymin(h) = tymin(h) - fy;

t2min = sqrt(txmin.^2 + tymin.^2);
end