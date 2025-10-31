clc
close all
clear

addpath(genpath('../src'))

path_load = '/mnt/HDD2/piero/Losanna/output/sleep/T15.mat';
load(path_load)
path_save = path_load(1:end-4);

t = datetime;
DateString = char(t, "yyyy-MMM-dd_HH:mm:ss"); 
name_log = strrep(path_load, '/', '_');
log_file_name = ['stat_log_' name_log '_' DateString '.txt'];
diary([path_save log_file_name]);
diary on

%% Analysis of sync percentage %%
tit = 'Sync Percentage';
fig = analyze_field(agg_result, 'Percentage', tit, 'Percentage %');
print(fig, [path_save '/' tit '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Analysis of samples distribution
tit = 'Sample Size';
fig = analyze_field(agg_result, 'All_count', tit, 'Samples');
print(fig, [path_save '/' tit '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Analysis of sync samples
tit = 'Samples Sync Distribution';
fig = analyze_field(agg_result, 'Sync_count', tit, 'Samples');
print(fig, [path_save '/' tit '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Analyze Sound Conditions across Sleep Stages (filtered by Sync_count)
% Define sound conditions
sound_conditions = {'sync', 'async', 'isoch', 'baseline'};%'nan' removed
num_sound_conds = length(sound_conditions);

% Remove outliers subject
% d(strcmp({d.name}, 's31')) = [];

% Get sleep stages
all_sub = fieldnames(agg_result);
stage_names = agg_result.(all_sub{1}).general_table.Stage;
num_stages = length(stage_names);
num_subjects = length(all_sub);

% Mask threshold for TOTAL sync percentage
th_mask = 1;

% Initialize 3D matrix: (subjects x sleep_stages x sound_conditions)
sound_data = zeros(num_subjects, num_stages, num_sound_conds);
sync_percentages = zeros(num_subjects, num_stages);

for subj = 1:num_subjects
    current_table = agg_result.(all_sub{subj}).general_table;
    
    for stage = 1:num_stages
        % Columns are: Stage, Sync_count, All_count, Percentage, nan, sync, async, isoch, baseline
        % Adjust column indices based on your actual table structure
        sound_data(subj, stage, :) = table2array(current_table(stage, sound_conditions));
        sync_percentages(subj, stage) = current_table{stage, 4};
    end
end

%% Identify stages with sync > 5% for each subject
sync_mask = sync_percentages > th_mask;
subjects_with_sync = sum(sync_mask, 1);

fprintf('Number of subjects with sync > %d %% for each stage:\n', th_mask);
for stage = 1:num_stages
    fprintf('%s: %d/%d subjects\n', stage_names{stage}, subjects_with_sync(stage), num_subjects);
end

% Identify stages where at least some subjects have sync > 5%
stages_to_analyze = find(subjects_with_sync > 0);

%% Statistical Analysis for filtered Sleep Stages
fprintf('\n=== SOUND CONDITION ANALYSIS (Only stages with sync > %d%%) ===\n\n', th_mask);

for stage_idx = 1:length(stages_to_analyze)
    stage = stages_to_analyze(stage_idx);
    fprintf('------- %s -------\n', stage_names{stage});
    
    % Get subjects with sync > 5% for this stage
    valid_subjects = sync_mask(:, stage);
    num_valid = sum(valid_subjects);
    
    fprintf('Analyzing %d subjects with sync > %d %%\n', num_valid, th_mask);
    
    if num_valid < 3
        fprintf('Not enough subjects for statistical analysis (need at least 3)\n\n');
        continue;
    end
    
    % Extract data only for valid subjects: (valid_subjects x sound_conditions)
    stage_data = squeeze(sound_data(valid_subjects, stage, :));
    
    % Friedman test for this sleep stage
    [p_friedman, ~, ~] = friedman(stage_data, 1, 'off');
    fprintf('Friedman test p-value: %.4f\n', p_friedman);
    
    if p_friedman < 0.05
        fprintf('Significant differences found between sound conditions!\n');
        
        % Post-hoc pairwise comparisons
        num_comparisons = nchoosek(num_sound_conds, 2);
        alpha_corrected = 0.05 / num_comparisons;
        
        fprintf('Post-hoc comparisons (alpha = %.4f):\n', alpha_corrected);
        
        p_values_sound = [];
        comparisons_sound = [];
        comp_idx = 1;
        
        for i = 1:num_sound_conds-1
            for j = i+1:num_sound_conds
                [p, ~, ~] = signrank(stage_data(:, i), stage_data(:, j));
                p_values_sound(comp_idx) = p;
                comparisons_sound(comp_idx, :) = [i, j];
                
                if p < 0.001
                    sig_text = '***';
                elseif p < 0.01
                    sig_text = '**';
                elseif p < alpha_corrected
                    sig_text = '*';
                else
                    sig_text = '';
                end
                
                fprintf('  %s vs %s: p = %.4f%s\n', ...
                    sound_conditions{i}, sound_conditions{j}, p, sig_text);
                
                comp_idx = comp_idx + 1;
            end
        end
    end
    fprintf('\n');
end

%% Create boxplots for filtered sleep stages
fig2 = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);

for plot_idx = 1:length(stages_to_analyze)
    stage = stages_to_analyze(plot_idx);
    
    % Get valid subjects for this stage
    valid_subjects = sync_mask(:, stage);
    num_valid = sum(valid_subjects);
    
    if num_valid < 3
        continue;
    end
    
    stage_data = squeeze(sound_data(valid_subjects, stage, :));
    
    % Reshape for boxplot
    data_for_boxplot = stage_data(:);
    groups_for_boxplot = repmat(sound_conditions, num_valid, 1);
    groups_for_boxplot = groups_for_boxplot(:);
    
%     subplot(ceil(length(stages_to_analyze)/2), 2, plot_idx);
    if stages_to_analyze > 1
        subplot(1, 5, plot_idx);
    end
    
    h = boxplot(data_for_boxplot, groups_for_boxplot, 'GroupOrder', sound_conditions);
    ylabel('Percentage');
    ylim([0, 66]);
    set(findobj(gca, 'Tag', 'Box'), 'Color', 'k');
    set(h, 'LineWidth', 1.5); % (optional) make lines thicker
    set(gca, 'FontSize',14);
    tit = sprintf('%s - n=%d', stage_names{stage}, num_valid);
    title(tit);
    grid on;
    xtickangle(45); % rotate labels 45 degrees
    % Optional: Add significance bars here (similar to previous code)
end

print(fig2, [path_save '/' tit '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution

% sgtitle(sprintf('Sync>%d%%', th_mask));

%% Alternative: Create grouped boxplot for all filtered stages
fig3 = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);

    colors = [
            1.0 0.0 0.0;  % red
            0.0 0.0 0.0;  % black
            0.0 0.0 1.0;  % blue
            0.7 0.7 0.7   % gray
    ];

data_for_grouped = [];
stage_labels = {};
sound_labels = {};

for stage_idx = 1:length(stages_to_analyze)
    stage = stages_to_analyze(stage_idx);
    valid_subjects = sync_mask(:, stage);
    num_valid = sum(valid_subjects);
    
    if num_valid >= 3
        for sound = 1:num_sound_conds
            stage_sound_data = sound_data(valid_subjects, stage, sound);
            data_for_grouped = [data_for_grouped; stage_sound_data];
            stage_labels = [stage_labels; repmat(stage_names(stage), num_valid, 1)];
            sound_labels = [sound_labels; repmat(sound_conditions(sound), num_valid, 1)];
        end
    end
end

if ~isempty(data_for_grouped)
    h = boxplot(data_for_grouped, {stage_labels, sound_labels}, ...
        'FactorGap', [5, 2], 'ColorGroup', sound_labels, 'Colors', colors);
    ylim([0, 80]);
    set(h, 'LineWidth', 1.5); % (optional) make lines thicker
    set(gca, 'FontSize',14);
    
    % Add significance bars
    % Need to reindex p_values and comparisons for only analyzed stages
%     p_values_reindexed = {};
%     comparisons_reindexed = {};
%     for i = 1:length(stages_analyzed)
%         p_values_reindexed{i} = p_values_per_stage{stages_analyzed(i)};
%         comparisons_reindexed{i} = comparisons_per_stage{stages_analyzed(i)};
%     end
%     
%     add_significance_bars_grouped(p_values_reindexed, comparisons_reindexed, ...
%         alpha_corrected, data_for_grouped, analyzed_stage_names, ...
%         sound_conditions);
    
    xlabel('Sleep Stage');
    ylabel('Percentage');
    tit = sprintf('Sound Conditions across Sleep Stages (filtered: sync > %d %%)', th_mask);
    title(tit);
    grid on;
end

print(fig3, [path_save '/' tit '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution

diary off
%%%%%%%%%%%%%

%% Statistical Analysis for filtered Sleep Stages
% fprintf('\n=== SOUND CONDITION ANALYSIS (Only stages with sync > %d%%) ===\n\n', th_mask);
% 
% % Store p-values and comparisons for each stage
% p_values_per_stage = cell(num_stages, 1);
% comparisons_per_stage = cell(num_stages, 1);
% num_valid_per_stage = zeros(num_stages, 1);
% stages_analyzed = [];
% 
% for stage_idx = 1:length(stages_to_analyze)
%     stage = stages_to_analyze(stage_idx);
%     fprintf('--- %s ---\n', stage_names{stage});
%     
%     % Get subjects with sync > threshold for this stage
%     valid_subjects = sync_mask(:, stage);
%     num_valid = sum(valid_subjects);
%     num_valid_per_stage(stage) = num_valid;
%     
%     fprintf('Analyzing %d subjects with sync > %d%%\n', num_valid, th_mask);
%     
%     if num_valid < 3
%         fprintf('Not enough subjects for statistical analysis (need at least 3)\n\n');
%         continue;
%     end
%     
%     stages_analyzed = [stages_analyzed, stage];
%     
%     % Extract data only for valid subjects
%     stage_data = squeeze(sound_data(valid_subjects, stage, :));
%     
%     % Friedman test
%     [p_friedman, ~, ~] = friedman(stage_data, 1, 'off');
%     fprintf('Friedman test p-value: %.4f\n', p_friedman);
%     
%     if p_friedman < 0.05
%         fprintf('Significant differences found between sound conditions!\n');
%         
%         % Post-hoc pairwise comparisons
%         num_comparisons = nchoosek(num_sound_conds, 2);
%         alpha_corrected = 0.05 / num_comparisons;
%         
%         fprintf('Post-hoc comparisons (alpha = %.4f):\n', alpha_corrected);
%         
%         p_values_sound = [];
%         comparisons_sound = [];
%         comp_idx = 1;
%         
%         for i = 1:num_sound_conds-1
%             for j = i+1:num_sound_conds
%                 [p, ~, ~] = signrank(stage_data(:, i), stage_data(:, j));
%                 p_values_sound(comp_idx) = p;
%                 comparisons_sound(comp_idx, :) = [i, j];
%                 
%                 if p < 0.001
%                     sig_text = '***';
%                 elseif p < 0.01
%                     sig_text = '**';
%                 elseif p < alpha_corrected
%                     sig_text = '*';
%                 else
%                     sig_text = '';
%                 end
%                 
%                 fprintf('  %s vs %s: p = %.4f%s\n', ...
%                     sound_conditions{i}, sound_conditions{j}, p, sig_text);
%                 
%                 comp_idx = comp_idx + 1;
%             end
%         end
%         
%         % Store for plotting
%         p_values_per_stage{stage} = p_values_sound;
%         comparisons_per_stage{stage} = comparisons_sound;
%     else
%         p_values_per_stage{stage} = [];
%         comparisons_per_stage{stage} = [];
%     end
%     fprintf('\n');
% end
% 
% %% Create grouped boxplot with significance bars
% figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);
% colors = [
%     1.0 0.0 0.0;  % red
%     0.0 0.0 0.0;  % black
%     0.0 0.0 1.0;  % blue
%     0.7 0.7 0.7   % gray
% ];
% 
% data_for_grouped = [];
% stage_labels = {};
% sound_labels = {};
% analyzed_stage_names = {};
% 
% for stage_idx = 1:length(stages_analyzed)
%     stage = stages_analyzed(stage_idx);
%     valid_subjects = sync_mask(:, stage);
%     num_valid = sum(valid_subjects);
%     
%     analyzed_stage_names{end+1} = stage_names{stage};
%     
%     for sound = 1:num_sound_conds
%         stage_sound_data = sound_data(valid_subjects, stage, sound);
%         data_for_grouped = [data_for_grouped; stage_sound_data];
%         stage_labels = [stage_labels; repmat(stage_names(stage), num_valid, 1)];
%         sound_labels = [sound_labels; repmat(sound_conditions(sound), num_valid, 1)];
%     end
% end
% 
% if ~isempty(data_for_grouped)
%     h = boxplot(data_for_grouped, {stage_labels, sound_labels}, ...
%         'FactorGap', [5, 2], 'ColorGroup', sound_labels, 'Colors', colors);
%     ylim([0, 80]);
%     set(h, 'LineWidth', 1.5);
%     set(gca, 'FontSize', 14);
%     xlabel('Sleep Stage');
%     ylabel('Percentage');
%     hold on;
%     
%     % Add significance bars
%     % Need to reindex p_values and comparisons for only analyzed stages
%     p_values_reindexed = {};
%     comparisons_reindexed = {};
%     for i = 1:length(stages_analyzed)
%         p_values_reindexed{i} = p_values_per_stage{stages_analyzed(i)};
%         comparisons_reindexed{i} = comparisons_per_stage{stages_analyzed(i)};
%     end
%     
% %     add_significance_bars_grouped(p_values_reindexed, comparisons_reindexed, ...
% %         alpha_corrected, data_for_grouped, analyzed_stage_names, ...
% %         sound_conditions);
%     
%     title(sprintf('Sound Conditions across Sleep Stages (filtered: sync > %d %%)', th_mask));
%     grid on;
%     hold off;
% end