
%Script to investigate the noise correction possibilities for signals
%currupted by noise. A high frequency and a low frequency signal is created
%to start with, giving rise to different PSFs. The sum of the two signals is
%corrupted by noise. By initially fitting the signals to their respective
%PSFs a first estimate is created. By then filtering the low-freq signal
%and recalculating the high-freq component a more accurate estimate can be
%achieved.

%Initial parameters
cmat = zeros(100,2);
N = 1000;
x = 1:N;

%Create high and low freq signals
ifsignal = sin(x/2);
oofsignal = ones(1,N);%sin(x/20);

%For each point in the signals, create a PSF scaled with the signal value,
%add the PSFs of the two signals and add noise to the sum. Then fit the
%noisy data to the two PSFs.
for i = 1:N
    %Create PSFs
    G1 = Gausskern(10,4);
    G1x = reshape(G1,[100, 1]);

    G2 = Gausskern(10,8);
    G2x = reshape(G2,[100, 1]);
    
    %B is matrix containing basis vectors
    B = [G1x G2x];

    noisefac = 1;

    %Add signals and add noise
    Gdatax = ifsignal(i)*G1x + oofsignal(i)*G2x + (randn(100, 1)*noisefac);

    G = B'*B;

    Ginv = inv(G);

    %Fit data to PSF bases
    cdual = B' * Gdatax;
    c = cdual' * Ginv;
    cmat(i,:) = c;
end

ifdet = cmat(:,1);
oofdet = cmat(:,2);

%Filter low-freq signal
kern = oneDGausskern(15,10)./sum(oneDGausskern(15,10));
filteredbg = conv(oofdet, kern, 'same');

ssquared = G1x'*G1x;
denoised = zeros(N,1);
for i = 1:N
   %Explanation : ifdet(i)*G1x + oofdet(i)*G2x is the projection of the
   %noisy data onto the subspace spanned by G1x and G2x. From this we
   %subtract the "known" low-freq vector filteredbg(i))*G2x. Resulting
   %vector v is then the original data shifted so that the origin is in 
   %filteredbg(i))*G2x. The projection v onto G1x is then given by 
   %(v'*G1x/ssquared) and represents the denoised data point.
   v = ifdet(i)*G1x + (oofdet(i) - filteredbg(i))*G2x;
   denoised(i) = (v'*G1x/ssquared);
    
end
disp(strcat('Variance before : ', num2str(var(ifdet))))
disp(strcat('Variance after : ', num2str(var(denoised))))

hold off
plot(1:N, ifdet)
hold on
plot(1:N, denoised)


