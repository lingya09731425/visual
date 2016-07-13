function s = sigmoid(x, amp, x_theta, g)
    s = amp ./ (1 + exp(-(x - x_theta) ./ g));
    s = s - amp ./ (1 + exp(x_theta ./ g));
end