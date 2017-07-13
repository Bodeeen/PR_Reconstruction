function [ corrected_stack, x_motion, y_motion ] = Motion_detection_fun( stack )
%Function for finding the motion of an object throughout the stack using a
%frame correlation approach

stack = stack - median(stack(:));

corr = xcorr2(stack(:,:,1), stack(:,:,2));
corr = corr - min(corr(:));
corr = corr ./ max(corr(:));
corr_stack = corr;

zero_coords = flipud(size(stack(:,:,1))'); % After flip, oriented as [X ; Y]

peak_coords = zeros(2, size(stack, 3) - 1);
motion = zeros(2, size(stack, 3));
cum_motion = zeros(2, size(stack, 3) - 1);
%FastPeakFind returns [X ; Y] i.e. [COL ; ROW]
pc = FastPeakFind(corr_stack(:,:,1), 0.5, (fspecial('gaussian', 7,1)), 1, 2);
if size(pc) == [0 0]
    peak_coords(:, 1) = zero_coords;
else
    peak_coords(:, 1) = pc;
end
motion(:,2) = peak_coords(:, 1) - zero_coords;
cum_motion(:,1) = motion(:,1);

corrected_stack = stack(:,:,1);

for i = 2:size(stack,3)-1
    corr = xcorr2(stack(:,:,1), stack(:,:,i+1));
    corr = corr - min(corr(:));
    corr = corr ./ max(corr(:));
    corr_stack = cat(3, corr_stack, corr);
    pc = FastPeakFind(corr_stack(:,:,i), 0.5, (fspecial('gaussian', 7,1)), 1, 2);
    if size(pc) == [0 0]
        peak_coords(:, i) = peak_coords(:, i-1);
    else
        peak_coords(:, i) = pc;
    end
    motion(:, i+1) = peak_coords(:, i) - zero_coords;
    cum_motion(:, i) = cum_motion(:, i-1) + motion(:, i);
    corrected_stack(:,:,i) = imtranslate(stack(:,:,i), [cum_motion(:,i)'], 'cubic');
end

x_motion = motion(1,:);
y_motion = motion(2,:);
x_cum_motion = cum_motion(1,:);
y_cum_motion = cum_motion(2,:);


averaged_uncorrected = mean(stack, 3);
averaged_corrected = mean(corrected_stack, 3);
end

