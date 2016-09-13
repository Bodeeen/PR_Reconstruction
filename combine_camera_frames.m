function [reconstructed B] = combine_camera_frames(B, input_camera_frames, input_camera_darkframe, output_filename)
% Combines the camera frames of the parallelized RESOLFT microscope used in
% the publication: 'Nanoscopy with more than a hundred thousand
% "doughnuts"' by Andriy Chmyrov et al., to appear in Nature Methods, 2013

%% file names
% input_camera_frames = 'rawstack1_p.tif';
% input_camera_darkframe = 'darkframe.tif';
% output_filename = 'recontructed.tif';

%% some physical parameters of the setup
camera_pixel_length = 0.0615;   % camera pixel length [µm] in sample space
scanning_period = 0.312;        % scanning period [µm] in sample space
pattern_period = 0.320;         % Expected period of pattern in um
activation_size = 0.040;
diff_limit = 0.250; %um
% Calculation of number of scanning steps comes from the step size
% calculation when creating the simulated data.
number_scanning_steps = 10;     % number of scanning steps in one direction
    % total number of camera frames is (number_scanning_steps)^2
recon_pixel_length = 0.010;            % pixel length [µm] of interpolated and combined frames
pinhole_um = 0.050;

% derived parameters
shift_per_step = scanning_period / number_scanning_steps / camera_pixel_length;
    % shift per scanning step [camera pixels]
recon_px_per_camera_px = recon_pixel_length / camera_pixel_length;
    % length of pixel of combined frames in camera pixels
diff_lim_px = diff_limit / camera_pixel_length;
%% load camera frames and subtract background frame and correct for photobleaching
data = import_data(input_camera_frames, input_camera_darkframe, true);

%% determine off switching pattern frequencies and offsets
disp('Identifying pattern...')
pattern = switching_pattern_identification(data, pattern_period / camera_pixel_length)
% pattern = [4.8345 0.7473 4.8384 0.7484]
% pattern = [9.6571 0.8072 9.6568 0.8077]
disp(pattern)

signalgot = 0;
signalsthlm = 0;

%% combination of camera images
% Check if bases and G matrix already exists
try
    size(B);
catch
    B = [];
end
disp('Extracting signal...')
%%
[central, peripheral] = signal_extraction_fast(data, pattern, recon_px_per_camera_px, shift_per_step, pinhole_um / camera_pixel_length);
signalgot = max(central - 0.8 * peripheral, 0);
% immax = max(signalgot(:));
% immin = min(signalgot(:));
% imstd = std(signalgot(:));
% snr = 10*log10((immax-immin)/imstd);
% % Plot
% figure('name', sprintf('Activation size (nm): %.1f \n Pinhole size (nm): %.1f', 1000*activation_size, 1000*pinhole_nm))
% subplot(1,2,1)
% imshow(signalgot,[])
% title(sprintf('SNR = %.1f', snr))
%%
% [signal B] = signal_extraction_LS(data, pattern, B, diff_lim_px, recon_px_per_camera_px, shift_per_step, pinhole_um / camera_pixel_length, activation_size/camera_pixel_length);
signal = signal_extraction_HSNR(data, pattern, recon_px_per_camera_px, shift_per_step, pinhole_um / camera_pixel_length, activation_size/camera_pixel_length);

% signalsthlm = central;
% immax = max(signalsthlm(:));
% immin = min(signalsthlm(:));
% imstd = std(signalsthlm(:));
% snr = 10*log10((immax-immin)/imstd);
% % Plot
% subplot(1,2,2)
% imshow(signalsthlm,[])
% title(sprintf('SNR = %.1f', snr))




% saving again
% save(output_filename, 'signal', 'pixel_length');
% disp('Saving output...')
output = signal - min(signal(:));
output = signal/max(signal(:));
imwrite(output, output_filename)
reconstructed = signal;
% B = [];
end