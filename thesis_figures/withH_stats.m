folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/withH_stats_multi';

L_p = 1.5;
bias = 0.05;
H_amp = 4.5;
W_initial = [0.15 0.25];
W_thres = [0 0.4];

H_p_all = 2.0 : 0.5 : 4.0;
corr_thrs_all = 0.26 : 0.02 : 0.34;

arf = NaN(length(H_p_all), length(corr_thrs_all));
arf_sd = NaN(length(H_p_all), length(corr_thrs_all));
sparseness = NaN(length(H_p_all), length(corr_thrs_all));
sparseness_sd = NaN(length(H_p_all), length(corr_thrs_all));

for i = 1 : length(H_p_all)
    for j = 1 : length(corr_thrs_all)
    
        H_p = H_p_all(i);
        corr_thres = corr_thrs_all(j);
    
        subfolder_name = sprintf('%s/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f_Hamp%.2f_Winit%.2f', ...
            folder_name, L_p, H_p, corr_thres, bias, H_amp, W_initial(1) + 0.05);
        weights_sparse_name = sprintf('%s/weights.mat', subfolder_name);
        load(weights_sparse_name);

%         num_of_plots = size(plot_W, 3);
% 
%         W_evo = double(plot_W) / 1000;
%         W_end = W_evo(:,:,num_of_plots);
%         if any(all(all(W_evo > W_thres(2) * 0.95)))
%             W_end(:,:) = W_thres(2);
%         end

%         active = W_end > W_thres(2) / 20;
%         bar_width = sum(active, 2);
% 
%         arf(i,j) = mean(bar_width(bar_width > 0));
%         sd(i,j) = std(bar_width(bar_width > 0));
%         sparseness(i,j) = sum(bar_width > 0) / 50;
          
        arfs = zeros(1,5);
        sparses = zeros(1,5);
          
        for k = 1 : 5
            W_end = W(:,:,k);
            active = W_end > W_thres(2) / 20;
            bar_width = sum(active, 2);

            arfs(k) = mean(bar_width(bar_width > 0));
            sparses(k) = sum(bar_width > 0) / 50;
        end
        
        arf(i,j) = nanmean(arfs);
        arf_sd(i,j) = nanstd(arfs);
        sparseness(i,j) = mean(sparses);
        sparseness_sd(i,j) = std(sparses);
    end
end

subplot(2, 2, 3);
errorbar(corr_thrs_all' * ones(1, 5), arf', arf_sd', '.-', 'MarkerSize', 15);
ylim([0 50]);
xlabel('input threshold');
ylabel('average receptive field');
legend('H_p = 2.0 (most frequent)', 'H_p = 2.5', ...
    'H_p = 3.0', 'H_p = 3.5', 'H_p = 4.0 (least frequent)');

subplot(2, 2, 4);
errorbar(corr_thrs_all' * ones(1, 5), sparseness', sparseness_sd', '.-', 'MarkerSize', 15);
ylim([0 1]);
xlabel('input threshold');
ylabel('sparseness');
legend('H_p = 2.0', 'H_p = 2.5', ...
    'H_p = 3.0', 'H_p = 3.5', 'H_p = 4.0');


