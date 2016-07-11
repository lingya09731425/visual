function W = biased_weights(N_in, W_initial, bias, spread, random)
    W = zeros(N_in);
    
    limit = random * floor(N_in / 2) + ~random * spread;

    for i = 0 : limit
        for j = 1 : N_in
            W(j,mod(j + i - 1, N_in) + 1) = normpdf(i, 0, spread);
            W(j,mod(j - i - 1, N_in) + 1) = normpdf(i, 0, spread);
        end
    end

    W = W / normpdf(0, 0, spread);
    % W = W - mean(mean(W));
    
    if random
        W = bias * W + W_initial(1) + (W_initial(2) - W_initial(1)) * rand(N_in);
        W(W < 0) = 0;
    else
        W = bias * W .* (1 - eye(N_in));
    end
    
end