function [perc_sync] = sync_phase2(cycles, theta, R_locs, avg_w, std_w, saved_windows, m, n, fs)
% SYNC_PHASE2 Summary of this function goes here

%% Initialization
    delta = 5;
    th = (2*pi*m)/(n*delta);
    
    % Compute the duration in seconds of the breathing cycles, and the total
    % time of all the selected cycles
    duration_cycles = (cycles(:,2)-cycles(:,1)) /fs;
    total_time = sum(duration_cycles);
    
    % Average of the std values windowed on 30s
    avg_std = mean(std_w(:,1:3),2);
    % Boolean condition to check if the std is under threshold.
    bool_std = avg_std<th;
    
    % Identification of breathing cycles that respect the two condition
    index_res_cycle_selected = find((bool_std)==1); %bool_cons & 
    % Find the jump between syncronization windows 
    index_jumps = [find(diff(index_res_cycle_selected)~=1);...
        find(index_res_cycle_selected == index_res_cycle_selected(end))];
    % BUG if no jump found
    
    % Final_selection is a matrix that has the number of index jums as row 
    % and 3 columns:
    % 1 = starting cycle that has syncronization;
    % 2 = stoping cycle that has syncronization;
    % 3 = lenght in seconds.
    final_selection = ones(length(index_jumps), 3);
    final_selection(:,2) = index_jumps;
    final_selection(2:end,1) = index_jumps(1:end-1)+1;
    for w=1:size(final_selection,1)
        final_selection(w,3) = sum(duration_cycles(final_selection(w,1):final_selection(w,2)));
    end
    
    bool_time_sel = final_selection(:,3)>-1;
    time_sync = sum(final_selection(bool_time_sel,3));
    perc_sync = 100*time_sync/total_time;
    
    sss = index_res_cycle_selected(final_selection(bool_time_sel,1));
    ppp = index_res_cycle_selected(final_selection(bool_time_sel,2));

    accepted_cycles = unique([saved_windows{[sss;ppp]}]);
    perc_sync_cycles = 100*length(accepted_cycles)/size(cycles,1);

    figure
    plot(theta)
    hold on
    plot(R_locs, theta(R_locs), 'o', 'MarkerFaceColor','red')
    xregion(cycles(sss,1), cycles(ppp,2), FaceColor="b")
    % xregion(cycles(:,1), cycles(:,2))
    title('Phase and selected sync window')

    figure
    plot(theta)
    hold on
    plot(R_locs, theta(R_locs), 'o', 'MarkerFaceColor','red')
    xregion(cycles(accepted_cycles,1), cycles(accepted_cycles,2), FaceColor="b")
    % xregion(cycles(:,1), cycles(:,2))
    title(['Respiratory cycles sync: ' num2str(round(perc_sync_cycles,2)) '%'])

    figure
    plot(avg_std)
    yline(th)
    xregion(sss, ppp)
    
    figure
    plot(avg_w(:,1:3), '+')
    legend('1', '2', '3')
    
    figure
    plot(std_w(:,1:3))
    yline(th)
    xregion(sss, ppp)
    legend('1', '2', '3', 'th')
    
    % figure
    % g = [zeros(length(avg_w(:,1)), 1); ones(length(avg_w(:,1)), 1); 2*ones(length(avg_w(:,1)), 1)];
    % boxplot([avg_w(:,1), avg_w(:,2), avg_w(:,3)], g, Labels={'1';'2';'3'})
end

