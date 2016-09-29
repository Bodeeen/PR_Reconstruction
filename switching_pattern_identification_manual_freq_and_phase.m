function [pattern] = switching_pattern_identification(data, expected_value, pattern_images)
% Extracts the frequencies and offsets of the off switching pattern from
% the camera frame data as used in the publication: 'Nanoscopy with more
% than a hundred thousand "doughnuts"' by Andriy Chmyrov et al.,
% to appear in Nature Methods, 2013
%
% data are the camera frames, expected_value is the initial guess on the
% period of the pattern in pixels
%
% output is a vector with the following order:
%   - period in x-direction [pixels] (px)
%   - offset in x-direction [pixels] (x0)
%   - period in y-direction [pixels] (py)
%   - offset in y-direction [pixels] (y0)
% and the function for recreating the off switching pattern would be:
%   sin(pi * (x - x0) / px).^2 + sin(pi * (y - y0) / py).^2
%
% however here we use cosine instead of sine because we actually fit what
% we see, which is the pattern of on-switched molecules

%% error check
assert(nargin == 3, 'Not enough arguments!');
scale = 10;
if numel(pattern_images) == 0
    addup = sum(data, 3);
else
    addup = sum(pattern_images, 3);
end
f = figure
imshow(addup,[]);
rect = round(getrect);
close(f)

xrange = rect(1):rect(1)+(rect(3)-1);
yrange = rect(2):rect(2)+(rect(4)-1);
cropped = imresize(addup(yrange,xrange, :), scale);

f = figure
imshow(cropped,[]);
[pix_x_1 pix_y_1] = ginput(1);
pix_x_1 = rect(1) + pix_x_1/scale;
pix_y_1 = rect(2) + pix_y_1/scale;
close(f)

phx_1 = mod(pix_x_1 - 1, expected_value);
phy_1 = mod(pix_y_1 - 1, expected_value);

f = figure
imshow(addup,[]);
rect = round(getrect);
close(f)

xrange = rect(1):rect(1)+(rect(3)-1);
yrange = rect(2):rect(2)+(rect(4)-1);
cropped = imresize(addup(yrange,xrange, :), scale);

f = figure
imshow(cropped,[]);
[pix_x_2 pix_y_2] = ginput(1);
pix_x_2 = rect(1) + pix_x_2/scale;
pix_y_3 = rect(2) + pix_y_2/scale;
close(f)

phx_2 = mod(pix_x_2 - 1, expected_value);
phy_2 = mod(pix_y_2 - 1, expected_value);

cycles_x = abs(pix_x_1 - pix_x_2)/expected_value;
diff_x = cycles_x - round(cycles_x);
correction_x = diff_x/round(cycles_x);
corrected_x = expected_value*(1 + correction_x);

cycles_y = abs(pix_y_1 - pix_y_2)/expected_value;
diff_y = cycles_y - round(cycles_y);
correction_y = diff_y/round(cycles_y);
corrected_y = expected_value*(1 + correction_y);



pattern = [corrected_y mean([phy_1 phy_2]) corrected_x mean([phx_1 phx_2])];
end

