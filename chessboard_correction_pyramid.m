function [ corrected ] = chessboard_correction_pyramid( im, square_side )
% Under development

cluster_size = 5;

size_x = size(im, 2);
size_y = size(im, 1);

dx = factor(size_x/square_side);
dy = factor(size_y/square_side);
common = intersect(dx,dy);
[id id] = min(abs(common - cluster_size));

c_size = common(id);

if numel(c_size) == 0
    c_size = cluster_size;
end
    
cx = size_x / square_side;
cy = size_y / square_side;

best_csize_x = round(cx/cluster_size);
best_csize_y = round(cy/cluster_size);


fun = @(block_struct)chessboard_correction_LS(block_struct.data, square_side);

corrected = blockproc(im, [c_size*square_side c_size*square_side], fun);

square_side = c_size*square_side;

% fun = @(block_struct)chessboard_correction_LS(block_struct.data, square_side);

% corrected = blockproc(corrected, [cluster_size*square_side cluster_size*square_side], fun, 'PadPartialBlocks', true, 'PadMethod', 'replicate');

corrected = chessboard_correction_LS(corrected, square_side);

corrected = corrected(1:size(im,1), 1:size(im,2));

end

