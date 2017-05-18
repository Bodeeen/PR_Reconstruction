function [ up_lines, down_lines, right_lines, left_lines ] = make_border_matrices( im, square_side )
%% Makes four matrices containing the average values of different borders of each square

up_lines = im(1:square_side:end, :);
up_lines = downsample_square_av( up_lines, square_side );

down_lines = im(square_side:square_side:end, :);
down_lines = downsample_square_av( down_lines, square_side );

left_lines = im(:, 1:square_side:end);
left_lines = downsample_square_av( left_lines', square_side );
left_lines = left_lines';

right_lines = im(:, square_side:square_side:end);
right_lines = downsample_square_av( right_lines', square_side );
right_lines = right_lines';

end

