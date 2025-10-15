function [] = polar_hist_stages(f, n_bar, save_path)
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
    
    if contains(save_path, 's') 
        fig2 = figure('doublebuffer','off', 'Visible','Off');
    else
        fig2 = figure();
    end
    set(fig2,'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

    stages = fieldnames(f);
    if numel(stages) > 1
        row = 2;
        col = ceil(numel(stages)/row);
    else
        row = 1;
        col = 1;
    end
    
    for i=1:size(stages ,1)
        subplot(row,col,i)
        polarhistogram(f.(stages{i}),n_bar,'EdgeAlpha',0.2)
        %     rlim([0 rmax])
        title(['Stage ' stages{i}])
    end

    set(fig2, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    set(fig2, 'PaperPositionMode', 'auto');
    
    if contains(save_path, 's') 
        print(fig2, [save_path 'raw_data_polar_hist.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
        close(fig2)
    end
    
end

