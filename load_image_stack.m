function [ stack ] = load_image_stack( path )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

split = strsplit(path, '.');
format = split{end};

if strcmp(format,'tif') || strcmp(format, 'tiff')
    %% TIFF
    info = imfinfo(path);
    frames = size(info, 1);
    stack = imread(path, 1);
    for i = 2:frames
        stack = cat(3, stack, imread(path, i));
    end
%     stack = sum(stack, 3);
    stack = rot90(flipud(stack), -1);
elseif strcmp(format, 'hdf5')
%%HDF5
    stack = hdf5read(path, 'data');
end
end

