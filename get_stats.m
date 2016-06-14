subliminal = 'images/compare';
folder_name = sprintf('%s/bcm', subliminal);

close all;
plot_examples_only = true;


N_in = 50; N_out = 50;

L_p_vals = [0.1 0.3 0.5 0.7 0.9];
H_p_vals = [Inf 1.0 2.0 3.0 4.0 5.0];

record_dim = [length(L_p_vals),length(H_p_vals)];

mean_spr = NaN(record_dim); std_spr = NaN(record_dim);
mean_bar = NaN(record_dim); std_bar = NaN(record_dim);
mean_dev = NaN(record_dim); std_dev = NaN(record_dim);

figure;

for i = 1 : length(L_p_vals)
    for j = 1 : length(H_p_vals)
        
        L_p = L_p_vals(i);
        H_p = H_p_vals(j);
        
        data_filename = sprintf('%s/weights_Lp%d_Hp%d.mat', folder_name, L_p * 10, H_p * 10);
        load(data_filename);
        num_of_trials = size(all_W, 3);
        
        % plot the first result
        subplot(length(L_p_vals), length(H_p_vals), length(H_p_vals) * (i - 1) + j);
        colormap('hot');
        imagesc(all_W(:,:,4));
        caxis([0,0.4]); axis off;
        title(sprintf('L = %.1f H = %.1f', L_p, H_p));
        
        if plot_examples_only
            continue;
        end
        
        % percentage of active cortical cells
        sparsity = NaN(num_of_trials, 1);
        
        % average # of active synpases per cortical cell
        bar_length = NaN(num_of_trials, 1);
        
        % L1 deviation from the diagonal
        dev_L1 = NaN(num_of_trials, 1);
        
        for t = 1 : num_of_trials
            W = all_W(:,:,t);
            
            % a synapse is active iff (the weight is > 0.02 or both its
            % neighbors are active            
            active_weights = W > 0.02;
            active_weights = active_weights | (active_weights(:,[N_in 1:(N_in - 1)]) & active_weights(:,[2:N_in 1]));
            
            % a cortical cell is active iff > 7 synapses are active
            active_cortical = sum(active_weights, 2) > 7;
            sparsity(t) = sum(active_cortical) / N_out * 100;
            
            % continue with stats if > 5 cortical cells are active
            if sum(active_cortical) > 5
                bar_length(t) = mean(sum(active_weights(active_cortical,:), 2));

                min_sd = Inf(1, sum(active_cortical));
                best_center = zeros(1, sum(active_cortical));

                % find bar center
                for s = 0:49
                    shifted = active_weights(active_cortical,[(N_in - s + 1): N_in 1:(N_in - s)]);
                    centers = round(arrayfun(@(r) mean(find(shifted(r,:))), 1:size(shifted, 1)));
                    sd = arrayfun(@(r) std(find(shifted(r,:))), 1:size(shifted, 1));

                    best_center(sd < min_sd) = mod(centers(sd < min_sd) - s - 1, N_in) + 1;
                    min_sd(sd < min_sd) = sd(sd < min_sd);
                end

                % calculate deviation
                dev = min([abs(best_center - find(active_cortical)');
                           abs(best_center + 50 - find(active_cortical)');
                           abs(best_center - 50 - find(active_cortical)')] , [], 1);
                dev_L1(t) = sum(dev) / sum(active_cortical);
            end
        end
        
        mean_spr(i,j) = nanmean(sparsity);
        std_spr(i,j) = nanstd(sparsity);
        
        mean_bar(i,j) = nanmean(bar_length);
        std_bar(i,j) = nanstd(bar_length);
        
        mean_dev(i,j) = nanmean(dev_L1);
        std_dev(i,j) = nanstd(dev_L1);
    end
end

if ~plot_examples_only
    figure;

    xaxis_values = L_p_vals' * ones(1, record_dim(2));

    subplot(1, 3, 1);
    errorbar(xaxis_values, mean_spr, std_spr, '-*', 'Linewidth', 2);
    xlabel('L period'); ylabel('activated cortical cell %');
    legend(num2str(H_p_vals'), 'Location', 'southwest'); legend('boxoff');

    subplot(1, 3, 2);
    errorbar(xaxis_values, mean_bar, std_bar, '-*', 'Linewidth', 2);
    xlabel('L period'); ylabel('activated synapses per cortical cell (bar width)');
    legend(num2str(H_p_vals'), 'Location', 'southwest'); legend('boxoff');

    subplot(1, 3, 3);
    errorbar(xaxis_values, mean_dev, std_dev, '-*', 'Linewidth', 2);
    xlabel('L period'); ylabel('L1 deviation from diagonal');
    legend(num2str(H_p_vals'), 'Location', 'southwest'); legend('boxoff');
end

