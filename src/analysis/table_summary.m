function [sleepTable] = table_summary(sleep_stages, sound_cond, prov_struct)
%BAR_SLEEP Summary of this function goes here
% Create the table
    sl_sync = fieldnames(prov_struct);
    percentages = zeros(length(sleep_stages), 1);
    sync_count = zeros(length(sleep_stages), 1);
    all_count = zeros(length(sleep_stages), 1);

    % Loop through each stage and extract the percentage
    for i = 1:length(sleep_stages)
        stage_name = sleep_stages{i};

        % Only proceed if the stage exists in the struct
        if ismember(stage_name, sl_sync)
            percentages(i) = prov_struct.(stage_name).sync_perc;
            sync_count(i) = prov_struct.(stage_name).sync_samples;
            all_count(i) = prov_struct.(stage_name).tot_samples;
        else
            percentages(i) = 0;
            sync_count(i) = 0; 
            all_count(i) = 0;
        end
    end
            
    sleepTable = table(sleep_stages, sync_count, all_count, percentages, ...
                               'VariableNames', {'Stage', 'Sync_count', 'All_count','Percentage'});
                           
    sound_group = ["no sound", "sound"]';
    group1 = "baseline";
    group2 = ["sync", "async", "isoch"];

    % Create a table of zero columns
    soundCols = cell2table(num2cell(zeros(height(sleepTable), numel(sound_cond))), ...
                         'VariableNames', sound_cond);
    
    aggsoundCols = cell2table(num2cell(zeros(height(sleepTable), numel(sound_group))), ...
                         'VariableNames', sound_group);                 
    
    % Concatenate with the original table
    sleepTable = [sleepTable soundCols aggsoundCols];
    
    for slstage=1:length(sleep_stages)
        if any(ismember(fieldnames(prov_struct), sleep_stages{slstage})) && not(isempty(prov_struct.(sleep_stages{slstage}).sound_table))
            sleepTable{slstage, sound_cond} = prov_struct.(sleep_stages{slstage}).sound_table.Percentage;%% trasposto-testare
            
            sleepTable{slstage, sound_group} = [sum(table2array(sleepTable(slstage, group1)),2), mean(table2array(sleepTable(slstage, group2)),2)];
        end
    end
    

end

