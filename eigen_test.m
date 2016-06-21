    M = biased_weights(N_out, NaN, 6, false);
    M = M .* (1 - eye(N_out)) / 15;
    
    [V,D] = eigs(M, 5);
    D