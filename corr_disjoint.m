% LR type / run purpose
type = 'corr';
note = 'disjointLH';

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
corr_thres = 0.4;

% parameters for events
L_dur = 0.20;
H_dur = 0.05;

% combinations
L_p_vals = [1.0 1.5 2.0 2.5 3.0];
H_p_vals = [5 10 15 20 25 Inf];
num_of_trials = 5;

% run all combinations
main_script_rates;