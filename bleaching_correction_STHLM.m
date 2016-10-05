function [corrected] = bleaching_correction(data)
% Bleaching can induce a decay in the total signal collected in each frame.
% Here we divide the total signal per frame by this decay.

dims = size(data);
nframes = dims(3);

x = (1 : nframes)';
% average_frame = mean(data, 3);
% average_frame = average_frame - min(average_frame(:));
% average_frame = average_frame / max(average_frame(:));
% 
% bg_thresh = median(average_frame(:));
% 
% sig = average_frame > bg_thresh;

%% compute total signal per frame, where there is actually signal
% sum_sig = []
% for i = 1:dims(3)
%     frame = data(:,:,i);
%     sum_sig(end+1) = mean(frame(:));
% end
sum_sig = squeeze(mean(mean(data, 1), 2));
sum_sig_inv = sum_sig - min(sum_sig);
sum_sig_inv = max(sum_sig_inv) - sum_sig_inv;
sum_sig_inv = sum_sig_inv - mean(sum_sig_inv);
sum_sig_norm = sum_sig/mean(sum_sig);

%% smooth total signal per frame to get the average decay without noise,
% but also without too much smoothing (requires careful parameter
% adjustment), using Savitzky-Golay-filtering
% v = sgolayfilt(sum_sig, 15, min(141, 2 * floor(nframes / 2) - 1));
% v = v / mean(v); % so we divide by 1 on average (total counts aren't distorted too much)

%% create output data array and fill it with camera frames divided by
% correction factor
corrected = zeros(dims);
for kf = 1 : nframes
    corrected(:, :, kf) = (data(:, :, kf) + sum_sig_inv(kf));
end
corr_av = squeeze(mean(mean(corrected, 1), 2));
end