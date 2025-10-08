function [c_pks_cln, c_locs_cln, p_out] = filter_R_peaks(c_pks, c_locs, RR_window_pks, RR_window_len, data, stage, graph, save_path)
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


    [~, out_pks] = rmoutliers(c_pks, 'movmean', RR_window_pks);
    [~, out_len] = rmoutliers(diff(c_locs),'movmean', RR_window_len);
    
    % Add a false in front of the vector to have the same dimension between
    % logic vector for outliers and pks locations vector.
    out_len_unilenght = [false out_len];

    c_pks_cln = c_pks(not(out_pks) & not(out_len_unilenght));
    c_locs_cln = cast(c_locs(not(out_pks) & not(out_len_unilenght)), 'single');
    
    p_out = round(sum(out_len_unilenght | out_pks)/ length(c_pks)*100, 1);

    if graph == "plot"
        if contains(save_path, 's') 
            fig2 = figure('doublebuffer','off', 'Visible','Off');
            set(fig2,'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
        else
            fig2 = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);
        end
        
        plot(data, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.1)
        hold on
        plot(c_locs, c_pks,'r+')
        scatter(c_locs(out_pks), c_pks(out_pks),150, 'o','MarkerFaceColor','#FFD700', 'MarkerFaceAlpha',.5);
        plot(c_locs(out_len_unilenght), c_pks(out_len_unilenght),'bo','MarkerSize',10, 'LineWidth', 3)
        legend('ECG', ['raw peaks ' num2str(length(c_pks))], ...
            ['amp outlier ' num2str(sum(out_pks)) ' - ' num2str(round((sum(out_pks)/length(c_pks))*100,3)) '%'],...
            ['time outlier ' num2str(sum(out_len)) ' - ' num2str(round((sum(out_len)/length(c_pks))*100,3)) '%']);
        set(gca, 'LooseInset', get(gca, 'TightInset'));
        axis tight
        title([stage ' - Percentage of outlier: ' num2str(p_out) '%'])
        ax = gca; % Get current axes
        ax.FontSize = 14;
        
        if contains(save_path, 's') 
            print(fig2, [save_path '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
            close(fig2);
        end
    end
end

