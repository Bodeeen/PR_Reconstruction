function data = import_data(camera_frames_file, dark_frame_file, correct_for_bleaching)
% Reads data (camera frame data) from a Matlab file, rotates it to our
% needs and subtracts the background. Additionally can correct for
% bleaching.

%% argument check
assert(nargin == 3, 'Wrong number of arguments!');


%% load dark frame and compute average value
img = imread(dark_frame_file);
background = mean(img(:));


%% load camera frames file, rotate and subtract background
%h = load(camera_frames_file);
info = imfinfo(camera_frames_file);
frames = size(info, 1);
images = imread(camera_frames_file, 1);
for i = 2:frames
    images = cat(3, images, imread(camera_frames_file, i));
end


% data = double(permute(images(:, end:-1:1, 1:end),[2 1 3])) - background;
data = double(images) - background;
data = max(data, 0);
    % after subtraction of the average background some background pixels could be slightly negative
clear h;

%% correct for bleaching by division of the average decay of the total
% signal per frame, if wished
if correct_for_bleaching
    data = bleaching_correction(data);
end

end