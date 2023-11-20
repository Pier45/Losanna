function [x] = phase_sync_plot(r_cycles_cln, r_data_cln, c_locs, k)
% PHASE_SYNC_PLOT function to plot in polar coordinates the phase of the R
% peaks signals in a respiratory cycle. 
% INPUT
% r_cycles_cln = 2 columns matrix, each row is a good respiratory cycle.
% r_data_cln = denoised respiratory signal
% k = range of respiratory cycles that want to plot

    % If isn't indicated a range of selection (k), all the cycles are shown.
    if k == 0
        k = 1:size(r_cycles_cln, 1);
    end
    
    R_peaks_inside = c_locs > min(r_cycles_cln(k,1)) & c_locs < max(r_cycles_cln(k,2));
    H_r_data_cln = hilbert(r_data_cln);
    % [theta,rho] = cart2pol(real(H_r_data_cln), imag(H_r_data_cln));
    % sigphase = atan2(imag(H_r_data_cln),real(H_r_data_cln));
    theta = angle(H_r_data_cln);
    x = theta(c_locs(R_peaks_inside));

    %% Figure for single plot
    % figure
    % polarhistogram(x, 60, 'EdgeAlpha',0.2);
    % title("Phase of the respiratory signal in the R-peaks instant")

    %% Figure raw with amplitude and theta
    
    % 3D plot test
    % selection_interv = min(c_locs(R_peaks_inside)):max(c_locs(R_peaks_inside));
    % figure
    % plot3(1:length(selection_interv),real(H_r_data_cln(selection_interv)), imag(H_r_data_cln(selection_interv)))
    % hold on
    % plot3(c_locs(R_peaks_inside), real(H_r_data_cln(c_locs(R_peaks_inside))), imag(H_r_data_cln(c_locs(R_peaks_inside))), 'o','MarkerFaceColor','red')
  
    % figure
    % plot(theta)
    % hold on
    % plot(c_locs(R_peaks_inside), theta(c_locs(R_peaks_inside)),'o', 'MarkerFaceColor','red')
    % axis tight

    % Plot angle phase and normalized amplitude in a single plot
    % figure
    % plot(theta)
    % hold on
    % plot(zscore(real(H_r_data_cln)))

end