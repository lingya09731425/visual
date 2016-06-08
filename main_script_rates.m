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
total_ms = 4000;
dt_per_ms = 1000;

% time constants
tau_w = 500;
tau_out = 0.01;
tau_theta = 0.5;

% thresholds
out_thres = 0.5;
W_thres = 0.20;
corr_thres = 0.4;

% parameters for events
L_portion = 0.7; H_portion = 1 - L_portion;
L_dur = 0.20; L_pct = [0.2 0.6];
H_dur = 0.05; H_pct = [0.8 1.0];
% L_avg_period = 0.3; H_avg_period = 2.0;

%% independent

folder_name = sprintf('images/%s/bcm_vary_Lp_Hp_10runs_%s', datestr(now, 'mmmdd'), datestr(now, 'HHMM'));
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

L_p_vals = [0.1 0.3 0.5 0.7 0.9];
H_p_vals = [Inf 0.5 1.0 1.5 2.0 2.5 3.0];
num_of_trials = 10;

for L_p = L_p_vals
    for H_p = H_p_vals

        all_W = zeros(N_out, N_in, num_of_trials);
        
        for trial = 1:num_of_trials
            fprintf('Running L_p = %.1f H_p = %.1f trial %d \n', L_p, H_p, trial);

            filename = sprintf('%s/independent_rates_Lp%d_Hp%d_Wthr%d_outthr%d_%s.png', ...
                folder_name, L_p * 10, H_p * 10, ...
                W_thres * 100, out_thres * 100, ...
                datestr(now, 'HHMM'));

            W = independent_rates(biased_W, bias, random_L_events, ...
                    N_in, N_out, total_ms, dt_per_ms, ...
                    out_thres, W_thres, corr_thres, L_p, H_p, ...
                    L_dur, H_dur, L_pct, H_pct, ...
                    tau_w, tau_out, tau_theta, ...
                    filename, NaN, false);
            
            all_W(:,:,trial) = W;
        end
        
        data_filename = sprintf('%s/weights_Lp%d_Hp%d.mat', folder_name, L_p * 10, H_p * 10);
        save(data_filename, 'all_W');
    end
end

