function [pks, locs, pks_min, locs_min, clear_data] = clean_data_find_peaks(fc1, fc2, fs, data, name, mode, graph)
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

    [b,a] = butter(3,fc1/(fs/2),'low');% initial order 2
    f_data = filtfilt(b,a,data);

    if mode == "cardiac"
        [b,a] = butter(5,fc2/(fs/2),'low');% initial order 5
        f_data_low = filtfilt(b,a,f_data);
        clear_data = f_data-f_data_low;
        std_hb = std(clear_data);
        [pks,locs] = findpeaks(clear_data, 'MinPeakDistance', fs/2, 'MinPeakHeight',mean(clear_data)+std_hb*2);
        pks_min = 0; locs_min = 0;
    else
        [b,a] = butter(2,fc2/(fs/2),'low');
        f_data_low = filtfilt(b,a,f_data);

        clear_data = f_data-f_data_low;
        % Searching for maximum values
        [pks,locs] = findpeaks(clear_data, 'MinPeakDistance', fs*2, 'MinPeakHeight', mean(clear_data));
        % Searching for minimum values
        [pks_min,locs_min] = findpeaks(-clear_data, 'MinPeakDistance', fs*2, 'MinPeakHeight', -mean(clear_data));
        pks_min = - pks_min;
        locs_min = cast(locs_min, 'single');
    end

    locs = cast(locs, 'single');

    diff_locs = diff(locs);
    mean_hb = fs/mean(diff_locs)*60;

    if graph == "plot"
        figure
        plot(data)
        hold on
        plot(f_data, 'r')
        plot(f_data_low, 'g')
        plot(clear_data)
        plot(locs, pks, '*')
        axis tight
        if mode == "respiration"
            plot(locs_min, pks_min, 'r*')
            legend("raw data", "fileter raw data (high noise)", "low componet data", "data cleaned and aligned", "resp peaks max", "resp peaks min")
        else
            legend("raw data", "fileter raw data (high noise)", "low componet data", "data cleaned and aligned", "peaks")
        end
        title([name ' - mean ' convertStringsToChars(mode) ' frequency: ' num2str(round(mean_hb,1)) ' bpm'])
        ax = gca; % Get current axes
        ax.FontSize = 14;
    end
end


