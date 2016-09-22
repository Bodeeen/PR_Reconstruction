function [data widefield]= import_data(camera_frames_file, camera_widefield_file, dark_frame_file, correct_for_bleaching)
% Reads data (camera frame data) from a Matlab file, rotates it to our
% needs and subtracts the background. Additionally can correct for
% bleaching.

%% argument check
assert(nargin == 4, 'Wrong number of arguments!');


%% load dark frame and compute average value
background = imread(dark_frame_file);

%% load camera frames file and subtract background

split = strsplit(camera_frames_file, '.');
format = split{end};

if strcmp(format,'tif') || strcmp(format, 'tiff')
    %% TIFF
    info = imfinfo(camera_frames_file);
    frames = size(info, 1);
    images = imread(camera_frames_file, 1);
    for i = 2:frames
        images = cat(3, images, imread(camera_frames_file, i));
    end
elseif strcmp(format, 'hdf5')
%%HDF5
    images = hdf5read(camera_frames_file, 'data');

%% Correct for scanning acquiring one frame in beginning and one too few in the end
    images = images(:,:,2:end);
    images(:,:,end+1) = images(:,:,end);
end

if size(background) ~= size(images(:,:,1))
    background = double(background);
    background = mean(background(:));
    bg_scalar = true;
else
    bg_scalar = false;
end
%% load widefield file

split = strsplit(camera_widefield_file, '.');
format = split{end};

if strcmp(format,'tif') || strcmp(format, 'tiff')
    %% TIFF
    info = imfinfo(camera_widefield_file);
    frames = size(info, 1);
    wide_images = imread(camera_widefield_file, 1);
    for i = 2:frames
        wide_images = cat(3, wide_images, imread(camera_frames_file, i));
    end
elseif strcmp(format, 'hdf5')
%%HDF5
    wide_images = hdf5read(camera_widefield_file, 'data');
end

widefield = mean(double(wide_images), 3);
button = questdlg('Crop data?','Yes','No');
switch button
    case 'Yes'
        im = sum(images, 3);
        f = figure
        imshow(im,[]);
        rect = getrect;
        close(f)
        xrange = round(rect(1):rect(1)+rect(3));
        yrange = round(rect(2):rect(2)+rect(4));
        images = images(yrange,xrange, :);
        widefield = widefield(yrange,xrange);
        if ~bg_scalar
            background = background(yrange,xrange);
        end
end

% data = double(permute(images(:, end:-1:1, 1:end),[2 1 3])) - background;
if ~bg_scalar
    data = double(images) - double(repmat(background, [1 1 size(images, 3)]));
else
    data = double(images) - background;
end;
data = max(data, 0);
    % after subtraction of the average background some background pixels could be slightly negative
clear h;

%% correct for bleaching by division of the average decay of the total
% signal per frame, if wished
if correct_for_bleaching
    data = bleaching_correction(data);
end

end