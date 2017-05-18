function [corrected] = bleaching_correction(data)

dims = size(data);
nframes = dims(3);


sum_sig = squeeze(mean(mean(data, 1), 2));
sum_sig_inv = sum_sig - min(sum_sig);
sum_sig_inv = max(sum_sig_inv) - sum_sig_inv;
sum_sig_inv = sum_sig_inv - mean(sum_sig_inv);
sum_sig_norm = sum_sig/mean(sum_sig);

corrected = zeros(dims);
for kf = 1 : nframes
    corrected(:, :, kf) = (data(:, :, kf) + sum_sig_inv(kf));
end
end