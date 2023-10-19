function [] = boxplot4stages(locs0, locs1, locs2, locs3, locs4, fs)
%BOXPLOT4STAGES Summary of this function goes here
%   Detailed explanation goes here
    g = [zeros(length(locs0)-1, 1); ones(length(locs1)-1, 1); 2*ones(length(locs2)-1, 1); 3*ones(length(locs3)-1, 1); 4*ones(length(locs4)-1, 1)];
    figure
    boxplot([(fs./diff(locs0)).*60, (fs./diff(locs1)).*60, (fs./diff(locs2)).*60, (fs./diff(locs3)).*60, (fs./diff(locs4)).*60]', g, Labels={'N0';'N1';'N2';'N3';'N4'})
    ylabel('bpm')
    title('Comparison beats for minutes in different sleep phases')
end

