clear
close all
clc

path_folder = 'output';
d = dir([path_folder '/s*']);
is_match = ~cellfun(@isempty, regexp({d.name}, '^s\d+$'));
d = d(is_match, :);

sleep_stages = {'Awake', 'n1', 'n2', 'n3', 'REM'};

%% s31 at the moment has only one night
d(strcmp({d.name}, 's31')) = [];

%%
test_perc=zeros(length(d)*2,1);
test = struct();
codeData = [0; 96; 128; 160; 192];
Percentage = [0; 0; 0; 0; 0];
Count = [0; 0; 0; 0; 0];
testtab = table(codeData, Percentage, Count, 'VariableNames', {'Code', 'Percentage', 'Count'});

sel_path = [d(1).folder '/' d(1).name '/n1/' ];
raw_data_path = [sel_path 'result.mat'];
load(raw_data_path);        
combinations = result.combinations;

for c = 1:length(combinations)
    disp(['Combination analysed: ' num2str(round((c/length(combinations))*100,2)) '%     -    ' combinations{c}]);
    for i = 1:length(sleep_stages)

        kk=1;
        for k = 1:length(d)
            sub_name = d(k).name;

            for j = 1:2
                night = ['n' num2str(j)];

                %% Load restricted part of the mat file
                sel_path = [d(k).folder '/' sub_name '/' night '/'];
                raw_data_path = [sel_path 'result.mat'];
                load(raw_data_path);
                perc = result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_perc;
                tab = result.(combinations{c}).sleep_stages.(sleep_stages{i}).sound_table;
                
                test_perc(kk) = perc;
                kk = kk + 1;
            end
            if not(isempty(tab))
                for ea=1:size(tab,1)
                    cod=tab.Code(ea);
                    if any(testtab.Code == cod)
                        testtab.Percentage(testtab.Code == cod)=(testtab.Percentage(testtab.Code == cod)+tab.Percentage(tab.Code == cod))/2;
                        testtab.Count(testtab.Code == cod)=(testtab.Count(testtab.Code == cod)+tab.Count(tab.Code == cod));
                    end
                end
            end
        end
        test.(combinations{c}).(sleep_stages{i}) = test_perc;
    end
end
        
for c=1:length(combinations)
    
    meanValues = zeros(length(sleep_stages), 1);
    % Loop to compute mean of each phase
    for g = 1:length(sleep_stages)
        phaseName = sleep_stages{g};
        values = test.(combinations{c}).(phaseName);  % Get the 54 values
        meanValues(g) = mean(values);    % Compute mean
    end

    % Create bar plot of the mean values
    figure;
    subplot(1,2,1)
    bar(meanValues);
    ylim([0, 2.5]);
    set(gca, 'XTickLabel', sleep_stages);  % Label x-axis with sleep phase names
    xlabel('Sleep Phase');
    ylabel('Mean % Value');
    title(['Mean of sync % per Sleep Phase all subjects  -  ' combinations{c}]);
    ax = gca; % Get current axes
    ax.FontSize = 14;
    axis tight
    
    numPhases = length(sleep_stages);

    % Initialize containers
    allValues = [];
    groupLabels = [];

    % Loop through each sleep phase and collect data
    for gg = 1:numPhases
        phaseName = sleep_stages{gg};
        values = test.(combinations{c}).(phaseName)(:);  % Ensure it's a column vector

        % Append values and group labels
        allValues = [allValues; values];
        groupLabels = [groupLabels; repmat({phaseName}, length(values), 1)];
    end

    % Create the boxplot
    subplot(1,2,2)
    boxplot(allValues, groupLabels);
    ylim([0, 50]);
    xlabel('Sleep Phase');
    ylabel('Value');
    title(['Sync % per Sleep Phase for each night  -  ' combinations{c}]);
    ax = gca; % Get current axes
    ax.FontSize = 14;
end
