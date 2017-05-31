
% Script that simulates data from a certain signal underlying a single foci 
%("sig") by creating PSFs scaled by the perticular signal value. Poissonian
%noise is added and the signal is then reconstructed by fitting again to
%the PSF used to create the data. The simulation was initially created to
%test if the least squares estimate when the PSF is currupted by
%poissonian noise is unbiased i.e. if the average of a large amount of
%estimations convereges to the correct value.

%Initial parameters
px_size = 65;
sq_size = 750;
psf_fwhm = 220;
sig_length = 10000;
sig_str = 100;

sq_size_px = ceil(sq_size/px_size);

%Create signal, empty data matrix and PSF
sig = sig_str*ones(1, sig_length);
data = zeros(sq_size_px, sq_size_px, length(sig));
PSF = Gausskern(ceil(sq_size/px_size), psf_fwhm/px_size);

%Create scaled PSFs and place in data matrix.
for i = 1:length(sig)
    int = sig(i)*PSF;
    data(:,:,i) = poissrnd(int);
end

%Reshape so that each column contains data from one "scan position".
data_vec = reshape(data, [sq_size_px^2 size(data,3)]);

%Create basis for reconstruction
b1 = reshape(PSF, [sq_size_px^2, 1]);
B = b1;
G = B'*B;
Ginv = inv(G);

%Least squares fitting
cdual = b1' * data_vec;
c = Ginv * cdual;

%Sum all estimations to a cumulative sum and then a cumulative mean.
cum = 1:sig_length;
cs = cumsum(c);
cm = cs ./ cum;
plot(cm)
std(c)