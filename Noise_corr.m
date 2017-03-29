function [ central_signal, bg_signal ] = Noise_corr( cent_signal, bg_signal, presets )
%UNTITLED2 Correct noise 
filter_size = 10,;
filter_fwhm = 5;
nulls = presets.nulls_x * presets.nulls_y;
kern = Gausskern(filter_size, filter_fwhm);
kern = kern./sum(kern(:));

filtered_bg = conv2(bg_signal, kern, 'same');

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

