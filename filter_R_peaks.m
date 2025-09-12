function [c_pks_cln, c_locs_cln, p_out] = filter_R_peaks(c_pks, c_locs, RR_window_pks, RR_window_len, data, graph)
% FILTER_R_PEAKS 
% Identification of R peaks that are outliers. The identification criteria
% are:
%   1) Amplitude of the peak, computed using MAD, in a moving window of a
%   length set as input (RR_window)
%   2) Samples distance between R peaks, using the same algorithm as case 1
% INPUT
% c_pks = Amplitude of R peaks.
% c_locs = Locations of R peaks.
% RR_window_pks = Length of the window (in samples) for the outliers
%                 Identification for the amplitude of the signal. 
% RR_window_len = Length of the window (in samples) for the outliers
%				  identification for the time between 2 R peaks.
% data = ECG
% graph = choose between "plot" to show a graph or "no" to not show nothing. 
%
% OUTPUT
% c_pks_cln = Amplitude of the selected peaks.
% c_locs_cln = Location in samples) of the selected peaks.
% p_out = percentage outlires of R peaks.


    [~, out_pks] = rmoutliers(c_pks, 'movmedian', RR_window_pks);
    [~, out_len] = rmoutliers(diff(c_locs),'movmedian', RR_window_len);
    
    % Add a false in front of the vector to have the same dimension between
    % logic vector for outliers and pks locations vector.
    out_len_unilenght = [false out_len];

    c_pks_cln = c_pks(not(out_pks) & not(out_len_unilenght));
    c_locs_cln = cast(c_locs(not(out_pks) & not(out_len_unilenght)), 'single');
    
    p_out = round(sum(out_len_unilenght | out_pks)/ length(c_pks)*100, 1);

    if graph == "plot"
        figure
        plot(data, 'k')
        hold on
        plot(c_locs, c_pks,'r+')
        plot(c_locs(out_pks), c_pks(out_pks),'ro','MarkerSize',20)
        plot(c_locs(out_len_unilenght), c_pks(out_len_unilenght),'bo','MarkerSize',10)
        legend('ECG', ['raw peaks ' num2str(length(c_pks))], ['amp outlier ' num2str(sum(out_pks))], ['time outlier ' num2str(sum(out_len))])
        axis tight
        title(['Percentage of outlier: ' num2str(p_out) '%'])
        ax = gca; % Get current axes
        ax.FontSize = 14;
    end
end

