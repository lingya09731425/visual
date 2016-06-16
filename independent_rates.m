function W = independent_rates( ...
    type, ...
    bias, N_in, N_out, total_ms, dt_per_ms, ...
    out_thres, W_thres, corr_thres, ...
    L_avg_period, H_avg_period, L_dur, H_dur, L_pct, H_pct, ...
    tau_w, tau_out, tau_theta, ...
    filename)

    switch type
        case 'corr'
            type_id = 0;
        case 'bcm'
            type_id = 1;
        case 'adapt'
            type_id = 2;
        otherwise
            warning('unexpected type');
    end

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
    record_counter = 1;

    % record events and weights
    plot_W_freq = 100;
    L_active_pct = []; H_active_pct = [];
    L_active_rate = []; H_active_rate = [];
    
    num_of_records = round(total_ms / plot_W_freq) + 1;
    avg = zeros(1, num_of_records);
    avg(1) = mean(mean(W));
    W_all = zeros(N_out, N_in, num_of_records);
    W_all(:,:,1) = W;
    
    % for plotting
    figure;
    equi_t = 0.5 * total_ms * dt_per_ms;
    
    for t = 1 : total_ms * dt_per_ms

        if L_counter == 0
            L_length = round(N_in * (L_pct(1) + rand(1) * (L_pct(2) - L_pct(1))));
            L_start = randsample(N_in, 1);   

            in = zeros(N_in, 1);
            in(mod(L_start : L_start + L_length - 1, N_in) + 1) = 1;

            L_dur_counter = round(normrnd(L_dur, L_dur * 0.1) * dt_per_ms);
            L_counter = round(exprnd(L_avg_period * dt_per_ms)) + L_dur_counter;
            
            if t > equi_t
                record_event(W, in, out_spon);
            end
        end

        if H_counter == 0
            H_length = round(N_out * (H_pct(1) + rand(1) * (H_pct(2) - H_pct(1))));
            H_start = randsample(N_out, 1);
            
            out_spon = zeros(N_out, 1);
            out_spon(mod(H_start : H_start + H_length - 1, N_out) + 1) = normrnd(2, 0.5, H_length,1);
            if type_id == 2 % adapt
                out_spon = out_spon .* theta;
            end

            H_dur_counter = round(normrnd(H_dur, H_dur * 0.1) * dt_per_ms);
            H_counter = round(poissrnd(H_avg_period * dt_per_ms)) + H_dur_counter;
            
            if t > equi_t
                record_event(W, in, out_spon);
            end
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
        
        % record W
        if mod(t, plot_W_freq * dt_per_ms) == 0         
            record_counter = record_counter + 1;
            fprintf('completion %.2f %% \n', t / (total_ms * dt_per_ms) * 100); 
            
            avg(record_counter) = mean(mean(W));
            W_all(:,:,record_counter) = W;

            subplot(4, 6, [1,2,7,8]);
            colormap('hot');
            imagesc(W);
            colorbar; caxis([0,W_thres]);
            getframe;
        end
    end
    
    % plot end result
    subplot(4, 6, [1,2,7,8]);
    colormap('hot');
    imagesc(W);
    colorbar; caxis([0,W_thres]);

    % plot histogram for cortical cell activation
    subplot(4, 6, [3,4]);
    histogram(H_active_pct / N_out, 0:0.04:1);
    hold on; histogram(L_active_pct / N_out, 0:0.04:1);
    title('percent of cortical cells activated by events');
    legend('H', 'L');
    
   % average firing rate of activated cells   
    subplot(4, 6, [9,10]);
    histogram(H_active_rate, 0:0.05:3);
    hold on; histogram(L_active_rate, 0:0.05:3);
    title('average firing rate of activated cortical cells');
    legend('H', 'L');
    
    % plot all synaptic weights to a cortical cell
    for i = 1 : 4
        subplot(4, 6, 14 + i);
        plot(reshape(W_all(10 * i,:,:), N_in, size(W_all, 3))');
        ylim([0,W_thres]); xlim([0,num_of_records]);
        title(sprintf('all synapses to CORTICAL cell #%d', 10 * i));
    end

    % plot all synaptic weights from a retina cell
    for i = 1 : 4
        subplot(4, 6, 20 + i);
        plot(reshape(W_all(:, 10 * i,:), N_in, size(W_all, 3))');
        ylim([0,W_thres]); xlim([0,num_of_records]);
        title(sprintf('all synapses from RETINAL cell #%d', 10 * i));
    end

    % plot the progression of the average weight
    subplot(4, 6, [13,14]);
    plot(1 : num_of_records, avg);
    title('average weight v.s. t');

    % add notations
    s = subplot(4, 6, [19,20]); set(s, 'visible', 'off');
    text(0.1, 1.0, sprintf('total run time = %d ms', total_ms));
    text(0.5, 1.0, sprintf('dt per ms = %d', dt_per_ms));
    
    text(0.1, 0.8, sprintf('L period = %.2f ms', L_avg_period));
    text(0.5, 0.8, sprintf('H period = %.2f ms', H_avg_period));
    text(0.1, 0.7, sprintf('L dur = %.2f ms', L_dur));
    text(0.5, 0.7, sprintf('H dur = %.2f ms', H_dur));
    text(0.1, 0.6, sprintf('L pct = %.2f - %.2f', L_pct(1), L_pct(2)));
    text(0.5, 0.6, sprintf('H pct = %.2f - %.2f', H_pct(1), H_pct(2)));
    
    text(0.1, 0.4, sprintf('tau w = %.2f', tau_w));
    text(0.1, 0.3, sprintf('tau out = %.2f', tau_out));
    text(0.1, 0.2, sprintf('tau theta = %.2f', tau_theta));
    
    text(0.5, 0.4, sprintf('W thres = %.2f', W_thres));
    text(0.5, 0.3, sprintf('out thres = %.2f', out_thres));
    text(0.5, 0.2, sprintf('corr thres = %.2f', corr_thres));
    
    text(0.1, 0.0, sprintf('biased weights (max = %.4f)', bias));

    % save figure
    export_fig(filename);    
    
    % helper function: record event
    function record_event(W, in, out_spon)
        equi_out = W * in + out_spon;
        active_out = equi_out > out_thres;
        active_rate = mean(equi_out(active_out));

        if sum(active_out) < 0.8 * N_out
            L_active_pct = [L_active_pct sum(active_out)];
            L_active_rate = [L_active_rate active_rate];
        else
            H_active_pct = [H_active_pct sum(active_out)];
            H_active_rate = [H_active_rate active_rate];
        end
    end    
end

