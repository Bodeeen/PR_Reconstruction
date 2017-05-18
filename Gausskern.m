function [ S ] = Gausskern( size, fwhm )
%Returns a square 2D gaussian kernal, input size and fwhm in pixels
size = round(size);
fwhm = round(fwhm);
S = zeros(size);
rad = (size-1)/2;
c = 2*(fwhm / 2.35)^2;

[y, x] = ndgrid(-rad:rad, -rad:rad);
        
d = sqrt(x.^2+y.^2);
S = exp( -(d.^2 / c));

