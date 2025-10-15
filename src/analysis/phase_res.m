function [theta_R] = phase_res(r_cycles_cln, r_data_cln, c_locs, k, stage, graph)
% PHASE_SYNC_PLOT function to plot in polar coordinates the phase of the R
% peaks signals in a respiratory cycle. 
% INPUT
% r_cycles_cln = 2 columns matrix, each row is a good respiratory cycle.
% r_data_cln = denoised respiratory signal
% k = range of respiratory cycles to plot
% OUTPUT
% theta_R = phase angles in the position of the R peaks.

    % If isn't indicated a range of selection (k), all the cycles are shown.
    if k == 0
        k = 1:size(r_cycles_cln, 1);
    end
    
    % Identify the R peaks inside the selected respiratory cycles.
    R_peaks_inside = c_locs > min(r_cycles_cln(k,1)) & c_locs < max(r_cycles_cln(k,2));
    H_r_data_cln = hilbert(r_data_cln);
    % Alternative method to compute the angle (same result)
    % [theta,rho] = cart2pol(real(H_r_data_cln), imag(H_r_data_cln));
    % sigphase = atan2(imag(H_r_data_cln),real(H_r_data_cln));
    theta = angle(H_r_data_cln) + pi;
    % Select the theta angle that correspond to the position of the R peak. 
    theta_R = theta(c_locs(R_peaks_inside));

    if graph == "plot"
        %% Figure for single plot
        figure
        polarhistogram(theta_R, 60, 'EdgeAlpha',0.2);
        title([stage '  -  Phase of the respiratory signal in the R-peaks instant'])
        ax = gca; % Get current axes
        ax.FontSize = 14;
        
%         figure
%         plot(theta)
%         hold on
%         plot(zscore(r_data_cln))
%         hold off

    end

    %% 3D plot test
    % selection_interv = min(c_locs(R_peaks_inside)):max(c_locs(R_peaks_inside));
    % figure
    % plot3(1:length(selection_interv),real(H_r_data_cln(selection_interv)), imag(H_r_data_cln(selection_interv)))
    % hold on
    % plot3(c_locs(R_peaks_inside), real(H_r_data_cln(c_locs(R_peaks_inside))), imag(H_r_data_cln(c_locs(R_peaks_inside))), 'o','MarkerFaceColor','red')

end