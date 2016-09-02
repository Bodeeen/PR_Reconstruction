function [ S ] = Gausskern( size, fwhm )
%Returns a kernel with cross section of a spher
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

