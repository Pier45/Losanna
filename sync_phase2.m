function [perc_sync, sync_cycle] = sync_phase2(m_cycle, phase, R_locs, std_w, saved_windows, m, n, delta, sleep_stage, fs, graph)
% SYNC_PHASE2 compute the percentage of synchronized cycles under the threshold.
	
    %% Threshold formula.
    th = (2*pi*m)/(n*delta);
    
    total_time = length(phase)/fs;
    
    % Average of the std values computed on windows of 30 seconds.
    avg_std = mean(std_w(:,1:n),2);
    % Boolean that checks if the std is under threshold.
    bool_std = avg_std < th;
    
    % Identification of breathing cycles that respect the condition.
    index_cycle_selected = find((bool_std)==1); 
    
    sync_cycle = unique([saved_windows{index_cycle_selected}]);
    %perc_sync_cycles = 100*length(sync_cycle)/size(cycles,1);
    
    % Computing the percentage of time in seconds where there is
    % synchronization (equal to perc_sync_cycles).
    duration_cycles = (m_cycle(sync_cycle,2)-m_cycle(sync_cycle,1))/fs;

    time_sync = sum(duration_cycles);
    perc_sync = 100*time_sync/total_time;
    
    if graph
        figure
        plot(phase)
        hold on 
        plot(R_locs, phase(R_locs), 'o', 'MarkerFaceColor','red')
        % Not compatible with Matlab 2019a
        % xregion(m_cycle(sync_cycle,1), m_cycle(sync_cycle,2), FaceColor="b")
        draw_xregion(m_cycle(sync_cycle,1), m_cycle(sync_cycle,2), ylim, 'b', 0.3);
        for i = 1:length(index_cycle_selected)
            xline(m_cycle(index_cycle_selected(i),1), '-', num2str(index_cycle_selected(i)));
        end
        title(['Sleep phase ' sleep_stage '   -   Respiratory cycles sync: ' num2str(round(perc_sync,2)) '%'])
        ax = gca; % Get current axes
        ax.FontSize = 14;

        figure
        bar(std_w)
        string_vector = arrayfun(@num2str, 1:n, 'UniformOutput', false);
        hold on
        plot(avg_std, '*', 'MarkerSize',15)
        yline(th,'-', 'Threshold for selection')
        % Not compatible with Matlab 2019a
        % xline(index_cycle_selected, '-', num2cell(index_cycle_selected))
        for i = 1:length(index_cycle_selected)
            xline(index_cycle_selected(i), '-', num2str(index_cycle_selected(i)));
        end
        title(['Sleep phase ' sleep_stage '   -   Respiratory cycles sync: ' num2str(round(perc_sync,2)) '%'])
        legend(string_vector{:}, 'mean std for cycle')
        ax = gca; % Get current axes
        ax.FontSize = 14;
    end
end

