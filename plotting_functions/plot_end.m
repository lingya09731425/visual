function plot_end(plot_W, W_thres)

    W_evo = double(plot_W) / 1000;
    W_end = W_evo(:,:,size(W_evo,3));
    
    if ~isnan(W_thres)
        W_max = max(max(max(W_evo)));
        if any(all(all(W_evo > W_max * 0.98)))
            W_end(:,:) = W_max;
        end
    end
    
    if ~isnan(W_thres)
        colormap('hot');
    else
        colormap('jet');
    end
    imagesc(W_end);
    xlabel('retina'); ylabel('cortex');
    if ~isnan(W_thres)
        caxis(W_thres);
    end
    colorbar;
end

