function plot_heat(W, cax)
    colormap('hot');
    imagesc(W);
    colorbar; caxis(cax);
end

