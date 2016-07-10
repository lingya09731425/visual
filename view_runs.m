figure;

note = 'H_theta_correspond_unbounded';
folder_name = sprintf('../visual_images/%s/%s', datestr(now, 'mmmdd'), note);

plot_num = 0;

L_p = 1.5;
% H_p = 3.0;
% corr_thres = 0.25;
W_thres = [0.0 0.4];
bias = 0.07;

widths = [];
sparsities = [];

% for bias = 0.04 : 0.03 : 0.10
%     figure;
%     suptitle(sprintf('bias = %.2f', bias));
%     plot_num = 0;
    
for corr_thres = 0.25 : 0.05 : 0.50
    for H_p = [2.0 : 0.5 : 4.0 Inf]
    

            plot_num = plot_num + 1;

            subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f', ...
                folder_name, L_p, H_p, corr_thres, bias);

            if exist(subfolder_name, 'dir')
                weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
                load(weights_sparse_name);

                W_end = double(plot_W(:,:,size(plot_W, 3))) / 1000;
                if any(all(all(plot_W >= W_thres(2) * 1000 * 0.98 )))
                    W_end = 400 * ones(size(W_end));
                end

                active = W_end > W_thres(2) / 5;
                bar_width = sum(active, 2);
                avg_width = mean(bar_width(bar_width > 5));
                sparsity = sum(bar_width > 5) / size(W_end, 1);
                
                widths = [widths avg_width];
                sparsities = [sparsities sparsity];

                subplot(6, 6, plot_num);
                phase(plot_W, corr_thres);
                % colormap('hot');
                % imagesc(W_end);
                % caxis(W_thres);
                title(sprintf('sparsity = %d%% width = %.1f', round(sparsity * 100), avg_width));
            end
    end
end
% end

