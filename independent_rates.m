function [W_all, out_all] = independent_rates( ...
    type, ...
    bias, N_in, N_out, total_ms, dt_per_ms, ...
    out_thres, W_thres, bounded, corr_thres, pot_dep_ratio, ...
    L_p, H_p, L_dur, H_dur, L_pct, H_pct, H_rate, ...
    tau_w, tau_out, tau_theta, ...
    filename, logfile)

    switch type
        case 'corr'
            type_id = 0;
        case 'bcm'
            type_id = 1;
        case 'adapt'
            type_id = 2;
        case 'oja'
            type_id = 3;
        otherwise
            warning('unexpected type');
    end

    dt = 1 / dt_per_ms;
    
    % initialize weights
    W = biased_weights(N_in, bias, 2, true) * 2;
    M = biased_weights(N_out, NaN, 10, false);
    M = M .* (1 - eye(N_out)) / 20;
    
    % initialize activities
    in = zeros(N_in, 1);
    out = zeros(N_out, 1);
    out_spon = zeros(N_out, 1);
    theta = zeros(N_out, 1);

    % initialize counters
    L_counter = round(exprnd(L_p * dt_per_ms)) + 1;
    L_dur_counter = 0;
    
    intrin_counter = round(exprnd(H_p * dt_per_ms, 1, N_out)) + 1;
    intrin_dur_counter = zeros(1, N_out);

    % record events, weights and output vectors
    L_active_pct = []; H_active_pct = [];
    L_active_rate = []; H_active_rate = [];
    
    plot_W_freq = 50;
    record_out_freq = 0.01;
    num_of_records = round(total_ms / plot_W_freq) + 1;
    equi_t = 0.5 * total_ms;
    
    avg = zeros(1, num_of_records);
    avg(1) = mean(mean(W));
    W_all = zeros(N_out, N_in, num_of_records);
    W_all(:,:,1) = W;
    
    out_all = zeros((total_ms - equi_t) / record_out_freq, N_out);
    
    % for plotting
    figure;
    
    for t = 1 : total_ms * dt_per_ms

        % L event
        if ~isinf(L_p) && L_counter == 0
            L_length = round(N_in * (L_pct(1) + rand(1) * (L_pct(2) - L_pct(1))));
            L_start = randsample(N_in, 1);

            in = zeros(N_in, 1);
            in(mod(L_start : L_start + L_length - 1, N_in) + 1) = 1;

            L_dur_counter = round(normrnd(L_dur, L_dur * 0.1) * dt_per_ms);
            L_counter = round(exprnd(L_p * dt_per_ms)) + L_dur_counter;
            
            if t > equi_t * dt_per_ms
                record_event(W, in, out_spon, true);
            end
            
            fprintf(logfile, '*** L event center = %d ***\n', ...
                mod(L_start + round(L_length / 2), N_in));
        end
        
        % intrinsic firing
        if ~isinf(H_p)
            fire = intrin_counter == 0;
            num_of_fire = sum(fire);
            if num_of_fire > 0
                fprintf(logfile, 'intrinsic: ');
                fprintf(logfile, '%d ', find(fire));
                fprintf(logfile, '\n');
                out_spon(fire) = H_rate;

                intrin_dur_counter(fire) = round(normrnd(H_dur, H_dur * 0.1, 1, num_of_fire) * dt_per_ms);
                intrin_counter(fire) = round(exprnd(H_p * dt_per_ms, 1, num_of_fire)) + ...
                    intrin_dur_counter(fire);
            end
        end

        % adaptive/intrinsic firing in cortical cells
        % out_spon = normrnd(H_rate, H_rate * 0.1, N_out, 1) .* theta;
                
        % output vector
        forward = W * in;
        recur_intrin = out_spon + M * out;
        % target = forward + recur_intrin;
        target = sigmoid(forward + recur_intrin, H_rate, H_rate / 2, H_rate / 8);
        out = out + (dt / tau_out) * (-out + target);
                
        if mod(t, record_out_freq * dt_per_ms) == 0
            fprintf(logfile, '%.3f ', out);
            fprintf(logfile, '\n');
            fprintf(logfile, 'forward = %.3f else = %.4f active = %d \n', ...
                mean(forward), mean(recur_intrin), sum(out > out_thres));
            
            if t > equi_t * dt_per_ms
                ind = round((t / dt_per_ms - equi_t) / record_out_freq);
                out_all(ind,:) = out';
            end
        end
        
        switch type_id
            case 0 % corr
                dW = (dt / tau_w) * out * (in - corr_thres)';
                
            case 1 % bcm
                dW = (dt / tau_w) * (out .* (out - theta)) * (in - corr_thres)';
                fix = double(out < theta) * double(in < corr_thres)';                                                                                                        
                dW = dW .* (1 - fix);                                                                                                                                        
                theta = theta + (dt / tau_theta) * (-theta + out .^ 2);
                
            case 2 % adapt
                dW = (dt / tau_w) * out * (in - corr_thres)';                                                                                                                       
                theta = theta + (dt / tau_theta) * (-theta + out .^ 2);
                
            case 3 % oja
                dW = (dt / tau_w) * (out * ones(1, N_in)) .* (ones(N_out, 1) * in' ...
                    - (out * ones(1, N_in)) .* W);
        end
        
        % update weight matrix
        dW(dW < 0) = dW(dW < 0) / pot_dep_ratio;
        W = W + dW;
        
        if bounded
            W(W < W_thres(1)) = W_thres(1);
            W(W > W_thres(2)) = W_thres(2);
        end
            
        % counter operations
        L_counter = L_counter - 1;
        L_dur_counter = L_dur_counter -1;
        intrin_counter = intrin_counter - 1;
        intrin_dur_counter = intrin_dur_counter -1;
        
        if L_dur_counter == 0
            in = zeros(N_in, 1);
        end
        
        out_spon(intrin_dur_counter == 0) = 0;
        
        % record W
        if mod(t, plot_W_freq * dt_per_ms) == 0         
            fprintf('completion %.2f %% \n', t / (total_ms * dt_per_ms) * 100);
            
            rc = t / (plot_W_freq * dt_per_ms) + 1;
            avg(rc) = mean(mean(W));
            W_all(:,:,rc) = W;

            subplot(4, 6, [1,2,7,8]);
            colormap('hot');
            imagesc(W);
            colorbar; caxis(W_thres);
            getframe;
            
            if all(all(round(W, 2) == W_thres(1))) || ...
                    all(all(round(W, 2) == W_thres(2)))
                fprintf('termination: all lit or all died \n');
                break;
            end
        end
    end
    
    % plot end result
    subplot(4, 6, [1,2,7,8]);
    colormap('hot');
    imagesc(W);
    colorbar; caxis(W_thres);

    % plot histogram for cortical cell activation
    subplot(4, 6, [3,4]);
    histogram(H_active_pct / N_out, 0:0.04:1);
    hold on; histogram(L_active_pct / N_out, 0:0.04:1);
    title('percent of cortical cells activated by events');
    legend('H', 'L');
    
   % average firing rate of activated cells   
    subplot(4, 6, [9,10]);
    histogram(H_active_rate, 0:0.05:5);
    hold on; histogram(L_active_rate, 0:0.05:5);
    title('average firing rate of activated cortical cells');
    legend('H', 'L');
    
    % plot all synaptic weights to a cortical cell
    for i = 1 : 4
        subplot(4, 6, 14 + i);
        plot(reshape(W_all(10 * i,:,:), N_in, size(W_all, 3))');
        ylim(W_thres); xlim([0,num_of_records]);
        title(sprintf('all synapses to CORTICAL cell #%d', 10 * i));
    end

    % plot all synaptic weights from a retina cell
    for i = 1 : 4
        subplot(4, 6, 20 + i);
        plot(reshape(W_all(:, 10 * i,:), N_in, size(W_all, 3))');
        ylim(W_thres); xlim([0,num_of_records]);
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
    
    text(0.1, 0.8, sprintf('L period = %.2f ms', L_p));
    text(0.5, 0.8, sprintf('H period = %.2f ms', H_p));
    text(0.1, 0.7, sprintf('L dur = %.2f ms', L_dur));
    text(0.5, 0.7, sprintf('H dur = %.2f ms', H_dur));
    text(0.1, 0.6, sprintf('L pct = %.2f - %.2f', L_pct(1), L_pct(2)));
    text(0.5, 0.6, sprintf('H rate = %.2f', H_rate));
    
    text(0.1, 0.4, sprintf('tau w = %.2f', tau_w));
    text(0.1, 0.3, sprintf('tau out = %.2f', tau_out));
    text(0.1, 0.2, sprintf('tau theta = %.2f', tau_theta));
    
    text(0.5, 0.4, sprintf('W thres = %.2f - %.2f', W_thres(1), W_thres(2)));
    text(0.5, 0.3, sprintf('out thres = %.2f', out_thres));
    text(0.5, 0.2, sprintf('corr thres = %.2f', corr_thres));
    
    text(0.1, 0.0, sprintf('biased weights (max = %.4f)', bias));

    % save figure
    export_fig(filename);    
    
    % helper function: record event
    function record_event(W, in, out_spon, is_L)
        equi_out = W * in + out_spon;
        active_out = equi_out > out_thres;
        active_rate = mean(equi_out(active_out));

        if is_L % sum(active_out) < 0.8 * N_out
            L_active_pct = [L_active_pct sum(active_out)];
            L_active_rate = [L_active_rate active_rate];
        else
            H_active_pct = [H_active_pct sum(active_out)];
            H_active_rate = [H_active_rate active_rate];
        end                       
    end 
end

