function [] = polar_hist_stages(f0,f1,f2,f3,f4, n_bar)
% POLARHIST_MULTISTAGE Plots n polar histogram plot in a subplot.
    
    figure    
    subplot(2,3,1)
    polarhistogram(f0,n_bar,'EdgeAlpha',0.2)
    title("Stage awake")
    subplot(2,3,2)
    polarhistogram(f1,n_bar,'EdgeAlpha',0.2)
    title("Stage n1")
    subplot(2,3,3)
    polarhistogram(f2,n_bar,'EdgeAlpha',0.2)
    title("Stage n2")
    subplot(2,3,4)
    polarhistogram(f3,n_bar,'EdgeAlpha',0.2)
    title("Stage n3")
    subplot(2,3,5)
    polarhistogram(f4,n_bar,'EdgeAlpha',0.2)
    title("Stage n4 (REM)")

    ax = gca; % Get current axes
    ax.FontSize = 14;
end

