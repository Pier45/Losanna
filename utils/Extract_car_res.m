close all
clear
clc

addpath(genpath('../src'))

%% Loading data and setting of parameters
% The data are stored in a matrix called "data":
% data(1,:) -> Raw ECG
% data(2,:) -> Raw breathing
% data(3,:) -> 0 = Awake; 1 = N1; 2 = N2; 3 = N3; 4 = REM; 6 = Arousal

% path = 'C:\Users\piero\OneDrive\Dottorato\Travels\Losanna\Data\Cardio_resp\s21_sleep_cardioresp.mat';

path = '/mnt/HDD2/CardioAudio_sleepbiotech/data/sleep/s27/n1/process/';
sleep_stages = ["Awake", "REM", "n1", "n2", "n3"];

fs = 1024;
RR_window_pks = 20;
RR_window_len = 20;
sf_res = 0.5;
sf_car = 20;

tokens = regexp(path, 'sleep/(s\d+)', 'tokens');
sub_name = tokens{1}{1};

matches = regexp(path, '[\/\\](n\d+)[\/\\]', 'tokens');
night = matches{end}{1};  % Get the last matching 'nX'

load([path, 'raw_data.mat'])
data(1,:) = y(65,:);
data(2,:) = y(68,:);

files = dir(fullfile(path, '*.mat'));
match_idx = ~cellfun(@isempty, regexp({files.name}, ['^' sub_name '_allsleep_n\d+_slscore.mat$']));
matched_files = files(match_idx);
sleep_labels = load([matched_files.folder '/' matched_files.name]);
data(3,:) = sleep_labels.score_labels;

sound = y(69,:);
[sound_events] = extract_sound_info(sound, true, sub_name, night, "");

% Change the number of row in the next variable, if the row are different
row_ECG = 1;
row_RES = 2;
row_SLEEP = 3;

%% Initialization
raw_data = struct();
res = struct();
car = struct();

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

raw_data.n0.perc = sum(raw_data.n0.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;
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
% plot(data(row_ECG,raw_data.n0.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.n0.logic_selection), 'b'); title(['Awake - percentage of time in stage ' num2str(round(raw_data.n0.perc,1)) '%']); axis tight
% subplot(5,1,2)
% plot(data(row_ECG,raw_data.n1.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.n1.logic_selection), 'b'); title(['N1 - percentage of time in stage ' num2str(round(raw_data.n1.perc,1)) '%']); axis tight
% subplot(5,1,3)
% plot(data(row_ECG,raw_data.n2.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.n2.logic_selection), 'b'); title(['N2 - percentage of time in stage ' num2str(round(raw_data.n2.perc,1)) '%']); axis tight
% subplot(5,1,4)
% plot(data(row_ECG,raw_data.n3.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.n3.logic_selection), 'b'); title(['N3 - percentage of time in stage ' num2str(round(raw_data.n3.perc,1)) '%']); axis tight
% subplot(5,1,5)
% plot(data(row_ECG,raw_data.n4.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.n4.logic_selection), 'b'); title(['N4 - percentage of time in stage ' num2str(round(raw_data.n4.perc,1)) '%']); axis tight

if convertCharsToStrings(sub_name) == "s22" && convertCharsToStrings(night) == "n2"
    ecg_temp = data(row_ECG, raw_data.n0.idx);
    res_temp = data(row_RES, raw_data.n0.idx);
    range_out = 1258520:1693850;
    new_section = ones(1, length(range_out))*-1667;
    ecg_temp(range_out) = new_section;
    res_temp(range_out) = new_section;

    data(row_ECG, raw_data.n0.idx) = ecg_temp;
    data(row_RES, raw_data.n0.idx) = res_temp;
end

%% Denoising of the ECG and identification of R peaks
[c_pks0, c_locs0, ~, ~, car.n0.data_cln, car.n0.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.n0.idx), 'Awake', "cardiac", "plot");
[c_pks1, c_locs1, ~, ~, car.n1.data_cln, car.n1.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.n1.idx), 'N1', "cardiac", "plot");
[c_pks2, c_locs2, ~, ~, car.n2.data_cln, car.n2.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.n2.idx), 'N2', "cardiac", "plot");
[c_pks3, c_locs3, ~, ~, car.n3.data_cln, car.n3.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.n3.idx), 'N3', "cardiac", "plot");
[c_pks4, c_locs4, ~, ~, car.n4.data_cln, car.n4.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.n4.idx), 'N4', "cardiac", "plot");
% boxplot4stages(c_locs0, c_locs1, c_locs2, c_locs3, c_locs4, fs)

%% Cleaning of R peaks from outliers
[car.n0.pks, car.n0.locs, car.n0.p_out] = filter_R_peaks(c_pks0, c_locs0, RR_window_pks, RR_window_len, car.n0.data_cln, 'Awake', "plot", 'no');
[car.n1.pks, car.n1.locs, car.n1.p_out] = filter_R_peaks(c_pks1, c_locs1, RR_window_pks, RR_window_len, car.n1.data_cln, 'N1', "plot", 'no');
[car.n2.pks, car.n2.locs, car.n2.p_out] = filter_R_peaks(c_pks2, c_locs2, RR_window_pks, RR_window_len, car.n2.data_cln, 'N2', "plot", 'no');
[car.n3.pks, car.n3.locs, car.n3.p_out] = filter_R_peaks(c_pks3, c_locs3, RR_window_pks, RR_window_len, car.n3.data_cln, 'N3', "plot", 'no');
[car.n4.pks, car.n4.locs, car.n4.p_out] = filter_R_peaks(c_pks4, c_locs4, RR_window_pks, RR_window_len, car.n4.data_cln, 'N4', "plot", 'no');

%% Need some changes
% Now compute the cycles between the peaks not considering the outliers.
% boxplot4stages(car.n0.locs_cln, car.n1.locs_cln, car.n2.locs_cln, car.n3.locs_cln, car.n4.locs_cln, fs)

%% Denoising of respiration signal and identification of the cycles
% The respiratory signal is filtered with a low pass filter to remove the
% noise at 0.5Hz; to identify the mean of the signal another low pass
% filter at 0.07Hz is applied.
[res.n0.max_pks, res.n0.max_locs, res.n0.min_pks, res.n0.min_locs, res.n0.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.n0.idx), 'Awake', "respiration", "plot");
[res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, res.n1.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.n1.idx), 'N1', "respiration", "plot");
[res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, res.n2.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.n2.idx), 'N2', "respiration", "plot");
[res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, res.n3.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.n3.idx), 'N3', "respiration", "plot");
[res.n4.max_pks, res.n4.max_locs, res.n4.min_pks, res.n4.min_locs, res.n4.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.n4.idx), 'N4', "respiration", "plot");
% boxplot4stages(res.n0.max_locs, res.n1.max_locs, res.n2.max_locs, res.n3.max_locs, res.n4.max_locs, fs)
% boxplot4stages(res.n0.min_locs, res.n1.min_locs, res.n2.min_locs, res.n3.min_locs, res.n4.min_locs, fs)

%% Breathing cycles cleaning from outliers, for both maximum and minimum
[res.n0.cycles_max, res.n0.cycles_min] = filter_res_cycles(res.n0.data_cln, res.n0.max_pks, res.n0.max_locs, res.n0.min_pks, res.n0.min_locs, fs, 'Awake', "plot", ['../output/card_resp/BH_' sub_name '_Awake']);
[res.n1.cycles_max, res.n1.cycles_min] = filter_res_cycles(res.n1.data_cln, res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, fs, 'N1', "plot", 'no');
[res.n2.cycles_max, res.n2.cycles_min] = filter_res_cycles(res.n2.data_cln, res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, fs, 'N2', "plot", 'no');
[res.n3.cycles_max, res.n3.cycles_min] = filter_res_cycles(res.n3.data_cln, res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, fs, 'N3', "plot", 'no');
[res.n4.cycles_max, res.n4.cycles_min] = filter_res_cycles(res.n4.data_cln, res.n4.max_pks, res.n4.max_locs, res.n4.min_pks, res.n4.min_locs, fs, 'N4', "plot", 'no');

%% Plot in polar coordianates the the R peaks signals in a respiratory cycle. 
f.(sleep_stages(1)) = phase_res(res.n0.cycles_min, res.n0.data_cln, car.n0.locs, 0,'N0',"no");
f.(sleep_stages(2)) = phase_res(res.n1.cycles_min, res.n1.data_cln, car.n1.locs, 0,'N1', "no");
f.(sleep_stages(3)) = phase_res(res.n2.cycles_min, res.n2.data_cln, car.n2.locs, 0,'N2', "no");
f.(sleep_stages(4)) = phase_res(res.n3.cycles_min, res.n3.data_cln, car.n3.locs, 0,'N3', "no");
f.(sleep_stages(5)) = phase_res(res.n4.cycles_min, res.n4.data_cln, car.n4.locs, 0,'N4', "no");

polar_hist_stages(f, 60, '');

%% Save res and car structures in a mat file
save(['../output/card_resp/car_resp_' sub_name '.mat'], 'res', 'car')