function [reconstructed fr_p_line fr_p_column] = cmat2image(cmat, presets, double_lines, double_columns)
% Create the reconstructed image from the matrix cmat, each line in cmat
% contains the signal values over time for a specific focal point.
    nulls_x = presets.nulls_x;
    nulls_y = presets.nulls_y;

    fr_p_line = sqrt(size(cmat, 2));
    fr_p_column = fr_p_line;
    nnulls = nulls_y*nulls_x;
    subsquares = zeros(fr_p_line, fr_p_line, nnulls);
    
    %% Attempt to estimate pixel to pixel (step to step) noise in each point

%     Pxx = pwelch(cmat');
%     Pxx_high = sum(Pxx(end-3:end,:),1);
%     Pim = reshape(Pxx_high', [nulls_y nulls_x]);
%     
%     kern = [-1 2 -1];
%     noise = conv2(cmat, kern, 'valid');
%     sum_noise = sum(abs(noise), 2);
%     noise_im = reshape(sum_noise, [nulls_y nulls_x]);
    
    for i = 1:nnulls
        subsquare = reshape(cmat(i,:), fr_p_line, fr_p_line);
        subsquare(:,1:2:end) = flipud(subsquare(:,1:2:end));
        subsquare = rot90(subsquare,2);
        subsquares(:,:,i) = subsquare;
    end
    
    if double_lines > 0
        subsquares = subsquares(1:end-double_lines,:,:);
        fr_p_column = fr_p_column - double_lines;
    end
    if double_columns > 0
        subsquares = subsquares(:,1:end-double_columns,:);
        fr_p_line = fr_p_line - double_columns;
    end
    
    reconstructed = zeros(nulls_y*fr_p_column, nulls_x*fr_p_line);
    yind = 1;
    xind = 1;

    for x = 1:nulls_x
        for y = 1:nulls_y
            xr = xind:xind+fr_p_line-1;
            yr = yind:yind+fr_p_column-1;
            reconstructed(yr, xr) = subsquares(:,:,(x-1)*nulls_y + y);
            yind = yind + fr_p_column;
        end
        yind = 1;
        xind = xind + fr_p_line;
    end
end