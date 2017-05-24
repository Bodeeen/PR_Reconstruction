function [ noisy ] = add_noise( im, SS, bg, std )
%Add poissonian noise to matrix, im should be between 0-1 and SS is an an
%arbitrary unit signal strength measure
im_c = im * SS;
noisy = 1e12*imnoise(im_c/1e12, 'poisson');
noisy = noisy + bg;
noisy = noisy + std^2.*randn(size(noisy)); 
end

