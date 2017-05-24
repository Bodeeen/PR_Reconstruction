function rec = Make_simulated_data( WF_R, OP_p )

%% Make simulated MF-RESOLFT data

%% Set parameters of simulation
size_x = 10000;
size_y = 10000;
size_z = 4000;
px_size = 32.5;

step_size = 25;
uL_p = 750;
% OP_p = 320;

% WF_R = true;

px_size_out = 65;

act_sat_fac = 2; %2 here Gives 86% activation
off_sat_fac = 10;
off_switch_bg_lvl = 0.1;
ro_sat_fac = 2;% 2 here Gives 86% read_out
bg_fluorescence = 0.1; %Bg fluorescence is 10% of "structure fluorescence"

%% Make ndgrids, x-1 and y-1 is used to ease later construction of rec matrix
%z-1 is not used because we want a true z = 0 plane.
[yi, xi, zi] = ndgrid(-(size_x-1)/2:px_size:(size_x-1)/2, -(size_y-1)/2:px_size:(size_y-1)/2, -(size_z)/2:px_size:(size_z)/2);

s0xy = 185/2.355;
s0z = 460/2.355;
detPSFxy0 = 220/2.355; %Sigma of detection PSF in xy where z = 0
detPSFz0 = 520/2.355; %Sigma of detection PSF in z where x=y=0

z_decay_ex = exp(-zi.^2/(2*s0z^2));
z_decay_det = exp(-zi.^2/(2*detPSFz0^2));

if WF_R
    scan_size = OP_p;
else
    scan_size = uL_p;
    assert(mod(uL_p, OP_p) == 0, 'Off pattern and microlens pattern does not match!')
end
if(round(scan_size/step_size) ~= scan_size/step_size)
       warning('Step size corrected!')
       steps = round(OP_p/step_size);
       step_size = OP_p / steps;
end
s = s0xy ./ sqrt(z_decay_ex);
detPSFxy = detPSFxy0 ./ sqrt(squeeze(z_decay_det(1,1,:))); % Decay of detection PSF sigma along z 

%Make activation pattern
if WF_R
    Act = ones(size(xi));
else
    Act = zeros(size(xi));
    for dx = -size_x:uL_p:size_x
        for dy = -size_y:uL_p:size_y
            Act = Act + z_decay_ex .* exp(-((xi-dx).^2 + (yi-dy).^2)./(2*s.^2));
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

%Make OFF-switching pattern
OP = 0.5 + 0.25*(cos((xi-OP_p/2)/(OP_p/(2*pi))) + cos((yi-OP_p/2)/(OP_p/(2*pi))));
%% Make GT volume
gt = bg_fluorescence*ones(size(xi));
fp = zeros(size(xi, 1), size(xi,2));
row = 1;
step = 1;
while row < size(xi,1)
    fp(row,:) = 1;
    step = step+1;
    row = row + step;
end
k = 0.1;
foc_z = ceil(size(xi,3)/2);
gt(:,:,foc_z) = fp;
% for x = 1 : size(xi, 2)
%     z = ceil(size(xi,3)/2) + round(x*k);
%     if z > size(xi, 3)
%         break
%     end
%     gt(:, x, z) = fp(x,:);
% end
z_step_nm = 200;
z_step_px = round(z_step_nm / px_size);
rot_step = 1;
rot_ang = 10;
for z = foc_z + z_step_px:z_step_px:size(xi,3)
    gt(:,:,z) = imrotate(fp, rot_step*rot_ang, 'crop');
    rot_step = rot_step + 1;
end
gt = gpuArray(imrotate(gt, 30, 'crop'));
% gt = imrotate(gt, 30, 'crop');
%%
%%Make data

Act_fac = gpuArray(1 - exp(-act_sat_fac .* Act));
Off_fac = gpuArray(off_switch_bg_lvl + (1-off_switch_bg_lvl)*exp(-off_sat_fac .* OP));
RO_fac = gpuArray(1 - exp(-ro_sat_fac .* RO));

steps = scan_size / step_size;
[yj, xj, zj] = ndgrid(1:size(xi, 1), 1:size(xi,2), 1:size(xi,3));
step_size_px = step_size/px_size;
scan_size_px = scan_size/px_size;

test = imresize(xi,px_size/px_size_out);

rec = zeros(size(test, 1), size(test, 2), steps^2);

ft_diff_lim_kerns = zeros(size(rec, 1), size(rec, 2), size(xi, 3));
for i = 1:size(ft_diff_lim_kerns,3)
    diff_lim_kern = Gausskern(size(ft_diff_lim_kerns, 1), detPSFxy(i)*2.355/px_size_out);
    diff_lim_kern = diff_lim_kern ./ sum(diff_lim_kern(:));
    ft_diff_lim_kerns(:,:,i) = fftshift(fft2(diff_lim_kern));
end
ft_diff_lim_kerns = gpuArray(ft_diff_lim_kerns);
step = 1;
b_or_f = 1; %Back and forth mem var
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
            Em_resizedGPU = Em;
        else
            Em_resizedGPU = imresize(Em, px_size/px_size_out);
            Em_resizedGPU(isnan(Em_resizedGPU)) = 0;
        end
        
        for z = 1:size(xi,3);
            Blurred = ifft2(ifftshift(abs(ft_diff_lim_kerns(:,:,z)).*fftshift(fft2(Em_resizedGPU(:,:,z)))));
            rec(:,:,step) = rec(:,:,step) + gather(real(Blurred));
        end
        step = step + 1;
    end
    b_or_f = b_or_f + 1;
end
close(h)
rec = cat(3, zeros(size(rec, 1),size(rec, 2)), rec);












end

