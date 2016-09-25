figure;

folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/withoutH_stats';

plot_num = 0;

N_in = 50;
N_out = 50;

L_p = 1.5;
H_p = Inf;
bias = 0.05;
H_amp = 4.5;
W_initial = [0.15 0.25];
W_thres = [0 0.4];

for corr_thres = 0.30 : 0.05 : 0.75

        plot_num = plot_num + 1;

        subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
            folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);

        if exist(subfolder_name, 'dir')
            weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
            load(weights_sparse_name);

            num_of_plots = size(plot_W, 3);

            W_evo = double(plot_W) / 1000;
            W_end = W_evo(:,:,num_of_plots);
            if any(all(all(W_evo > W_thres(2) * 0.98)))
                W_end(:,:) = W_thres(2);
            end

            active = W_end > W_thres(2) / 20;
            bar_width = sum(active, 2);
            avg_width = mean(bar_width(bar_width > 0));
            sd_width = std(bar_width(bar_width > 0));
            sparsity = sum(bar_width > 0) / N_out;
            
            if isnan(avg_width)
                avg_width = 0;
                sd_width = 0;
            end
            
            subplot(2, 5, plot_num);
            % phase(plot_W);
            colormap('hot');
            imagesc(W_end);
            caxis(W_thres);
            
            title(sprintf('S = %d%%   ARF = %.1f', ...
                round(sparsity * 100), avg_width));
            % title(sprintf('S = %d%% RF = %.2f +/- %.2f', ...
            %     round(sparsity * 100), avg_width, sd_width));
        end
end


