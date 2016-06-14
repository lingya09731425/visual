function W = independent_rates( ...
    type_id, ...
    bias, N_in, N_out, total_ms, dt_per_ms, ...
    out_thres, W_thres, corr_thres, ...
    L_avg_period, H_avg_period, L_dur, H_dur, L_pct, H_pct, ...
    tau_w, tau_out, tau_theta)

    dt = 1 / dt_per_ms;

    % initialize weights
    W = biased_weights(N_in, bias);
    
    % initialize activities
    in = zeros(N_in, 1);
    out = zeros(N_out, 1);
    out_spon = zeros(N_out, 1);
    theta = zeros(N_out, 1);

    % initialize counters
    L_counter = round(exprnd(L_avg_period * dt_per_ms)) + 1;
    H_counter = isinf(H_avg_period) * (-1) + ...
        ~isinf(H_avg_period) * (round(poissrnd(H_avg_period * dt_per_ms)) + 1);
    L_dur_counter = 0; H_dur_counter = 0;

    for t = 1 : total_ms * dt_per_ms

        if L_counter == 0
            L_length = round(N_in * (L_pct(1) + rand(1) * (L_pct(2) - L_pct(1))));
            L_start = randsample(N_in, 1);   

            in = zeros(N_in, 1);
            in(mod(L_start : L_start + L_length - 1, N_in) + 1) = 1;

            L_dur_counter = round(normrnd(L_dur, L_dur * 0.1) * dt_per_ms);
            L_counter = round(exprnd(L_avg_period * dt_per_ms)) + L_dur_counter;
        end

        if H_counter == 0
            H_length = round(N_out * (H_pct(1) + rand(1) * (H_pct(2) - H_pct(1))));
            H_start = randsample(N_out, 1);
            
            out_spon = zeros(N_out, 1);
            out_spon(mod(H_start : H_start + H_length - 1, N_out) + 1) = normrnd(2, 0.5, H_length,1);

            H_dur_counter = round(normrnd(H_dur, H_dur * 0.1) * dt_per_ms);
            H_counter = round(poissrnd(H_avg_period * dt_per_ms)) + H_dur_counter;
        end

        % output vector
        out = out + (dt / tau_out) * (-out + out_spon + W * in);
        
        switch type_id
            case 0 % corr
                dW = (dt / tau_w) * out * (in - corr_thres)';
                
            case 1 % bcm
                dW = (dt / tau_w) * (out .* (out - theta)) * (in - corr_thres)';
                fix = double(out < theta) * double(in < corr_thres)';                                                                                                        
                dW = dW .* (1 - fix);                                                                                                                                        
                theta = theta + (dt / tau_theta) * (- theta + out .^ 2);
                
            case 2 % adapt
                dW = (dt / tau_w) * out * (in - corr_thres)';                                                                                                                       
                theta = theta + (dt / tau_theta) * (- theta + out .^ 2);
        end
        
        % update weight matrix
        W = W + dW;
        W(W < 0) = 0;
        W(W > W_thres) = W_thres;

        % counter operations
        L_counter = L_counter - 1;
        H_counter = H_counter - 1;
        L_dur_counter = L_dur_counter -1;
        H_dur_counter = H_dur_counter -1;
        
        if L_dur_counter == 0
            in = zeros(N_in, 1);
        end
        if H_dur_counter == 0
            out_spon = zeros(N_out, 1);
        end
    end
end

