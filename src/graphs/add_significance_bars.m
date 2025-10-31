function add_significance_bars_grouped(p_values, comparisons, alpha_corrected, all_data, stage_names, sound_conditions, boxplot_handle)
% ADD_SIGNIFICANCE_BARS_GROUPED Add significance bars to grouped boxplot
%
% Inputs:
%   p_values             - Cell array {stage_idx}(comparison_vector) of p-values for each stage
%   comparisons          - Cell array {stage_idx}(n_comparisons x 2) of compared sound condition indices
%   alpha_corrected      - Corrected alpha threshold
%   all_data             - All data for y-axis calculation
%   stage_names          - Cell array of stage names being plotted
%   sound_conditions     - Cell array of sound condition names
%   boxplot_handle       - Handle to the boxplot (to extract actual positions)

    % Get current axis limits
    ylims = ylim;
    y_range = ylims(2) - ylims(1);
    y_max = max(all_data);
    
    % Extract actual x-positions from the boxplot
    % The boxes are children of the current axes
    ax = gca;
    box_objects = findobj(ax, 'Tag', 'Box');
    
    % Get x-positions of all boxes
    num_boxes = length(box_objects);
    x_positions = zeros(num_boxes, 1);
    for i = 1:num_boxes
        x_data = get(box_objects(i), 'XData');
        x_positions(i) = mean(x_data); % Center of the box
    end
    
    % Sort positions (they might be in reverse order)
    x_positions = sort(x_positions);
    
    % Organize positions by stage
    num_stages = length(stage_names);
    num_sounds = length(sound_conditions);
    
    positions_per_stage = cell(num_stages, 1);
    for stage_idx = 1:num_stages
        start_idx = (stage_idx - 1) * num_sounds + 1;
        end_idx = stage_idx * num_sounds;
        positions_per_stage{stage_idx} = x_positions(start_idx:end_idx);
    end
    
    % Add significance bars for each stage
    bar_height = y_range * 0.05;
    bar_offset = y_max + y_range * 0.05;
    
    max_sig_comparisons = 0;
    
    for stage_idx = 1:num_stages
        if isempty(p_values{stage_idx})
            continue;
        end
        
        % Find significant comparisons for this stage
        sig_comparisons = find(p_values{stage_idx} < alpha_corrected);
        
        if ~isempty(sig_comparisons)
            max_sig_comparisons = max(max_sig_comparisons, length(sig_comparisons));
            
            % Sort by span
            [~, sort_idx] = sort(comparisons{stage_idx}(sig_comparisons, 2) - comparisons{stage_idx}(sig_comparisons, 1), 'descend');
            sig_comparisons_sorted = sig_comparisons(sort_idx);
            
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
    if max_sig_comparisons > 0
        ylim([ylims(1), bar_offset + max_sig_comparisons * bar_height + y_range*0.05]);
    end
end
