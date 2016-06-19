num_records = size(W_evo, 3);

w_up = NaN(50, num_records);
w_down = NaN(50, num_records);

cov = csvread('cov');
u = 0.04730429;
[V,~] = eigs(cov + u * (u - corr_thres), 5);

c1 = W_evo(:,:,1) * V(:,1);
c2 = W_evo(:,:,1) * V(:,2);

pot = c1 * V(:,1)' + c2 * V(:,2)' >= 0;
dep = ~pot;

for i = 1 : num_records
    up = W_evo(:,:,i); up(dep) = NaN;
    down = W_evo(:,:,i); down(pot) = NaN;
    
    w_up(:,i) = nanmean(up, 2);
    w_down(:,i) = nanmean(down, 2);
end

figure;
plot(w_up(1,:), w_down(1,:));
xlim([-0.1 0.1]); ylim([-0.1 0.1]);
hold on;
for i = 2 : 50
    plot(w_up(i,:), w_down(i,:));
end
plot(get(gca,'xlim'), [0 0]);
plot([0 0], get(gca,'ylim'));
plot([-1 1], [-1 1]);


bar_width = sum(W_evo(:,:,num_records) > 0.15, 2);
mean(bar_width(bar_width > 5))

