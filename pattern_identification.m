function [ pattern ] = pattern_identification( pattern_im, expected_period )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% Identify pattern manually

scale = 10; % For upsampling of image to improve accuracy

f = figure
imshow(pattern_im,[]);
rect = round(getrect);
close(f)

xrange = rect(1):rect(1)+(rect(3)-1);
yrange = rect(2):rect(2)+(rect(4)-1);
cropped = imresize(pattern_im(yrange,xrange, :), scale);

f = figure
imshow(cropped,[]);
[pix_x_1 pix_y_1] = ginput(1);
pix_x_1 = rect(1) + pix_x_1/scale;
pix_y_1 = rect(2) + pix_y_1/scale;
close(f)

f = figure
imshow(pattern_im,[]);
rect = round(getrect);
close(f)

xrange = rect(1):rect(1)+(rect(3)-1);
yrange = rect(2):rect(2)+(rect(4)-1);
cropped = imresize(pattern_im(yrange,xrange, :), scale);

f = figure
imshow(cropped,[]);
[pix_x_2 pix_y_2] = ginput(1);
pix_x_2 = rect(1) + pix_x_2/scale;
pix_y_2 =  rect(2) + pix_y_2/scale;
close(f)

cycles_x = abs(pix_x_1 - pix_x_2)/expected_period;
diff_x = cycles_x - round(cycles_x);
correction_x = diff_x/round(cycles_x);
corrected_x = expected_period*(1 + correction_x);

cycles_y = abs(pix_y_1 - pix_y_2)/expected_period;
diff_y = cycles_y - round(cycles_y);
correction_y = diff_y/round(cycles_y);
corrected_y = expected_period *(1 + correction_y);

phx = mod(pix_x_1 - 1, corrected_x);
phy = mod(pix_y_1 - 1, corrected_y);

pattern = [corrected_x phx corrected_y phy];

end

