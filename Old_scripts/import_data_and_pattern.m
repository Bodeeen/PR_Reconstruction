function [data widefield pattern_images]= import_data_and_pattern(camera_frames_file, camera_widefield_file, dark_frame_file, pattern_file)
% Reads data (camera frame data) from a Matlab file, rotates it to our
% needs and subtracts the background. Additionally can correct for
% bleaching.

%% argument check
assert(nargin == 4, 'Wrong number of arguments!');


%% load dark frame and compute average value
load(dark_frame_file);

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
elseif strcmp(format, 'hdf5') || strcmp(format, 'h5')
%%HDF5
    images = hdf5read(camera_frames_file, 'data');
%Get cropping parameters from hdf5 file.
%Note the Y-X mismatch that comes from how Tempesta saves the hdf5 file
%(rotated, X0 and Y0 for Orcaflash is bottom left corner).
    X0 = h5readatt(camera_frames_file, '/data', 'Y0');
    Y0 = h5readatt(camera_frames_file, '/data', 'X0');
    Width = h5readatt(camera_frames_file, '/data', 'Height');
    Height = h5readatt(camera_frames_file, '/data', 'Width');
end
nframes = size(images, 3);
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
elseif strcmp(format, 'hdf5') || strcmp(format, 'h5')
%%HDF5
    wide_images = hdf5read(camera_widefield_file, 'data');
end

%% Load pattern file

split = strsplit(pattern_file, '.');
format = split{end};

if strcmp(format,'tif') || strcmp(format, 'tiff')
    %% TIFF
    info = imfinfo(pattern_file);
    frames = size(info, 1);
    pattern_images = imread(pattern_file, 1);
    for i = 2:frames
        pattern_images = cat(3, pattern_images, imread(pattern_file, i));
    end
    pattern_images = sum(pattern_images, 3);
    pattern_images = rot90(flipud(pattern_images), -1);
elseif strcmp(format, 'hdf5')
%%HDF5
    pattern_images = hdf5read(pattern_file, 'data');
end

widefield = mean(double(wide_images(:,:,1:end)), 3);
button = questdlg('Crop data?', 'Cropping', 'Yes','No', 'Yes');
switch button
    case 'Yes'
        im = sum(images, 3);
        f = figure
        imshow(im,[]);
        rect = round(getrect);
        close(f)
        xrange = rect(1):rect(1)+(rect(3)-1);
        yrange = rect(2):rect(2)+(rect(4)-1);
        images = images(yrange,xrange, :);
        widefield = widefield(yrange,xrange);
        
        X0big = X0+rect(1); 
        Y0big = Y0+rect(2);
        Xend_big = X0big+rect(3)-1;
        Yend_big = Y0big+rect(4)-1;
        background = background(Y0big:Yend_big, X0big:Xend_big);
        pattern_images = pattern_images(Y0big:Yend_big, X0big:Xend_big, :);
    case 'No'
        % Matlab indexes from 1
        X0 = X0+1;
        Y0 = Y0+1;
        background = background(Y0:Y0+Height-1, X0:X0+Width-1);
        pattern_images = pattern_images(Y0:Y0+Height-1, X0:X0+Width-1, :);
end
%% Correct for scanning acquiring one frame in beginning and one too few in the end
images = images(:,:,2:end);
images(:,:,end+1) = images(:,:,end);
if round(sqrt(size(images, 3))) ~= sqrt(size(images, 3))
    images = cat(3, images(:,:,1), images);
end


% data = double(images) - repmat(background,[1 1 nframes]);
data = images;
data = max(data, 0);
    % after subtraction of the average background some background pixels could be slightly negative
clear h;

end