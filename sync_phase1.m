function [theta, avg_w, std_w, saved_windows] = sync_phase1(cycles, R_locs, data, T, m, n, fs)
% SYNC_PHASE1 extract the phase angle of the respiratory signal and possible
% windows of synchronization
% INPUT
% cycles = matrix of 2 columns that contains the starting and ending
%          point ot the breathing cycles.
% R_locs = location of the R peaks.
% data = respiratory signal.
% T = lenght in seconds of the window.
% m = number of breathing cycle.
% n = number of R peaks.
% fs = sampling frequency. 
% OUTPUT
% theta = angle of hilbert trasform in rad.
% avg_w = mean value of the angle for each respiratory cycle in the window.
%         (at the moment unused).
% std_w = std value of the angle for each respiratory cycle in the window.
% saved_windows = saved windows that respect the selection criteria.

    % Each R_peak is associated with a respiratory cycle
    % Rp_res_cycle is a matrix that has the number of respiratory cycles as
    % rows and 5 number of columns (max 5 peaks for a respiration cycles can
    % be identified).
    start = 1;
    R_res_cycle = nan(size(cycles,1),5);
    for i=1:length(cycles)
        pos_R = 1;
        % if i == 19
        %     disp('debug')
        % end
        
        for j=start:length(R_locs)
            % Select only the R peaks inside a respiratory cycle, in the
            % matrix is inserted the time in seconds.
            if R_locs(j) > cycles(i,1) && R_locs(j) < cycles(i,2)
                R_res_cycle(i,pos_R) = R_locs(j)/fs;
                pos_R = pos_R + 1;
            else
                if pos_R > 1
                    % Record the last loc for the R peak so next iteration
                    % it will stat from that peak, and not iterate from the
                    % beginign.
                    start = j;
                    break
                end
            end
        end
    end
    
    H_r_data_cln = hilbert(data);
    theta = angle(H_r_data_cln);

    % figure
    % plot(theta)
    % hold on
    % plot(zscore(real(H_r_data_cln)))
    % plot(R_locs, theta(R_locs), 'o', 'MarkerFaceColor','red')
    % axis tight

    %% Initialization of matrix for the moving windows
    avg_w = nan(size(R_res_cycle, 1), n);
    std_w = nan(size(R_res_cycle, 1), n);
        
    % 1) Check if all the respiratory cycles are consecutive
    bool_cons = true(length(cycles),1);
    for g=2:length(cycles)
        if cycles(g,1) ~= cycles(g-1,2)
            bool_cons(g)=0;
        end
    end

    % 2) Check if there is exactly n R peaks inside m respiratory cycle 
    bool_one = sum(not(isnan(R_res_cycle)), 2) == n;
    bool_tot = bool_one & bool_cons;
    
    saved_windows = cell(size(cycles, 1), 1);
    for k=1:n
        % if k == 3
        %     disp('s')
        % end

        for c=1:size(R_res_cycle,1)
            % if c == 23
            %     disp('debug')
            % end

            % If the two check are respected, identify a window of length T
            if bool_tot(c)
                begin_W  = find(R_res_cycle(:,k) >= R_res_cycle(c,k), 1, 'first' );
                close_W = find(R_res_cycle(:,k) < R_res_cycle(c,k)+T, 1, 'last'); % Bug che si risolve fuori  da solo ma da rivedere caso in cui c'è un nan per una colonna e altri no
                window = begin_W:close_W;
                
                % Check if inside the selected windows all R peaks respect
                % check 1 & 2. Moreover, the window must not exceed the
                % length of the signal.
                if sum(bool_tot(window)) == length(window) && cycles(end,2)/fs >= R_res_cycle(c,k)+T
                    idx_R_peaks = R_res_cycle(window,k)*fs;
                    avg_w(c, k) = mean(theta(idx_R_peaks) + pi);
                    std_w(c, k) = std(theta(idx_R_peaks));
                    saved_windows{c, 1} = window; % semplificato rage sono gli stessi, ma da controllare 
                end
            end
        end
    end
end


