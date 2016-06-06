subliminal = 'images/subliminal';
folder_name = sprintf('%s/correlation_0.4', subliminal);

N_in = 50; N_out = 50;

L_p = 0.7; H_p = 2.5;

data_filename = sprintf('%s/weights_Lp%d_Hp%d.mat', folder_name, L_p * 10, H_p * 10);
load(data_filename);

W = all_W(:,:,8);
active_cortical = sum(W > 0.02, 2) > 7; 
active_weights = W > 0.02;

subplot(1, 3, 1);
colormap('hot');
imagesc(W);
caxis([0,0.2]); axis off;


subplot(1, 3, 2);
imagesc(active_weights);

active_weights = active_weights | (active_weights(:,[N_in 1:(N_in - 1)]) & active_weights(:,[2:N_in 1]));
subplot(1, 3, 3);
imagesc(active_weights);


min_sd = Inf(1, sum(active_cortical));
best_center = zeros(1, sum(active_cortical));

for s = 0:49
    shifted = active_weights(active_cortical,[(N_in - s + 1): N_in 1:(N_in - s)]);
    centers = round(arrayfun(@(r) mean(find(shifted(r,:))), 1:size(shifted, 1)));
    sd = arrayfun(@(r) std(find(shifted(r,:))), 1:size(shifted, 1));
    
    best_center(sd < min_sd) = mod(centers(sd < min_sd) - s, N_in) + 1;
    min_sd(sd < min_sd) = sd(sd < min_sd);
end

dev = min([abs(best_center - find(active_cortical)');
           abs(best_center + 50 - find(active_cortical)');
           abs(best_center - 50 - find(active_cortical)')] , [], 1);
dev_L1 = sum(dev) / sum(active_cortical);

% for t = 1 : 10            
%     subplot(2, 5, t);
%     colormap('hot');
%     imagesc(all_W(:,:,t));
%     caxis([0,0.2]); axis off;
% end