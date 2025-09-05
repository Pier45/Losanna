function [perc_sync, accepted_cycles] = sync_phase2(new_cycles, theta, R_locs, std_w, saved_windows, m, n, delta, sleep_stage, fs)
% SYNC_PHASE2 compute the percentage of synchronized cycles under the threshold.
	
    %% Threshold formula.
    th = (2*pi*m)/(n*delta);
    
    total_time = length(theta)/fs;
    
    % Average of the std values computed on windows of 30 seconds.
    avg_std = mean(std_w(:,1:n),2);
    % Boolean that checks if the std is under threshold.
    bool_std = avg_std < th;
    
    % Identification of breathing cycles that respect the condition.
    index_cycle_selected = find((bool_std)==1); 
    
    accepted_cycles = unique([saved_windows{index_cycle_selected}]);
    %perc_sync_cycles = 100*length(accepted_cycles)/size(cycles,1);
    
    % Computing the percentage of time in seconds where there is
    % synchronization (equal to perc_sync_cycles).
    duration_cycles = (new_cycles(accepted_cycles,2)-new_cycles(accepted_cycles,1))/fs;

    time_sync = sum(duration_cycles);
    perc_sync = 100*time_sync/total_time;
    
    if isempty(accepted_cycles)
        warning([sleep_stage ' - Not found any locking cycle'])
    else
        figure
        plot(theta)
        hold on
        plot(R_locs, theta(R_locs), 'o', 'MarkerFaceColor','red')
        % xregion(cycles(accepted_cycles,1), cycles(accepted_cycles,2), FaceColor="b")
        xregion(new_cycles(accepted_cycles,1), new_cycles(accepted_cycles,2), FaceColor="b")
        title(['Sleep phase ' sleep_stage '   -   Respiratory cycles sync: ' num2str(round(perc_sync,2)) '%'])
        ax = gca; % Get current axes
        ax.FontSize = 14;

        figure
        bar(std_w)
        string_vector = arrayfun(@num2str, 1:n, 'UniformOutput', false);
        hold on
        plot(avg_std, '*', 'MarkerSize',15)
        yline(th,'-', 'Threshold for selection')
        xline(index_cycle_selected, '-', num2cell(index_cycle_selected))
        title(['Sleep phase ' sleep_stage '   -   Respiratory cycles sync: ' num2str(round(perc_sync,2)) '%'])
        legend(string_vector{:}, 'mean std for cycle')
        ax = gca; % Get current axes
        ax.FontSize = 14;
    end
end

