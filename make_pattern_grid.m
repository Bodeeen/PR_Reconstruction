function [ grid_vectors ] = make_pattern_grid( pattern, imsize )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% decode the pattern
fx = pattern(1);
x0 = pattern(2);
fy = pattern(3);
y0 = pattern(4);

nr_nulls_x = floor((imsize(2) - x0) / fx);
nr_nulls_y = floor((imsize(1) - y0) / fy);

null_ind_x = [0:nr_nulls_x - 1];
null_ind_y = [0:nr_nulls_y - 1];

null_coords_x = x0 + null_ind_x * fx;
null_coords_y = y0 + null_ind_y * fy;

x_vec = repmat(null_coords_x, [1 nr_nulls_y]);
y_vec = reshape(repmat(null_coords_y, [nr_nulls_x 1]), [nr_nulls_x*nr_nulls_y 1]);

grid_vectors = struct('x_vec', x_vec, 'y_vec', y_vec);
end

