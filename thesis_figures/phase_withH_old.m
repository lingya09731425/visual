figure;

L_p = 1.5;
bias = 0.05;
H_amp = 4.5;
W_initial = [0.15 0.25];
W_thres = [0 0.4];

folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/withoutH_stats';

H_p = Inf; corr_thres = 0.50;
subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
    folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
load(weights_sparse_name);

subplot(2,3,1);
plot_end(plot_W, W_thres);
subplot(2,3,4);
phase(plot_W, [-0.1 0.4]);

folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/withH_stats';

H_p = 4.0; corr_thres = 0.34;
subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
    folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
load(weights_sparse_name);

subplot(2,3,2);
plot_end(plot_W, W_thres);
subplot(2,3,5);
phase(plot_W, [-0.1 0.4]);


H_p = 2.0; corr_thres = 0.26;
subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
    folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
load(weights_sparse_name);

subplot(2,3,3);
plot_end(plot_W, W_thres);
subplot(2,3,6);
phase(plot_W, [-0.1 0.4]);