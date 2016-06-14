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
for L_p = L_p_vals
    for H_p = H_p_vals
        fprintf('Running L_p = %.1f H_p = %.1f \n', L_p, H_p);
        
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
        
        data_filename = sprintf('%s/weights_Lp%d_Hp%d.mat', folder_name, L_p * 10, H_p * 10);
        save(data_filename, 'all_W');
    end
end

