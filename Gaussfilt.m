function [ S ] = Gaussfilt( size, fwhm )
%Returns a square 2D gaussian fourier filter, input size in pixels as [Y X] and
%fwhm as ratio between 0-1, 1 meaning 0.5*sampling rate
size = round(size);
c = 2*(fwhm / 2.35)^2;

dy = 2/(size(1)-1);
dx = 2/(size(2)-1);

[y, x] = ndgrid(-1:dy:1, -1:dx:1);
        
d = sqrt(x.^2+y.^2);
S = exp( -(d.^2 / c));
