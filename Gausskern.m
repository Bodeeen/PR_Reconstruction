function [ S ] = Gausskern( size, fwhm )
%Returns a 2D gaussian kernal, input size and fwhm
size = round(size);
fwhm = round(fwhm);
S = zeros(size);
rad = (size+1)/2;
c = 2*(fwhm / 2.35)^2;
for y = 1:size
    for x = 1:size
        u = x-rad;
        v = y-rad;
        
        d = sqrt(u^2+v^2);
        S(y,x) = exp( -(d^2 / c));
    end
end
end

