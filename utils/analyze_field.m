function [fig2] = analyze_field(agg_result, field, tit, yl)
% ANALYZE_SLEEP_STAGES performs statistical analysis and plotting of sleep stage percentages
%
%   INPUT:
%       agg_result : Struct where each field is a subject containing
%                    .general_table with fields 'Stage' and 'Percentage'
%
%   The function:
%       - Aggregates data across subjects
%       - Performs Friedman test and pairwise Wilcoxon signed-rank tests
%       - Applies Bonferroni correction
%       - Plots a boxplot with significance markers
%
%   Example:
%       analyze_sleep_stages(agg_result);

    %% Initialize storage for all subjects' data
    all_stages = {};
    all_percentages = [];
    all_sub = fieldnames(agg_result);

    % Get stage names from the first subject
    stage_names = agg_result.(all_sub{1}).general_table.Stage;
    num_stages = length(stage_names);
    num_subjects = numel(all_sub);

    % Initialize data matrix (subjects × stages)
    percentage_matrix = zeros(num_subjects, num_stages);

    %% Combine all data
    for subj = 1:num_subjects
        current_table = agg_result.(all_sub{subj}).general_table;
        percentage_matrix(subj, :) = current_table.Percentage';
        all_stages = [all_stages; current_table.Stage];
        all_percentages = [all_percentages; current_table.(field)];
    end
    
    if num_stages>1
        %% Friedman test (non-parametric repeated measures ANOVA)
        [p_friedman, tbl_friedman, stats_friedman] = friedman(percentage_matrix, 1, 'off');
        fprintf('Friedman test p-value: %.4f\n', p_friedman);

        %% Post-hoc pairwise Wilcoxon signed-rank tests
        num_comparisons = nchoosek(num_stages, 2);
        alpha_corrected = 0.05 / num_comparisons; % Bonferroni correction

        fprintf('\nPost-hoc pairwise comparisons (Wilcoxon signed-rank test):\n');
        fprintf('Bonferroni-corrected alpha: %.4f\n\n', alpha_corrected);

        p_values = zeros(num_comparisons, 1);
        comparisons = zeros(num_comparisons, 2);
        comparison_idx = 1;

        for i = 1:num_stages-1
            for j = i+1:num_stages
                [p, ~, stats_wilcoxon] = signrank(percentage_matrix(:, i), percentage_matrix(:, j));
                p_values(comparison_idx) = p;
                comparisons(comparison_idx, :) = [i, j];

                % Significance stars
                if p < 0.001
                    significance = ' ***';
                elseif p < 0.01
                    significance = ' **';
                elseif p < alpha_corrected
                    significance = ' *';
                else
                    significance = '';
                end

                fprintf('%s vs %s: p = %.4f%s\n', ...
                    stage_names{i}, stage_names{j}, p, significance);

                comparison_idx = comparison_idx + 1;
            end
        end
    end

    %% Boxplot with significance bars
    fig2 = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    h = boxplot(all_percentages, all_stages, 'GroupOrder', stage_names);
    set(findobj(gca, 'Tag', 'Box'), 'Color', 'k');
    set(h, 'LineWidth', 1.5);
    set(gca, 'FontSize', 14);
    xlabel('Sleep Stage');
    ylabel(yl);
    title(tit);
    grid on;
    hold on;

    if num_stages > 1
        % Add significance bars if helper function exists
        if exist('add_significance_bars', 'file') == 2
            add_significance_bars(p_values, comparisons, alpha_corrected, all_percentages);
        else
            warning('add_significance_bars.m not found — skipping significance bars.');
        end
    
        sig_comparisons = find(p_values < alpha_corrected);

        %% Print summary
        fprintf('\n--- Summary of Significant Differences (p < %.4f) ---\n', alpha_corrected);
        for i = 1:length(sig_comparisons)
            idx = sig_comparisons(i);
            stage1 = stage_names{comparisons(idx, 1)};
            stage2 = stage_names{comparisons(idx, 2)};
            p_val = p_values(idx);

            if p_val < 0.001
                sig_text = '***';
            elseif p_val < 0.01
                sig_text = '**';
            else
                sig_text = '*';
            end

            fprintf('%s vs %s: p = %.6f %s\n', stage1, stage2, p_val, sig_text);
        end
        
        fprintf('-------------------%s-----------------------\n', tit);
    end
    
    hold off;
    
end

