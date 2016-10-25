
%Script to correct for individual pixel gain variations
if exist('Gain_char_defect_corr_ON') ~= 1
    [LoadIlluminationFileName,LoadIlluminationPathName] = uigetfile({'*.*'}, 'Load illumination file');
    load(strcat(LoadIlluminationPathName, LoadIlluminationFileName));
end

% Extract b1 and b2 from Gain_char... struct
b1 = Gain_char_defect_corr_ON.k;
b2 = Gain_char_defect_corr_ON.m;

%Load path to data
[LoadDataFileName,LoadDataPathName] = uigetfile({'*.*'}, 'Load data file');
data_path = strcat(LoadDataPathName, LoadDataFileName);

split = strsplit(data_path, '.');
format = split{end};

% Load data to correct
if strcmp(format,'tif') || strcmp(format, 'tiff')
    %% TIFF
    info = imfinfo(data_path);
    frames = size(info, 1);
    data = imread(data_path, 1);
    for i = 2:frames
        data = cat(3, data, imread(data_path, i));
    end
    X0 = 0;
    Y0 = 0;
    Width = 0;
    Height = 0;
elseif strcmp(format, 'hdf5')
%%HDF5
    data = hdf5read(data_path, 'data');
%Get cropping parameters from hdf5 file.
%Note the Y-X mismatch that comes from how Tempesta saves the hdf5 file
%(rotated, X0 and Y0 for Orcaflash is bottom left corner).
    X0 = h5readatt(data_path, '/data', 'Y0');
    Y0 = h5readatt(data_path, '/data', 'X0');
    Width = h5readatt(data_path, '/data', 'Height');
    Height = h5readatt(data_path, '/data', 'Width');
end

% Matlab indexes from 1
X0 = X0+1;
Y0 = Y0+1;

%Crop gain corr maps according to data
b1 = b1(Y0:Y0+Height-1, X0:X0+Width-1);
b2 = b2(Y0:Y0+Height-1, X0:X0+Width-1);

nframes = size(data, 3);

h = waitbar(0, 'Correcting frames...')
size_x = size(data, 2);
size_y = size(data, 1);
% data_corr = zeros(size(data));
for f = 1:nframes
    waitbar(f/nframes)
    data_corr(:,:,f) = (double(data(:,:,f)) - b2) ./ b1;
end
close(h)

split = strsplit(LoadDataFileName, '.')
filename = strcat(split{1}, '_corrected', '.h5')
pathname = strcat(LoadDataPathName, filename);
h5create(pathname, '/data', size(data_corr));
h5write(pathname, '/data', data_corr);

h5writeatt(pathname, '/data', 'Y0', X0);
h5writeatt(pathname, '/data', 'X0', Y0);
h5writeatt(pathname, '/data', 'Height', Width);
h5writeatt(pathname, '/data', 'Width', Height);



























