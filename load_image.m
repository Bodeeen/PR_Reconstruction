function [ im ] = load_image( path )
%UNTITLED Summary of this function goes here
%   Loads image, hdf5 or tif. The tranformation of the tif image is due to
%   the fact than hdf5 and tif snapshots were saved in different
%   orientations.

split = strsplit(path, '.');
format = split{end};

if strcmp(format,'tif') || strcmp(format, 'tiff')
    %% TIFF
    im = imread(path, 1);
    im = rot90(flipud(im), -1);
elseif strcmp(format, 'hdf5')
%%HDF5
    im = hdf5read(path, 'data');
end
end