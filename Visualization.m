clc
close all
clear

%% Loading and initialization
load("C:\Users\piero\Desktop\Losanna\Data\Cardio_resp\s21_awake_cardioresp.mat")
fs = 1024;

%% General visualization
t = 463040:740229;

figure
plot(data(1,t))
hold on
plot(data(2,t))
plot(data(3,t))
axis tight

l_N0 = data(3,:)==0; 
l_N1 = data(3,:)==1; perc_N1 = sum(l_N1)/sum(data(3,:)~=0)*100;
l_N2 = data(3,:)==2; perc_N2 = sum(l_N2)/sum(data(3,:)~=0)*100;
l_N3 = data(3,:)==3; perc_N3 = sum(l_N3)/sum(data(3,:)~=0)*100;
l_N4 = data(3,:)==4; perc_N4 = sum(l_N4)/sum(data(3,:)~=0)*100;

%% Visualization of signals in different sleep phases
% figure subplot(5,1,1) plot(data(1,l_N0)) hold on plot(data(2,l_N0))
% %title(['Awake - ' num2str(round(perc_N0,1)) '%']) axis tight
% 
% subplot(5,1,2) plot(data(1,l_N1)) hold on plot(data(2,l_N1)) title(['N1 -
% percentage of time in stage ' num2str(round(perc_N1,1)) '%']) axis tight
% 
% subplot(5,1,3) plot(data(1,l_N2)) hold on plot(data(2,l_N2)) title(['N2 -
% percentage of time in stage ' num2str(round(perc_N2,1)) '%']) axis tight
% 
% subplot(5,1,4) plot(data(1,l_N3)) hold on plot(data(2,l_N3)) title(['N3 -
% percentage of time in stage ' num2str(round(perc_N3,1)) '%']) axis tight
% 
% subplot(5,1,5) plot(data(1,l_N4)) hold on plot(data(2,l_N4)) title(['N4 -
% percentage of time in stage ' num2str(round(perc_N4,1)) '%']) axis tight

l_N0_small = find(l_N0 == 1);
l_N1_small = find(l_N1 == 1);
l_N2_small = find(l_N2 == 1);
l_N3_small = find(l_N3 == 1);
l_N4_small = find(l_N4 == 1);

%% Figure small portion of all
% figure subplot(5,1,1) plot(data(1,l_N0_small(t))) hold on
% plot(data(2,l_N0_small(t))) title('Awake') axis tight
% 
% subplot(5,1,2) plot(data(1,l_N1_small(t))) hold on
% plot(data(2,l_N1_small(t))) title(['N1 - percentage of time in stage '
% num2str(round(perc_N1,1)) '%']) axis tight
% 
% subplot(5,1,3) plot(data(1,l_N2_small(t))) hold on
% plot(data(2,l_N2_small(t))) title(['N2 - percentage of time in stage '
% num2str(round(perc_N2,1)) '%']) axis tight
% 
% subplot(5,1,4) plot(data(1,l_N3_small(t))) hold on
% plot(data(2,l_N3_small(t))) title(['N3 - percentage of time in stage '
% num2str(round(perc_N3,1)) '%']) axis tight
% 
% subplot(5,1,5) plot(data(1,l_N4_small(t))) hold on
% plot(data(2,l_N4_small(t))) title(['N4 - percentage of time in stage '
% num2str(round(perc_N4,1)) '%']) axis tight

%% Denoising of the ECG and identification of R peaks
% [c_pks0, c_locs0, ~, ~, c_N0_small_clean] = clean_data_find_peaks(25, 1, fs, data(1, l_N0_small), 'Awake N0', "cardiac");
[c_pks1, c_locs1, ~, ~, c_N1_small_clean] = clean_data_find_peaks(25, 1, fs, data(1, l_N1_small), 'N1', "cardiac");
% [c_pks2, c_locs2, ~, ~, c_N2_small_clean] = clean_data_find_peaks(25, 1, fs, data(1, l_N2_small), 'N2', "cardiac");
% [c_pks3, c_locs3, ~, ~, c_N3_small_clean] = clean_data_find_peaks(25, 1, fs, data(1, l_N3_small), 'N3', "cardiac");
% [c_pks4, c_locs4, ~, ~, c_N4_small_clean] = clean_data_find_peaks(25, 1, fs, data(1, l_N4_small), 'N4', "cardiac");
% 
% boxplot4stages(c_locs0, c_locs1, c_locs2, c_locs3, c_locs4, fs)

%% Cleaning of R peaks from outliers
[c_pks1_cln, c_locs1_cln] = filter_R_peaks(c_pks1, c_locs1, 60, c_N1_small_clean);

%% Denoising of respiration signal and identification of the cycles
% The respiratory signal is filtered with a low pass filter to remove the
% noise at 0.5Hz; to identify the mean of the signal another low pass
% filter at 0.07Hz is applied.
[rmax_pks0, rmax_locs0, rmin_pks0, rmin_locs0, N0_small_clean] = clean_data_find_peaks(0.5, 0.07, fs, data(2, l_N0_small), 'Awake N0', "respiration");
[rmax_pks1, rmax_locs1, rmin_pks1, rmin_locs1, N1_small_clean] = clean_data_find_peaks(0.5, 0.07, fs, data(2, l_N1_small), 'N1', "respiration");
[rmax_pks2, rmax_locs2, rmin_pks2, rmin_locs2, N2_small_clean] = clean_data_find_peaks(0.5, 0.07, fs, data(2, l_N2_small), 'N2', "respiration");
[rmax_pks3, rmax_locs3, rmin_pks3, rmin_locs3, N3_small_clean] = clean_data_find_peaks(0.5, 0.07, fs, data(2, l_N3_small), 'N3', "respiration");
[rmax_pks4, rmax_locs4, rmin_pks4, rmin_locs4, N4_small_clean] = clean_data_find_peaks(0.5, 0.07, fs, data(2, l_N4_small), 'N4', "respiration");

boxplot4stages(rmax_locs0, rmax_locs1, rmax_locs2, rmax_locs3, rmax_locs4, fs)
boxplot4stages(rmin_locs0, rmin_locs1, rmin_locs2, rmin_locs3, rmin_locs4, fs)

%% Breathing cycles cleaning from outliers, for both maximum and minimum
% [cycles_max_clean0,cycles_min_clean0] = filter_breathing_cycles(N0_small_clean, rmax_pks0, rmax_locs0, rmin_pks0, rmin_locs0, fs);
[cycles_max_clean1,cycles_min_clean1] = filter_breathing_cycles(N1_small_clean, rmax_pks1, rmax_locs1, rmin_pks1, rmin_locs1, fs);
%[cycles_max_clean2,cycles_min_clean2] = filter_breathing_cycles(N2_small_clean, rmax_pks2, rmax_locs2, rmin_pks2, rmin_locs2, fs);
%[cycles_max_clean3,cycles_min_clean3] = filter_breathing_cycles(N3_small_clean, rmax_pks3, rmax_locs3, rmin_pks3, rmin_locs3, fs);
[cycles_max_clean4,cycles_min_clean4] = filter_breathing_cycles(N4_small_clean, rmax_pks4, rmax_locs4, rmin_pks4, rmin_locs4, fs);

sa = readtable("C:\Users\piero\Downloads\Telegram Desktop\data.csv");
