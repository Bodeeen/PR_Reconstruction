function [ S ] = Gausskern( size, fwhm, cx, cy )
%Returns a square 2D gaussian kernal, input size and fwhm in pixels
%cx and cy are center coords in x and y
size = round(size);
fwhm = round(fwhm);
S = zeros(size);
rad = (size-1)/2;
c = 2*(fwhm / 2.35)^2;

[y, x] = ndgrid(-rad:rad, -rad:rad);
x = x + cx;
y = y + cy;
d = sqrt(x.^2+y.^2);
S = exp( -(d.^2 / c));

