clc
close all
clear

dir_path = dir();
name_path = [dir_path(strcmp({dir_path.name}, 'output')).folder '/output/card_resp/car_resp_s28.mat'];
match = char(regexp(name_path, '_s\w+', 'match'));
load(name_path)

fs = 1024;
T = 30;
m = 1; n = 4;
delta = 5;

sleep_stages = fieldnames(res(1));
sleep_stages_names = {'Awake', 'n1', 'n2', 'n3', 'REM'};

result = struct();
for i = 1:length(sleep_stages)
    cycles = res.(sleep_stages{i}).cycles_min;
    R_locs = car.(sleep_stages{i}).locs;
    data = res.(sleep_stages{i}).data_cln;

    [phase, R_res_cycle, avg_w, std_w, saved_windows, m_cycle] = sync_phase1(cycles, R_locs, data, T, m, n, fs);
    [perc_sync, sync_cycle]= sync_phase2(m_cycle, phase, R_locs, std_w, saved_windows, m, n, delta, sleep_stages_names{i}, fs, true);
    
    %% Save sleep stage data output
    result.sleep_stages.(sleep_stages_names{i}).sync_perc = perc_sync;
    result.sleep_stages.(sleep_stages_names{i}).sync_cycle = sync_cycle; 
    result.sleep_stages.(sleep_stages_names{i}).m_cycle = m_cycle;
    result.sleep_stages.(sleep_stages_names{i}).cycle = cycles;

    %% Save the signals ECG and respiratory
    result.sleep_stages.(sleep_stages_names{i}).phase = phase;
    result.sleep_stages.(sleep_stages_names{i}).R_locs = R_locs;
    
    %% Save the setted parameters
    result.parameters.m = m;
    result.parameters.n = n;
    result.parameters.T = T;
    result.parameters.delta = delta;
end

perc_sync_all = zeros(1, size(sleep_stages_names, 2));
for i = 1:length(sleep_stages_names)
    perc_sync_all(i) = result.sleep_stages.(sleep_stages_names{i}).sync_perc;
end

figure
bar(categorical(sleep_stages_names), perc_sync_all)
ylabel('sync %')
ylim([0, 30])
title(['Subject ' match(3:end)])
ax = gca; % Get current axes
ax.FontSize = 14;
