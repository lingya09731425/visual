cov = csvread('cov2');
u = 0.03644017;
thres = [0.2 0.3 0.4 0.5 0.7 0.9];

L_p = 1.5;
H_p = Inf;
H_amp = 4.5;
bias = 0.05;
W_initial = [0.15 0.25];

rows = 5;
cols = length(thres);


for i = 1 : length(thres)
    corr_thres = thres(i);
    
    [V,D] = eig(cov + u * (u - corr_thres));
    [D,I] = sort(diag(D),'descend');
    V = V(:,I);
    
    col = zeros(50,3);
    if i == 1
        col(1,:) = [1 0.5 0];
    else
        col(1,:) = [1 0 0]; col(2,:) = [0 0.7 0];
    end
    
    subplot(rows, cols, i);
    scatter(1 : 50, D, 20, col, 'filled');
    xlim([0 50]); ylim([-0.5 0.7]);
    xlabel('rank'); ylabel('eigenvalue');
    
    subplot(rows, cols, i + cols * 1);
    if i == 1
        plot(V(:,1), 'Color', [1 0.5 0], 'LineWidth', 2);
    else
        plot(V(:,1), 'Color', [1 0 0], 'LineWidth', 2); hold on;
        plot(V(:,2), 'Color', [0 0.7 0], 'LineWidth', 2);
    end
    xlim([0 50]); ylim([-0.3 0.3]);
    xlabel('retina');
    
    folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/phase_noH/unbounded';
    subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
        folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
    weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
    load(weights_sparse_name);
            
    subplot(rows, cols, i + cols * 2);
    plot_end(plot_W, NaN);
    if i == 1
        caxis([-32 32]);
    end
    
    subplot(rows, cols, i + cols * 3);
    phase(plot_W, [-5 20], [-10 10]);
    
    subplot(rows, cols, i + cols * 4);
    phase(plot_W, [-0.1 0.4], [-0.4 0.4]);
end


% figure;
% for i = 1 : length(thres)
%     corr_thres = thres(i);
% 
%     folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/unbound_originalW/bounded';
%     subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
%         folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
%     weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
%     load(weights_sparse_name);
%             
%     subplot(2, 3, i);
%     plot_end(plot_W, [0 0.4]);
%     
%     subplot(2, 3, 3 + i);
%     phase(plot_W, [-0.1 0.4]);
% end





