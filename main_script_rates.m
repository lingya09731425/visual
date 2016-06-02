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
L_avg_period = 0.5;
H_avg_period = 2.0;

%% independent

folder_name = sprintf('images/%s', datestr(now, 'mmmdd'));
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end

filename = sprintf('%s/independent_rates_Ld%d_Hd%d_Wthr%d_outthr%d_%s.png', ...
    folder_name, L_dur * 1000, H_dur * 1000, ...
    W_thres * 100, out_thres * 100, ...
    datestr(now, 'HHMM'));

independent_rates(biased_W, bias, random_L_events, N_in, N_out, total_ms, dt_per_ms, ...
    out_thres, W_thres, L_avg_period, H_avg_period, ...
    L_dur, H_dur, L_pct, H_pct, ...
    tau_w, tau_out, tau_theta, ...
    filename, plot_W_all)

