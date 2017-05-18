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
[pix_x pix_y] = ginput(1);
close(f)

phx = mod(rect(1) + pix_x/scale - 1, expected_value);
phy = mod(rect(2) + pix_y/scale - 1, expected_value);

pattern = [expected_value phy expected_value phx];
end

