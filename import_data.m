function data = import_data(camera_frames_file, dark_frame_file, correct_for_bleaching)
% Reads data (camera frame data) from a Matlab file, rotates it to our
% needs and subtracts the background. Additionally can correct for
% bleaching.

%% argument check
assert(nargin == 3, 'Wrong number of arguments!');


%% load dark frame and compute average value
background = imread(dark_frame_file);


%% load camera frames file, rotate and subtract background
%h = load(camera_frames_file);

split = strsplit(camera_frames_file, '.');
format = split{2};

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

button = questdlg('Crop data?','Yes','No');
switch button
    case 'Yes'
        im = sum(images, 3);
        imshow(im,[]);
        rect = getrect;
        xrange = round(rect(1):rect(1)+rect(3));
        yrange = round(rect(2):rect(2)+rect(4));
        images = images(yrange,xrange, :);
        background = background(yrange,xrange);
end

% data = double(permute(images(:, end:-1:1, 1:end),[2 1 3])) - background;
data = double(images) - double(repmat(background, [1 1 size(images, 3)]));
data = max(data, 0);
    % after subtraction of the average background some background pixels could be slightly negative
clear h;

%% correct for bleaching by division of the average decay of the total
% signal per frame, if wished
if correct_for_bleaching
    data = bleaching_correction(data);
end

end