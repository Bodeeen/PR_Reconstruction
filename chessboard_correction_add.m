function tot_corr_im = chessboard_correction_add( im, square_side )

[up_lines, ~, right_lines, left_lines] = make_border_matrices(im, square_side);

% Find number of coefficients in each dimension
cx = size(up_lines, 2);
cy = size(right_lines, 1);

LtRcorr_factors_x = zeros(cy,cx);

for y = 1:cy
    for x = 2:cx;
        LtRcorr_factors_x(y,x) = (LtRcorr_factors_x(y,x-1)+right_lines(y,x-1)) - left_lines(y,x);
    end
end

corr_im_x_LtR = imresize(LtRcorr_factors_x, square_side, 'nearest');

im_x = size(im,2);
im_y = size(im,1);

dx = (cx-1)/(im_x-1)
xi = repmat(1:dx:cx, [cy 1]);
y = 1:cy;
yi = repmat(y', [1 cx*square_side]);

corr = interpn(LtRcorr_factors_x, yi, xi, 'bicubic');

corr_im = zeros(im_y, im_x);

for y = 1:im_y
    yi = ceil(y/square_side);
    corr_im(y,:) = corr(yi,:);
end

final_correction_x = corr_im_x_LtR - corr_im;
final_corrected_x = double(im) + final_correction_x;

up_lines = final_corrected_x(1:square_side:end, :);
down_lines = final_corrected_x(square_side:square_side:end, :);

UtDcorr_factors = zeros(cy, im_x);
for x = 1:im_x
    for y = 2:cy;
        UtDcorr_factors(y,x) = (UtDcorr_factors(y-1,x)+down_lines(y-1,x)) - up_lines(y,x);
    end
end

UtDcorr_im = zeros(im_y, im_x);

for x = 1:im_x
    for y = 1:im_y
        yi = ceil(y/square_side);
        UtDcorr_im(y,x) = UtDcorr_factors(yi,x);
    end
end

kern_x = oneDGausskern(50, 25);
kern_x = kern_x/sum(kern_x(:));
kern_y = kern_x';
filtered_y = conv2(UtDcorr_im, kern_y, 'same');

corr_im_y = UtDcorr_im - filtered_y;
filtered_corr_im_y = conv2(corr_im_y, kern_x, 'same');

tot_corr_im = final_corrected_x + filtered_corr_im_y;

% figure
% subplot(1,2,1)
% imshow(im,[])
% title('Uncorrected')
% subplot(1,2,2)
% imshow(tot_corr_im,[])
% title('Corrected')
end



