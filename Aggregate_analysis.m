clear
close all
clc

addpath(genpath('src'))

%% Select the folder, 1 sleep, 2 awake
conditions = ['sleep'; 'awake'];
selected_cond = conditions(2,:);

path_folder = ['output/', selected_cond];
d = dir([path_folder '/s*']);
is_match = ~cellfun(@isempty, regexp({d.name}, '^s\d+$'));
d = d(is_match, :);

if convertCharsToStrings(selected_cond) == "sleep"
    number_folder = 2;
    sleep_stages = {'Awake', 'REM', 'n1', 'n2', 'n3'}';
    sel_path = [d(1).folder '/' d(1).name '/n1/' ];
else
    number_folder = 1;
    sleep_stages = {'Awake'};
    sel_path = [d(1).folder '/' d(1).name '/' ];
end

%% s31 at the moment has only one night
d(strcmp({d.name}, 's31')) = [];
sound_cond = {'nan', 'sync', 'async', 'isoc', 'baseline'};
sound_codes = [0, 96, 160, 128, 192];

raw_data_path = [sel_path 'result.mat'];
load(raw_data_path);        
combinations = result.combinations;

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

    
agg_result = struct();
for k = 1:length(d)
    sub_name = d(k).name;

    for j = 1:number_folder
        if number_folder > 1
            night = ['n' num2str(j)];
            sel_path = [d(k).folder '/' sub_name '/' night '/process/'];

            %% Create a folder for the subject
            path_checks = ['output/sleep/'  sub_name '/' night '/check_plots'];
            path_save = ['output/sleep/' sub_name '/' night '/'];

            if not(exist(path_save, 'dir'))
                status = mkdir(path_save);        
            end
        else
            path_checks = ['output/awake/'  sub_name '/check_plots'];
            path_save = ['output/awake/' sub_name '/'];
            
            if not(exist(['output/awake/'  sub_name '/'], 'dir'))
                status = mkdir(['output/awake/'  sub_name '/']);        
            end
            
            sel_path = [d(k).folder '/' sub_name '/'];
            night = 'n0';
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
            [sleepTable] = bar_sleep(sleep_stages, sub_name, night, 0, 0, sound_cond, agg_result.(sub_name).(night).sleep_stages, path_save);             
            agg_result.(sub_name).(night).summary_table = sleepTable;
        end
    end
    fprintf('Progress: %6.2f%%   -   sub =%4s\n', round((k/length(d))*100,2), sub_name);
end

% figure;
% plot(sound_vector, 'b');
% hold on;
% plot(find(logic_selection), sound_vector(logic_selection), 'r.', 'MarkerSize', 10);
% xlabel('Sample');
% ylabel('Sound Vector Value');
% legend('Sound Vector', 'Selected Points');
% grid on;
