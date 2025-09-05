clc
close all
clear

load("output\card_resp\info_s23.mat")

fs = 1024;
T = 30;
m = 1; n = 3;
delta = 5;

sleep_stages = fieldnames(res(1));
sleep_stages_names = {'Awake', 'n1', 'n2', 'n3', 'REM'};

result = struct();
for i = 1:length(sleep_stages)
    cycles = res.(sleep_stages{i}).cycles_min;
    R_locs = car.(sleep_stages{i}).locs;
    data = res.(sleep_stages{i}).data_cln;

    [theta, R_res_cycle, avg_w, std_w, saved_windows, new_cycle] = sync_phase1(cycles, R_locs, data, T, m, n, fs);
    [result(i).perc_sync, good_cycle]= sync_phase2(new_cycle, theta, R_locs, std_w, saved_windows, m, n, delta, sleep_stages_names{i}, fs);
end

figure
bar(categorical(sleep_stages_names), [result.perc_sync])
ylabel('sync %')
ylim([0, 30])
title('Subject 21')
