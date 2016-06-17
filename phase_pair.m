figure;

for i = 2 : 11
    subplot(2, 5, i - 1);
    plot(squeeze(W_evo(1,1,:)), squeeze(W_evo(1,i,:))); hold on;
    xlim([-0.05 0.05]); ylim([-0.05 0.05]);
    for j = 2 : 50
        plot(squeeze(W_evo(j,1,:)), squeeze(W_evo(j,i,:)));
    end
end
	

