function [c_signals bg_signals] = combine_camera_frames()
% Combines the camera frames of the parallelized RESOLFT microscope used in
% the publication: 'Nanoscopy with more than a hundred thousand
% "doughnuts"' by Andriy Chmyrov et al., to appear in Nature Methods, 2013

%% file names
% input_camera_frames = 'rawstack1_p.tif';
% input_camera_darkframe = 'darkframe.tif';
% output_filename = 'recontructed.tif';

%% some physical parameters of the setup
camera_pixel_length = 0.065;   % camera pixel length [µm] in sample space
diff_limit = 0.100; %um
corr_bleach = 'additive'; % proportional, additive or no
% Calculation of number of scanning steps comes from the step size
% calculation when creating the simulated data.
    % total number of camera frames is (number_scanning_steps)^2
recon_pixel_length = 0.02;            % pixel length [µm] of interpolated and combined frames
activation_size = 0.040;

LoadDataPathName = uigetdir('C:\Users\andreas.boden\Documents\GitHub\PR_Reconstruction\Data');
D = dir(LoadDataPathName);
fileNames = {D([D.isdir] == 0)};  
fileNames = fileNames{1};
[~, file_indexes] = sort([fileNames.datenum]);


input_camera_darkframe = 'Darkframe_defect_corr_ON.mat';
input_camera_frames = strcat(LoadDataPathName, '\', fileNames(file_indexes(1)).name);

% Paramater set for type of acquisition
answ_ulens = questdlg('Microlens data or widefield?', 'Microlenses?', 'Microlenses','Widefield', 'Microlenses');
switch answ_ulens
    case 'Microlenses'
        scanning_period = 1.25;        % scanning period [µm] in sample space
        pattern_period = 1.25;         % Expected period of pattern in um
        pinhole_um = 0.500;
    case 'Widefield'
        scanning_period = 0.3125;        % scanning period [µm] in sample space
        pattern_period = 0.3125;         % Expected period of pattern in um
        pinhole_um = 0.150;
end

%% determine off switching pattern frequencies and offsets
answ_pat = questdlg('Use automatic or manual pattern detection?', 'Pattern selection', 'Automatic', 'Manual', 'Manual');

switch answ_pat
    case 'Automatic'
        disp('Identifying pattern...')
        [data, widefield] = import_data(input_camera_frames, input_widefield_frames, input_camera_darkframe);
        pattern = switching_pattern_identification_160927(data, pattern_period / camera_pixel_length, true)
    case 'Manual'
        answ_pat = questdlg('Load seperate pattern file?', 'Pattern selection', 'Seperate', 'Use raw data', 'Seperate');
        switch answ_pat
            case 'Seperate'
                [LoadPatternFileName,LoadPatternPathName] = uigetfile({'*.*'}, 'Load pattern file');
                input_pattern_frames = strcat(LoadPatternPathName, LoadPatternFileName);
                [data, pattern_images] = import_data_and_pattern_no_WF(input_camera_frames, input_camera_darkframe, input_pattern_frames);
                pattern = switching_pattern_identification_manual(pattern_images, pattern_period / camera_pixel_length, pattern_images);                
            case 'Use raw data'
                data = import_data_no_WF(input_camera_frames, input_camera_darkframe);
                pattern = switching_pattern_identification_manual(data, pattern_period / camera_pixel_length, []);                

        end
end

switch corr_bleach
    case 'proportional'
        data = bleaching_correction(data);
    case 'additive'
        data = bleaching_correction_STHLM(data);
    case 'no'
        a = 1
end


number_scanning_steps = sqrt(size(data,3)) - 1;     % number of scanning steps (NOT SPOTS) in one direction
% derived parameters
shift_per_step = scanning_period / number_scanning_steps / camera_pixel_length;
    % shift per scanning step [camera pixels]
recon_px_per_camera_px = recon_pixel_length / camera_pixel_length;
    % length of pixel of combined frames in camera pixels
diff_lim_px = diff_limit / camera_pixel_length;

[central_signal bg_signal] = signal_extraction_BandPass(data, pattern, diff_lim_px, recon_px_per_camera_px, shift_per_step, pinhole_um / camera_pixel_length, activation_size/camera_pixel_length);
fr_p_line = sqrt(size(data, 3));
[adjusted bg_sub pixels] = image_adjustment_ui(central_signal, bg_signal, fr_p_line);

seq = adjusted;

for i = file_indexes(2:end)
    input_camera_frames = strcat(LoadDataPathName, '\', fileNames(i).name);
    data = import_data_no_WF(input_camera_frames, input_camera_darkframe);
    switch corr_bleach
    case 'proportional'
        data = bleaching_correction(data);
    case 'additive'
        data = bleaching_correction_STHLM(data);
    case 'no'
        a = 1
end
    %Check that number of frames is correct
    if(round(number_scanning_steps) ~= number_scanning_steps)
        h = errordlg('Number of frames is super strange!', 'Huh!?')
        return
    end
    [central_signal bg_signal] = signal_extraction_BandPass(data, pattern, diff_lim_px, recon_px_per_camera_px, shift_per_step, pinhole_um / camera_pixel_length, activation_size/camera_pixel_length);
    adjusted = image_adjustment(central_signal, bg_signal, fr_p_line, pixels, bg_sub);
    seq(:,:,end+1) = adjusted;
end
fname = strcat(LoadDataPathName, '\', 'timelapse.hdf5')
h5create(fname, '/data', size(seq))
h5write(fname, '/data', seq)

h = figure('name', sprintf('Backgroun subtraction : %.2f', bg_sub));
imshow(adjusted,[])
colormap('hot')
title('Reconstructed')

answ = questdlg('Action?', 'Action?', 'Save image', 'Change adjustments.', 'Exit', 'Change adjustments.');
close(h)
while ~strcmp(answ, 'Exit')
    switch answ
        case 'Save image'
            save_image(widefield, adjusted, bg_sub, LoadDataFileName, LoadDataPathName);
            answ = questdlg('Action?', 'Action?', 'Change adjustments.','Exit', 'Change adjustments.');
        case 'Change adjustments.'
            [adjusted bg_sub] = image_adjustment_ui(central_signal, bg_signal, fr_p_line);
            imshow(adjusted,[])
            colormap('hot')
            title('Reconstructed')
            pause
            answ = questdlg('Action?', 'Action?', 'Save image', 'Change adjustments.', 'Exit', 'Change BG subtr.');
    end
end

end

function save_image(widefield, recon, bp_fac, LoadDataFileName, LoadDataPathName)
        savename = strsplit(LoadDataFileName,'.');
        savename = savename{1};
        dname = uigetdir(LoadDataPathName);
        fname = inputdlg('Chose name', 'Name',1,{savename});
        fname = fname{1};
        savepath = strcat(dname, '\', fname, sprintf('_Reconstruction_pin_%.2f_bg_sub_fac', bp_fac));
        disp(strcat('Saving in :', savename))
        savepath_check = savepath;
        new_ver = 2;
        while exist(savepath_check) == 7
            savepath_check = strcat(savepath, '_', num2str(new_ver))
            new_ver = new_ver + 1;
        end
        savepath = savepath_check;
        mkdir(savepath)
        output = recon - min(recon(:));
        output = output/max(output(:));
        imwrite(output, strcat(savepath, '\', fname, '_Reconstructed_Sthlm', '.tif'))
        widefield = widefield - min(widefield(:));
        widefield = widefield/max(widefield(:));
        imwrite(widefield, strcat(savepath, '\', fname, '_WF', '.tif'))
end

function shifted_im = shift_columns(im, pixels, columns_per_square)

    x_coords = 1:size(im, 2);

    x_coords = mod(x_coords, columns_per_square);
    selection_bool = mod(x_coords, 2) == 0;

    selection = im(:, selection_bool);

    size_selection_y = size(selection, 1);
    size_selection_x = size(selection, 2);
    [yi xi] = ndgrid(1:size_selection_y, 1:size_selection_x);

    yi_shifted = yi + pixels;

    shifted_selection = interp2(selection, xi, yi_shifted);
    shifted_selection(isnan(shifted_selection)) = min(im(:));
    im(:,selection_bool) = shifted_selection;
    shifted_im = im;

end

function [adjusted, bg_sub, pixels] = image_adjustment_ui(central_signal, bg_signal, fr_p_line)
    answ = 'Yes'
    h = figure
    while strcmp(answ, 'Yes')
        parameters = inputdlg({'Background subtraction', 'Nr of pixels to shift?'}, 'Parameter', 1, {'0.75','0'})
        bg_sub = str2double(parameters{1});
        pixels = str2double(parameters{2});
        sr_signal = central_signal - bg_sub*bg_signal;
        adjusted = shift_columns(sr_signal, pixels, fr_p_line);
        imshow(adjusted,[])
        colormap('hot')
        title('Shifted columns')
        pause
        answ = questdlg('Change adjustments?', 'Change adjustments?', 'Yes', 'No', 'No');
    end
    close(h)
end
function adjusted = image_adjustment(central_signal, bg_signal, fr_p_line, pixels, bg_sub)

    sr_signal = central_signal - bg_sub*bg_signal;
    adjusted = shift_columns(sr_signal, pixels, fr_p_line);
end