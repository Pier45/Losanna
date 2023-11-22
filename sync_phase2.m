function [perc_sync, accepted_cycles] = sync_phase2(cycles, theta, R_locs, avg_w, std_w, saved_windows, m, n, fs)
% SYNC_PHASE2 Summary of this function goes here

%% Initialization
    delta = 5;
    th = (2*pi*m)/(n*delta);
    
    % Compute the duration in seconds of the breathing cycles, and the total
    % time of all the selected cycles
    duration_cycles = (cycles(:,2)-cycles(:,1))/fs;
    total_time = sum(duration_cycles);
    
    % Average of the std values computed on windowes on 30 seconds.
    avg_std = mean(std_w(:,1:3),2);
    % Boolean condition to check if the std is under threshold.
    bool_std = avg_std < th;
    
    % Identification of breathing cycles that respect the two condition
    index_cycle_selected = find((bool_std)==1); 
    
    accepted_cycles = unique([saved_windows{index_cycle_selected}]);
    %perc_sync_cycles = 100*length(accepted_cycles)/size(cycles,1);
    
    % Computing the percentage of time in seconds where there is
    % syncronization (equal to perc_sync_cycles).
    time_sync = sum(duration_cycles(accepted_cycles));
    perc_sync = 100*time_sync/total_time;
    
    if isempty(accepted_cycles)
        warning("Not found any respiratory cycle sync.")
    else
        figure
        plot(theta)
        hold on
        plot(R_locs, theta(R_locs), 'o', 'MarkerFaceColor','red')
        xregion(cycles(accepted_cycles,1), cycles(accepted_cycles,2), FaceColor="b")
        title(['Respiratory cycles sync: ' num2str(round(perc_sync,2)) '%'])
    
        figure
        bar(1:size(cycles, 1), std_w(:,1:3))
        hold on
        plot(avg_std, '*', 'MarkerSize',10)
        yline(th,'-', 'Threshold for selection')
        xline(index_cycle_selected, '-', num2cell(index_cycle_selected))
        legend('std angle 1', 'std angle 2', 'std angle 3', 'mean std for cycle', 'Location','bestoutside')
    end
end

