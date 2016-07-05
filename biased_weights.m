function W = biased_weights(N_in, W_initial, bias, spread)
    W = zeros(N_in);

    for i = 0 : floor(N_in / 2)
        for j = 1 : N_in
            W(j,mod(j + i - 1, N_in) + 1) = normpdf(i, 0, spread);
            W(j,mod(j - i - 1, N_in) + 1) = normpdf(i, 0, spread);
        end
    end

    W = W / normpdf(0, 0, spread);
    W = bias * W + normrnd(W_initial, W_initial / 5, N_in, N_in) - mean(mean(bias * W));
    W(W < 0) = 0;
end




