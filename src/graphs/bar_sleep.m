function [sleepTable] = bar_sleep(sleep_stages, sub_name, night, m, n, sound_cond, prov_struct, path_save)
%BAR_SLEEP Summary of this function goes here
% Create the table
    sl_sync = fieldnames(prov_struct);
    percentages = zeros(length(sleep_stages), 1);

    % Loop through each stage and extract the percentage
    for i = 1:length(sleep_stages)
        stage_name = sleep_stages{i};

        % Only proceed if the stage exists in the struct
        if ismember(stage_name, sl_sync)
            percentages(i) = prov_struct.(stage_name).sync_perc;
        else
            percentages(i) = 0; 
        end
    end
            
    sleepTable = table(sleep_stages, percentages, ...
                               'VariableNames', {'Stage', 'Percentage'});
    
    for i = 1:length(sound_cond)
        sleepTable.(sound_cond{i}) = zeros(height(sleepTable), 1);
    end

    for slstage=1:length(sleep_stages)
        if any(ismember(fieldnames(prov_struct), sleep_stages{slstage})) && not(isempty(prov_struct.(sleep_stages{slstage}).sound_table))
            sleepTable{slstage, sound_cond} = prov_struct.(sleep_stages{slstage}).sound_table.Percentage';
        end
    end
            
    fig2 = figure('doublebuffer','off', 'Visible','Off');
    set(fig2,'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

    subplot(1, 2, 1)
    bar(percentages, 'FaceColor', [0.2 0.8 0.8], 'EdgeColor', 'w');
    set(gca, 'XTickLabel', sleep_stages, 'FontSize',14);
    ylabel('Percentage (%)');

    grid on;
    ylim([0, 60]);

    %% Add percentage text above each bar
    for i = 1:length(percentages)
        % Only show label if it's not NaN
        if ~isnan(percentages(i))
            text(i, percentages(i) + 1, sprintf('%.1f%%', percentages(i)), ...
                'HorizontalAlignment', 'center', 'FontSize', 14);
        end
    end
    
    if m == 0
        %% Aggregated graph
        title(['Sync % - ', sub_name, ' night ', night(2)]);
    else
        if convertCharsToStrings(night) == "n0"
            title(['Subject ' sub_name ' - m=' num2str(m) ' n=' num2str(n)])
        else
            title(['Subject ' sub_name ' ' night ' - m=' num2str(m) ' n=' num2str(n)])
            xlabel('Sleep Stage');
        end
    end
    
    subplot(1, 2, 2)
    data_to_plot = table2array(sleepTable(:, 3:end));  % Last 5 columns
    %colors = {'g', 'r','k','b', [.7 .7 .7]}; % pastel shades [0.9290 0.6940 0.1250]
    colors = [
        0.9290 0.6940 0.1250;  % mustard
        1.0000 0.0000 0.0000;  % red
        0.0000 0.0000 0.0000;  % black
        0.0000 0.0000 1.0000;  % blue
        0.7000 0.7000 0.7000   % gray
    ];
    % Create the bar plot
    b = bar(data_to_plot);

    % Customize the plot
    if convertCharsToStrings(night) == "n0"
        set(gca, 'XTickLabel', sound_cond);
        ylabel('Sync % in each sound event');
        title('Sound Conditions');
        
        b.FaceColor = 'flat';  % Enable individual bar coloring

        for i = 1:length(data_to_plot)
            b.CData(i, :) = colors(i, :);  % Apply each color
        end
        b.EdgeColor = 'none';
        b.FaceAlpha = 0.7;
    else
        set(gca, 'XTickLabel', sleep_stages);
        xlabel('Sleep Stage');
        ylabel('Sync % in each sound event');
        title('Sound Conditions by Sleep Stage');
        
        for i = 1:length(b)
            b(i).FaceColor = colors(i, :);
            b(i).EdgeColor = 'none';        % Remove border
            b(i).FaceAlpha = 0.7;  
        end
        
        % Add legend with the column names
        legend(sleepTable.Properties.VariableNames(3:end), 'Location', 'best');

    end


    grid on;
    ylim([0, 100]);
    set(gca, 'XGrid', 'off', 'YGrid', 'on', 'FontSize', 14);
    
    if m == 0
        print(fig2, [path_save 'aggreg_perc.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
    else
        print(fig2, [path_save 'perc_sync_bar_m' num2str(m) '_n' num2str(n) '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
    end
    
    close(fig2)
end

