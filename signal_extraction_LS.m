function [central_signal B] = signal_extraction(data, pattern, B, diff_lim_px, objp, shiftp, W, activation_size_px)
% Given the pattern period and offset as well as the output pixel length
% and the scanning pixel length it constructs the central and peripheral
% signal frames as used in the publication: 'Nanoscopy with more than a
% hundred thousand "doughnuts"' by Andriy Chmyrov et al., to appear in
% Nature Methods, 2013
%
% pattern is the periods and offsets of the on-switched regions

%% error checks
assert(nargin == 8)

%%Scan directions

%% data parameters
dy = size(data, 1);
dx = size(data, 2);
nframes = size(data, 3);
nsteps = sqrt(nframes);

pinhole_shrink_fac = (W/activation_size_px);

% decode the pattern
fy = pattern(1);
y0 = pattern(2);
fx = pattern(3);
x0 = pattern(4);

%% Compute pattern values in units of upsampled pixels
dx_up = ceil(dx/objp);
dy_up = ceil(dy/objp);
x0_up = x0/objp;
y0_up = y0/objp;
fx_up = fx/objp;
fy_up = fy/objp;

%% object positions in image so that they are always in the scanned regions
%NOTE: These depend on scanning directions
[yi, xi] = ndgrid((0:dx/objp)*objp, (0:dy/objp)*objp);%object_positions([1, dx], [1, dy], objp);
try 
    if size(B{1}, 1) == dx_up*dy_up
        numspotsX = B{2};
        numspotsY = B{3};
        B = B{1};
    else
        [numspotsX numspotsY B] = make_gauss_bases(dx_up, dy_up, diff_lim_px/objp, x0_up, y0_up, fx_up, fy_up);
    end
catch
    [numspotsX numspotsY B] = make_gauss_bases(dx_up, dy_up, diff_lim_px/objp, x0_up, y0_up, fx_up, fy_up);
end
sB = sparse(B);
sBt = sB';
G = sBt*sB;
Ginv = inv(G);
h = waitbar(0,'Extracting coordinates...');
c = zeros(size(G,1), nframes);

for i = 1:nframes
    waitbar(i/nframes);
    frame = imresize(data(:,:,i), 1/objp, 'nearest');
    frame_vec = reshape(frame, [numel(frame) 1]);
    
    cd = sBt*frame_vec;
%     c(:, i) = lsqnonneg(G ,cd);
    c(:, i) = Ginv*cd; % Linear least squares solution.
                        % NOTE: Order of computation essential for computation
                        % time


end
close(h)

%% Activation gaussian is the 2D gaussian that corresponds in size to the
%  activation spot. Used to recontrucs the image.
act_gauss_size = 1+2*round(activation_size_px/objp);
activation_gaussian = Gausskern(act_gauss_size, activation_size_px/objp);


%Frame pixels
frame_pix = 100;%act_gauss_size;

%% Allocate matrices for central signal and central weights
central_signal = zeros(ceil(dy_up + 2*frame_pix + fy_up), ceil(dx_up + 2*frame_pix + fx_up));
central_weights = zeros(ceil(dy_up + 2*frame_pix + fy_up), ceil(dx_up + 2*frame_pix + fx_up));

% Initiate values to store the corners of the reconstructed image
min_sx = 100;
min_sy = 100;
max_ex = 0;
max_ey = 0;


% Loop over all coefficients and multiply each coefficient with a 
% correctly shifted activation gaussian

for i = 1:nframes
    l = floor((i-1)/nsteps);
    shift_x = -l* shiftp/objp;
    dir = (-1)^l;
    off = mod(l,2);
    shift_y = off*(nsteps - 1)*shiftp/objp + dir * mod(i-1,nsteps) * shiftp/objp;
    for cx = 1:numspotsX % -2 to avoid spots lying on the edge
        for cy = 1:numspotsY
            % Determine correct area for activation gaussian to be
            % placed in 
            sy = frame_pix + ceil(shift_y + (cy-1)*fy_up);
            ey = round(sy + act_gauss_size - 1);
            sx = frame_pix + ceil(shift_x + cx*fx_up);
            ex = round(sx + act_gauss_size - 1);

            % Update corners
            min_sx = min(min_sx, sx);
            min_sy = min(min_sy, sy);
            max_ex = max(max_ex, ex);
            max_ey = max(max_ey, ey);

            % Add signal and wights
            signal = c((cx-1)*numspotsY+cy, i);
            central_signal(sy:ey, sx:ex) = central_signal(sy:ey, sx:ex) + signal*activation_gaussian;
            central_weights(sy:ey, sx:ex) = central_weights(sy:ey, sx:ex) + activation_gaussian;
        end
    end
%     imshow(central_signal,[]);
%     drawnow
end
% normalize by weights
central_signal = central_signal ./ central_weights;
central_signal = central_signal(min_sy+5:max_ey-5, min_sx+5:max_ex-5);
central_signal(isnan(central_signal)) = 0;
B = {B, numspotsX, numspotsY};
end 

function [numspotsX numspotsY bases] = make_gauss_bases(size_x, size_y, fwhm, x0, y0, fx, fy)

%%Calculate size of and create gaussian kernal
gauss_kern_size = 4*round(fwhm) + 1; % Use even factor in front
gauss_kern = Gausskern(gauss_kern_size, fwhm);

%Size of edge to use when creating base images
edg = ceil(gauss_kern_size / 2);

base_1 = sparse(zeros(2*edg+size_y, 2*edg+size_x));
center_1_x = round(x0 + edg);
center_1_y = round(y0 + edg);
rad = (gauss_kern_size - 1) / 2;
area_1_x = (center_1_x - rad:center_1_x + rad);
area_1_y = (center_1_y - rad:center_1_y + rad);
base_1(area_1_y, area_1_x) = gauss_kern;

steps_y = 1;
steps_x = 0;
shift_y = round(fy);
shift_x = 0;
cropped_base = base_1(edg:edg-1+size_y, edg:edg-1+size_x);
bases = reshape(cropped_base, [numel(cropped_base) 1]);
h = waitbar(0,'Extracting bases...');
while shift_x < size_x
    while shift_y < size_y
        waitbar((shift_x*size_x + shift_y)/(size_y*size_x));
        
        base = circshift(base_1, [shift_y shift_x]);
%         bases(:,:,end+1) = base(edg:edg-1+size_y, edg:edg-1+size_x);
        cropped_base = base(edg:edg-1+size_y, edg:edg-1+size_x);
        bases(:, end + 1) = reshape(cropped_base, [numel(cropped_base) 1]);
        steps_y = steps_y + 1;
        shift_y = round(steps_y * fy);
    end
    steps_x = steps_x + 1;
    shift_x = round(steps_x * fx);
    maxY = steps_y;
    maxX = steps_x;
    steps_y = 0;
    shift_y = 0;
    
end
numspotsX = maxX;
numspotsY = maxY;
close(h)
end





    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
