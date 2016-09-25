plot([-20 10], [0 0], 'k', 'LineWidth', 2); hold on;
plot([0 0], [-20 1000], 'k', 'LineWidth', 2);
xlim([-1 15]); ylim([-20 50]);

[x,y] = fplot(@(x) x * (x - 5), [-1 20]);
l1 = plot(x, y, 'LineWidth', 2);
[x,y] = fplot(@(x) x * (x - 3), [-1 20]);
l2 = plot(x, y, 'LineWidth', 2);
[x,y] = fplot(@(x) x * (x - 7), [-1 20]);
l3 = plot(x, y, 'LineWidth', 2);

set(gca, 'Xtick', [], 'Ytick', []);
set(gca, 'Visible', 'off', 'box', 'off');

c1 = get(l1, 'Color');
c2 = get(l2, 'Color');
c3 = get(l3, 'Color');

figure;
subplot(3,1,2);
plot([-20 10], [0 0], 'k', 'LineWidth', 2); hold on;
plot([0 0], [-20 1000], 'k', 'LineWidth', 2);
xlim([-1 15]); ylim([-20 50]);
[x,y] = fplot(@(x) x * (x - 5), [-1 20]);
plot(x, y, 'Color', c1, 'LineWidth', 2);
set(gca, 'Xtick', [], 'Ytick', []);
set(gca, 'Visible', 'off', 'box', 'off');

subplot(3,1,1);
plot([-20 10], [0 0], 'k', 'LineWidth', 2); hold on;
plot([0 0], [-20 1000], 'k', 'LineWidth', 2);
xlim([-1 15]); ylim([-20 50]);
[x,y] = fplot(@(x) x * (x - 3), [-1 20]);
plot(x, y, 'Color', c2, 'LineWidth', 2);
set(gca, 'Xtick', [], 'Ytick', []);
set(gca, 'Visible', 'off', 'box', 'off');

subplot(3,1,3);
plot([-20 10], [0 0], 'k', 'LineWidth', 2); hold on;
plot([0 0], [-20 1000], 'k', 'LineWidth', 2);
xlim([-1 15]); ylim([-20 50]);
[x,y] = fplot(@(x) x * (x - 7), [-1 20]);
plot(x, y, 'Color', c3, 'LineWidth', 2);
set(gca, 'Xtick', [], 'Ytick', []);
set(gca, 'Visible', 'off', 'box', 'off');
