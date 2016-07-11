M = biased_weights(50, NaN, 0.05, 7, false);

[V,D] = eigs(M, 5);
M(1:20, 1:20)
D