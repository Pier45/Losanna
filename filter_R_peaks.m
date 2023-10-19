function [c_pks_cln, c_locs_cln, out_pks, out_len_unilenght] = filter_R_peaks(c_pks, c_locs, RR_window_pks, RR_window_len, data)
% FILTER_R_PEAKS 
% Identification of R peaks that are outliers. The identification criteria
% are:
%   1) Amplitude of the peak, computed using MAD, in a moving window of a
%   length set as input (RR_window)
%   2) Samples distance between R peaks, using the same algorithm as case
%   1.

    [~, out_pks] = rmoutliers(c_pks, 'movmedian', RR_window_pks);
    [~, out_len] = rmoutliers(diff(c_locs),'movmedian', RR_window_len);
    
    % Add a false in front of the vector to have the same dimention between
    % logic vector for outliers and pks locations vector.
    out_len_unilenght = [false out_len];

    c_pks_cln = c_pks(not(out_pks) & not(out_len_unilenght));
    c_locs_cln = c_locs(not(out_pks) & not(out_len_unilenght));
    
    figure
    plot(data, 'k')
    hold on
    plot(c_locs, c_pks,'r+')
    plot(c_locs(out_pks), c_pks(out_pks),'ro','MarkerSize',40)
    plot(c_locs(out_len_unilenght), c_pks(out_len_unilenght),'bo','MarkerSize',20)
    legend(["data", "raw peaks", "pks outlier", "time outlier"])
    axis tight
    title(['Number of peaks: ' num2str(length(c_pks)) ' - Number of outlier: ' num2str(sum(out_len_unilenght | out_pks))])
end

