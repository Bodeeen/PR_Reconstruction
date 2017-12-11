function rec = Make_simulated_data( WF_R, OP_p )
% Make simulated RESOLFT data, input variable WF_R determines WF-RESOLFT
% mode (true) or MF/SP-RESOLFT mode (false). OP_p determines Off-pattern
% periodicity

%% Set parameters of simulation
% size_x = 10000;
% size_y = 10000;
% size_z = 4000;
size_x = 5000;
size_y = 5000;
size_z = 2000;
vx_size = 20; %Voxel side of the initial data volume 

step_size = 25; %Step size of scan
uL_p = 500; % uLens periodicity
zp = 2000; %Z-repetition of fourier planes

px_size_out = 65;

%Define the amount of energy (arbitrary units) delivered to the sample with
%each pulse. Also the bg level of off-switching and bg-fluorescence.
act_E = 2; %2 here Gives 86% activation
off_E = 10;
bg = 0.05;
ro_E = 2;% 2 here Gives 86% read_out
bg_fluorescence = 0.01; %Bg fluorescence is 1% of "structure fluorescence"

%% Make ndgrids, x-1 and y-1 is used to ease later construction of rec matrix
%z-1 is not used because we want a true z = 0 plane.
[yi, xi, zi] = ndgrid(-(size_x-1)/2:vx_size:(size_x-1)/2, -(size_y-1)/2:vx_size:(size_y-1)/2, -(size_z)/2:vx_size:(size_z)/2);

s0xy = 185/2.355; %Sigma of excitation PSF in xy where z = 0
s0z = 460/2.355;    % Sigma of excitation PSF in z where x=y=0
detPSFxy0 = 220/2.355; %Sigma of detection PSF in xy where z = 0
detPSFz0 = 520/2.355; %Sigma of detection PSF in z where x=y=0

z_decay_det = exp(-zi.^2/(2*detPSFz0^2)); % Decay of intensity along Z-axis of the detection PSF

detPSFxy = detPSFxy0 ./ sqrt(squeeze(z_decay_det(1,1,:))); % Decay of detection PSF sigma along z 

%Make OFF-switching pattern
% OP = 0.5 + 0.25*(cos((xi-OP_p/2)/(OP_p/(2*pi))) + cos((yi-OP_p/2)/(OP_p/(2*pi)))); % "Old" 2D pattern

lair = 488;
n = 1.51;
l = lair/n;

a1 = degtorad(68);
a2 = degtorad(0);

OP = cos((pi/l)*(-zi.*(sin(pi/2 - a1) - sin(pi/2 - a2)) - xi.*(cos(pi/2 - a1) - cos(pi/2 - 0)))).^2 + ...
cos((pi/l)*(-zi.*(sin(pi/2 + a1) - sin(pi/2 + a2)) - xi.*(cos(pi/2 + a1) - cos(pi/2 + a2)))).^2 + ...
cos((pi/l)*(-zi.*(sin(pi/2 - a1) - sin(pi/2 - a2)) - yi.*(cos(pi/2 - a1) - cos(pi/2 - a2)))).^2 + ...
cos((pi/l)*(-zi.*(sin(pi/2 + a1) - sin(pi/2 + a2)) - yi.*(cos(pi/2 + a1) - cos(pi/2 + a2)))).^2;

In_plane_p = 1/((1/l)*(cos(pi/2 - a1) + cos(pi/2 - a2)));

uL_p = 2*In_plane_p;

%Make activation pattern
if WF_R
    Act = ones(size(xi));
else
    Act = zeros(size(xi));
    zp1 = zp:zp:size_z/2;
    zp2 = fliplr(0:-zp:-size_z/2);
    zp_v = cat(2, zp2, zp1);
    for dz = zp_v
        if mod(dz/zp, 2) == 1
            xyshift = uL_p / 2;
        else
            xyshift = 0;
        end
        z_decay_ex = exp(-(zi-dz).^2/(2*s0z^2)); % Decay of intensity along Z-axis of the excitation light
        s = s0xy ./ sqrt(z_decay_ex);
        for dx = -size_x:uL_p:size_x
            for dy = -size_y:uL_p:size_y
                Act = Act + z_decay_ex .* exp(-((xi-dx-xyshift).^2 + (yi-dy-xyshift).^2)./(2*s.^2));
            end
        end
    end
end

%Make Read out pattern
RO = Act;

% for x = -4000:750:4000
%     for y = -4000:750:4000
%         RO = RO + z_decay .* exp(-((xi-x).^2 + (yi-y).^2)./(2*s.^2));
%     end
% end


%% Make GT volume
gt = bg_fluorescence*ones(size(xi));
fp = bg_fluorescence*ones(size(xi, 1), size(xi,2));
row = 1;
step = 0;
while row < size(xi,1)
    fp(row,:) = 1;
    step = step+0.5;
    row = row + round(100/vx_size * (2+sin(step)));
end
k = 0.1;
foc_z = ceil(size(xi,3)/2);
gt(:,:,foc_z) = fp;

z_step_nm = 300;
z_step_px = round(z_step_nm / vx_size);
rot_step = 1;
rot_ang = 10;
for z = foc_z + z_step_px:z_step_px:size(xi,3)
    gt(:,:,z) = imrotate(fp, rot_step*rot_ang, 'crop');
    rot_step = rot_step + 1;
end
rot_step = -1;
for z = foc_z - z_step_px:-z_step_px:1
    gt(:,:,z) = imrotate(fp, rot_step*rot_ang, 'crop');
    rot_step = rot_step - 1;
end
gt = imrotate(gt, 30, 'crop');

%% Make data
%Calculate factors for activation, off-switching and read-out.
Act_fac = 1 - exp(-act_E .* Act);
Off_fac = bg + (1-bg)*exp(-off_E .* OP);
RO_fac = (bg-1)*exp(-ro_E .* RO) + bg*(-ro_E .* RO) + 1 - bg;

%Scan parameters
if WF_R
    scan_size = OP_p; % In WF-RESOLFT mode, scan_size equals Off-pattern periodicity.
else
    scan_size = uL_p; % In MF/SP-RESOLFT mode, scan_size equals uL-pattern periodicity.
    assert(mod(uL_p, OP_p) == 0, 'Off pattern and microlens pattern does not match!')
end

%Correct so that scan_size is a multiple of step_size
if(round(scan_size/step_size) ~= scan_size/step_size)
       warning('Step size corrected!')
       steps = round(OP_p/step_size);
       step_size = OP_p / steps;
end


steps = scan_size / step_size;
[yj, xj, zj] = ndgrid(1:size(xi, 1), 1:size(xi,2), 1:size(xi,3));
step_size_px = step_size/vx_size;
scan_size_px = scan_size/vx_size;

%test is just matrix used to find what the size of the resized data will
%be.
test = imresize(xi,vx_size/px_size_out);

rec = zeros(size(test, 1), size(test, 2), steps^2);


%Create fourier domain filters for the different Z-planes to simulate the
%blurring of the microscope later.
ft_diff_lim_kerns = zeros(size(rec, 1), size(rec, 2), size(xi, 3));
for i = 1:size(ft_diff_lim_kerns,3)
    diff_lim_kern = Gausskern(size(ft_diff_lim_kerns, 1), detPSFxy(i)*2.355/px_size_out);
    diff_lim_kern = diff_lim_kern ./ sum(diff_lim_kern(:));
    ft_diff_lim_kerns(:,:,i) = fftshift(fft2(diff_lim_kern));
end
step = 1;
b_or_f = 1; %Back and forth memory var

%Simulate the scan
h = waitbar(0, 'Simulating...');
for dx = step_size_px/2:step_size_px:scan_size_px - step_size_px/2
    waitbar(dx/scan_size_px)
    for dy = step_size_px/2:step_size_px:scan_size_px - step_size_px/2
        % Make back and forth scan
        if mod(b_or_f, 2) == 0
            dy = scan_size_px - dy;
        end
        scan_data = interpn(gt, yj+dy, xj+dx, zj, 'linear', 0);
        Em = scan_data .* Act_fac .* Off_fac .* RO_fac;
        
        if size(Em) == size(test)
            Em_resized = Em;
        else
            Em_resized = imresize(Em, vx_size/px_size_out);
            Em_resized(isnan(Em_resized)) = 0;
        end
        
        for z = 1:size(xi,3);
            Blurred = ifft2(ifftshift(abs(ft_diff_lim_kerns(:,:,z)).*fftshift(fft2(Em_resized(:,:,z)))));
            rec(:,:,step) = rec(:,:,step) + real(Blurred);
        end
        step = step + 1;
    end
    b_or_f = b_or_f + 1;
end
close(h)
%Add emtpy first frame, only because the real data has that and the
%reconstruction software is writted to account for that.
rec = cat(3, zeros(size(rec, 1),size(rec, 2)), rec);


end

