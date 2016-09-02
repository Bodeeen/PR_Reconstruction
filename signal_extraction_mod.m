 function [central_signal, peripheral_signal] = signal_extraction(data, pattern, objp, shiftp, W, activation_size_px)
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
fx = pattern(1);
x0 = pattern(2);
fy = pattern(3);
y0 = pattern(4);

%% object positions in image so that they are always in the scanned regions
%NOTE: These depent on scanning directions
[xi, yi] = object_positions([1, dx], [1, dy], objp);

%% central loop: interpolate camera frame on shifting grids (scanning)
% and extract central and peripheral signals
central_signal = 0;
central_signal_weights = 0;
peripheral_signal = 0;
peripheral_signal_weights = 0;

cx = round(fx / 2 / objp); % cx/cy here is the distance (in upsampled pixels) between
cy = round(fy / 2 / objp); % a minima and a maxima in the different dimensions.

[t2max, txmin, tymin, txmax, tymax] = object_distances(xi, yi, fx, x0, fy, y0);
central_wmax = power(2., -t2max / (W / 2)^2);

% create x and y vector elements for resizing pinholed gaussian
resize_vec_x = pinhole_shrink_fac * txmax;
outside_pos = resize_vec_x > fx/2;
outside_neg = resize_vec_x < -fx/2;
resize_vec_x(outside_pos == 1) = fx/2;
resize_vec_x(outside_neg == 1) = -fx/2;

resize_vec_y = pinhole_shrink_fac * tymax;
outside_pos = resize_vec_y > fy/2;
outside_neg = resize_vec_y < -fy/2;
resize_vec_y(outside_pos == 1) = fy/2;
resize_vec_y(outside_neg == 1) = -fy/2;



periph_wmax = circshift(central_wmax, [-cx, -cy]);

[xj, yj] = ndgrid(1:size(xi,2), 1:size(xi,1));

% loop (attention, the scanning direction of our microscope is hardcoded,
% first down, then right)
h = waitbar(0,'Extracting signal...');
for kx = 0 : nsteps - 1
    shift_x = (kx * shiftp) / objp;
    
    for ky = 0 : nsteps - 1
        waitbar((kx*nsteps + ky)/(nsteps^2))
        shift_y = (ky * shiftp) / objp;
        
        % get frame number and frame
        kf = ky + 1 + nsteps * kx;
        frame = data(:, :, kf);
        % Upsampling
        est = interpn(frame, xi, yi, 'nearest');

        central_est = central_wmax .* est;
        peripheral_est = periph_wmax .* est;
        
        %Shift and sum peripheral signal and weights
        shifted = circshift(peripheral_est, [cx, cy]);
        shifted_w = circshift(periph_wmax, [cx, cy]);
        
        shifted = shifted + circshift(peripheral_est, [cx, -cy]);
        shifted_w = shifted_w + circshift(periph_wmax, [cx, -cy]);
        
        shifted = shifted + circshift(peripheral_est, [-cx, cy]);
        shifted_w = shifted_w + circshift(periph_wmax, [-cx, cy]);
        
        shifted = shifted + circshift(peripheral_est, [-cx, -cy]);
        shifted_w = shifted_w + circshift(periph_wmax, [-cx, -cy]);
        
        %Scale gaussian pinholes
        
        xsc = xj - txmax + resize_vec_x;
        ysc = yj - tymax + resize_vec_y;
        
        central_est = interpn(central_est, xsc, ysc, 'linear');
        
        per_est_sum = interpn(shifted, xsc, ysc, 'nearest');
        
        % adjust positions for this frame
        xsh = xj + shift_x;% - txmax + resize_vec_x;
        ysh = yj + shift_y;% - tymax + resize_vec_y;
        % Shift frame to correct position
        
        central_est = interpn(central_est, xsh, ysh, 'linear');
        
        per_est_sum = interpn(per_est_sum, xsh, ysh, 'nearest');
%        
%         test = interpn(central_wmax, xsh, ysh, 'linear');
%         imshow(central_est,[])
%         drawnow

        % Shift weights to correct position
        weights_shifted = interpn(central_wmax, xsh, ysh, 'nearest');
        
        per_weights_sum = interpn(shifted_w, xsh, ysh, 'nearest');

        
        % result will be isnan for outside interpolation (should not happen)
        central_est(isnan(central_est)) = 0;
        central_est = max(central_est, 0); % no negative values (should only happen rarely)
        
        central_signal = central_signal + central_est;
        central_signal_weights = central_signal_weights + weights_shifted;
        
        peripheral_signal = peripheral_signal + per_est_sum;
        peripheral_signal_weights = peripheral_signal_weights + per_weights_sum;
        % compute distance to center (minima of off switching pattern)

        
        % compute weights (we add up currently 50nm around each position),
        % feel free to change this value for tradeoff of SNR and resolution
%         W = 0.05 / 0.0975;

        
%         % subtraction of surrounding minima
%         cx = round(fx / 2 / objp); % cx/cy here is the distance (in upsampled pixels) between
%         cy = round(fy / 2 / objp); % a minima and a maxima in the different dimensions.
%         
%         % left upper
%         shifted = circshift(est, [-cx, -cy]);
%         peripheral_signal = peripheral_signal + cental_wmax .* shifted;
%         peripheral_signal_weights = peripheral_signal_weights + cental_wmax;
%         
%         % another
%         shifted = circshift(est, [cx, -cy]);
%         peripheral_signal = peripheral_signal + cental_wmax .* shifted;
%         peripheral_signal_weights = peripheral_signal_weights + cental_wmax;
%         
%         % another
%         shifted = circshift(est, [-cx, cy]);
%         peripheral_signal = peripheral_signal + cental_wmax .* shifted;
%         peripheral_signal_weights = peripheral_signal_weights + cental_wmax;
%         
%         % another
%         shifted = circshift(est, [cx, cy]);
%         peripheral_signal = peripheral_signal + cental_wmax .* shifted;
%         peripheral_signal_weights = peripheral_signal_weights + cental_wmax;
%         imshow(central_signal,[])
%         drawnow
    end
end
close (h)
% normalize by weights
central_signal = central_signal ./ central_signal_weights;

peripheral_signal = peripheral_signal ./ peripheral_signal_weights;

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
function [t2max, txmin, tymin, txmax, tymax] = object_distances(xj, yj, fx, x0, fy, y0)
txmax = mod(xj - x0, fx);
h = txmax > fx / 2;
txmax(h) = txmax(h) - fx;

tymax = mod(yj - y0, fy);
h = tymax > fy / 2;
tymax(h) = tymax(h) - fy;

t2max = txmax.^2 + tymax.^2;

txmin = mod(xj - x0 + fx/2, fx);
h = txmin > fx / 2;
txmin(h) = txmin(h) - fx;

tymin = mod(yj - y0 + fy/2, fy);
h = tymin > fy / 2;
tymin(h) = tymin(h) - fy;

t2min = txmin.^2 + tymin.^2;
end