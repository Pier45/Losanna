function [theta, R_res_cycle, avg_w, std_w, saved_windows, m_cycle] = sync_phase1(cycles, R_locs, data, T, m, n, fs)
% SYNC_PHASE1 extract the phase angle of the respiratory signal and possible
% windows of synchronization.
%
% INPUT
% cycles = matrix of 2 columns that contains the starting and ending
%          point of the breathing cycles.
% R_locs = location of the R peaks.
% data = respiratory signal.
% T = length in seconds of the window.
% m = number of breathing cycle.
% n = number of R peaks.
% fs = sampling frequency. 
%
% OUTPUT
% theta = angle of hilbert transform in rad.
% avg_w = mean value of the angle for each respiratory cycle in the window.
%         (at the moment unused).
% std_w = std value of the angle for each respiratory cycle in the window.
% saved_windows = saved windows that respect the selection criteria.

    n_row = round(size(cycles, 1)/m);
    % Define cycles end before padding
    if not(isempty(cycles))
        cycles_end = cycles(end,2);

        if mod(size(cycles, 1), m) ~= 0
            padding_size = m - mod(size(cycles, 1), m);
            cycles = [cycles; zeros(padding_size, size(cycles, 2))];
        end

        % Each R_peak is associated with a respiratory cycle
        % Rp_res_cycle is a matrix that has the number of respiratory cycles/m as
        % rows and n number of columns.
        start = 1;
        R_res_cycle = zeros(n_row, n);
        for i=1:(n_row) % check errors  prima era - m + 1
            pos_R = 1;
            % if i == 13
            %     disp('debug i sync1')
            % end
            start_index = i*m - m + 1;
            stop_index = i*m;

            open_w = cycles(start_index, 1);
            close_w = cycles(stop_index,2);

            for j=start:length(R_locs)
                % Select only the R peaks inside a respiratory cycle, in the
                % matrix is inserted the time in seconds.
                % if j==38
                %     disp('debug j sync1')
                % end

                if R_locs(j) > open_w && R_locs(j) < close_w 
                    if pos_R <= n
                        R_res_cycle(i,pos_R) = R_locs(j);
                    else
                        R_res_cycle(i,:) = 0; % The row is set to 0 because exceed the number of desired R peaks (n)
                    end
                    pos_R = pos_R + 1;
                else
                    if pos_R > 1
                        % Record the last loc for the R peak so next iteration
                        % it will stat from that peak, and not iterate from the
                        % beginning.
                        start = j;
                        break
                    end
                end
            end
        end

        H_res_data = hilbert(data);
        theta = angle(H_res_data);

        % figure
        % plot(theta)
        % hold on
        % plot(zscore(real(H_res_data)))
        % plot(R_locs, theta(R_locs), 'o', 'MarkerFaceColor','red')
        % axis tight

        %% Initialization of matrix for the moving windows
        avg_w = nan(n_row, n);
        std_w = nan(n_row, n);

        %% 1) Check if all the respiratory cycles are consecutive
        m_cycle = zeros(n_row, 2);
        m_cycle(:, 1) = cycles(1:m:end, 1);
        m_cycle(:, 2) = cycles(m:m:end, 2);
        m_cycle = single(m_cycle);
        bool_cons = true(length(cycles) - mod(length(cycles), m),1);
        for g=2:length(cycles)
            if cycles(g,1) ~= cycles(g-1,2)
                bool_cons(g)=0;
            end
        end

        if m > 1
            prov = reshape(bool_cons, m, []);
            bool_cons_f = (prov(1,:) & prov(2,:))';
        else
            bool_cons_f = bool_cons;
        end

        %% 2) Check if there is exactly n R peaks inside m respiratory cycle 
        bool_one = sum(not(R_res_cycle==0), 2) == n;
        bool_tot = bool_one & bool_cons_f;

        saved_windows = cell(n_row, 1);
        for k=1:n
            % if k == 3
            %     disp('debug k')
            % end

            for c=1:size(R_res_cycle,1)
                % if c == 10
                %     disp('debug c')
                % end

                % If the two check are respected, identify a window of length T
                if bool_tot(c)
                    begin_W  = find(R_res_cycle(:,k) >= R_res_cycle(c,k), 1, 'first' );
                    close_W = find(R_res_cycle(:,k) < R_res_cycle(c,k)+T*fs & R_res_cycle(:,k)~= 0, 1, 'last');
                    th_len_W = (m_cycle(close_W,2)-m_cycle(begin_W,1)) >= T*fs;
                    window = begin_W:close_W;

                    % Check if inside the selected windows all R peaks respect
                    % check 1 & 2. Moreover, the window must not exceed the
                    % length of the signal.
                    if sum(bool_tot(window)) == length(window) && cycles_end >= R_res_cycle(c,k)+T*fs && th_len_W
                        idx_R_peaks = R_res_cycle(window,k);
                        avg_w(c, k) = mean(theta(idx_R_peaks) + pi);
                        std_w(c, k) = std(theta(idx_R_peaks));
                        saved_windows{c, 1} = window; % semplificato rage sono gli stessi, ma da controllare 
                    end
                end
            end
        end
    else
        theta=0;
        R_res_cycle=0;
        avg_w=0;
        std_w=0;
        saved_windows=0;
        m_cycle=0;
    end
    
end


