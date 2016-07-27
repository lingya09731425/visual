% figure;

H_amp = 5;
target = sigmoid(-10 : 0.01: 10, H_amp, 4, H_amp / 8);
plot(-10 : 0.01: 10, target);