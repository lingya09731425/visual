clear; close all;

% LR type: corr, bcm, adapt, oja
type = 'bcm';

% number of cells
N_in = 50; N_out = 50;

% bias
bias = 0.02;

% time resolution
total_ms = 20000;
dt_per_ms = 1000;

% time constants
tau_w = 500;
tau_out = 0.01;
tau_theta = 10;

% thresholds
out_thres = 0.05;
W_thres = [0.0 0.3]; bounded = true;
corr_thres = 0;

% parameters for events
L_p = 1.5; L_dur = 0.10; L_pct = [0.2 0.6];
H_p = Inf; H_dur = 0.20; H_pct = [0.8 1.0];
H_amp = 2.0;

% file naming
folder_name = sprintf('images/%s', datestr(now, 'mmmdd'));
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

subfolder_name = sprintf(['%s/%s_%s_bias%.2f_' ...
    'Ld%.2f_Hd%.2f_Lp%.2f_Hp%.2f_Hamp%.2f_' ...
    'Tw%.2f_Tout%.2f_Ttheta%.2f_' ...
    'outthr%.2f_Wthr%.2f_corrthr%.2f'], ...
    folder_name, datestr(now, 'HHMM'), type, bias, ...
    L_dur, H_dur, ...
    L_p, H_p, ...
    H_amp, ...
    tau_w, tau_out, tau_theta, ...
    out_thres, W_thres(2), corr_thres);
if ~exist(subfolder_name, 'dir')
    mkdir(subfolder_name)
end

summary_name = sprintf('%s/summary.png', subfolder_name);
weights_name = sprintf('%s/weights.mat', subfolder_name);
weights_sparse_name = sprintf('%s/weights_sparse.mat', subfolder_name);
output_name = sprintf('%s/output.mat', subfolder_name);
theta_name = sprintf('%s/theta.mat', subfolder_name);
eventlog = fopen(sprintf('%s/eventlog.txt', subfolder_name), 'w');
 
[record_times,record_W,record_output,record_theta,plot_times,plot_W] = ...
    independent_rates( ...
        type, ...
        bias, N_in, N_out, total_ms, dt_per_ms, ...
        out_thres, W_thres, bounded, corr_thres, ...
        L_p, H_p, L_dur, H_dur, L_pct, H_pct, H_amp, ...
        tau_w, tau_out, tau_theta, ...
        summary_name, eventlog);

save(weights_name, 'record_W', 'record_times', '-v7.3');
save(weights_sparse_name, 'plot_W', 'plot_times');
save(output_name, 'record_output', 'record_times');
save(theta_name, 'record_theta', 'record_times');
 
fclose(eventlog);
        
        
        
