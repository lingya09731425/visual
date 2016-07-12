figure;

note = 'H_theta_correspond';
folder_name = sprintf('../visual_images/Jul11/%s', note);

plot_num = 0;

N_in = 50;
N_out = 50;

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

                num_of_plots = size(plot_W, 3);
                
                W_evo = double(plot_W) / 1000;
                W_end = W_evo(:,:,num_of_plots);
                if any(all(all(W_evo >= W_thres(2) * 0.98)))
                    W_end(:,:) = W_thres(2);
                end

                active = W_end > W_thres(2) / 5;
                bar_width = sum(active, 2);
                avg_width = mean(bar_width(bar_width > 5));
                sparsity = sum(bar_width > 5) / N_out;

                stable_t = NaN(1, N_out);
                min_sd = Inf(1, N_out);
                best_center = NaN(1, N_out);
                
                maxed = W_evo > W_thres(2) * 0.98;
                maxed_evo = sum(maxed, 2);
                maxed_end = sum(W_end > W_thres(2) * 0.98, 2);
                
                for c = 1 : 50
                    if bar_width(c) > 5
                        stable = find(maxed_evo(c,1,:) == maxed_end(c));
                        stable_t(c) = stable(1);
                        
                        for s = 0:49
                            shifted = active(c,[(N_in - s + 1) : N_in 1 : (N_in - s)]);
                            center = round(mean(find(shifted)));
                            sd = std(find(shifted));

                            if sd < min_sd(c)
                                best_center(c) = mod(center - s - 1, N_in) + 1;
                                min_sd(c) = sd;
                            end
                        end
                    end
                end
                
                mean_stable_t = nanmean(stable_t);
                
                
                dev = min([abs(best_center - (1 : N_out));
                           abs(best_center + N_out - (1 : N_out));
                           abs(best_center - N_out - (1 : N_out))] , [], 1);
                mean_dev = nanmean(dev);
                
                widths = [widths avg_width];
                sparsities = [sparsities sparsity];

                subplot(6, 6, plot_num);
                % phase(plot_W, corr_thres);
                
                colormap('hot');
                imagesc(W_end);
                caxis(W_thres);
                
%                 extracted = reshape(W_evo(20,:,:), [50,size(W_evo,3)]);
%                 plot(extracted');
%                 ylim(W_thres);
                
                title(sprintf('%d%%   %.1f   %.2f  %.2f', ...
                    round(sparsity * 100), avg_width, mean_stable_t, mean_dev));
            end
    end
end
% end

