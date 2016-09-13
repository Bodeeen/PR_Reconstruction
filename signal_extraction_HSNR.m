 function central_signal = signal_extraction(data, pattern, objp, shiftp, W, activation_size_px)
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
[yi, xi] = ndgrid((0:dx/objp)*objp, (0:dy/objp)*objp);%object_positions([1, dx], [1, dy], objp);

%% central loop: interpolate camera frame on shifting grids (scanning)
% and extract central and peripheral signals
central_signal = 0;
central_signal_weights = 0;
peripheral_signal = 0;
peripheral_signal_weights = 0;

cx = round(fx / 2 / objp); % cx/cy here is the distance (in upsampled pixels) between
cy = round(fy / 2 / objp); % a minima and a maxima in the different dimensions.

%% Calculate distances of each pixel to nearest activation center and
%  from this compute central and peripheral weights. central_weights
%  contains a gaussian window for each activation spot.
[t2max] = object_distances(xi, yi, fx, x0, fy, y0);
c = 2*(W/2.35)^2;
central_wmax = exp(-(t2max.^2/c));
periph_wmax = circshift(central_wmax, [-cx, -cy]);

%% Copute pattern values in units of upsampled pixels
x0_up = x0/objp;
y0_up = y0/objp;
fx_up = fx/objp;
fy_up = fy/objp;

%% Activation gaussian is the 2D gaussian that corresponds in size to the
%  activation spot. Used to recontrucs the image.
act_gauss_size = 1+2*activation_size_px/objp;
activation_gaussian = Gausskern(act_gauss_size, activation_size_px/objp);

%% Calculate number of activation spots in each dimension to use for 
%  reconstruction
numspotsx = floor((size(xi,2) - (x0_up+fx_up/2)) / (fx_up));
numspotsy = floor((size(xi,1) - (y0_up+fy_up/2)) / (fy_up));

%Frame pixels
frame_pix = 5*act_gauss_size;

%% Allocate matrices for central signal and central weights
central_signal = zeros(size(xi, 1) + 2*frame_pix, size(xi, 2)+ 2*frame_pix);
central_weights = zeros(size(xi, 1) + 2*frame_pix, size(xi, 2)+ 2*frame_pix);

% Initiate values to store the corners of the reconstructed image
min_sx = 100;
min_sy = 100;
max_ex = 0;
max_ey = 0;

% loop (attention, the scanning direction of our microscope is hardcoded,
% first down, then right)
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
        central_est = central_wmax .* est;
        periph_est = periph_wmax .* est;
        
        % Allocate matrix for storing coefficients (signal from each
        % activation spot)
        coeffs = zeros(numspotsy, numspotsx);
        
        % Find start and end pixel in each dimension defining the area
        % from where to extract signal
        py_s = ceil(y0_up+fy_up/2); % Start y
        py_e = floor(y0_up - 1 +numspotsy*fy_up); % End y
        px_s = ceil(x0_up+fx_up/2); %Start x
        px_e = floor(x0_up - 1 +numspotsy*fx_up); % End x
        
        % Loop over each pixel in frame and assign value to correct
        % coefficient
        for py = py_s:py_e
            for px = px_s:px_e
                % Determine with coefficient the pixel belongs to (x and y)
                cy = 1+floor((py-(y0_up+fy_up/2))/fy_up);
                cx = 1+floor((px-(x0_up+fx_up/2))/fx_up);
                % Add pixel value to coefficient
                coeffs(cy,cx) = coeffs(cy,cx) + central_est(py,px);
            end
        end
        
        
        % Loop over all coefficients and multiply each coefficient with a 
        % correctly shifted activation gaussian
        for cy = 1:numspotsy
            for cx = 1:numspotsx
                % Determine correct area for activation gaussian to be
                % placed in 
                sy = frame_pix + ceil(shift_y + (cy-1)*fy_up);
                ey = round(sy + act_gauss_size - 1);
                sx = frame_pix + ceil(shift_x + (cx-1)*fx_up);
                ex = round(sx + act_gauss_size - 1);

                % Add signal and wights
                signal = coeffs(cy,cx);
                central_signal(sy:ey, sx:ex) = central_signal(sy:ey, sx:ex) + signal*activation_gaussian;
                central_weights(sy:ey, sx:ex) = central_weights(sy:ey, sx:ex) + activation_gaussian;
            end
        end
%         peripheral_est = periph_wmax .* est;
%         imshow(central_signal,[])
%         drawnow
    end
end
%% Find corners
min_sx = round(frame_pix - nsteps*shiftp/objp);
min_sy = frame_pix;
max_ex = round(frame_pix + ceil((numspotsx-1)*fx_up));
max_ey = round(frame_pix + ceil(nsteps*shiftp/objp + (numspotsy-1)*fx_up));

close (h)
% normalize by weights
central_signal = central_signal ./ central_weights;
central_signal = central_signal(min_sy:max_ey-5, min_sx:max_ex-5);
central_signal(isnan(central_signal)) = 0;

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
function [t2max] = object_distances(xj, yj, fx, x0, fy, y0)
txmax = mod(xj - x0, fx);
h = txmax > fx / 2;
txmax(h) = txmax(h) - fx;

tymax = mod(yj - y0, fy);
h = tymax > fy / 2;
tymax(h) = tymax(h) - fy;

t2max = sqrt(txmax.^2 + tymax.^2);

txmin = mod(xj - x0 + fx/2, fx);
h = txmin > fx / 2;
txmin(h) = txmin(h) - fx;

tymin = mod(yj - y0 + fy/2, fy);
h = tymin > fy / 2;
tymin(h) = tymin(h) - fy;

t2min = sqrt(txmin.^2 + tymin.^2);
end