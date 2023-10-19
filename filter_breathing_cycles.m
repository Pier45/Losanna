function [cycles_max_cln,cycles_min_cln] = filter_breathing_cycles(data, max_pks, max_locs, min_pks, min_locs, fs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    % Create the breth cycle, this vector in the first column has the start
    % sample when the cycle start, in the second column the end of the
    % cycle. The lenght of each cycle will be studied and the outliers will
    % be removed (lenght higher thant the median value over 30 seconds). 

    % Before creating the cycles identify the outliers looking at the
    % ampitude of the signal.

    cycles_max = create_cycles(max_locs);
    cycles_min = create_cycles(min_locs);
    
    [~, out_pks_max] = rmoutliers(max_pks, 'quartiles');
    [~, out_pks_min] = rmoutliers(min_pks, 'quartiles');
    
    [cycles_max_cln] = clean_breathing_cycles(cycles_max, max_locs, out_pks_max, min_locs, out_pks_min);
    [cycles_min_cln] = clean_breathing_cycles(cycles_min, min_locs, out_pks_min, max_locs, out_pks_max);
    
    % Filtering for cycles length
    [~, out_len_max] = rmoutliers(diff(cycles_max_cln'),'movmedian', fs*30);
    [~, out_len_min] = rmoutliers(diff(cycles_min_cln'),'movmedian', fs*30);

    cycles_max_cln2 = cycles_max_cln(not(out_len_max), :);
    cycles_min_cln2 = cycles_min_cln(not(out_len_min), :);
    

    %% Comparison between cycles samples lenght before and after outliers remotion
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
    figure
    plot(data, 'k')
    hold on
    scatter(max_locs(out_pks_max), max_pks(out_pks_max), 150, 'o',  'MarkerFaceColor','#FFD700', 'MarkerFaceAlpha',.5, 'MarkerEdgeAlpha', .5);
    scatter(min_locs(out_pks_min), min_pks(out_pks_min), 150, 'o',  'MarkerFaceColor','#FFD700', 'MarkerFaceAlpha',.5, 'MarkerEdgeAlpha', .5);
    scatter(max_locs, max_pks, 'r+')
    scatter(min_locs, min_pks, 'b+')
    axis tight

    xregion(cycles_max_cln(out_len_max,1), cycles_max_cln(out_len_max,2), FaceColor="b"); 
    xregion(cycles_min_cln(out_len_min,1), cycles_min_cln(out_len_min,2), FaceColor="r");
    
    xregion(cycles_max_cln2(:,1), cycles_max_cln2(:,2))
    xregion(cycles_min_cln2(:,1), cycles_min_cln2(:,2))

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



