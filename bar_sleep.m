function [sleepTable] = bar_sleep(sleep_stages,percentages, sub_name, night, m, n, path_save)
%BAR_SLEEP Summary of this function goes here
% Create the table
    sleepTable = table(sleep_stages, percentages, ...
                               'VariableNames', {'Stage', 'Percentage'});
    % Display the table
%             disp(sleepTable);

    fig2 = figure('doublebuffer','off', 'Visible','Off');
    bar(percentages, 'FaceColor', [0.2 0.8 0.8], 'EdgeColor', 'w');
    set(gca, 'XTickLabel', sleep_stages);
    ylabel('Percentage (%)');
    xlabel('Sleep Stage');

    grid on;
    ylim([0, 60]);

    %% Add percentage text above each bar
    for i = 1:length(percentages)
        % Only show label if it's not NaN
        if ~isnan(percentages(i))
            text(i, percentages(i) + 1.5, sprintf('%.1f%%', percentages(i)), ...
                'HorizontalAlignment', 'center', 'FontSize', 10);
        end
    end
    
    if m == 0
        title(['Sync breathing cycles percentage - ', sub_name, ' night ', night(2)]);
        print(fig2, [path_save 'aggreg_perc.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
    else
        if convertCharsToStrings(night) == "n0"
            title(['Subject ' sub_name ' - m=' num2str(m) ' n=' num2str(n)])
        else
            title(['Subject ' sub_name ' ' night ' - m=' num2str(m) ' n=' num2str(n)])
        end
        print(fig2, [path_save 'perc_sync_bar_m' num2str(m) '_n' num2str(n) '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
    end
    close(fig2)
end

