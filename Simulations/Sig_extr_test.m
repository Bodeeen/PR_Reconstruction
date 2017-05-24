px_size = 65;
sq_size = 750;
psf_fwhm = 220;
sig_length = 10000;
sig_str = 100;

sq_size_px = ceil(sq_size/px_size);

sig = sig_str*ones(1, sig_length);
data = zeros(sq_size_px, sq_size_px, length(sig));
PSF = Gausskern(ceil(sq_size/px_size), psf_fwhm/px_size);

for i = 1:length(sig)
    int = sig(i)*PSF;
    data(:,:,i) = poissrnd(int);
end

data_vec = reshape(data, [sq_size_px^2 size(data,3)]);

b1 = reshape(PSF, [sq_size_px^2, 1]);
B = b1;
G = B'*B;
Ginv = inv(G);

cdual = b1' * data_vec;
c = Ginv * cdual;

cum = 1:sig_length;
cs = cumsum(c);
cm = cs ./ cum;
plot(cm)
std(c)