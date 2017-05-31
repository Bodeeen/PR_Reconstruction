Noisefac = 0.1;

NoisefreeG = oneDGausskern(12, 3.4);
NoisefreeC = ones(1,12);

Noise = randn(1,12)*Noisefac;
plot(NoisefreeG+NoisefreeC+Noise)

raw_sig = 2*NoisefreeG' + NoisefreeC' + Noise';

B = [NoisefreeG' NoisefreeC'];

G = B'*B;
Ginv = inv(G);

cdual = B'*raw_sig;
c = Ginv*cdual

%%

NoisefreeG_1 = NoisefreeG(1:2:end);
NoisefreeG_2 = NoisefreeG(2:2:end);

NoisefreeC_1 = NoisefreeC(1:2:end);
NoisefreeC_2 = NoisefreeC(2:2:end);

raw_sig_1 = raw_sig(1:2:end);
raw_sig_2 = raw_sig(2:2:end);

B_1 = [NoisefreeG_1' NoisefreeC_1'];
B_2 = [NoisefreeG_2' NoisefreeC_2'];

G_1 = B_1' * B_1;
G_2 = B_2' * B_2;

G_1inv = inv(G_1);
G_2inv = inv(G_2);

c_1dual = B_1'*raw_sig_1;
c_2dual = B_2'*raw_sig_2;

c_1 = G_1inv * c_1dual;
c_2 = G_2inv * c_2dual;
c_better = mean([c_1 c_2], 2)