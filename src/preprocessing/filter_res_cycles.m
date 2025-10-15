function [cycles_max_cln2,cycles_min_cln2, perc_remotion_min] = filter_breathing_cycles(data, max_pks, max_locs, min_pks, min_locs, fs, stage, graph, save_path)
% FILTER_BREATHING_CYCLES
% The purpose of this function is to discover the breathing cycles. In this matrix the start
% of the cycle is in the first column and the end of the cycle is in the second column.
% The length of each cycle is examined and the outliers are removed (length greater than 
% the median over 30 seconds). 

    window_time = 30;
    % Before creating the cycles identify the outliers looking at the
    % amplitude of the signal.
    cycles_max = create_cycles(max_locs);
    cycles_min = create_cycles(min_locs);
    
    %% Filtering for cycles amplitude
    [~, out_pks_max] = rmoutliers(max_pks, 'movmean', fs*window_time);
    [~, out_pks_min] = rmoutliers(min_pks, 'movmean', fs*window_time);
    [cycles_max_cln] = clean_res_cycles(cycles_max, max_locs, out_pks_max, min_locs, out_pks_min);
    [cycles_min_cln] = clean_res_cycles(cycles_min, min_locs, out_pks_min, max_locs, out_pks_max);
    
    %% Filtering for cycles length
    [~, out_len_max] = rmoutliers(diff(cycles_max_cln'),'movmean', fs*window_time);
    [~, out_len_min] = rmoutliers(diff(cycles_min_cln'),'movmean', fs*window_time);
    cycles_max_cln2 = cycles_max_cln(not(out_len_max), :);
    cycles_min_cln2 = cycles_min_cln(not(out_len_min), :);
    
    perc_remotion_max = round(100*(sum(out_len_max) + sum(out_pks_max))/size(cycles_max, 1),2);
    perc_remotion_min = round(100*(sum(out_len_min) + sum(out_pks_min))/size(cycles_min, 1),2);

    p_good_cycles = (sum(diff(cycles_min_cln2'))/length(data))*100;
    %% Comparison between cycles samples length before and after outliers remotion
    % figure
    % histogram(diff(cycles_min_cln'))
    % hold on
    % histogram(diff(cycles_min_cln2'))
    % legend(["Raw"; "Clean"])
    % title('Cycles duration min')
    %
    % figure
    % histogram(diff(cycles_max_cln'))
    % hold on
    % histogram(diff(cycles_max_cln2'))
    % legend(["Raw"; "Clean"])
    % title('Cycles duration max')
    
    %% Visualization cycles
    if graph == "plot"
        if contains(save_path, 's') 
            fig2 = figure('doublebuffer','off', 'Visible','Off');
            set(fig2,'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
        else
            fig2 = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);
        end
        
        plot(data, 'k');
        hold on
        scatter(max_locs(out_pks_max), max_pks(out_pks_max), 150, 'o',  'MarkerFaceColor','#FFD700', 'MarkerFaceAlpha',.5);
        scatter(min_locs(out_pks_min), min_pks(out_pks_min), 150, 'o',  'MarkerFaceColor','#FFD700', 'MarkerFaceAlpha',.5);
        scatter(max_locs, max_pks, 'r+')
        scatter(min_locs, min_pks, 'b+')
        axis tight
%         draw_xregion(cycles_max_cln(out_len_max,1), cycles_max_cln(out_len_max,2), ylim, 'b', 0.2);
        draw_xregion(cycles_min_cln(out_len_min,1), cycles_min_cln(out_len_min,2), ylim, 'r', 0.2);
%         draw_xregion(cycles_max_cln2(:,1), cycles_max_cln2(:,2), ylim, [0.5 0.5 0.5], 0.2);
        draw_xregion(cycles_min_cln2(:,1), cycles_min_cln2(:,2), ylim, [6,64,43]/256, 0.2);
        legend('Respiration', 'Max amp out', 'Min amp out', 'Max spikes', 'Min spikes');
        set(gca, 'LooseInset', get(gca, 'TightInset'));
        
        %% Sezione compatibile solo con 2025a
        %         xregion(cycles_max_cln(out_len_max,1), cycles_max_cln(out_len_max,2), FaceColor="b"); 
        %         xregion(cycles_min_cln(out_len_min,1), cycles_min_cln(out_len_min,2), FaceColor="r");
        %         xregion(cycles_max_cln2(:,1), cycles_max_cln2(:,2))
        %         xregion(cycles_min_cln2(:,1), cycles_min_cln2(:,2))
        %%
        
        title([stage ' - Selected cycles: ' num2str(round(p_good_cycles,2)) '%'])
        ax = gca; % Get current axes
        ax.FontSize = 14;
        axis tight

        if contains(save_path, 's') 
            print(fig2, [save_path '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
            close(fig2)
        end
        
    end
    
    % Only for the max
    % figure
    % plot(data, 'k')
    % hold on
    % scatter(max_locs(out_pks_max), max_pks(out_pks_max), 150, 'o',  'MarkerFaceColor','#FFD700', 'MarkerFaceAlpha',.5, 'MarkerEdgeAlpha', .5);
    % scatter(max_locs, max_pks, 'r+')
    % scatter(min_locs, min_pks, 'b+')
    % axis tight
    % xregion(cycles_max_cln(:,1), cycles_max_cln(:,2))
    % xregion(cycles_max_cln(out_len_max,1), cycles_max_cln(out_len_max,2), FaceColor="b");     

    % Only for the min
    % figure
    % plot(data, 'k')
    % hold on
    % scatter(min_locs(out_pks_min), min_pks(out_pks_min), 150, 'o',  'MarkerFaceColor','#FFD700', 'MarkerFaceAlpha',.5, 'MarkerEdgeAlpha', .5);
    % scatter(max_locs, max_pks, 'r+')
    % scatter(min_locs, min_pks, 'b+')
    % axis tight
    % xregion(cycles_min_cln(:,1), cycles_min_cln(:,2))
    % xregion(cycles_min_cln(out_len_min,1), cycles_min_cln(out_len_min,2), FaceColor="b");     

end



