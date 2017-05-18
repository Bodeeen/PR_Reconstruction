%% Make simulated MF-RESOLFT data

size_x = 10000;
size_y = 10000;
size_z = 2000;
px_size = 20;
%Make ndgrids, x-1 and y-1 is used to ease later construction of rec matrix
%z-1 is not used because we want a true z = 0 plane.
[yi, xi, zi] = ndgrid(-(size_x-1)/2:px_size:(size_x-1)/2, -(size_y-1)/2:px_size:(size_y-1)/2, -(size_z)/2:px_size:(size_z)/2);

s0xy = 185/2.355;
s0z = 500/2.355;

z_decay = exp(-zi.^2/(2*s0z^2));

step_size = 25;

uL_p = 750;
OP_p = 350;
WF_R = true;
if WF_R
    scan_size = OP_p;
else
    scan_size = uL_p;
end
assert(round(scan_size/step_size) == scan_size/step_size, 'Invalid step size')
s = s0xy ./ sqrt(z_decay);

%Make activation pattern
if WF_R
    Act = ones(size(xi));
else
    Act = zeros(size(xi));
    for dx = -size_x:uL_p:size_x
        for dy = -size_y:uL_p:size_y
            Act = Act + z_decay .* exp(-((xi-dx).^2 + (yi-dy).^2)./(2*s.^2));
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
gt = zeros(size(xi));
fp = zeros(size(xi, 1), size(xi,2));
row = 1;
step = 1;
while row < size(xi,1)
    fp(row,:) = 1;
    step = step+1;
    row = row + step;
end
k = 0.1;
gt(:,:,ceil(size(xi,3)/2)) = fp;
for x = 1 : size(xi, 2)
    z = ceil(size(xi,3)/2) + round(x*k);
    if z > size(xi, 3)
        break
    end
    gt(:, x, z) = fp(x,:);
end
gt = imrotate(gt, 30, 'crop');
%%Make data
px_size_out = 65;

act_sat_fac = 1;
off_sat_fac = 3;
ro_sat_fac = 1;

Act_fac = 1 - exp(-act_sat_fac .* Act);
Off_fac = exp(-off_sat_fac .* OP);
RO_fac = 1 - exp(-ro_sat_fac .* RO);

steps = scan_size / step_size;
[yj, xj, zj] = ndgrid(1:size(xi, 1), 1:size(xi,2), 1:size(xi,3));
step_size_px = step_size/px_size;
scan_size_px = scan_size/px_size;

test = imresize(xi,px_size/px_size_out);

rec = zeros(size(test, 1), size(test, 2), steps^2);

ft_diff_lim_kerns = zeros(size(rec, 1), size(rec, 2), size(xi, 3));
for i = 1:size(ft_diff_lim_kerns,3)
    diff_lim_kern = Gausskern(size(ft_diff_lim_kerns, 1), s(1,1,i)*2.355/px_size_out);
    diff_lim_kern = diff_lim_kern ./ sum(diff_lim_kern(:));
    ft_diff_lim_kerns(:,:,i) = fftshift(fft2(diff_lim_kern));
end
step = 1;
b_or_f = 1; %Back and forth mem var
for dx = step_size_px/2:step_size_px:scan_size_px - step_size_px/2
    for dy = step_size_px/2:step_size_px:scan_size_px - step_size_px/2
        % Make back and forth scan
        if mod(b_or_f, 2) == 0
            dy = scan_size_px - dy;
        end
        disp(['x step:' num2str(dx)])
        disp(['y step:' num2str(dy)])
        scan_data = interpn(gt, yj+dy, xj+dx, zj, 'linear', 0);
        Em = scan_data .* Act_fac .* Off_fac .* RO_fac;
        
        for z = 1:size(xi,3);
            Em_resized = imresize(Em, px_size/px_size_out);
            Em_resized(isnan(Em_resized)) = 0;
            Blurred = ifft2(ifftshift(abs(ft_diff_lim_kerns(:,:,z)).*fftshift(fft2(Em_resized(:,:,z)))));
            rec(:,:,step) = rec(:,:,step) + real(Blurred);
        end
        step = step + 1;
    end
    b_or_f = b_or_f + 1;
end     












