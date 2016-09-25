% figure -- example_withoutH

figure; set(gcf,'color','white');

subplot(2,2,1);
colormap('hot');
imagesc(double(plot_W(:,:,1)) / 1000);
colorbar; caxis([0,1]);
xlabel('retina'); ylabel('cortex');

subplot(2,2,2);
colormap('hot');
imagesc(double(plot_W(:,:, (size(plot_W,3) - 1) * 4 / 5)) / 1000);
colorbar;
xlabel('retina'); ylabel('cortex');

subplot(2,2,3);
extracted = reshape(double(plot_W(50,:,:))/1000, [N_in,size(plot_W,3)]);
plot(plot_times', extracted');
xlim([0,max(plot_times) * 0.8]);
xlabel('time'); ylabel('W_{50,i}');

subplot(2,2,4);
extracted = reshape(double(plot_W(31,:,:))/1000, [N_in,size(plot_W,3)]);
plot(plot_times', extracted');
xlim([0,max(plot_times) * 0.8]);
xlabel('time'); ylabel('W_{31,i}');

%% figure -- bias_explain

figure; set(gcf,'color','white');
plot_end(plot_W);

figure;
subplot(1,3,1);
plot_heat(biased_weights(50, [0.15 0.25], 0, 4), [0 0.5]);

subplot(1,3,2);
plot_heat(biased_weights(50, [0 0], 0.05, 4), [0 0.5]); 

subplot(1,3,3);
plot_heat(biased_weights(50, [0.15 0.25], 0.05, 4), [0 0.5]); 


%% figure -- example

figure;
plot_end(plot_W);

figure;

for i = 1 : 4
    subplot(2, 2, i);
    colormap('hot');
    extracted = reshape(double(plot_W(10 * i,:,:)) / 1000, [N_in, size(plot_W,3)]);
    imagesc(extracted);
    caxis([0,0.4]);
    xlabel('time'); ylabel(sprintf('W_{%d,i}', 10 * i));
    title(sprintf('cortical cell #%d', 10 * i))
end


figure;
active_pct = sum(record_output > 1000);
out_sig = record_output;
out_sig(out_sig < 1000) = NaN;
[hAx,hLine1,hLine2] = ...
    plotyy(record_times, active_pct, record_times, nanmean(out_sig) / 1000, 'plot');
xlabel('time');
ylabel(hAx(1), '# of active cortical cells');
ylabel(hAx(2), 'avg. rate of active cortical cells');
ylim(hAx(1), [0 50]);


figure;
histogram(H_active_rate, 0:0.1:8);
hold on; histogram(L_active_rate, 0:0.1:8);
xlabel('avg. rate of active cortical cells');
ylabel('count');
legend('high-part. events', 'low-part. events');
















