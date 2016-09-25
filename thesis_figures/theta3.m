figure;

L_p = 1.5;
H_p = Inf;
corr_thres = 0.3;
H_amp = 4.5;
bias = 0.05;
W_initial = [0.15 0.25];

folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/phase_noH/unbounded';
subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
    folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
load(weights_sparse_name);

phase(plot_W, [-5 10], [-5 10]);
hold on;
plot([1 1], [-100 100], 'r');
plot([6 6], [-100 100], 'b');