figure;

folder_name = '/Users/Monica/Dropbox (MIT)/thesis_images/bcm_diffH';

L_p = 1.5;
corr_thres = 0.00;
bias = 0.05;
H_amp = 4.5;
W_initial = [0.15 0.25];
W_thres = [0 1.0];

H_p_all = [Inf 4.5 : -0.5 : 1.5];

arf = NaN(1, length(H_p_all));
arf_sd = NaN(1, length(H_p_all));
sparseness = NaN(1, length(H_p_all));
sparseness_sd = NaN(1, length(H_p_all));

for i = 1 : length(H_p_all)
    
    H_p = H_p_all(i);
       
    arfs = zeros(1,3);
    sparses = zeros(1,3);

    for k = 1 : 3
        
        subfolder_name = sprintf('%s/trial%d/Lp%.2f_Hp%.2f_corrthr%.2f_bias%.2f', ...
            folder_name, k, L_p, H_p, corr_thres, bias);
        weights_sparse_name = sprintf('%s/weights.mat', subfolder_name);
        load(weights_sparse_name);
        
        num_of_plots = size(record_W, 3); 
        
        W_evo = double(record_W) / 1000;
        W_end = W_evo(:,:,(num_of_plots - 3000) : num_of_plots);

        active = all(W_end > W_thres(2) / 10, 3);
        bar_width = sum(active, 2);

        arfs(k) = mean(bar_width(bar_width > 0));
        sparses(k) = sum(bar_width > 0) / 50;
    end

    arf(i) = nanmean(arfs);
    arf_sd(i) = nanstd(arfs);
    sparseness(i) = mean(sparses);
    sparseness_sd(i) = std(sparses);
end

H_p_all(1) = 6.0;

errorbar(H_p_all, arf, arf_sd, '.-', 'MarkerSize', 15);
ylim([10 17]);
xlabel('H_p (average inter-event interval)');
ylabel('average receptive field');

ax = gca;
set(ax, 'XTick', fliplr(H_p_all(1 : 6)));
set(ax, 'XTickLabel', {'2.5' '3.0' '3.5' '4.0' '4.5' 'No H-events'});



