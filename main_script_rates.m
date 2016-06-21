clear; close all;

% LR type: corr, bcm, adapt, oja
type = 'bcm';

% number of cells
N_in = 50; N_out = 50;

% bias
bias = 0.02;

% time resolution
total_ms = 10000;
dt_per_ms = 1000;

% time constants
tau_w = 250;
tau_out = 0.01;
tau_theta = 10;

% thresholds
out_thres = 0.05;
W_thres = [0.0 0.4]; bounded = true;
corr_thres = 0;

% parameters for events
L_p = 1.5; L_dur = 0.10; L_pct = [0.2 0.6];
H_p = Inf; H_dur = 0.20; H_pct = [0.8 1.0];
H_rate = 2.0;

% file naming
folder_name = sprintf('images/%s', datestr(now, 'mmmdd'));
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

filename = sprintf('%s/%s_Ld%d_Hd%d_Lp%d_Hp%d_%s.png', ...
    folder_name, type, ...
    L_dur * 1000, H_dur * 1000, ...
    L_p * 1000, H_p * 1000, ...
    datestr(now, 'HHMM'));

W_evo = independent_rates( ...
            type, ...
            bias, N_in, N_out, total_ms, dt_per_ms, ...
            out_thres, W_thres, bounded, corr_thres, ...
            L_p, H_p, L_dur, H_dur, L_pct, H_pct, H_rate, ...
            tau_w, tau_out, tau_theta, ...
            filename);

% phase;
        
        
        
