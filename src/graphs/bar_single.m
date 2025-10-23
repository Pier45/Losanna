function bar_single(data_to_plot, sleep_stages, sound_group, colors)
    
    b = bar(data_to_plot);

    if size(sleep_stages, 1) == 1 %convertCharsToStrings(title_info) == "Awake"
        set(gca, 'XTickLabel', sound_group);
        ylabel('Sync % in each sound event');
        
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
        
        for i = 1:length(b)
            b(i).FaceColor = colors(i, :);
            b(i).EdgeColor = 'none';        % Remove border
            b(i).FaceAlpha = 0.7;  
        end
        
        % Add legend with the column names
        legend(sound_group, 'Location', 'best');
    end

    grid on;
    ylim([0, 100]);
    set(gca, 'XGrid', 'off', 'YGrid', 'on', 'FontSize', 14);
end

