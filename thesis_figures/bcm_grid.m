figure;

folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/bcm_diffH/trial1';

plot_num = 0;

N_in = 50;
N_out = 50;

L_p = 1.5;
% H_p = Inf;
corr_thres = 0.00;
bias = 0.05;
H_amp = 4.5;
W_initial = [0.15 0.25];
W_thres = [0 1.0];

for H_p = [Inf 4.5 : -0.5 : 1.5]

        plot_num = plot_num + 1;

        subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f', ...
            folder_name, L_p, H_p, corr_thres, bias);

        if exist(subfolder_name, 'dir')
            weights_sparse_name = sprintf('%s/weights.mat', subfolder_name);
            load(weights_sparse_name);

            num_of_plots = size(record_W, 3);

            W_evo = double(record_W) / 1000;
            W_end = W_evo(:,:,(num_of_plots - 3000) : num_of_plots);

            active = all(W_end > W_thres(2) / 10, 3);
            bar_width = sum(active, 2);
            avg_width = mean(bar_width(bar_width > 0));
            sd_width = std(bar_width(bar_width > 0));
            sparsity = sum(bar_width > 0) / N_out;
            
            if isnan(avg_width)
                avg_width = 0;
                sd_width = 0;
            end
            
            subplot(2, 4, plot_num);
            % phase(plot_W);
            colormap('hot');
            imagesc(W_end(:,:,1001));
            caxis(W_thres);
            
            title(sprintf('S = %d%%   ARF = %.1f', ...
                round(sparsity * 100), avg_width));
            % title(sprintf('S = %d%% RF = %.2f +/- %.2f', ...
            %     round(sparsity * 100), avg_width, sd_width));
        end
end


