function tot_corr_im = chessboard_correction_add( im, square_side )

[up_lines, down_lines, right_lines, left_lines] = make_border_matrices(im, square_side);

% Find number of coefficients in each dimension
cx = size(up_lines, 2);
cy = size(right_lines, 1);

calib_im = ones(cy,cx);

LtRcorr_factors_x = ones(cy,cx);
RtLcorr_factors_x = ones(cy,cx);

for y = 1:cy
    for x = 2:cx;
        LtRcorr_factors_x(y,x) = (LtRcorr_factors_x(y,x-1)*right_lines(y,x-1)) / left_lines(y,x);
    end
end

for y = cy:-1:1
    for x = cx-1:-1:1;
        RtLcorr_factors_x(y,x) = (RtLcorr_factors_x(y,x+1)+left_lines(y,x+1)) - right_lines(y,x);
    end
end

corr_factors_x = ones(cy,cx);

for y = 1:cy
    for x = 1:cx
        corr_factors_x(y,x) = (cx-x)/cx * LtRcorr_factors_x(y,x) + x/cx * RtLcorr_factors_x(y,x);
    end
end

resize_fac = size(im)./size(LtRcorr_factors_x);
assert(resize_fac(1) == resize_fac(2), 'Something strange here')
resize_fac = resize_fac(1);

corr_im_x = imresize(corr_factors_x, resize_fac, 'nearest');
corr_im_x_RtL = imresize(RtLcorr_factors_x, resize_fac, 'nearest');
corr_im_x_LtR = imresize(LtRcorr_factors_x, resize_fac, 'nearest');
weight_im = imresize(LtRcorr_factors_x, resize_fac, 'bicubic');

x_corr_im = corr_im_x .* double(im);
x_corr_RtL = corr_im_x_RtL .* double(im);

x_corr_up = up_lines + LtRcorr_factors_x;
x_corr_down = down_lines + LtRcorr_factors_x;
corr_x_calib_im = LtRcorr_factors_x;

im_x = size(im,2);
im_y = size(im,1);

dx = (cx-1)/(im_x-1)
xi = repmat(1:dx:cx, [cy 1]);
y = 1:cy;
yi = repmat(y', [1 cx*resize_fac]);

corr = interpn(LtRcorr_factors_x, yi, xi, 'bicubic');

kern = oneDGausskern(1000, 500);
kern = kern ./ sum(kern(:));
corr = conv2(corr, kern, 'same');

corr_im = zeros(im_y, im_x);

for y = 1:im_y
    yi = ceil(y/square_side);
    corr_im(y,:) = corr(yi,:);
end

final_corr = corr_im_x_LtR ./ corr_im;

tot_corr_im = double(im) .* final_corr;

figure
subplot(1,2,1)
imshow(im,[])
title('Uncorrected')
subplot(1,2,2)
imshow(tot_corr_im,[])
title('Corrected')
end



