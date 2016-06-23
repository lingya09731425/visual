    M = biased_weights(N_out, NaN, 3, false);
    % M = M / 10;
    M = M .* (1 - eye(N_out)) / 10;
    
    [V,D] = eigs(M, 5);
    
    
    M(1:10, 1:10)
    D