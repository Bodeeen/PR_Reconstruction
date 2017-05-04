function [corrected] = Skew_stripe_corr( skew_fac, line_px, im, lines_per_square)
%Corrects image for stripe and skew artifact.
    imsize_x = size(im, 2);
    imsize_y = size(im, 1);
    % Skew correction
    
    [yi, xi] = ndgrid(0:imsize_y-1, 0:imsize_x-1);
    rel_pos_in_square = yi./lines_per_square - floor(yi./lines_per_square);

    x_shift = skew_fac * rel_pos_in_square * lines_per_square;
    
    
    
    xi_shifted = 1 + xi - x_shift;
    yi = 1+ yi;
    skew_corrected = interp2(im, xi_shifted, yi, 'cubic');  
    skew_corrected(isnan(skew_corrected)) = 0;
    
    
    x_coords = 1:imsize_x;

    x_coords = mod(x_coords, lines_per_square);
    selection_bool = mod(x_coords, 2) == 0;
    selection = skew_corrected(:, selection_bool);
        
    size_selection_y = size(selection, 1);
    size_selection_x = size(selection, 2);
    [yi xi] = ndgrid(1:size_selection_y, 1:size_selection_x);

    yi_shifted = yi + line_px;

    shifted_selection = interp2(selection, xi, yi_shifted);
    shifted_selection(isnan(shifted_selection)) = min(im(:));
    shifted_im = skew_corrected;
    shifted_im(:,selection_bool) = shifted_selection;
    corrected = shifted_im;

end

