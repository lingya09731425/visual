figure;

active_pct = sum(record_output > 1000);
% plot(record_times, active_pct);

out_sig = double(record_output);
out_sig(out_sig < 1000) = NaN;
hold on;
out_mean = nanmean(out_sig) / 1000;
out_mean(isnan(out_mean)) = 0;
plot(record_times, out_mean);
hold on;
out_std = nanstd(out_sig) / 1000;
out_std(isnan(out_std)) = 0;
plot(record_times, out_std);