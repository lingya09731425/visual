function [record_times_ms,record_W,record_output,record_theta,plot_times_ms,plot_W] = ...
    independent_rates( ...
        type, ...
        bias, N_in, N_out, total_ms, dt_per_ms, ...
        out_thres, W_thres, bounded, corr_thres, ...
        L_p, H_p, L_dur, H_dur, L_pct, H_pct, H_amp, ...
        tau_w, tau_out, tau_theta, ...
        summary_name, eventlog)

    switch type
        case 'corr'
            type_id = 0;
        case 'bcm'
            type_id = 1;
            y0 = 0.1;
            fprintf(eventlog, 'y0: %.1f \n', y0);
        case 'adapt'
            type_id = 2;
        case 'oja'
            type_id = 3;
        otherwise
            warning('unexpected type');
    end

    dt = 1 / dt_per_ms;
    
    % initialize weights
    W = biased_weights(N_in, bias, 2, true);
    
    % initialize activities
    in = zeros(N_in, 1);
    out = zeros(N_out, 1);
    out_spon = zeros(N_out, 1);
    theta = zeros(N_out, 1);

    % initialize counters
    L_counter = round(exprnd(L_p * dt_per_ms)) + 1;
    H_counter = isinf(H_p) * (-1) + ...
        ~isinf(H_p) * (round(poissrnd(H_p * dt_per_ms)) + 1);
    L_dur_counter = 0; H_dur_counter = 0;
    
    record_counter = 1;
    plot_counter = 1;

    % initialize vectors for recording events
    L_active_pct = []; H_active_pct = [];
    L_active_rate = []; H_active_rate = [];
    
    % initialize matrices for recording weights, output, theta
    record_freq = 0.05;
    fprintf(eventlog, 'record freq: every %.2f ms \n', record_freq);
    
    record_times_ms = [0 : record_freq : (total_ms * 0.2) ...
        (total_ms * 0.5) : record_freq : (total_ms * 0.6) ...
        (total_ms * 0.9) : record_freq : total_ms];
    record_times_dt = int32(record_times_ms * dt_per_ms);
    num_of_records = length(record_times_dt);
    
    data_multi = 1000;
    fprintf(eventlog, 'data multiplication factor: %d \n', data_multi);
    
    record_W = zeros(N_out, N_in, num_of_records, 'int16');
    record_W(:,:,1) = W * data_multi;
    record_output = zeros(N_out, num_of_records, 'uint16');
    record_output(:,1) = out * data_multi;
    record_theta = zeros(N_out, num_of_records, 'uint16');
    record_theta(:,1) = theta * data_multi;
    
    % initialize matrices for summary plotting
    plot_W_freq = 50;
    
    plot_times_ms = 0 : plot_W_freq : total_ms;
    num_of_plots = length(plot_times_ms);
    
    plot_W = zeros(N_out, N_in, num_of_plots, 'int16');
    plot_W(:,:,1) = W * data_multi;
    
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
            L_counter = round(exprnd(L_p * dt_per_ms)) + L_dur_counter;
            
            if t > equi_t
                event_recorder(W, in, out_spon, true);
            end
            
            center = mod(L_start + round(L_length / 2), N_in);
            fprintf(eventlog, '%d L %d %d \n', t, center, L_length);
        end

        if H_counter == 0
            H_length = round(N_out * (H_pct(1) + rand(1) * (H_pct(2) - H_pct(1))));
            H_start = randsample(N_out, 1);
            
            out_spon = zeros(N_out, 1);
            out_spon(mod(H_start : H_start + H_length - 1, N_out) + 1) = normrnd(H_amp, 0.5, H_length,1);
            if type_id == 2 % adapt
                out_spon = out_spon .* theta;
            end

            H_dur_counter = round(normrnd(H_dur, H_dur * 0.1) * dt_per_ms);
            H_counter = round(poissrnd(H_p * dt_per_ms)) + H_dur_counter;
            
            if t > equi_t
                event_recorder(W, in, out_spon, false);
            end
            
            center = mod(H_start + round(H_length / 2), N_in);
            fprintf(eventlog, '%d H %d %d \n', t, center, H_length);
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
                theta = theta + (dt / tau_theta) * (-theta + out .^ 2 / y0);
                
            case 2 % adapt
                dW = (dt / tau_w) * out * (in - corr_thres)';                                                                                                                       
                theta = theta + (dt / tau_theta) * (-theta + out .^ 2);
                
            case 3 % oja
                dW = (dt / tau_w) * (out * ones(1, N_in)) .* (ones(N_out, 1) * in' ...
                    - (out * ones(1, N_in)) .* W);
        end
        
        % update weight matrix
        W = W + dW;
        if bounded
            W(W < W_thres(1)) = W_thres(1);
            W(W > W_thres(2)) = W_thres(2);
        end
            
        % counter operations
        L_counter = L_counter - 1;
        H_counter = H_counter - 1;
        L_dur_counter = L_dur_counter - 1;
        H_dur_counter = H_dur_counter - 1;
        
        % end of events
        if L_dur_counter == 0
            in = zeros(N_in, 1);
        end
        if H_dur_counter == 0
            out_spon = zeros(N_out, 1);
        end
        
        % record W, output, theta
        if mod(t, record_freq * dt_per_ms) == 0 && ismember(t, record_times_dt)
            record_counter = record_counter + 1;
            
            record_W(:,:,record_counter) = W * data_multi;
            record_output(:,record_counter) = out * data_multi;
            record_theta(:,record_counter) = theta * data_multi;
        end
        
        % sparsely record W
        if mod(t, plot_W_freq * dt_per_ms) == 0
            plot_counter = plot_counter + 1;
            fprintf('completion %.2f %% \n', t / (total_ms * dt_per_ms) * 100);
            
            plot_W(:,:,plot_counter) = W * data_multi;
            
            % plot intermediate W
            subplot(4, 6, [1,2,7,8]);
            colormap('hot');
            imagesc(W);
            colorbar; caxis(W_thres);
            getframe;
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
        extracted = reshape(plot_W(10 * i,:,:), [N_in,num_of_plots])';
        plot(plot_times_ms, double(extracted) / data_multi);
        ylim(W_thres);
        title(sprintf('all synapses to CORTICAL cell #%d', 10 * i));
    end

    % plot all synaptic weights from a retina cell
    for i = 1 : 4
        subplot(4, 6, 20 + i);
        extracted = reshape(plot_W(:, 10 * i,:), [N_out,num_of_plots])';
        plot(plot_times_ms, double(extracted) / data_multi);
        ylim(W_thres);
        title(sprintf('all synapses from RETINAL cell #%d', 10 * i));
    end

    % plot the progression of the average weight
    subplot(4, 6, [5,6,11,12]);
    plot(plot_times_ms, reshape(mean(mean(plot_W)), [1,num_of_plots])  / data_multi);
    title('average weight v.s. t');

    % add notations to summary plot
    s = subplot(4, 6, [13,14,19,20]); set(s, 'visible', 'off');
    text(0.1, 1.0, sprintf('total run time = %d ms', total_ms));
    text(0.5, 1.0, sprintf('dt per ms = %d', dt_per_ms));
    
    text(0.1, 0.8, sprintf('L period = %.2f ms', L_p));
    text(0.5, 0.8, sprintf('H period = %.2f ms', H_p));
    text(0.1, 0.7, sprintf('L dur = %.2f ms', L_dur));
    text(0.5, 0.7, sprintf('H dur = %.2f ms', H_dur));
    text(0.1, 0.6, sprintf('L pct = %.2f - %.2f', L_pct(1), L_pct(2)));
    text(0.5, 0.6, sprintf('H pct = %.2f - %.2f', H_pct(1), H_pct(2)));
    text(0.5, 0.5, sprintf('H amp = %.2f', H_amp));
    
    text(0.1, 0.3, sprintf('tau w = %.2f', tau_w));
    text(0.1, 0.2, sprintf('tau out = %.2f', tau_out));
    text(0.1, 0.1, sprintf('tau theta = %.2f', tau_theta));
    
    text(0.5, 0.3, sprintf('W thres = %.2f - %.2f', W_thres(1), W_thres(2)));
    text(0.5, 0.2, sprintf('out thres = %.2f', out_thres));
    text(0.5, 0.1, sprintf('corr thres = %.2f', corr_thres));

    % save figure
    export_fig(summary_name);    
    
    % helper function: record event
    function event_recorder(W, in, out_spon, ~)
        equi_out = W * in + out_spon;
        active_out = equi_out > out_thres;
        active_rate = mean(equi_out(active_out));

        if sum(active_out) < 0.8 * N_out % is_L
            L_active_pct = [L_active_pct sum(active_out)];
            L_active_rate = [L_active_rate active_rate];
        else
            H_active_pct = [H_active_pct sum(active_out)];
            H_active_rate = [H_active_rate active_rate];
        end                       
    end    
end

