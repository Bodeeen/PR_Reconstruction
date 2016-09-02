 function [central_signal, peripheral_signal] = signal_extraction(data, pattern, objp, shiftp, W)
% Given the pattern period and offset as well as the output pixel length
% and the scanning pixel length it constructs the central and peripheral
% signal frames as used in the publication: 'Nanoscopy with more than a
% hundred thousand "doughnuts"' by Andriy Chmyrov et al., to appear in
% Nature Methods, 2013
%
% pattern is the periods and offsets of the on-switched regions

%% error checks
assert(nargin == 5)

%%Scan directions

%% data parameters
dx = size(data, 1);
dy = size(data, 2);
nframes = size(data, 3);
nsteps = sqrt(nframes);

% decode the pattern
fx = pattern(1);
x0 = pattern(2);
fy = pattern(3);
y0 = pattern(4);

%% object positions in image so that they are always in the scanned regions
%NOTE: These depent on scanning directions
[xi, yi] = object_positions([1, dx - fx], [1, dy - fy], objp);

%% central loop: interpolate camera frame on shifting grids (scanning)
% and extract central and peripheral signals
central_signal = 0;
central_signal_weights = 0;
peripheral_signal = 0;
peripheral_signal_weights = 0;

% loop (attention, the scanning direction of our microscope is hardcoded,
% first down, then right)
h = waitbar(0,'Extracting signal...');
for kx = 0 : nsteps - 1
    shift_x = kx * shiftp;
    
    for ky = 0 : nsteps - 1
        waitbar((kx*nsteps + ky)/(nsteps^2))
        shift_y = ky * shiftp;
        
        % get frame number and frame
        kf = ky + 1 + nsteps * kx;
        frame = data(:, :, kf);
        
        % adjust positions for this frame
        xj = xi + shift_x;
        yj = yi + shift_y;
        
        % interpolation
        est = interpn(frame, xj, yj, 'nearest');
        
        % result will be isnan for outside interpolation (should not happen)
        est(isnan(est)) = 0;
        est = max(est, 0); % no negative values (should only happen rarely)
        
        % compute distance to cener (minima of off switching pattern)
        [t2max, ~] = object_distances(xj, yj, fx, x0, fy, y0);
        
        % compute weights (we add up currently 50nm around each position),
        % feel free to change this value for tradeoff of SNR and resolution
%         W = 0.05 / 0.0975;
        wmax = power(2., -t2max / (W / 2)^2);
        
        % add up with weights
        central_signal = central_signal + wmax .* est;
        central_signal_weights = central_signal_weights + wmax;
        
        % subtraction of surrounding minima
        cx = round(fx / 2 / objp); % cx/cy here is the distance (in upsampled pixels) between
        cy = round(fy / 2 / objp); % a minima and a maxima in the different dimensions.
        
        % left upper
        shifted = circshift(est, [-cx, -cy]);
        peripheral_signal = peripheral_signal + wmax .* shifted;
        peripheral_signal_weights = peripheral_signal_weights + wmax;
        
        % another
        shifted = circshift(est, [cx, -cy]);
        peripheral_signal = peripheral_signal + wmax .* shifted;
        peripheral_signal_weights = peripheral_signal_weights + wmax;
        
        % another
        shifted = circshift(est, [-cx, cy]);
        peripheral_signal = peripheral_signal + wmax .* shifted;
        peripheral_signal_weights = peripheral_signal_weights + wmax;
        
        % another
        shifted = circshift(est, [cx, cy]);
        peripheral_signal = peripheral_signal + wmax .* shifted;
        peripheral_signal_weights = peripheral_signal_weights + wmax;
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
function [t2max, t2min] = object_distances(xj, yj, fx, x0, fy, y0)
tx = mod(xj - x0, fx);
h = tx > fx / 2;
tx(h) = tx(h) - fx;

ty = mod(yj - y0, fy);
h = ty > fy / 2;
ty(h) = ty(h) - fy;

t2max = tx.^2 + ty.^2;

tx = mod(xj - x0 + fx/2, fx);
h = tx > fx / 2;
tx(h) = tx(h) - fx;

ty = mod(yj - y0 + fy/2, fy);
h = ty > fy / 2;
ty(h) = ty(h) - fy;

t2min = tx.^2 + ty.^2;
end