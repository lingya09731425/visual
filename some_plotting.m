active_pct = sum(record_output > 1000);
plot(active_pct);

out_sig = record_output;
out_sig(out_sig < 1000) = NaN;
hold on;
plot(nanmean(out_sig) / 1000);
