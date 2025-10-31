function add_significance_bars(p_values, comparisons, alpha_corrected, all_data)
% ADD_SIGNIFICANCE_BARS Add significance bars and asterisks to existing boxplot
%
% Inputs:
%   p_values        - Vector of p-values from pairwise comparisons
%   comparisons     - Matrix (n_comparisons x 2) with indices of compared groups
%   alpha_corrected - Corrected alpha threshold for significance
%   all_data        - Vector of all data points used in boxplot (for calculating y_max)
%
% Example usage:
%   add_significance_bars(p_values, comparisons, alpha_corrected, all_percentages);

    % Get current axis limits
    ylims = ylim;
    y_range = ylims(2) - ylims(1);
    y_max = max(all_data);
    
    % Find significant comparisons
    sig_comparisons = find(p_values < alpha_corrected);
    
    if ~isempty(sig_comparisons)
        % Calculate vertical spacing for multiple bars
        bar_height = y_range * 0.05; % Height of each significance bar level
        bar_offset = y_max + y_range * 0.05; % Starting position above the data
        
        % Sort comparisons by span (larger spans drawn higher)
        [~, sort_idx] = sort(comparisons(sig_comparisons, 2) - comparisons(sig_comparisons, 1), 'descend');
        sig_comparisons_sorted = sig_comparisons(sort_idx);
        
        for k = 1:length(sig_comparisons_sorted)
            idx = sig_comparisons_sorted(k);
            stage1_idx = comparisons(idx, 1);
            stage2_idx = comparisons(idx, 2);
            p_val = p_values(idx);
            
            % Determine significance stars
            if p_val < 0.001
                sig_text = '***';
            elseif p_val < 0.01
                sig_text = '**';
            elseif p_val < alpha_corrected
                sig_text = '*';
            end
            
            y_pos = bar_offset + (k-1) * bar_height;
            
            % Draw significance bar
            x1 = stage1_idx;
            x2 = stage2_idx;
            
            % Draw the horizontal line
            plot([x1, x2], [y_pos, y_pos], 'k-', 'LineWidth', 1.5);
            
            % Add significance text
            text((x1 + x2)/2, y_pos + y_range*0.01, sig_text, ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 12, ...
                'FontWeight', 'bold');
        end
        
        % Adjust y-axis to fit all significance bars
        ylim([ylims(1), bar_offset + length(sig_comparisons_sorted) * bar_height + y_range*0.05]);
    end
end
