clear
close all
clc

addpath("..")

%% Parameter to set
fs = 1024;
% One breath each 3 seconds.
f_resp = 1/3;
seconds = 100;
% Time of the first R peak in seconds, use integer.
time_first_R = 15;
% Random noise can be added setting next parameter to true, instead of false.
random_noise = true;
% Select a value between 0 and -1024, higher is noiser
noise_lev = -100;

%% Creation of signal and data similar to real structures
t = 0:1/fs:seconds;
data = sin(2*pi*f_resp*t);
y = hilbert(data);
phase_angle = angle(y);
R_locs = time_first_R*fs:fs:seconds*fs;

if random_noise == 1
    rng(1)
    R_locs = R_locs + randi([noise_lev 1],1,length(R_locs));
end
[pks,locs]  = findpeaks(-data);
cycles = create_cycles(locs);

%% Modify R locs, removing or adding new peaks
R_locs(10) = [];
R_locs(45) = [];
% R_locs = sort([R_locs R_locs(44)+100]);

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

[perc_sync, good_c] = sync_phase2(cycles, theta, R_locs, avg_w, std_w, saved_windows, m, n, 'simulated',fs);
