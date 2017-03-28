G1 = Gausskern(10,4);
G1x = reshape(G1,[100, 1]);

G2 = Gausskern(10,8);
G2x = reshape(G2,[100, 1]);

B = [G1x G2x];

noisefac = 0.1;

Gdatax = G1x + G2x + (randn(100, 1)*noisefac);

G = B'*B;

Ginv = inv(G);

cdual = B' * Gdatax;
c = cdual' * Ginv;