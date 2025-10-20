function [pks, locs, pks_min, locs_min, clear_data, mean_bpm] = clean_data_find_peaks(fc, fs, data, sleep_stage, mode, graph)
% CLEAN_DATA_FIND_PEAKS
% INPUT
% fc1 = cut off frequency.
% fc2 = cut off frequency mean signal identification.
% fs = sampling frequency.
% data = data in columns or row.
% name = the sleep stage.
% mode = "cardiac" for the analysis of ECG data, "respiration" for respiration.
% graph = choose between "plot" to show a graph or "no".
%
% OUTPUT
% pks = amplitude of the peaks.
% locs = x position of the peaks.
% clear_data = filtered and aligned data.
% mean_bpm = mean heart beat

    if not(isempty(data))
        
        %% Check for saturation sections    
        th_bad_section = 5;        
        N = fs;  % 1sec Number of samples to expand (left and right) bad areas
        std_data = std(data);
        mov_mean = movmedian(data, fs*45);
        log_bad_sections = data > mov_mean+std_data*th_bad_section | data < mov_mean-std_data*th_bad_section;
        cl_data = data;
        log_bad_sections = conv(double(log_bad_sections), ones(1, 2*N+1), 'same') > 0;
        cl_data(log_bad_sections) = mov_mean(log_bad_sections);
        rem_samples = sum(log_bad_sections);
        
        if rem_samples > 0
            fprintf('%11s - %5s - Saturation sections - %.3f%% of signal.\n', mode, sleep_stage, rem_samples/length(data)*100);        
        end
                

        if mode == "cardiac"
            [b,a] = butter(8,fc/(fs/2),'low');
            f_data = filtfilt(b,a,cl_data);
            
            f_data_low = movmedian(f_data, fs);
            clear_data = f_data-f_data_low;
            std_hb = std(clear_data);
            [pks,locs] = findpeaks(clear_data, 'MinPeakDistance', fs/2, 'MinPeakHeight',mean(clear_data)+std_hb);
            pks_min = 0; locs_min = 0;
        else
            [b,a] = butter(4,fc/(fs/2),'low');
            f_data = filtfilt(b,a,cl_data);
            
            f_data_low = movmedian(f_data, fs*45);

            clear_data = f_data-f_data_low;
            % Searching for maximum values
            [pks,locs] = findpeaks(clear_data, 'MinPeakDistance', fs*3, 'MinPeakHeight', mean(clear_data));
            % Searching for minimum values
            [pks_min,locs_min] = findpeaks(-clear_data, 'MinPeakDistance', fs*3, 'MinPeakHeight', -mean(clear_data));
            pks_min = - pks_min;
            locs_min = cast(locs_min, 'single');
        end

        locs = cast(locs, 'single');

        diff_locs = diff(locs);
        mean_bpm = fs/mean(diff_locs)*60;

        if graph == "plot"
            diff_vec = diff([false, log_bad_sections, false]);  % pad to detect edges
            starts = find(diff_vec == 1);   % where false → true
            
            fig = figure;
            set(fig,'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

            subplot(2, 1, 1)
            plot(data, 'k')
            hold on
            plot(cl_data, 'b')
            plot(f_data, 'r')
            plot(mov_mean+std_data*th_bad_section, '--');
            plot(mov_mean-std_data*th_bad_section, '--');
            plot(f_data_low, 'g')
            legend("raw data", "cl_data","fileter raw data (high noise)", "th up", "th down","low componet data")
            
            for i = 1:length(starts)
                xline(starts(i), 'r--', 'LineWidth', 1);
            end
            
            subplot(2, 1, 2)
            plot(clear_data)
            hold on
            plot(locs, pks, '*')
            axis tight
            if mode == "respiration"
                plot(locs_min, pks_min, 'r*')
                legend("data cleaned and aligned", "resp peaks max", "resp peaks min")
            else
                legend("data cleaned and aligned", "peaks")
            end
            title([sleep_stage ' - mean ' convertStringsToChars(mode) ' frequency: ' num2str(round(mean_bpm,1)) ' bpm'])
            ax = gca; % Get current axes
            ax.FontSize = 14;
            
            ax = findall(gcf, 'type', 'axes');  % get handles to all axes
            linkaxes(ax, 'x');
        end
    else
        warning([sleep_stage ' - No sleep stage data'])
        pks = 0;
        locs = 0;
        pks_min = 0;
        locs_min = 0;
        clear_data = 0;
        mean_bpm = 0;
    end
end


