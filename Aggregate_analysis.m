clear
close all
clc

addpath(genpath('src'))

%% Select the folder, 1 sleep, 2 awake
conditions = ["sleep/T30"; "awake/T15"; "sleep/T15"; "awake/T30"];
selected_cond = char(conditions(3,:));

path_folder = ['output/', selected_cond];
d = dir([path_folder '/s*']);
is_match = ~cellfun(@isempty, regexp({d.name}, '^s\d+$'));
d = d(is_match, :);

fid = fopen('/mnt/HDD2/piero/Losanna/config/config.json');
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
config = jsondecode(str);
sound_cond = config.sound_cond;
sound_codes = config.sound_codes;
sleep_score_codes = config.sleep_score_codes;
start_folder = 1;

if contains(selected_cond, 'sleep')
    number_folder = 2;
    sleep_stages = config.sleep_stages;
    sel_path = [d(1).folder '/' d(1).name '/n1/' ];
else
    number_folder = 1;
    sleep_stages = {'Awake'};
    sel_path = [d(1).folder '/' d(1).name '/' ];
end

%% To create a single night dataset DE-COMMENT with EXTREME CARE
single_night_mode = false; % true
% start_folder = 1;
% number_folder = 2;

%% s31 at the moment has only one night
d(strcmp({d.name}, 's31')) = [];
%%

raw_data_path = [sel_path 'result.mat'];
load(raw_data_path);        
combinations = result.combinations;
    
agg_result = struct();
for k = 1:length(d)
    sub_name = d(k).name;
    
    if string(sub_name) == "s29"
        disp('')
    end

    for j = start_folder:number_folder
        if number_folder > 1 || single_night_mode == true
            night = ['n' num2str(j)];
            sel_path = [d(k).folder '/' sub_name '/' night '/'];

            %% Create a folder for the subject
            path_checks = ['output/' selected_cond '/'  sub_name '/' night '/check_plots'];
            path_save = ['output/' selected_cond '/' sub_name '/' night '/'];

            if not(exist(path_save, 'dir'))
                status = mkdir(path_save);        
            end
        else
            path_checks = ['output/' selected_cond '/'  sub_name '/check_plots'];
            path_save = ['output/'  selected_cond '/' sub_name '/'];
            
            if not(exist(['output/'  selected_cond '/'  sub_name '/'], 'dir'))
                status = mkdir(['output/'  selected_cond '/'  sub_name '/']);        
            end
            
            sel_path = [d(k).folder '/' sub_name '/'];
            night = 'Awake';
        end
        
        %% Loading
        raw_data_path = [sel_path 'result.mat'];
        load(raw_data_path);
        sound_vector = result.sound_events.vector;
        
        for c = 1:length(combinations)
            
            for i = 1:length(sleep_stages)
                sync_cycle = result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_cycle;
                all_cycle = result.(combinations{c}).sleep_stages.(sleep_stages{i}).cycle;
                logic_selection = false(length(sound_vector), 1);
            
                if not(isempty(sync_cycle))
                    sel_cycle = all_cycle(sync_cycle, :);

                    if not(isfield(agg_result,  sub_name)) || not(isfield(agg_result.(sub_name),  night)) || not(isfield(agg_result.(sub_name).(night).sleep_stages,  sleep_stages{i}))
                        agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).sel_cycle =  sel_cycle;
                        agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).all_cycle =  all_cycle;
                        agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).tot_samples = sum(diff(all_cycle'));
                        for l = 1:size(sel_cycle, 1)
                            logic_selection(sel_cycle(l,1):sel_cycle(l,2)) = true;  
                        end
                        agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).log_cycle = logic_selection;
                    else
                        agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).sel_cycle = [agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).sel_cycle; sel_cycle];
                        for l = 1:size(sel_cycle, 1)
                            logic_selection(sel_cycle(l,1):sel_cycle(l,2)) = true; 
                        end
                        agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).log_cycle = agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).log_cycle | logic_selection;
                    end
                    agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).sync_samples = sum(agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).log_cycle);
                    agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).sync_perc = (sum(agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).log_cycle)*100)/agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).tot_samples;       
                    
                    sound_table = table();
                    sound_sel = sound_vector(agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).log_cycle);
                    if not(isempty(sound_sel))
                        counts = zeros(size(sound_codes));
                        for g = 1:length(sound_codes)
                            counts(g) = sum(sound_sel == sound_codes(g));
                        end
                        percentages = (counts / length(sound_sel)) * 100;
                        sound_table = table(sound_codes', sound_cond', counts', percentages', 'VariableNames', {'Code', 'Condition', 'Count', 'Percentage'});
                    end

                    agg_result.(sub_name).(night).sleep_stages.(sleep_stages{i}).sound_table = sound_table;   
                end             
            end
        end
        
        %% If a sync perc in at least one sleep stage is > 0, create plot
        if any(contains(fieldnames(agg_result), sub_name))
            [sleepTable] = table_summary(sleep_stages, sound_cond, agg_result.(sub_name).(night).sleep_stages);
            bar_subplot(sleep_stages, sub_name, night, 0, 0, sound_cond, sleepTable, path_save); 
            agg_result.(sub_name).(night).summary_table = sleepTable;
            
            if not(contains(fieldnames(agg_result.(sub_name)), 'general_table'))
                agg_result.(sub_name).general_table = sleepTable;
            else
                All_count = agg_result.(sub_name).general_table.All_count + sleepTable.All_count;
                Sync_count = agg_result.(sub_name).general_table.Sync_count + sleepTable.Sync_count;
                Percentages = (Sync_count ./ All_count) * 100;
                Percentages(isnan(Percentages)) = 0;
                
                newTable = table(sleep_stages, Sync_count, All_count, Percentages, ...
                               'VariableNames', {'Stage', 'Sync_count', 'All_count','Percentage'});

                sl_table = table2array(sleepTable(:, end- length(sound_cond) +1:end));
                sl_sample_cond = sl_table .* sleepTable.Sync_count;                
                gn_table = table2array(agg_result.(sub_name).general_table(:, end-length(sound_cond) +1:end));
                gn_sample_cond = gn_table .* agg_result.(sub_name).general_table.Sync_count;
                
                tot_prov_sample = sl_sample_cond + gn_sample_cond;
                per_prov = (tot_prov_sample./Sync_count);
                per_prov(isnan(per_prov)) = 0;
                
                for i = 1:length(sound_cond)
                    newTable.(sound_cond{i}) = per_prov(:, i);
                end
                
                agg_result.(sub_name).general_table = newTable;
            end
        end
    end
    
    if any(contains(fieldnames(agg_result), sub_name)) && number_folder > 1
        bar_subplot(sleep_stages, sub_name, 'cumulated', 0, 0, sound_cond, agg_result.(sub_name).general_table, path_save(1:end-3)); 
    end
    
    fprintf('Progress: %6.2f%%   -   sub =%4s\n', round((k/length(d))*100,2), sub_name);
end

save(['output/' selected_cond '.mat'], 'agg_result', '-v7.3');

% figure;
% plot(sound_vector, 'b');
% hold on;
% plot(find(logic_selection), sound_vector(logic_selection), 'r.', 'MarkerSize', 10);
% xlabel('Sample');
% ylabel('Sound Vector Value');
% legend('Sound Vector', 'Selected Points');
% grid on;

%%
% test_perc=zeros(length(d)*2,1);
% test = struct();
% codeData = [0; 96; 128; 160; 192];
% Percentage = [0; 0; 0; 0; 0];
% Count = [0; 0; 0; 0; 0];
% testtab = table(codeData, Percentage, Count, 'VariableNames', {'Code', 'Percentage', 'Count'});
% 
% for c = 1:length(combinations)
%     for i = 1:length(sleep_stages)
% 
%         kk=1;
%         for k = 1:length(d)
%             sub_name = d(k).name;
% 
%             for j = 1:2
%                 night = ['n' num2str(j)];
% 
%                 %% Load restricted part of the mat file
%                 sel_path = [d(k).folder '/' sub_name '/' night '/'];
%                 raw_data_path = [sel_path 'result.mat'];
%                 load(raw_data_path);
%                 perc = result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_perc;
%                 tab = result.(combinations{c}).sleep_stages.(sleep_stages{i}).sound_table;
%                 
%                 test_perc(kk) = perc;
%                 kk = kk + 1;
%             end
%             
%             if not(isempty(tab))
%                 for ea=1:size(tab,1)
%                     cod=tab.Code(ea);
%                     if any(testtab.Code == cod)
%                         testtab.Percentage(testtab.Code == cod)=(testtab.Percentage(testtab.Code == cod)+tab.Percentage(tab.Code == cod))/2;
%                         testtab.Count(testtab.Code == cod)=(testtab.Count(testtab.Code == cod)+tab.Count(tab.Code == cod));
%                     end
%                 end
%             end
%         end
%         test.(combinations{c}).(sleep_stages{i}) = test_perc;
%     end
%     fprintf('Combination analysed: %5.2f%     -    %4s',(c/length(combinations))*100,2, combinations{c});
% end
%         
% for c=1:length(combinations)
%     
%     meanValues = zeros(length(sleep_stages), 1);
%     % Loop to compute mean of each phase
%     for g = 1:length(sleep_stages)
%         phaseName = sleep_stages{g};
%         values = test.(combinations{c}).(phaseName);  % Get the 54 values
%         meanValues(g) = mean(values);    % Compute mean
%     end
% 
%     % Create bar plot of the mean values
%     figure;
%     subplot(1,2,1)
%     bar(meanValues);
%     ylim([0, 2.5]);
%     set(gca, 'XTickLabel', sleep_stages);  % Label x-axis with sleep phase names
%     xlabel('Sleep Phase');
%     ylabel('Mean % Value');
%     title(['Mean of sync % per Sleep Phase all subjects  -  ' combinations{c}]);
%     ax = gca; % Get current axes
%     ax.FontSize = 14;
%     axis tight
%     
%     numPhases = length(sleep_stages);
% 
%     % Initialize containers
%     allValues = [];
%     groupLabels = [];
% 
%     % Loop through each sleep phase and collect data
%     for gg = 1:numPhases
%         phaseName = sleep_stages{gg};
%         values = test.(combinations{c}).(phaseName)(:);  % Ensure it's a column vector
% 
%         % Append values and group labels
%         allValues = [allValues; values];
%         groupLabels = [groupLabels; repmat({phaseName}, length(values), 1)];
%     end
% 
%     % Create the boxplot
%     subplot(1,2,2)
%     boxplot(allValues, groupLabels);
%     ylim([0, 50]);
%     xlabel('Sleep Phase');
%     ylabel('Value');
%     title(['Sync % per Sleep Phase for each night  -  ' combinations{c}]);
%     ax = gca; % Get current axes
%     ax.FontSize = 14;
% end
