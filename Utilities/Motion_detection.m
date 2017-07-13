[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');

path = strcat(LoadPathName, LoadFileName);

stack = flipud(rot90(load_image_stack(path),1));
stack = stack - median(stack(:));
imshow(stack(:,:,1),[])
% mock = Gausskern(50, 10);
% stack = mock;
% for i = 1:10
%     stack = cat(3, stack, imtranslate(stack(:,:,i) , [0.5 1.5], 'cubic'));
% end

corr = xcorr2(stack(:,:,1), stack(:,:,2));
corr = corr - min(corr(:));
corr = corr ./ max(corr(:));
corr_stack = corr;

zero_coords = flipud(size(stack(:,:,1))'); % After flip, oriented as [X ; Y]

peak_coords = zeros(2, size(stack, 3) - 1);
motion = zeros(2, size(stack, 3) - 1);
cum_motion = zeros(2, size(stack, 3) - 1);
%FastPeakFind returns [X ; Y] i.e. [COL ; ROW]
pc = FastPeakFind(corr_stack(:,:,1), 0.8, (fspecial('gaussian', 7,1)), 1, 2);
if size(pc) == [0 0]
    peak_coords(:, 1) = peak_coords(:, i-1);
else
    peak_coords(:, 1) = pc;
end
motion(:,1) = peak_coords(:, 1) - zero_coords;
cum_motion(:,1) = motion(:,1);

corrected_stack = stack(:,:,1);

for i = 2:size(stack,3)-1
    i
    corr = xcorr2(stack(:,:,i), stack(:,:,i+1));
    corr = corr - min(corr(:));
    corr = corr ./ max(corr(:));
    corr_stack = cat(3, corr_stack, corr);
    pc = FastPeakFind(corr_stack(:,:,i), 0.5, (fspecial('gaussian', 7,1)), 1, 2);
    if size(pc) == [0 0]
        peak_coords(:, i) = peak_coords(:, i-1);
    else
        peak_coords(:, i) = pc;
    end
    motion(:, i) = peak_coords(:, i) - zero_coords;
    cum_motion(:, i) = cum_motion(:, i-1) + motion(:, i);
    corrected_stack(:,:,i) = imtranslate(stack(:,:,i), [cum_motion(:,i)'], 'cubic');
end

averaged_uncorrected = mean(stack, 3);
averaged_corrected = mean(corrected_stack, 3);

Write2Tiff(averaged_uncorrected, 'uncorrected.tif')
Write2Tiff(averaged_corrected, 'corrected.tif')

figure
subplot(2,2,1)
imshow(averaged_uncorrected,[])
subplot(2,2,2)
imshow(averaged_corrected,[])
subplot(2,2,[3 4])
plot(cum_motion(1,:))
hold on
plot(cum_motion(2,:))
hold off
xlabel('Frame')
ylabel('Motion (px)')
legend('X dim', 'Y dim')