figure; plot_end(plot_W, [0 0.4]);

figure;
extracted = reshape(double(plot_W(2,:,:))/1000, [N_in,size(plot_W,3)]);
plot(plot_times', extracted');
xlabel('time'); ylabel('weight');