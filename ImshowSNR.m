function [] = ImshowSNR( im1, im2 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
figure('name', sprintf('Activation size (nm): %.1f \n Pinhole size (nm): %.1f', 1000*0.020, 1000*0.5))

immax = max(im1(:));
immin = min(im1(:));
imstd = std(im1(:));
snr = 10*log10((immax-immin)/imstd)
% Plot
subplot(1,2,1)
imshow(im1,[])
title(sprintf('SNR = %.1f', snr))

immax = max(im2(:));
immin = min(im2(:));
imstd = std(im2(:));
snr = 10*log10((immax-immin)/imstd)
% Plot
subplot(1,2,2)
imshow(im2,[])
title(sprintf('SNR = %.1f', snr))

end

