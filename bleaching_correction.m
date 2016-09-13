function [corrected] = bleaching_correction(data)
% Bleaching can induce a decay in the total signal collected in each frame.
% Here we divide the total signal per frame by this decay.

dims = size(data);
nframes = dims(3);
%% compute total signal per frame
total_signal_per_frame = squeeze(sum(sum(data, 1), 2));
x = (1 : nframes)';

%% smooth total signal per frame to get the average decay without noise,
% but also without too much smoothing (requires careful parameter
% adjustment), using Savitzky-Golay-filtering
v = sgolayfilt(total_signal_per_frame, 15, min(141, 2 * floor(nframes / 2) - 1));
v = v / mean(v); % so we divide by 1 on average (total counts aren't distorted too much)

%% create output data array and fill it with camera frames divided by
% correction factor
corrected = zeros(dims);
for kf = 1 : nframes
    corrected(:, :, kf) = data(:, :, kf) ./ v(kf);
end
corr_av = squeeze(sum(sum(corrected, 1), 2));
end