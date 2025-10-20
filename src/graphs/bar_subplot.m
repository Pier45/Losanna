function bar_subplot(sleep_stages, sub_name, title_info, m, n, sound_cond,sleepTable, path_save)
%BAR_SLEEP Summary of this function goes here
% if title info is awake, change the plot graph
    
    percentages = sleepTable.Percentage;
    fig2 = figure('doublebuffer','off', 'Visible','Off');
    set(fig2,'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

    subplot(1, 3, 1)
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
        title(['Sync % - ', sub_name, ' ', title_info]);
    else
        if convertCharsToStrings(title_info) == "Awake"
            title(['Subject ' sub_name ' - m=' num2str(m) ' n=' num2str(n)])
        else
            title(['Subject ' sub_name ' ' title_info ' - m=' num2str(m) ' n=' num2str(n)])
            xlabel('Sleep Stage');
        end
    end
    
    %% Barplot sync percentage inside each sound block
    subplot(1, 3, 2)
    data_to_plot = table2array(sleepTable(:, end-length(sound_cond)+1:end));  % Last 5 columns
    colors = [
        0.5 0.5 0.5;  % mustard
        1.0 0.0 0.0;  % red
        0.0 0.0 0.0;  % black
        0.0 0.0 1.0;  % blue
        0.7 0.7 0.7   % gray
    ];

    bar_single(data_to_plot, title_info, sleep_stages, sound_cond, colors)

    
    %% Sound vs NoSound barplot
    subplot(1, 3, 3)
    colors2 = [
    0.3922 0.4745 0.2588;  % olive green
    0.7 0.7 0.7   % slate blue
    ];
    
    sound_group = ["sound", "no sound"];
    group1 = ["baseline", "nan"];
    group2 = ["sync", "async", "isoc"];
    
    data_to_plot_3 = [sum(table2array(sleepTable(:, group1)),2), sum(table2array(sleepTable(:, group2)),2)];
    bar_single(data_to_plot_3, title_info, sleep_stages, sound_group, colors2);
    
    %% Save
    if m == 0
        print(fig2, [path_save 'aggreg_perc.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
    else
        print(fig2, [path_save 'perc_sync_bar_m' num2str(m) '_n' num2str(n) '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
    end
    
    close(fig2)
end

