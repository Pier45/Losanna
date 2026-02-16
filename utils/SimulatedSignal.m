clear
close all
clc

addpath(genpath('../src'))

%% Parameters to be set
fs = 1024;
% One breath each 3 seconds.
f_resp = 1/3;
seconds = 100;
% Time of the first R peak in seconds, use integer.
time_first_R = 1;
% Random noise can be added setting next parameter to true, instead of false.
random_noise = false;
% Select a value between 0 and -1024, higher is noiser
noise_lev = -100;

%% Creation of signal and data similar to real structures
t = 0:1/fs:seconds;
data = sin(2*pi*f_resp*t)*3;
y = hilbert(data);
phase_angle = angle(y);
R_locs = time_first_R*fs:fs:seconds*fs;

if random_noise == 1
    rng(1)
    R_locs = R_locs + randi([noise_lev 1],1,length(R_locs));
end
[pks,locs]  = findpeaks(-data);
cycles = create_cycles(locs);

%% Remove a brething cycle test
% cycles(15,:) = [];

%% Modify R locs, removing or adding new peaks
add_lev = 6:6:32;
R_locs(add_lev) = R_locs(add_lev) + 500;
add_lev = 7:6:32;
R_locs(add_lev) = R_locs(add_lev) + 500;

remove_index = 8:6:38;
R_locs(remove_index) = [];

add_lev = 56:6:72;
R_locs(add_lev) = R_locs(add_lev) + 500;
add_lev = 57:6:72;
R_locs(add_lev) = R_locs(add_lev) + 500;
%R_locs = sort([R_locs R_locs(44)+100]);

remove_index = 58:6:82;
R_locs(remove_index) = [];

% figure
% plot(t, phase_angle)
% hold on
% plot(t, real(y)*pi)
% plot(R_locs/fs, phase_angle(R_locs), 'o', 'MarkerFaceColor', 'red')
% plot(locs/fs, data(locs), '+');
% xregion(cycles(:,1)/fs, cycles(:,2)/fs, FaceColor="b")
% legend('Phase', 'Resp. signal', 'R peaks','Min of cycles')
% axis tight

figure
% plot(phase_angle)
plot(t, real(y), LineWidth=1)
hold on
% plot(R_locs, phase_angle(R_locs), 'o', 'MarkerFaceColor', 'red')
plot(locs/fs, data(locs), 'o', 'MarkerFaceColor', 'green', 'MarkerSize', 8);
% xregion(cycles(:,1), cycles(:,2), FaceColor="b")
legend('Respiratory signal', 'Min of cycles')
xlim([0, 100])
ylabel('Amplitude')
xlabel('Time (s)')
% axis tight
ax = gca; % Get current axes
ax.FontSize = 16;
ti = ax.TightInset;
ax.Position = [ti(1) ti(2)+0.1 1-ti(3)-ti(1) 1-ti(4)-ti(2)-0.11];

T = 15;
m = 2; n = 5;
delta = 5;

[theta, R_res_cycle, avg_w, std_w, saved_windows, new_cycle] = sync_phase1(cycles, R_locs, data, T, m, n, fs);
[perc_sync, good_c] = sync_phase2(new_cycle, theta, R_locs, std_w, saved_windows, m, n, delta, 'simulated', fs, 1);
