function [ output_mat ] = downsample_square_av( mat, factor )
%Downsamples the vector or matrix along the x-dimenstion using a square
%averageing approach

x_size_in = size(mat, 2); 
x_size_out = x_size_in / factor;

assert(round(x_size_out) == x_size_out, 'Dimensions and downsample factor does not match')

output_mat = zeros(size(mat,1), x_size_out);

for i = 1:x_size_out
    m = mean(mat(:, 1+(i-1)*factor:i*factor), 2);
    output_mat(:,i) = m;
end
end

