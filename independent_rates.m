function independent_rates(biased_W, bias, random_L_events, ...
    N_in, N_out, total_ms, dt_per_ms, ...
    H_on, out_thres, W_thres, ...
    L_avg_period, H_avg_period, ...
    L_dur, H_dur, L_pct, H_pct, ...
    tau_w, tau_out, tau_theta, ...
    filename, plot_W_all)

    plot_W_freq = 5;
    record_W = true;
    
    dt = 1 / dt_per_ms;

    % preallocated record storage for whole-connectome avg
    num_of_records = round(total_ms / plot_W_freq) + 1;
    avg = zeros(1, num_of_records);

    % initialize weights
    W = biased_W * biased_weights(N_in, bias) + (~biased_W) * (rand(N_out, N_in) / 20);
    
    avg(1) = mean(mean(W));
    if record_W
        W_all = zeros(N_out, N_in, num_of_records);
        W_all(:,:,1) = W;
    end

    % initialize activities
    in = zeros(N_in, 1);
    out = zeros(N_out, 1);
    out_spon = zeros(N_out, 1);
    theta = zeros(N_out, 1);

    % initialize counters
    L_counter = round(exprnd(L_avg_period * dt_per_ms)) + 1;
    H_counter = H_on * (round(poissrnd(H_avg_period * dt_per_ms)) + 1) + (~H_on) * (-1);
    L_dur_counter = 0; H_dur_counter = 0;
    record_counter = 1; L_start = 1;

    % record event centers and cortical-cells activation pct
    L_centers = []; H_centers = [];
    L_active_pct = []; H_active_pct = [];
    L_active_rate = []; H_active_rate = [];
    L_times = []; H_times = [];

    figure;
    
    % after this time, assume selectivity is at equilibrium
    equi_t = 0.5 * total_ms * dt_per_ms;
    
    for t = 1 : total_ms * dt_per_ms

        if L_counter == 0
            L_length = 20;
            L_start = mod(L_start + 10, N_out);

            if random_L_events
                L_length = round(N_in * (L_pct(1) + rand(1) * (L_pct(2) - L_pct(1))));
                L_start = randsample(N_in, 1);
            end    

            in = zeros(N_in, 1);
            in(mod(L_start : L_start + L_length - 1, N_in) + 1) = 1;

            center = mod(L_start + round(L_length / 2), N_in);
            L_centers = [L_centers center];
            L_times = [L_times t];
            
            if t > equi_t
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

            L_dur_counter = round(normrnd(L_dur, L_dur * 0.1) * dt_per_ms);
            L_counter = round(exprnd(L_avg_period * dt_per_ms)) + L_dur_counter;
            
            % fprintf('*** L *** t = %d l = %d \n', t, L_dur_counter);
        end

        if H_counter == 0
            H_length = round(N_out * (H_pct(1) + rand(1) * (H_pct(2) - H_pct(1))));
            H_start = randsample(N_out, 1);
            
            out_spon = zeros(N_out, 1);
            out_spon(mod(H_start : H_start + H_length - 1, N_out) + 1) = normrnd(3, 0.5, H_length,1);
            
            center = mod(H_start + round(H_length / 2), N_out);
            H_centers = [H_centers center];
            H_times = [H_times t];
            
            if t > equi_t
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

            H_dur_counter = round(normrnd(H_dur, H_dur * 0.1) * dt_per_ms);
            H_counter = round(poissrnd(H_avg_period * dt_per_ms)) + H_dur_counter;
                        
            % fprintf('*** H *** t = %d l = %d \n', t, H_dur_counter);
        end

        % output vector
        out = out + (dt / tau_out) * (-out + out_spon + W * in);
        
        % LR-simple-thresholded: dWyx = y * (x - 0.4)
        % dW = (dt / tau_w) * out * (in - 0.4)';
        
        % LR-Oja's: dWyx = y * (x - y * w)
        dW = (dt / tau_w) * (out * ones(1, N_in)) .* (ones(N_out, 1) * in' - 5 * (out * ones(1, N_in)) .* W);
        
        % LR-BCM: dWyx = y * x * (y - theta)
        % dW = (dt / tau_w) * (out .* (out - theta)) * in';
        % theta = theta + (dt / tau_theta) * (- theta + out .^ 2);
        
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
            if record_W
                W_all(:,:,record_counter) = W;
            end

            if plot_W_all
                subplot(4, 6, [1,2,7,8]);
                colormap('hot');
                imagesc(W);
                colorbar; caxis([0,0.2]);
                getframe;
            end
        end
    end

    %% plot end result

    subplot(4, 6, [1,2,7,8]);
    colormap('hot');
    imagesc(W);
    colorbar; caxis([0,0.2]);

    %% plot histogram for cortical cell activation

    subplot(4, 6, [3,4]);
    histogram(H_active_pct / N_out, 0:0.04:1);
    title('percent of cortical cells activated by events');
    hold on;
    histogram(L_active_pct / N_out, 0:0.04:1);
    legend('H', 'L');
    
    
   %% average firing rate of activated cells
   
    subplot(4, 6, [9,10]);
    histogram(H_active_rate, 0:0.05:3);
    title('average firing rate of activated cortical cells');
    hold on;
    histogram(L_active_rate, 0:0.05:3);
    legend('H', 'L');

    %% plot centers for first events

    subplot(4, 6, [5,6,11,12]);
    max_t = 50000;
    scatter(L_times(L_times < max_t) / dt_per_ms, L_centers(L_times < max_t), 'filled', 'r');
    title('location of centers in initial events');
    hold on;
    scatter(H_times(H_times < max_t) / dt_per_ms, H_centers(H_times < max_t), 'filled', 'b');
    legend('L', 'H');

    %% plot all synaptic weights to a cortical cell

    if record_W
        for i = 1 : 4
            subplot(4, 6, 14 + i);
            plot(reshape(W_all(10 * i,:,:), N_in, size(W_all, 3))');
            ylim([0,0.25]); xlim([0,total_ms / plot_W_freq]);
            title(sprintf('all synapses to CORTICAL cell #%d', 10 * i));
        end
    end

    %% plot all synaptic weights from a retina cell

    if record_W
        for i = 1 : 4
            subplot(4, 6, 20 + i);
            plot(reshape(W_all(:, 10 * i,:), N_in, size(W_all, 3))');
            ylim([0,0.25]); xlim([0,total_ms / plot_W_freq]);
            title(sprintf('all synapses from RETINAL cell #%d', 10 * i));
        end
    end

    %% plot the progression of the average weight

    subplot(4, 6, [13,14]);
    plot(1 : num_of_records, avg);
    title('average weight v.s. t');

    %% add notations

    s = subplot(4, 6, [19,20]); set(s, 'visible', 'off');
    text(0.1, 1, sprintf('total run time = %d ms', total_ms));
    text(0.5, 1, sprintf('dt per ms = %d', dt_per_ms));
    text(0.1, 0.8, sprintf('L period = %.3f ms', L_avg_period));
    text(0.5, 0.8, sprintf('H period = %.3f ms', H_avg_period));
    text(0.1, 0.7, sprintf('L dur = %.3f ms', L_dur));
    text(0.5, 0.7, sprintf('H dur = %.3f ms', H_dur));
    text(0.1, 0.6, sprintf('L pct = %.2f - %.2f', L_pct(1), L_pct(2)));
    text(0.5, 0.6, sprintf('H pct = %.2f - %.2f', H_pct(1), H_pct(2)));
    text(0.1, 0.4, sprintf('tau w = %.3f', tau_w));
    text(0.5, 0.4, sprintf('tau out = %.3f', tau_out));
    text(0.1, 0.3, sprintf('W thres = %.2f', W_thres));
    text(0.5, 0.3, sprintf('out thres = %.2f', out_thres));
    text(0.1, 0, 'INDEPENDENT POISSON EVENTS');
    if biased_W
        text(0.1, 0.1, sprintf('biased weights (max = %.4f)', bias));
    end
    if ~random_L_events
        text(0.5, 0.1, 'sequential L events');
    end

    %% save figure
    export_fig(filename);

end

