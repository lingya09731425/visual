figure;

folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/bcm_grid';

plot_num = 0;

N_in = 50;
N_out = 50;

L_p = 1.5;
bias = 0.05;
H_amp = 4.5;
W_initial = [0.15 0.25];
W_thres = [0 1.0];

for corr_thres = 0.00 : 0.05 : 0.20
    for H_p = [2.0 : 0.5 : 4.0 Inf]

        plot_num = plot_num + 1;

        subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f', ...
            folder_name, L_p, H_p, corr_thres, bias);

        if exist(subfolder_name, 'dir')
            weights_sparse_name = sprintf('%s/weights.mat', subfolder_name);
            % weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
            load(weights_sparse_name);

            num_of_plots = size(record_W, 3);
            % num_of_plots = size(plot_W, 3);
            
            W_evo = double(record_W) / 1000;
            % W_evo = double(plot_W) / 1000;
            W_end = mean(W_evo(:,:,(num_of_plots - 100) : num_of_plots), 3);
            % W_end = W_evo(:,:,num_of_plots);
            if any(all(all(W_evo > W_thres(2) * 0.98)))
                W_end(:,:) = W_thres(2);
            end

            active = W_end > W_thres(2) / 20;
            bar_width = sum(active, 2);
            avg_width = mean(bar_width(bar_width > 0));
            sparsity = sum(bar_width > 0) / N_out;
            
            if isnan(avg_width)
                avg_width = 0;
            end
            
            subplot(5, 6, plot_num);
            colormap('hot');
            imagesc(W_end);
            caxis(W_thres);
            
            title(sprintf('S = %d%%   ARF = %.1f', ...
                round(sparsity * 100), avg_width));
        end
    end
end

%%

figure;

H_p_all = [2.0 : 0.5 : 4.0 Inf];
corr_thrs_all = 0.00 : 0.05 : 0.20;

arf = NaN(length(H_p_all), length(corr_thrs_all));
sparseness = NaN(length(H_p_all), length(corr_thrs_all));

for i = 1 : length(H_p_all)
    for j = 1 : length(corr_thrs_all)
    
        H_p = H_p_all(i);
        corr_thres = corr_thrs_all(j);
    
        subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f', ...
            folder_name, L_p, H_p, corr_thres, bias);
        weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
        load(weights_sparse_name);

        num_of_plots = size(plot_W, 3);

        W_evo = double(plot_W) / 1000;
        W_end = W_evo(:,:,num_of_plots);
        if any(all(all(W_evo > W_thres(2) * 0.95)))
            W_end(:,:) = W_thres(2);
        end

        active = W_end > W_thres(2) / 20;
        bar_width = sum(active, 2);

        arf(i,j) = mean(bar_width(bar_width > 0));
        sparseness(i,j) = sum(bar_width > 0) / 50;
    end
end

subplot(1, 2, 1);
plot(corr_thrs_all, arf', '.-', 'MarkerSize', 15);
ylim([0 50]);
xlabel('input threshold');
ylabel('average receptive field');
legend('H_p = 2.0 (most frequent)', 'H_p = 2.5', ...
    'H_p = 3.0', 'H_p = 3.5', 'H_p = 4.0 (least frequent)', 'No H-events');

subplot(1, 2, 2);
plot(corr_thrs_all, sparseness', '.-', 'MarkerSize', 15);
ylim([0 1]);
xlabel('input threshold');
ylabel('sparseness');
legend('H_p = 2.0', 'H_p = 2.5', ...
    'H_p = 3.0', 'H_p = 3.5', 'H_p = 4.0', 'No H-events');

