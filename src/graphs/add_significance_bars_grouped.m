function add_significance_bars_grouped(p_values, comparisons, alpha_corrected, all_data, stage_names, sound_conditions)
% ADD_SIGNIFICANCE_BARS_GROUPED Add significance bars to grouped boxplot
%
% Inputs:
%   p_values             - Cell array {stage_idx}(comparison_vector) of p-values for each stage
%   comparisons          - Cell array {stage_idx}(n_comparisons x 2) of compared sound condition indices
%   alpha_corrected      - Corrected alpha threshold
%   all_data             - All data for y-axis calculation
%   stage_names          - Cell array of stage names being plotted
%   sound_conditions     - Cell array of sound condition names
%   num_valid_per_stage  - Vector of number of valid subjects per stage

    % Get current axis limits
    ylims = ylim;
    y_range = ylims(2) - ylims(1);
    y_max = max(all_data);
    
    % Calculate x-positions for grouped boxplot
    num_stages = length(stage_names);
    num_sounds = length(sound_conditions);
    
    % Calculate base positions for each stage group
    % MATLAB's grouped boxplot spacing: groups are separated, sounds within groups
    positions_per_stage = cell(num_stages, 1);
    current_x = 1;
    
    for stage_idx = 1:num_stages
        % Each sound condition gets a position
        stage_positions = current_x : (current_x + num_sounds - 1);
        positions_per_stage{stage_idx} = stage_positions;
        % Move to next stage (with gap)
        current_x = current_x + num_sounds + 1; % +1 for gap between stages
    end
    
    % Add significance bars for each stage
    bar_height = y_range * 0.05;
    
    for stage_idx = 1:num_stages
        if isempty(p_values{stage_idx})
            continue;
        end
        
        % Find significant comparisons for this stage
        sig_comparisons = find(p_values{stage_idx} < alpha_corrected);
        
        if ~isempty(sig_comparisons)
            % Sort by span
            [~, sort_idx] = sort(comparisons{stage_idx}(sig_comparisons, 2) - comparisons{stage_idx}(sig_comparisons, 1), 'descend');
            sig_comparisons_sorted = sig_comparisons(sort_idx);
            
            % Calculate offset for this stage's bars
            bar_offset = y_max + y_range * 0.05;
            
            for k = 1:length(sig_comparisons_sorted)
                idx = sig_comparisons_sorted(k);
                sound1_idx = comparisons{stage_idx}(idx, 1);
                sound2_idx = comparisons{stage_idx}(idx, 2);
                p_val = p_values{stage_idx}(idx);
                
                % Determine significance stars
                if p_val < 0.001
                    sig_text = '***';
                elseif p_val < 0.01
                    sig_text = '**';
                elseif p_val < alpha_corrected
                    sig_text = '*';
                end
                
                y_pos = bar_offset + (k-1) * bar_height;
                
                % Get x-positions for this stage's sound conditions
                x1 = positions_per_stage{stage_idx}(sound1_idx);
                x2 = positions_per_stage{stage_idx}(sound2_idx);
                
                % Draw the horizontal line
                plot([x1, x2], [y_pos, y_pos], 'k-', 'LineWidth', 1.5);
                
                % Add significance text
                text((x1 + x2)/2, y_pos + y_range*0.01, sig_text, ...
                    'HorizontalAlignment', 'center', ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold');
            end
        end
    end
    
    % Adjust y-axis to fit all significance bars
    % Find maximum number of significant comparisons across all stages
    max_sig_comparisons = 0;
    for stage_idx = 1:num_stages
        if ~isempty(p_values{stage_idx})
            max_sig_comparisons = max(max_sig_comparisons, sum(p_values{stage_idx} < alpha_corrected));
        end
    end
    
    if max_sig_comparisons > 0
        bar_offset = y_max + y_range * 0.05;
        ylim([ylims(1), bar_offset + max_sig_comparisons * bar_height + y_range*0.05]);
    end
end

