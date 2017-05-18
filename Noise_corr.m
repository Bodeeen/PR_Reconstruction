function [ central_signal, bg_signal ] = Noise_corr( cent_signal, bg_signal, presets )
%UNTITLED2 Correct noise 
filter_size = 10,;
filter_fwhm = 5;
nulls = presets.nulls_x * presets.nulls_y;
kern = Gausskern(filter_size, filter_fwhm);
kern = kern./sum(kern(:));

pad = 50

% bg_mat = cmats(:,:,2);
% bg_signal = cmat2image(bg_mat, presets, 0, 0);
% startmean = mean(bg_mat(:,1:10), 2);
% startmeans = repmat(startmean, [1, pad]);
% endmean = mean(bg_mat(:,end-9:end), 2);
% endmeans = repmat(endmean, [1, pad]);
% 
% bg_mat_ext = [startmeans bg_mat endmeans];
% filtered_bg_ext = filtfilt(kern, [1], bg_mat_ext')';%conv2(bg_mat, kern, 'same');
% filtered_bg = filtered_bg_ext(:,pad+1:end-pad);

filtered_bg = conv2(bg_signal, kern, 'same');

% bg_signal = cmat2image(filtered_bg, presets, 0, 0);
% cent_signal = cmat2image(cmats(:,:,1), presets, 0, 0);

cent_bases = presets.B(:,1:nulls);
bg_bases = presets.B(:,nulls+1:end);
nulls_y = presets.nulls_y;
nulls_x = presets.nulls_x;
null_im = reshape(1:nulls_y*nulls_x, [nulls_y nulls_x]);
null_im = imresize(null_im, size(cent_signal,1)/presets.nulls_y, 'nearest');
cent_squared = diag(cent_bases'*cent_bases)';

corr_cent = zeros(size(cent_signal));

for i = 1:numel(cent_signal)
    cent_vec = cent_signal(i)*cent_bases(:,null_im(i));
    bg_vec = bg_signal(i) * bg_bases(:,null_im(i));
    filt_vec = filtered_bg(i) * bg_bases(:,null_im(i));
    v = cent_vec + bg_vec - filt_vec;
    corr_cent(i) = v'*cent_bases(:,null_im(i))./cent_squared(null_im(i));
end

central_signal = corr_cent;
bg_signal = filtered_bg;

