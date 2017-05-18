function [ im ] = load_image( path )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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