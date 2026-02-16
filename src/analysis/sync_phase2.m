function [perc_sync, sync_cycle, sync_samples, total_samples_filtered] = sync_phase2(m_cycle, phase, R_locs, std_w, saved_windows, m, n, delta, sleep_stage, fs, graph)
% SYNC_PHASE2 compute the percentage of synchronized cycles under the threshold.
    
    if not(isempty(m_cycle)) && not(length(m_cycle) == 1)
        %% Threshold formula.
        th = (2*pi*m)/(n*delta);
        
        %% Section to be improved in sync_phase1 and also other problem why 
        %m_cycle = 0 
        zero_test = m_cycle(:,2);
        m_cycle(zero_test == 0, :) = [];
        %%
        
        total_samples_filtered = sum(diff(m_cycle'));

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
        duration_cycles = (m_cycle(sync_cycle,2)-m_cycle(sync_cycle,1));

        sync_samples = sum(duration_cycles);
        perc_sync = 100*sync_samples/total_samples_filtered;

        if graph && perc_sync~=0
            t = 0:1/fs:length(phase)/fs;
            t(end) = [];

            figure
            plot(t, phase)
            xlabel('Time (s)');
            ylabel('Phase');
            hold on 
            plot(R_locs/fs, phase(R_locs), 'o', 'MarkerFaceColor','red')
            % Not compatible with Matlab 2019a
            % xregion(m_cycle(sync_cycle,1), m_cycle(sync_cycle,2), FaceColor="b")
            start = m_cycle(sync_cycle,1)/fs;
            stop = m_cycle(sync_cycle,2)/fs;
            draw_xregion(start, stop, ylim, 'b', 0.3);
            for i = 1:length(index_cycle_selected)
                xline(m_cycle(index_cycle_selected(i),1)/fs, '-', num2str(index_cycle_selected(i)));
            end
            % title(['Sleep phase ' sleep_stage '   -   Respiratory cycles sync: ' num2str(round(perc_sync,2)) '%'])
            legend('Phase of respiratory signal', 'R peaks')
            ax = gca; % Get current axes
            ax.FontSize = 16;
            ti = ax.TightInset;
            ax.Position = [ti(1) ti(2)+0.1 1-ti(3)-ti(1) 1-ti(4)-ti(2)-0.11];

            figure
            bar(std_w)
            % Finalize the bar plot with labels and title
            xlabel('Cycle Index');
            ylabel('Standard Deviation');
            string_vector = arrayfun(@num2str, 1:n, 'UniformOutput', false);
            hold on
            plot(avg_std, '*', 'MarkerSize',15)
            yline(th,'-', 'Threshold for selection');
            % Not compatible with Matlab 2019a
            % xline(index_cycle_selected, '-', num2cell(index_cycle_selected))
            for i = 1:length(index_cycle_selected)
                xline(index_cycle_selected(i), '-', num2str(index_cycle_selected(i)));
            end
            % title(['Sleep phase ' sleep_stage '   -   Respiratory cycles sync: ' num2str(round(perc_sync,2)) '%'])
            legend(string_vector{:}, 'mean std for cycle')
            ax = gca; % Get current axes
            ax.FontSize = 16;
            ti = ax.TightInset;
            ax.Position = [ti(1) ti(2)+0.1 1-ti(3)-ti(1) 1-ti(4)-ti(2)-0.11];
        end
    else
        perc_sync = 0;
        sync_cycle = [];
        sync_samples = 0;
        total_samples_filtered = 0;
    end
end

