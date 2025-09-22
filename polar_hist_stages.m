function [] = polar_hist_stages(f0,f1,f2,f3,f4, n_bar, save, save_path)
% POLARHIST_MULTISTAGE Plots n polar histogram plot in a subplot.
    % Compute all bin counts without plotting to find the global max
%     [counts0, ~] = histcounts(f0, n_bar);
%     [counts1, ~] = histcounts(f1, n_bar);
%     [counts2, ~] = histcounts(f2, n_bar);
%     [counts3, ~] = histcounts(f3, n_bar);
%     [counts4, ~] = histcounts(f4, n_bar);
% 
%     % Get the maximum count across all histograms
%     maxCount = max([counts0, counts1, counts2, counts3, counts4]);
% 
%     % Round up to a nice value for consistent radial limit
%     rmax = ceil(maxCount * 1.1);  % 10% margin
    
    fig = figure();    
    subplot(2,3,1)
    polarhistogram(f0,n_bar,'EdgeAlpha',0.2)
%     rlim([0 rmax])
    title("Stage awake")
    subplot(2,3,2)
    polarhistogram(f1,n_bar,'EdgeAlpha',0.2)
%     rlim([0 rmax])
    title("Stage n1")
    subplot(2,3,3)
    polarhistogram(f2,n_bar,'EdgeAlpha',0.2)
%     rlim([0 rmax])
    title("Stage n2")
    subplot(2,3,4)
    polarhistogram(f3,n_bar,'EdgeAlpha',0.2)
%     rlim([0 rmax])
    title("Stage n3")
    subplot(2,3,5)
    polarhistogram(f4,n_bar,'EdgeAlpha',0.2)
%     rlim([0 rmax])
    title("Stage n4 (REM)")
    
    set(fig, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    set(fig, 'PaperPositionMode', 'auto');
    
    if save
        print(fig, [save_path 'raw_data_polar_hist.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
    end
    
    close(fig)
end

