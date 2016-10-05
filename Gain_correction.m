
%Script to correct for individual pixel gain variations
if exist('illumination_stack') ~= 1
    [LoadIlluminationFileName,LoadIlluminationPathName] = uigetfile({'*.*'}, 'Load illumination file');
    load(strcat(LoadIlluminationPathName, LoadIlluminationFileName));
end
if exist('gains') ~= 1
    [LoadGainFileName,LoadGainPathName] = uigetfile({'*.*'}, 'Load gain file');
    load(strcat(LoadGainPathName, LoadGainFileName));
end
if exist('background') ~= 1
    [LoadBGFileName,LoadBGPathName] = uigetfile({'*.*'}, 'Load background file');
    load(strcat(LoadBGPathName, LoadBGFileName));
end
[LoadDataFileName,LoadDataPathName] = uigetfile({'*.*'}, 'Load data file');
data_path = strcat(LoadDataPathName, LoadDataFileName);

split = strsplit(data_path, '.');
format = split{end};

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
illumination_stack_cropped = illumination_stack(Y0:Y0+Height-1, X0:X0+Width-1,:);
gains_cropped = gains(Y0:Y0+Height-1, X0:X0+Width-1,:);
background_cropped = background(Y0:Y0+Height-1, X0:X0+Width-1);

nframes = size(data, 3);

%Can't convert to double due to memory limitations
data = data - repmat(uint16(background_cropped),[1 1 nframes]);

ill_levels = size(illumination_stack, 3);
h = waitbar(0, 'Correcting gain...')
size_x = size(data, 2);
size_y = size(data, 1);
ccfor f = 1:nframes
    waitbar(f/nframes)
    for yc = 1:size_y
        for xc = 1:size_x
            pix_v = data(yc, xc, f);
            i = 0;
            if pix_v >= illumination_stack_cropped(yc, xc, end)
                data(yc, xc, f) = pix_v / gains_cropped(yc, xc, end);
            else
                while pix_v > illumination_stack_cropped(yc,xc,i+1)
                    i = i+1;
                end
                if i>0
                    lower = illumination_stack_cropped(yc, xc, i);
                    upper = illumination_stack_cropped(yc, xc, i+1);
                    interval = upper - lower;
                    interp_v = (double(pix_v) - lower)/interval * gains_cropped(yc,yc,i+1) + (upper - double(pix_v))/interval * gains_cropped(yc,yc,i);
                else
                    interp_v = gains_cropped(yc, xc, 1);
                end
                data(yc, xc, f) = uint16(double(pix_v) / interp_v);
            end
        end
    end
end
close(h)

split = strsplit(LoadDataFileName, '.')
filename = strcat(split{1}, '_corrected', '.h5')
pathname = strcat(LoadDataPathName, filename);
h5create(pathname, '/data', size(data));
h5write(pathname, '/data', data);

h5writeatt(pathname, '/data', 'Y0', X0);
h5writeatt(pathname, '/data', 'X0', Y0);
h5writeatt(pathname, '/data', 'Height', Width);
h5writeatt(pathname, '/data', 'Width', Height);



























