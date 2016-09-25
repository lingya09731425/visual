function phase(plot_W, xlims, ylims)
    W_evo = double(plot_W) / 1000;
    W_end = W_evo(:,:,size(W_evo,3));
    num_records = size(W_evo, 3);

    w_up = NaN(50, num_records);
    w_down = NaN(50, num_records);

    % cov = csvread('cov');
    % u = 0.03643737;
    % [V,D] = eigs(cov + u * (u - corr_thres), 25);
    % 
    % c1 = W_evo(:,:,1) * V(:,1);
    % c2 = W_evo(:,:,1) * V(:,2);
    % c3 = W_evo(:,:,1) * V(:,3);
    % c4 = W_evo(:,:,1) * V(:,4);
    % c5 = W_evo(:,:,1) * V(:,5);

    % simp = c1 * V(:,1)' + c2 * V(:,2)'; % + c3 * V(:,3)';
    % simp2 = c1 * V(:,1)' + c2 * V(:,2)' + c3 * V(:,3)' + c4 * V(:,4)' + c5 * V(:,5)';
    % imagesc(simp);
    % pot = c1 * V(:,1)' + c2 * V(:,2)' >= 0;
    
    
    
    pot = false(50);
    for i = 1 : 50
        [~,k] = max(W_end(i,:));
        pot(i, mod(k - 12 : k + 12, 50) + 1) = true;
    end

    dep = ~pot;

    for i = 1 : num_records
        up = W_evo(:,:,i); up(dep) = NaN;
        down = W_evo(:,:,i); down(pot) = NaN;

        w_up(:,i) = nanmean(up, 2);
        w_down(:,i) = nanmean(down, 2);
    end

    % figure;
    plot(w_up(1,:), w_down(1,:));
    % plot_limit = max([max(max(abs(w_up))) max(max(abs(w_down)))]);
    % xlim([-plot_limit plot_limit]);
    % ylim([-plot_limit plot_limit]);
    % xlim([-0.02 0.05]);
    % ylim([-0.02 0.05]);
    xlim(xlims);
    ylim(ylims);
    hold on;
    for i = 2 : 50
        plot(w_up(i,:), w_down(i,:));
    end
    plot([-100 100], [0 0], ':k');
    plot([0 0], [-100 100], ':k');
    plot([-100 100], [-100 100], ':k');
    xlabel('w_+');
    ylabel('w_-');
end

