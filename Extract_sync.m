clc
close all
clear

load("info_s23.mat")
fs = 1024;
T = 30;
m = 1; n = 3;

cycles = res.n3.cycles_min;
R_locs = car.n3.locs;
data = res.n3.data_cln;

[theta, avg_w, std_w, saved_windows] = sync_phase1(cycles, R_locs, data, T, m, n, fs);

[perc_sync, good_cycle]= sync_phase2(cycles, theta, R_locs, avg_w, std_w, saved_windows, m, n, fs);
