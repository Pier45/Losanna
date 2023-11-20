clear
close all
clc

addpath("..")

fs = 1024;
f_resp = 1/3;
seconds = 100;

t = 0:1/fs:seconds;
data = sin(2*pi*f_resp*t);
y = hilbert(data);
phase_angle = angle(y);
R_locs = 15*fs:fs:seconds*fs;
rng(1)
% R_locs = R_locs + randi([-600 1],1,length(R_locs));
[pks,locs]  = findpeaks(-data);
cycles = create_cycles(locs);

R_locs(10) = [];
R_locs(45) = [];
R_locs = sort([R_locs R_locs(44)+100]);

figure
plot(t, phase_angle)
hold on
plot(t, real(y))
plot(R_locs/fs, phase_angle(R_locs), 'o', 'MarkerFaceColor', 'red')
plot(locs/fs, data(locs), '+');
legend('Phase', 'Resp. signal', 'R peaks','Min of cycles')
axis tight

T = 30;
m = 1; n = 3;

[theta, avg_w, std_w, saved_windows] = sync_phase1(cycles, R_locs, data, T, m, n, fs);

perc_sync = sync_phase2(cycles, theta, R_locs, avg_w, std_w, saved_windows, m, n, fs);
