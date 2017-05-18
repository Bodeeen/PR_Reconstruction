function [ S ] = oneDGausskern( size, fwhm )
%Returns a 1D gaussian kernal, input size and fwhm
size = round(size);
fwhm = round(fwhm);
S = zeros(1, size);
rad = (size+1)/2;
c = 2*(fwhm / 2.35)^2;
for x = 1:size
    d = x-rad;
    S(x) = exp( -(d^2 / c));
end
end

