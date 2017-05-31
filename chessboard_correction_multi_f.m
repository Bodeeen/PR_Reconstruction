function [ stack ] = chessboard_correction_multi_f( stack, square_side )
%Applies chessboard correction to a complete Z-stack of frames
stack = stack - min(stack(:));
averaged = mean(stack, 3);
[~, corr_fac] = chessboard_correction_LS(averaged, square_side);

for i = 1:size(stack, 3)
    stack(:,:,i) = corr_fac .* stack(:,:,i);
end

end

