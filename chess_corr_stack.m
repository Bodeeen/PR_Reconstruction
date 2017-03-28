stack = load_image_stack('14_rec_23_Stack.hdf5');

av = mean(stack, 3);

ppx = 23;
ppy = 23;

sqx = size(stack, 2)/ppx;
sqy = size(stack, 1)/ppy;

minmat = zeros(sqy, sqx);

for i = 1:sqx
    for j = 1:sqy
        ulp = [(j-1)*ppy, (i-1)*ppx];
        subsq = av(ulp(1) + ppy, ulp(2) + ppx);
        minimum = min(subsq);
        minmat(j,i) = minimum;
    end
end

filtered = conv2(minmat, ones(3)/9, 'valid');
minmat(2:end-1, 2:end-1) = minmat(2:end-1, 2:end-1) - filtered;

[yi xi] = meshgrid(1:size(av, 1), 1:size(av, 2));
yi = ceil(yi ./ ppy);
xi = ceil(xi ./ ppx);

resized = interpn(minmat, xi, yi);

corr = av - resized;

