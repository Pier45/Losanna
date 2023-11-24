clc
close all
clear

load("info_s21.mat")
fs = 1024;
T = 30;
m = 1; n = 3;

sleep_stages = fieldnames(res(1));

result = struct();
for i = 1:length(sleep_stages)
    cycles = res.(sleep_stages{i}).cycles_min;
    R_locs = car.(sleep_stages{i}).locs;
    data = res.(sleep_stages{i}).data_cln;

    [theta, avg_w, std_w, saved_windows] = sync_phase1(cycles, R_locs, data, T, m, n, fs);
    [result(i).perc_sync, good_cycle]= sync_phase2(cycles, theta, R_locs, avg_w, std_w, saved_windows, m, n, sleep_stages{i}, fs);
end
