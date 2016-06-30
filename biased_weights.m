function W = biased_weights(N_in, bias, spread, random)
    W = zeros(N_in);

    for i = 0 : floor(N_in / 2)
        for j = 1 : N_in
            W(j,mod(j + i - 1, N_in) + 1) = normpdf(i, 0, spread);
            W(j,mod(j - i - 1, N_in) + 1) = normpdf(i, 0, spread);
        end
    end

    W = W / normpdf(0, 0, spread);
    
    if random
        W = bias * W + rand(N_in) / 20 - mean(mean(bias * W));
        W(W < 0) = 0;
    end
end




