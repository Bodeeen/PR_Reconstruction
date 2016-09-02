function [ S ] = Spherkern( size )
%Returns a kernel with cross section of a spher
S = zeros(size);
rad = (size+1)/2;
for y = 1:size
    for x = 1:size
        u = (x-rad)/rad;
        v = (y-rad)/rad;
        
        d = sqrt(u^2+v^2);
        h = sqrt(1-d^2);
        S(y,x) = 2*h;
    end
end
S(imag(S) ~= 0) = 0;
end

