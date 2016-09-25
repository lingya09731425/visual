figure;

folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/withoutH_stats_multi';

L_p = 1.5;
H_p = Inf;
bias = 0.05;
H_amp = 4.5;
W_initial = [0.15 0.25];
W_thres = [0 0.4];

corr_thrs_all = 0.30 : 0.05 : 0.75;

arf = NaN(1, length(corr_thrs_all));
arf_sd = NaN(1, length(corr_thrs_all));
sparseness = NaN(1, length(corr_thrs_all));
sparseness_sd = NaN(1, length(corr_thrs_all));

for i = 1 : length(corr_thrs_all)
    
    corr_thres = corr_thrs_all(i);
    
    subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
        folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
    weights_sparse_name = sprintf('%s/weights.mat', subfolder_name);
    load(weights_sparse_name);
   
    arfs = zeros(1,5);
    sparses = zeros(1,5);

    for k = 1 : 5
        W_end = W(:,:,k);
        active = W_end > W_thres(2) / 20;
        bar_width = sum(active, 2);

        arfs(k) = mean(bar_width(bar_width > 0));
        sparses(k) = sum(bar_width > 0) / 50;
    end

    arf(i) = nanmean(arfs);
    arf_sd(i) = nanstd(arfs);
    sparseness(i) = mean(sparses);
    sparseness_sd(i) = std(sparses);
end

subplot(2, 2, 1);
errorbar(corr_thrs_all, arf, arf_sd, '.-', 'MarkerSize', 15);
ylim([0 50]);
xlabel('input threshold');
ylabel('average receptive field');

subplot(2, 2, 2);
errorbar(corr_thrs_all, sparseness, sparseness_sd, '.-', 'MarkerSize', 15);
ylim([0 1]);
xlabel('input threshold');
ylabel('sparseness');

withH_stats;

