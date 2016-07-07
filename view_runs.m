note = 'comb_long_time_small_bias';
folder_name = sprintf('../visual_images/%s/%s', datestr(now, 'mmmdd'), note);

plot_num = 0;

L_p = 2.0;
H_p = 3.5;
corr_thres = 0.25;
W_thres = [0.0 0.4];

for L_p = 1.5 : 0.5 : 3.0
    for H_p = 2.0 : 0.5 : 3.5

        plot_num = plot_num + 1;

        subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f', ...
            folder_name, L_p, H_p, corr_thres);

        if exist(subfolder_name, 'dir')
            weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
            load(weights_sparse_name);

            W_end = double(plot_W(:,:,size(plot_W, 3))) / 1000;
            
            active = W_end > W_thres(2) / 5;
            bar_width = sum(active, 2);
            avg_width = mean(bar_width(bar_width > 5));
            sparsity = sum(bar_width > 5) / size(W_end, 1);
            
            subplot(4, 4, plot_num);
            colormap('hot');
            imagesc(W_end);
            caxis(W_thres);
            title(sprintf('sparsity = %d%% width = %.1f', round(sparsity * 100), avg_width));
        end
    end
end