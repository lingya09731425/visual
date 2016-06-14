clear; close all;

% LR type
type = 'corr';

switch type
    case 'corr'
        type_id = 0;
    case 'bcm'
        type_id = 1;
    case 'adapt'
        type_id = 2;
end

% number of cells
N_in = 50; N_out = 50;

% bias
bias = 0.02;

% time resolution
total_ms = 2;
dt_per_ms = 1000;

% time constants
tau_w = 250;
tau_out = 0.01;
tau_theta = 0.5;

% thresholds
out_thres = 0.05;
W_thres = 0.4;
corr_thres = 0.4;

% parameters for events
L_dur = 0.20; L_pct = [0.2 0.6];
H_dur = 0.05; H_pct = [0.8 1.0];

% file naming
folder_name = sprintf('images/%s/%s_vary_Lp_Hp_%s', ...
    datestr(now, 'mmmdd'), type, datestr(now, 'HHMM'));
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

% run all combinations
L_p_vals = [0.1 0.3 0.5 0.7 0.9];
H_p_vals = [Inf 0.5 1.0 1.5 2.0 2.5 3.0];
num_of_trials = 5;

for L_p = L_p_vals
    for H_p = H_p_vals
        fprintf('Running L_p = %.1f H_p = %.1f \n', L_p, H_p);
        
        all_W = zeros(N_out, N_in, num_of_trials);
        
        for trial = 1:num_of_trials
            fprintf('--- trial %d \n', trial);

            W = independent_rates( ...
                    type_id, ...
                    bias, N_in, N_out, total_ms, dt_per_ms, ...
                    out_thres, W_thres, corr_thres, ...
                    L_p, H_p, L_dur, H_dur, L_pct, H_pct, ...
                    tau_w, tau_out, tau_theta);
            
            all_W(:,:,trial) = W;
        end
        
        data_filename = sprintf('%s/weights_Lp%d_Hp%d.mat', folder_name, L_p * 10, H_p * 10);
        save(data_filename, 'all_W');
    end
end

