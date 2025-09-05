close all
clear
clc

%% Loading data and setting of parameters
% The data are stored in a matrix called "data":
% data(1,:) -> Raw ECG
% data(2,:) -> Raw breathing
% data(3,:) -> 0 = Awake; 1 = N1; 2 = N2; 3 = N3; 4 = REM; 6 = Arousal
path = 'C:\Users\piero\OneDrive\Dottorato\Travels\Losanna\Data\Cardio_resp\s21_sleep_cardioresp.mat';

load(path)
fs = 1024;
% Change the number of row in the next variable, if the row are different
row_ECG = 1;
row_RES = 2;
row_SLEEP = 3;

%% Initialization
raw_data = struct();
res = struct();
car = struct();
t = 463040:740229;

raw_data.n0.logic_selection = data(row_SLEEP,:)==0; 
raw_data.n1.logic_selection = data(row_SLEEP,:)==1; 
raw_data.n2.logic_selection = data(row_SLEEP,:)==2; 
raw_data.n3.logic_selection = data(row_SLEEP,:)==3; 
raw_data.n4.logic_selection = data(row_SLEEP,:)==4; 

raw_data.n0.idx = find(raw_data.n0.logic_selection == 1);
raw_data.n1.idx = find(raw_data.n1.logic_selection == 1); 
raw_data.n2.idx = find(raw_data.n2.logic_selection == 1); 
raw_data.n3.idx = find(raw_data.n3.logic_selection == 1); 
raw_data.n4.idx = find(raw_data.n4.logic_selection == 1); 

raw_data.n1.perc = sum(raw_data.n1.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;
raw_data.n2.perc = sum(raw_data.n2.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;
raw_data.n3.perc = sum(raw_data.n3.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;
raw_data.n4.perc = sum(raw_data.n4.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;

%% Figure of different stages
% plot(data(3, :))
% hold on
% plot(find(data(3, :)==6), 6*ones(length(find(data(3, :)==6)),1), 'or')
% plot(find(data(3, :)==4), 4*ones(length(find(data(3, :)==4)),1), 'om')
% plot(find(data(3, :)==3), 3*ones(length(find(data(3, :)==3)),1), 'oy')
% plot(find(data(3, :)==2), 2*ones(length(find(data(3, :)==2)),1), 'ok')
% plot(find(data(3, :)==1), 1*ones(length(find(data(3, :)==1)),1), 'og')
% plot(find(data(3, :)==0), zeros(length(find(data(3, :)==0)),1), 'ob')

%% Visualization of signals in different sleep phases
% figure
% subplot(5,1,1);
% plot(data(1,raw_data.n0.logic_selection)); hold on
% plot(data(2,raw_data.n0.logic_selection)); title('Awake'); axis tight
% subplot(5,1,2)
% plot(data(1,raw_data.n1.logic_selection)); hold on
% plot(data(2,raw_data.n1.logic_selection)); title(['N1 - percentage of time in stage ' num2str(round(raw_data.n1.perc,1)) '%']); axis tight
% subplot(5,1,3)
% plot(data(1,raw_data.n2.logic_selection)); hold on
% plot(data(2,raw_data.n2.logic_selection)); title(['N2 - percentage of time in stage ' num2str(round(raw_data.n2.perc,1)) '%']); axis tight
% subplot(5,1,4)
% plot(data(1,raw_data.n3.logic_selection)); hold on
% plot(data(2,raw_data.n3.logic_selection)); title(['N3 - percentage of time in stage ' num2str(round(raw_data.n3.perc,1)) '%']); axis tight
% subplot(5,1,5)
% plot(data(1,raw_data.n4.logic_selection)); hold on
% plot(data(2,raw_data.n4.logic_selection)); title(['N4 - percentage of time in stage ' num2str(round(raw_data.n4.perc,1)) '%']); axis tight

%% Denoising of the ECG and identification of R peaks
[c_pks0, c_locs0, ~, ~, car.n0.data_cln] = clean_data_find_peaks(20, 0.5, fs, data(row_ECG, raw_data.n0.idx), 'Awake N0', "cardiac", "no");
[c_pks1, c_locs1, ~, ~, car.n1.data_cln] = clean_data_find_peaks(20, 0.5, fs, data(row_ECG, raw_data.n1.idx), 'N1', "cardiac", "no");
[c_pks2, c_locs2, ~, ~, car.n2.data_cln] = clean_data_find_peaks(20, 0.5, fs, data(row_ECG, raw_data.n2.idx), 'N2', "cardiac", "no");
[c_pks3, c_locs3, ~, ~, car.n3.data_cln] = clean_data_find_peaks(20, 0.5, fs, data(row_ECG, raw_data.n3.idx), 'N3', "cardiac", "plot");
[c_pks4, c_locs4, ~, ~, car.n4.data_cln] = clean_data_find_peaks(20, 0.5, fs, data(row_ECG, raw_data.n4.idx), 'N4', "cardiac", "no");
% boxplot4stages(c_locs0, c_locs1, c_locs2, c_locs3, c_locs4, fs)

%% Cleaning of R peaks from outliers
[car.n0.pks, car.n0.locs] = filter_R_peaks(c_pks0, c_locs0, 30, 10, car.n0.data_cln, "no");
[car.n1.pks, car.n1.locs] = filter_R_peaks(c_pks1, c_locs1, 30, 10, car.n1.data_cln, "no");
[car.n2.pks, car.n2.locs] = filter_R_peaks(c_pks2, c_locs2, 20, 10, car.n2.data_cln, "no");
[car.n3.pks, car.n3.locs] = filter_R_peaks(c_pks3, c_locs3, 30, 10, car.n3.data_cln, "plot");
[car.n4.pks, car.n4.locs] = filter_R_peaks(c_pks4, c_locs4, 30, 10, car.n4.data_cln, "no");

%% Need some changes
% Now compute the cycles between the peaks not considering the outliers.
% boxplot4stages(car.n0.locs_cln, car.n1.locs_cln, car.n2.locs_cln, car.n3.locs_cln, car.n4.locs_cln, fs)

%% Denoising of respiration signal and identification of the cycles
% The respiratory signal is filtered with a low pass filter to remove the
% noise at 0.5Hz; to identify the mean of the signal another low pass
% filter at 0.07Hz is applied.
[res.n0.max_pks, res.n0.max_locs, res.n0.min_pks, res.n0.min_locs, res.n0.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, data(row_RES, raw_data.n0.idx), 'Awake N0', "respiration", "no");
[res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, res.n1.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, data(row_RES, raw_data.n1.idx), 'N1', "respiration", "no");
[res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, res.n2.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, data(row_RES, raw_data.n2.idx), 'N2', "respiration", "no");
[res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, res.n3.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, data(row_RES, raw_data.n3.idx), 'N3', "respiration", "plot");
[res.n4.max_pks, res.n4.max_locs, res.n4.min_pks, res.n4.min_locs, res.n4.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, data(row_RES, raw_data.n4.idx), 'N4', "respiration", "no");
% boxplot4stages(res.n0.max_locs, res.n1.max_locs, res.n2.max_locs, res.n3.max_locs, res.n4.max_locs, fs)
% boxplot4stages(res.n0.min_locs, res.n1.min_locs, res.n2.min_locs, res.n3.min_locs, res.n4.min_locs, fs)

%% Breathing cycles cleaning from outliers, for both maximum and minimum
[res.n0.cycles_max, res.n0.cycles_min] = filter_breathing_cycles(res.n0.data_cln, res.n0.max_pks, res.n0.max_locs, res.n0.min_pks, res.n0.min_locs, fs, "no");
[res.n1.cycles_max, res.n1.cycles_min] = filter_breathing_cycles(res.n1.data_cln, res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, fs, "no");
[res.n2.cycles_max, res.n2.cycles_min] = filter_breathing_cycles(res.n2.data_cln, res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, fs, "no");
[res.n3.cycles_max, res.n3.cycles_min] = filter_breathing_cycles(res.n3.data_cln, res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, fs, "plot");
[res.n4.cycles_max, res.n4.cycles_min] = filter_breathing_cycles(res.n4.data_cln, res.n4.max_pks, res.n4.max_locs, res.n4.min_pks, res.n4.min_locs, fs, "no");

%% Plot in polar coordianates the the R peaks signals in a respiratory cycle. 
f0 = phase_R(res.n0.cycles_min, res.n0.data_cln, car.n0.locs, 0, "no");
f1 = phase_R(res.n1.cycles_min, res.n1.data_cln, car.n1.locs, 0, "no");
f2 = phase_R(res.n2.cycles_min, res.n2.data_cln, car.n2.locs, 0, "no");
f3 = phase_R(res.n3.cycles_min, res.n3.data_cln, car.n3.locs, 0, "plot");
f4 = phase_R(res.n4.cycles_min, res.n4.data_cln, car.n4.locs, 0, "no");

polar_hist_stages(f0,f1,f2,f3,f4, 60);

%% Save res and car structures in a mat file
sl_pos = strfind(path, '\');
name = path(sl_pos(end)+1: end);
save(['output/card_resp/info_' name(1:min(strfind(name, '_'))-1) '.mat'], 'res', 'car')