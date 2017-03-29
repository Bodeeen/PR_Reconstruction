
cmat = zeros(100,2);
N = 1000
x = 1:N;

ifsignal = ones(1,N);%sin(x/2);
oofsignal = ones(1,N);%sin(x/20);


for i = 1:N
    G1 = Gausskern(10,4);
    G1x = reshape(G1,[100, 1]);

    G2 = Gausskern(10,8);
    G2x = reshape(G2,[100, 1]);

    B = [G1x G2x];

    noisefac = 1;

    Gdatax = ifsignal(i)*G1x + oofsignal(i)*G2x + (randn(100, 1)*noisefac);

    G = B'*B;

    Ginv = inv(G);

    cdual = B' * Gdatax;
    c = cdual' * Ginv;
    cmat(i,:) = c;
end
ifdet = cmat(:,1);
oofdet = cmat(:,2);

(ifdet - 1)'*(oofdet - 1);

kern = oneDGausskern(15,10)./sum(oneDGausskern(15,10));
filteredbg = conv(oofdet, kern, 'same');

ssquared = G1x'*G1x;
denoised = zeros(N,1);
for i = 1:N
   v = ifdet(i)*G1x + (oofdet(i) - filteredbg(i))*G2x;
   denoised(i) = (v'*G1x/ssquared);
    
end
disp(strcat('Variance before : ', num2str(var(ifdet))))
disp(strcat('Variance after : ', num2str(var(denoised))))

hold off
plot(1:N, ifdet)
hold on
plot(1:N, denoised)


