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

path = '/mnt/HDD2/CardioAudio_sleepbiotech/data/sleep/s21/n2/process/';
path_output = '../output/car_res_single_sub/';

fid = fopen('/mnt/HDD2/piero/Losanna/config/config.json');
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
config = jsondecode(str);
combinations = config.sync_parameters.combinations;
sound_cond = config.sound_cond;
sound_codes = config.sound_codes;
sleep_score_codes = config.sleep_score_codes;
sleep_stages = config.sleep_stages;
  
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

% Change the number of row in the next variable, if the row are different
row_ECG = 1;
row_RES = 2;
row_SLEEP = 3;

%% Initialization
raw_data = struct();
res = struct();
car = struct();

raw_data.Awake.logic_selection = data(row_SLEEP,:)==0; 
raw_data.N1.logic_selection = data(row_SLEEP,:)==1; 
raw_data.N2.logic_selection = data(row_SLEEP,:)==2; 
raw_data.N3.logic_selection = data(row_SLEEP,:)==3; 
raw_data.REM.logic_selection = data(row_SLEEP,:)==4; 

raw_data.Awake.idx = find(raw_data.Awake.logic_selection == 1);
raw_data.N1.idx = find(raw_data.N1.logic_selection == 1); 
raw_data.N2.idx = find(raw_data.N2.logic_selection == 1); 
raw_data.N3.idx = find(raw_data.N3.logic_selection == 1); 
raw_data.REM.idx = find(raw_data.REM.logic_selection == 1); 

raw_data.Awake.perc = sum(raw_data.Awake.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;
raw_data.N1.perc = sum(raw_data.N1.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;
raw_data.N2.perc = sum(raw_data.N2.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;
raw_data.N3.perc = sum(raw_data.N3.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;
raw_data.REM.perc = sum(raw_data.REM.logic_selection)/sum(data(row_SLEEP,:)~=0)*100;

[sound_events] = extract_sound_info(sound, sound_cond, sound_codes, sleep_stages, raw_data, sub_name, night, false, path_output);

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
% plot(data(row_ECG,raw_data.Awake.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.Awake.logic_selection), 'b'); title(['Awake - percentage of time in stage ' num2str(round(raw_data.Awake.perc,1)) '%']); axis tight
% subplot(5,1,2)
% plot(data(row_ECG,raw_data.N1.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.N1.logic_selection), 'b'); title(['N1 - percentage of time in stage ' num2str(round(raw_data.N1.perc,1)) '%']); axis tight
% subplot(5,1,3)
% plot(data(row_ECG,raw_data.N2.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.N2.logic_selection), 'b'); title(['N2 - percentage of time in stage ' num2str(round(raw_data.N2.perc,1)) '%']); axis tight
% subplot(5,1,4)
% plot(data(row_ECG,raw_data.N3.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.N3.logic_selection), 'b'); title(['N3 - percentage of time in stage ' num2str(round(raw_data.N3.perc,1)) '%']); axis tight
% subplot(5,1,5)
% plot(data(row_ECG,raw_data.REM.logic_selection), 'r'); hold on
% plot(data(row_RES,raw_data.REM.logic_selection), 'b'); title(['REM - percentage of time in stage ' num2str(round(raw_data.REM.perc,1)) '%']); axis tight

if convertCharsToStrings(sub_name) == "s22" && convertCharsToStrings(night) == "N2"
    ecg_temp = data(row_ECG, raw_data.Awake.idx);
    res_temp = data(row_RES, raw_data.Awake.idx);
    range_out = 1258520:1693850;
    new_section = ones(1, length(range_out))*-1667;
    ecg_temp(range_out) = new_section;
    res_temp(range_out) = new_section;

    data(row_ECG, raw_data.Awake.idx) = ecg_temp;
    data(row_RES, raw_data.Awake.idx) = res_temp;
end

%% Denoising of the ECG and identification of R peaks
[c_pks0, c_locs0, ~, ~, car.Awake.data_cln, car.Awake.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.Awake.idx), 'Awake', "cardiac", "plot");
[c_pks1, c_locs1, ~, ~, car.N1.data_cln, car.N1.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.N1.idx), 'N1', "cardiac", "plot");
[c_pks2, c_locs2, ~, ~, car.N2.data_cln, car.N2.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.N2.idx), 'N2', "cardiac", "plot");
[c_pks3, c_locs3, ~, ~, car.N3.data_cln, car.N3.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.N3.idx), 'N3', "cardiac", "plot");
[c_pks4, c_locs4, ~, ~, car.REM.data_cln, car.REM.mean_bpm] = clean_data_find_peaks(sf_car, fs, data(row_ECG, raw_data.REM.idx), 'REM', "cardiac", "plot");
% boxplot4stages(c_locs0, c_locs1, c_locs2, c_locs3, c_locs4, fs)

%% Cleaning of R peaks from outliers
[car.Awake.pks, car.Awake.locs, car.Awake.p_out] = filter_R_peaks(c_pks0, c_locs0, RR_window_pks, RR_window_len, car.Awake.data_cln, 'Awake', "plot", 'no');
[car.N1.pks, car.N1.locs, car.N1.p_out] = filter_R_peaks(c_pks1, c_locs1, RR_window_pks, RR_window_len, car.N1.data_cln, 'N1', "plot", 'no');
[car.N2.pks, car.N2.locs, car.N2.p_out] = filter_R_peaks(c_pks2, c_locs2, RR_window_pks, RR_window_len, car.N2.data_cln, 'N2', "plot", 'no');
[car.N3.pks, car.N3.locs, car.N3.p_out] = filter_R_peaks(c_pks3, c_locs3, RR_window_pks, RR_window_len, car.N3.data_cln, 'N3', "plot", 'no');
[car.REM.pks, car.REM.locs, car.REM.p_out] = filter_R_peaks(c_pks4, c_locs4, RR_window_pks, RR_window_len, car.REM.data_cln, 'REM', "plot", 'no');

%% Need some changes
% Now compute the cycles between the peaks not considering the outliers.
% boxplot4stages(car.Awake.locs_cln, car.N1.locs_cln, car.N2.locs_cln, car.N3.locs_cln, car.REM.locs_cln, fs)

%% Denoising of respiration signal and identification of the cycles
% The respiratory signal is filtered with a low pass filter to remove the
% noise at 0.5Hz; to identify the mean of the signal another low pass
% filter at 0.07Hz is applied.
[res.Awake.max_pks, res.Awake.max_locs, res.Awake.min_pks, res.Awake.min_locs, res.Awake.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.Awake.idx), 'Awake', "respiration", "plot");
[res.N1.max_pks, res.N1.max_locs, res.N1.min_pks, res.N1.min_locs, res.N1.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.N1.idx), 'N1', "respiration", "plot");
[res.N2.max_pks, res.N2.max_locs, res.N2.min_pks, res.N2.min_locs, res.N2.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.N2.idx), 'N2', "respiration", "plot");
[res.N3.max_pks, res.N3.max_locs, res.N3.min_pks, res.N3.min_locs, res.N3.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.N3.idx), 'N3', "respiration", "plot");
[res.REM.max_pks, res.REM.max_locs, res.REM.min_pks, res.REM.min_locs, res.REM.data_cln] = clean_data_find_peaks(sf_res, fs, data(row_RES, raw_data.REM.idx), 'REM', "respiration", "plot");
% boxplot4stages(res.Awake.max_locs, res.N1.max_locs, res.N2.max_locs, res.N3.max_locs, res.REM.max_locs, fs)
% boxplot4stages(res.Awake.min_locs, res.N1.min_locs, res.N2.min_locs, res.N3.min_locs, res.REM.min_locs, fs)

%% Breathing cycles cleaning from outliers, for both maximum and minimum
[res.Awake.cycles_max, res.Awake.cycles_min] = filter_res_cycles(res.Awake.data_cln, res.Awake.max_pks, res.Awake.max_locs, res.Awake.min_pks, res.Awake.min_locs, fs, 'Awake', "plot", [path_output 'BH_' sub_name '_Awake']);
[res.N1.cycles_max, res.N1.cycles_min] = filter_res_cycles(res.N1.data_cln, res.N1.max_pks, res.N1.max_locs, res.N1.min_pks, res.N1.min_locs, fs, 'N1', "plot", 'no');
[res.N2.cycles_max, res.N2.cycles_min] = filter_res_cycles(res.N2.data_cln, res.N2.max_pks, res.N2.max_locs, res.N2.min_pks, res.N2.min_locs, fs, 'N2', "plot", 'no');
[res.N3.cycles_max, res.N3.cycles_min] = filter_res_cycles(res.N3.data_cln, res.N3.max_pks, res.N3.max_locs, res.N3.min_pks, res.N3.min_locs, fs, 'N3', "plot", 'no');
[res.REM.cycles_max, res.REM.cycles_min] = filter_res_cycles(res.REM.data_cln, res.REM.max_pks, res.REM.max_locs, res.REM.min_pks, res.REM.min_locs, fs, 'REM', "plot", 'no');

%% Plot in polar coordianates the the R peaks signals in a respiratory cycle. 
f.(sleep_stages(1)) = phase_res(res.Awake.cycles_min, res.Awake.data_cln, car.Awake.locs, 0,'Awake',"no");
f.(sleep_stages(2)) = phase_res(res.N1.cycles_min, res.N1.data_cln, car.N1.locs, 0,'N1', "no");
f.(sleep_stages(3)) = phase_res(res.N2.cycles_min, res.N2.data_cln, car.N2.locs, 0,'N2', "no");
f.(sleep_stages(4)) = phase_res(res.N3.cycles_min, res.N3.data_cln, car.N3.locs, 0,'N3', "no");
f.(sleep_stages(5)) = phase_res(res.REM.cycles_min, res.REM.data_cln, car.REM.locs, 0,'REM', "no");

polar_hist_stages(f, 60, '');

%% Save res and car structures in a mat file
save([path_output 'car_res_' sub_name '.mat'], 'res', 'car')