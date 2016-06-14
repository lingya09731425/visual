% LR type / run purpose
type = 'corr';
note = 'tune';

% bias
bias = 0.02;

% time course
total_ms = @(L_p) 5000 + 2000 * L_p;

% time constants
tau_w = 250;
tau_out = 0.01;
tau_theta = 0.5;

% thresholds
out_thres = 0.05;
W_thres = 0.4;

% parameters for events
L_dur = 0.20;
H_dur = 0.20;

% combinations
L_p = 2.0;
H_p_vals = [1.0 2.0 3.0 4.0 5.0 6.0 Inf];
corr_thres_vals = [0.05 0.10 0.15 0.20 0.25 0.30 0.35];
num_of_trials = 1;

% rarely-changed parameters
N_in = 50; N_out = 50;
dt_per_ms = 1000;
L_pct = [0.2 0.6];
H_pct = [0.8 1.0];

% file naming
folder_name = sprintf('images/%s/%s_%s_%s', ...
    datestr(now, 'mmmdd'), type, note, datestr(now, 'HHMM'));
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

% run all combinations
for H_p = H_p_vals
    for corr_thres = corr_thres_vals
        fprintf('Running H_p = %.1f corr_thres = %.2f \n', H_p, corr_thres);
        
        all_W = zeros(N_out, N_in, num_of_trials);
        
        for trial = 1:num_of_trials
            fprintf('--- trial %d \n', trial);

            W = independent_rates( ...
                    type, ...
                    bias, N_in, N_out, total_ms(L_p), dt_per_ms, ...
                    out_thres, W_thres, corr_thres, ...
                    L_p, H_p, L_dur, H_dur, L_pct, H_pct, ...
                    tau_w, tau_out, tau_theta);
            
            all_W(:,:,trial) = W;
        end
        
        data_filename = sprintf('%s/weights_Hp%d_corr%d.mat', folder_name, H_p * 10, corr_thres * 100);
        save(data_filename, 'all_W');
    end
end

