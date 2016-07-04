M = biased_weights(N_out, NaN, 10, false);
M = M .* (1 - eye(N_out)) / 10;

[V,D] = eigs(M, 5);
M(1:20, 1:20)
D


% range = -2:0.01:5;
% plot(range, sigmoid(range, 5, 2.5, 5 / 8));

% W = zeros(N_in);
% 
% for i = 1 : 5
%     for j = 1 : N_in
%         W(j,mod(j + i - 1, N_in) + 1) = 0.5;
%         W(j,mod(j - i - 1, N_in) + 1) = 0.5;
%     end
% end
% 
% [V,D] = eigs(W, 5);
% W(1:10, 1:10)
% D
