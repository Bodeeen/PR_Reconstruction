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

%% Copute pattern values in units of upsampled pixels
x0_up = x0/objp;
y0_up = y0/objp;
fx_up = fx/objp;
fy_up = fy/objp;

%% object positions in image so that they are always in the scanned regions
%NOTE: These depend on scanning directions
[yi, xi] = ndgrid((0:dx/objp)*objp, (0:dy/objp)*objp);%object_positions([1, dx], [1, dy], objp);
try 
    if size(B, 2) ~= round((dx/objp)*(dy/objp))
        B = make_gauss_bases(dx/objp, dy/objp, diff_lim_px/objp, x0_up, y0_up, fx_up, fy_up);
    end
catch
    B = make_gauss_bases(size(data, 2)/objp, size(data, 1)/objp, diff_lim_px/objp, x0_up, y0_up, fx_up, fy_up);
end

Bt = B';
sBt = sparse(Bt);
G = B*B';
Ginv = inv(G);
h = waitbar(0,'Extracting coordinates...');
c = zeros(nframes, size(B,1));
for i = 1:nframes
    waitbar(i/nframes);
    frame = imresize(data(:,:,i), 1/objp);
    frame_vec = reshape(frame, [1, numel(frame)]);
    
    cdual = frame_vec * sBt;
    c(i,:) = cdual * Ginv;
    

end
close(h)

%% Activation gaussian is the 2D gaussian that corresponds in size to the
%  activation spot. Used to recontrucs the image.
act_gauss_size = 1+2*activation_size_px/objp;
activation_gaussian = Gausskern(act_gauss_size, activation_size_px/objp);

%% Allocate matrices for central signal and central weights
central_signal = zeros(size(xi, 1) + act_gauss_size, size(xi, 2) + act_gauss_size);
central_weights = zeros(size(xi, 1) + act_gauss_size, size(xi, 2) + act_gauss_size);

% Initiate values to store the corners of the reconstructed image
min_sx = 100;
min_sy = 100;
max_ex = 0;
max_ey = 0;
%Frame pixels
frame_pix = act_gauss_size;

% Loop over all coefficients and multiply each coefficient with a 
% correctly shifted activation gaussian
numspot1D = sqrt(size(G,1)) - 2; % -2 to avoid spots lying on the edge
for i = 1:nframes
    shift_y = -floor((i-1)/nsteps)* shiftp/objp;
    shift_x = -mod(i-1,nsteps) * shiftp/objp;
    for cx = 1:numspot1D
        for cy = 1:numspot1D
            % Determine correct area for activation gaussian to be
            % placed in 
            sy = frame_pix + ceil(shift_y + cy*fy_up);
            ey = round(sy + act_gauss_size - 1);
            sx = frame_pix + ceil(shift_x + cx*fx_up);
            ex = round(sx + act_gauss_size - 1);

            % Update corners
            min_sx = min(min_sx, sx);
            min_sy = min(min_sy, sy);
            max_ex = max(max_ex, ex);
            max_ey = max(max_ey, ey);
            
            % Add signal and wights
            signal = c(i, (cx-1)*sqrt(size(G,1))+cy);
            central_signal(sy:ey, sx:ex) = central_signal(sy:ey, sx:ex) + signal*activation_gaussian;
            central_weights(sy:ey, sx:ex) = central_weights(sy:ey, sx:ex) + activation_gaussian;
        end
    end
end
% normalize by weights
central_signal = central_signal ./ central_weights;
central_signal = central_signal(min_sy:max_ey-5, min_sx:max_ex-5);
central_signal(isnan(central_signal)) = 0;

end

function bases = make_gauss_bases(size_x, size_y, fwhm, x0, y0, fx, fy)

%%Calculate size of and create gaussian kernal
gauss_kern_size = ceil(4*fwhm + 1); % Use even factor in front
gauss_kern = Gausskern(gauss_kern_size, fwhm);

%Size of edge to use when creating base images
edg = ceil(gauss_kern_size / 2);

base_1 = zeros(2*edg+size_y, 2*edg+size_x);
center_1_x = round(x0 + edg);
center_1_y = round(y0 + edg);
rad = (gauss_kern_size - 1) / 2;
area_1_x = (center_1_x - rad:center_1_x + rad);
area_1_y = (center_1_y - rad:center_1_y + rad);
base_1(area_1_y, area_1_x) = gauss_kern;

steps_y = 1;
steps_x = 0;
shift_y = 0;
shift_x = 0;
cropped_base = base_1(edg:edg-1+size_y, edg:edg-1+size_x);
bases = reshape(cropped_base, [1, numel(cropped_base)]);
h = waitbar(0,'Extracting bases...');
while shift_x < size_x
    shift_x = round(steps_x * fx);
    while shift_y < size_y
        waitbar((shift_x*size_x + shift_y)/(size_y*size_x));
        shift_y = round(steps_y * fy);
        
        base = circshift(base_1, [shift_y shift_x]);
        steps_y = steps_y + 1;
%         bases(:,:,end+1) = base(frame:frame-1+size_y, frame:frame-1+size_x);
        cropped_base = base(edg:edg-1+size_y, edg:edg-1+size_x);
        bases(end + 1,:) = reshape(cropped_base, [1, numel(cropped_base)]);
    end
    steps_y = 0;
    shift_y = 0;
    steps_x = steps_x + 1;
end
close(h)
end





    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
