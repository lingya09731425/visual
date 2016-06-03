function W = biased_weights(N_in, bias)
    W = zeros(N_in);

    for i = 0 : N_in - 1
        for j = 1 : N_in - i
            W(j,j+i) = normpdf(i, 0, 2);
            W(j+i,j) = normpdf(i, 0, 2);
        end
    end

    W = W / normpdf(0, 0, 2);
    W = bias * W + rand(N_in) / 10 - mean(mean(bias * W));
    W(W < 0) = 0;
    
%     figure;
%     colormap('hot');
%     imagesc(W);
%     colorbar; caxis([0,0.2]);
%     getframe;
end




