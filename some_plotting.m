figure;

active_pct = sum(record_output > 1000);
plot(record_times, active_pct);

out_sig = record_output;
out_sig(out_sig < 1000) = NaN;
hold on;
plot(record_times, nanmean(out_sig) / 1000);
