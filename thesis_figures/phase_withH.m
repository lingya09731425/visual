close all; figure;

L_p = 1.5;
corr_thres = 0.30;
H_amp = 4.5;
bias = 0.05;
W_initial = [0.15 0.25];

H_p = Inf;
folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/phase_noH/unbounded';
subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
    folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
load(weights_sparse_name);

subplot(2, 3, 1);
phase(plot_W, [-0.1 0.4], [-0.4 0.4]);

p = get(gca, 'Position');
h = axes('Position', [(p(1) - 0.02) (p(2) + p(4) - 0.10) 0.10 0.15], 'Layer','top');

phase(plot_W, [-5 20], [-20 20]);
set(gca,'XAxisLocation','top')
xlabel(''); ylabel('');

H_p_s = 2.0 : 0.5 : 4.0;
for i = 1 : length(H_p_s)
    H_p = H_p_s(i);
    
    folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/phase_withH/thres0.30';
    subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
        folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
    weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
    load(weights_sparse_name);
    
    subplot(2, 3, 7 - i);
    phase(plot_W, [-0.1 0.4], [-0.4 0.4]);
    
    p = get(gca, 'Position');
    h = axes('Position', [(p(1) - 0.02) (p(2) + p(4) - 0.10) 0.10 0.15], 'Layer','top');
    
    phase(plot_W, [-5 20], [-20 20]);
    set(gca,'XAxisLocation','top')
    xlabel(''); ylabel('');
end