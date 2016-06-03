clear; close all;

% independent poisson events
indp = true;

% randomness
biased_W = true; bias = 0.02;
random_L_events = true;

% plot each step
plot_W_all = true;

% number of cells
N_in = 50;
N_out = 50;

% time resolution
total_ms = 2000;
dt_per_ms = 1000;

% time constants
tau_w = 250;
tau_out = 0.01;
tau_theta = 0.5;

% thresholds and learn rate
out_thres = 0.5;
W_thres = 0.15;

% parameters for events
L_portion = 0.7; H_portion = 1 - L_portion;
L_dur = 0.20; L_pct = [0.2 0.6];
H_dur = 0.05; H_pct = [0.8 1.0];

% if events are independent
% L_avg_period = 0.3;
% H_avg_period = 2.0;

%% independent

folder_name = sprintf('images/%s/vary_Lp_Hp_%s', datestr(now, 'mmmdd'), datestr(now, 'HHMM'));
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

L_p_vals = [0.1 0.3 0.5 0.7 0.9];
H_p_vals = [0.5 1.0 1.5 2.0 2.5 3.0];

summ = figure;
individual = figure;

plot_num = 0;

for L_p = L_p_vals
    for H_p = H_p_vals

        fprintf('Running L_p = %.1f H_p = %.1f \n', L_p, H_p);
        
        filename = sprintf('%s/independent_rates_Lp%d_Hp%d_Wthr%d_outthr%d_%s.png', ...
            folder_name, L_p * 10, H_p * 10, ...
            W_thres * 100, out_thres * 100, ...
            datestr(now, 'HHMM'));

        W = ...
        independent_rates(biased_W, bias, random_L_events, N_in, N_out, total_ms, dt_per_ms, ...
            out_thres, W_thres, L_p, H_p, ...
            L_dur, H_dur, L_pct, H_pct, ...
            tau_w, tau_out, tau_theta, ...
            filename, individual);
        
        plot_num = plot_num + 1;

        figure(summ);
        subplot(length(L_p_vals), length(H_p_vals), plot_num);
        colormap('hot');
        imagesc(W);
        title(sprintf('L_{period} = %.1f H_{period} = %.1f', L_p, H_p));
        caxis([0,0.2]); axis off;
    end
end

summ_filename = sprintf('%s/summary_Lp_Hp.png', folder_name);
figure(summ);
export_fig(summ_filename);


