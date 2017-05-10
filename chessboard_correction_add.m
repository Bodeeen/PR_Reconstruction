function tot_corr_im = chessboard_correction_add( im, square_side )

[up_lines, ~, right_lines, left_lines] = make_border_matrices(im, square_side);

% Find number of coefficients in each dimension
cx = size(up_lines, 2);
cy = size(right_lines, 1);

%%Correct row by row from one side to the other
LtRcorr_factors_x = zeros(cy,cx);
%Left to right
for y = 1:cy
    for x = 2:cx;
        LtRcorr_factors_x(y,x) = (LtRcorr_factors_x(y,x-1)+right_lines(y,x-1)) - left_lines(y,x);
    end
end

RtLcorr_factors_x = zeros(cy,cx);
%Right to left
for y = 1:cy
    for x = cx-1:-1:1;
        RtLcorr_factors_x(y,x) = left_lines(y,x+1) + RtLcorr_factors_x(y,x+1) - right_lines(y,x);
    end
end
[y x] = ndgrid(0:1/(cy-1):1, 0:1/(cx-1):1);
B_dir_corr_fac_x = x.*RtLcorr_factors_x + (1-x).*LtRcorr_factors_x;

corr_im_x = imresize(B_dir_corr_fac_x, square_side, 'nearest');

im_x = size(im,2);
im_y = size(im,1);

dx = (cx-1)/(im_x-1)
xi = repmat(1:dx:cx, [cy 1]);
y = 1:cy;
yi = repmat(y', [1 cx*square_side]);

corr = interpn(B_dir_corr_fac_x, yi, xi, 'bicubic');
k_size = 500;
k_fwhm = 50;
kern = ones(1, k_size); %oneDGausskern( k_size, k_fwhm);
kern = kern ./ sum(kern(:));

[b1,a1] = butter(5,0.005,'low');
for i = 1:size(corr, 1);
    corr_filt(i,:) = filtfilt(b1, a1, corr(i,:)); 
end
% corr_filt = conv2(corr, kern, 'same');
% figure
% subplot(1,3,1)
% plot(corr(1,:))
% subplot(1,3,2)
% plot(corr_filt1)
% subplot(1,3,3)
% plot(corr_filt(1,:))



%%Correct for edge problem at right edge of corr_filt
% q = ceil(k_size/2);
% p = (im_x - q);
% for y = 1:cy
%     for x = p:im_x
%         corr_filt(y,x) = mean(corr(y,x-q:im_x));
%     end
% end

corr_im = zeros(im_y, im_x);

for y = 1:im_y
    yi = ceil(y/square_side);
    corr_im(y,:) = corr_filt(yi,:);
end

final_correction_x = corr_im_x - corr_im;
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

k_size = square_side;

% kern_x = ones(1,k_size);
% kern_x = kern_x/sum(kern_x(:));
% kern_y = kern_x';
% filtered_y = conv2(UtDcorr_im, kern_y, 'same');
filtered_y = zeros(size(im));
for i = 1:size(im, 2)
    filtered_y(:,i) = filtfilt(b1, a1, UtDcorr_im(:,i));
end

% q = ceil(k_size/2);
% p = (im_y - q);
% for x = 1:im_x
%     for y = p:im_y
%         filtered_y(y,x) = mean(UtDcorr_im(y-q:im_y,x));
%     end
% end

%%Filter in x-dim
corr_im_y = UtDcorr_im - filtered_y;
filtered_corr_im_y = zeros(size(im));
[b2, a2] = butter(5,0.03,'low');
for i = 1:size(im, 1)
    filtered_corr_im_y(i,:) = filtfilt(b2, a2, corr_im_y(i,:));
end
% filtered_corr_im_y = conv2(corr_im_y, kern_x, 'same');

tot_corr_im = final_corrected_x + filtered_corr_im_y;

% figure
% subplot(1,2,1)
% imshow(im,[])
% title('Uncorrected')
% subplot(1,2,2)
% imshow(tot_corr_im,[])
% title('Corrected')
end



