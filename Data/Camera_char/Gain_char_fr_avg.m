load('Darkframe_defect_corr_ON.mat')
OFFSET = double(background);
GM_STACK = GM_STACK;
nr_measurements = size(GM_STACK, 3);
width = size(GM_STACK, 2);
height = size(GM_STACK, 1);
pixels = height*width;
gain_stack = [];
illumination_stack = [];

MEAN_STACK = GM_STACK - repmat(OFFSET, [1 1 nr_measurements]);

kern_size = 11;

kern = ones(kern_size)/kern_size^2;

for i = 1:nr_measurements
    disp(sprintf('Analysing measurement %d', i));
    CUR_GM = MEAN_STACK(:,:,i);
    illumination_map = conv2(CUR_GM, kern, 'same');

    illumination_stack = cat(3, illumination_stack, illumination_map);
end

illumination_table = reshape(illumination_stack, [pixels nr_measurements]);

MEAN_TABLE = reshape(MEAN_STACK, [pixels nr_measurements]);

gain_table = [];
h = waitbar(0, 'Processing');
for i = i:pixels
    waitbar(i/pixels);
    gain_table(i, :) = MEAN_TABLE(i, :) * pinv(illumination_table(i, :));
end

gain_map = reshape(gain_table, [height, width]);