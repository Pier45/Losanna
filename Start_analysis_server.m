% Script Name: Start_analyis_server 
%
% Description:
%   Analyzes nighttime raw data to detect and extract synchrony events, 
%   revealing temporal patterns of coordinated activity.
%
% Author:
%   Piero Policastro
%   Email: piero.policastro@gmail.com
%
% Created: 2025-09-11
%
% License:
%   MIT License
%   Copyright (c) 2025 Piero Policastro
%
%   Permission is hereby granted, free of charge, to any person obtaining a 
%   copy of this software and associated documentation files (the "Software"), 
%   to deal in the Software without restriction, including without limitation 
%   the rights to use, copy, modify, merge, publish, distribute, sublicense, 
%   and/or sell copies of the Software, and to permit persons to whom the 
%   Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included 
%   in all copies or substantial portions of the Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
%   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
%   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
%   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
%   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
%   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
%   DEALINGS IN THE SOFTWARE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all
clc

addpath(genpath('src'))

%% Select the folder, 1 sleep, 2 awake
conditions = ['sleep'; 'awake'];
selected_cond = conditions(1,:);
%%

path_folder = ['/mnt/HDD2/CardioAudio_sleepbiotech/data/', selected_cond];
d = dir([path_folder '/s*']);
is_match = ~cellfun(@isempty, regexp({d.name}, '^s\d+$'));
d = d(is_match, :);

if convertCharsToStrings(selected_cond) == "sleep"
    number_folder = 2;
    sleep_stages = {'Awake', 'REM', 'n1', 'n2', 'n3'}';
else
    number_folder = 1;
    sleep_stages = {'Awake'};
end

%% Settable parameters 
fs = 1024;
T = 15;
delta = 5;
RR_window_pks = 20;
RR_window_len = 20;
sf_res = 0.5;
sf_car = 20;

combinations = {'m1n2', 'm1n3', 'm1n4', 'm1n5', 'm1n6', 'm2n5','m2n7'};

sound_cond = {'nan', 'sync', 'async', 'isoc', 'baseline'};
sound_codes = [0, 96, 160, 128, 192];

%% s31 removed
d(strcmp({d.name}, 's31')) = [];


for k = 1:length(d)
        
    if k==2
        disp('test')
    end
    
    raw_data = struct();
    res = struct();
    car = struct();
    sub_name = d(k).name;
    
    tstart = tic;
    for j = 1:number_folder
        if number_folder > 1
            night = ['n' num2str(j)];
            sel_path = [d(k).folder '/' sub_name '/' night '/process/'];

            %% Create a folder for the subject
            path_checks = ['output/sleep/'  sub_name '/' night '/check_plots'];
            path_save = ['output/sleep/' sub_name '/' night '/'];

            if not(exist(path_save, 'dir'))
                status = mkdir(path_save);        
            end
        else
            path_checks = ['output/awake/'  sub_name '/check_plots'];
            path_save = ['output/awake/' sub_name '/'];
            
            if not(exist(['output/awake/'  sub_name '/'], 'dir'))
                status = mkdir(['output/awake/'  sub_name '/']);        
            end
            
            sel_path = [d(k).folder '/' sub_name '/process/'];
            night = 'n0';
        end

        if not(exist(path_checks, 'dir'))
            status2 = mkdir(path_checks);
        end
            
        raw_data_path = [sel_path 'raw_data.mat'];
        mfile = matfile(raw_data_path);
        
        %% Loading in this way is faster x5 respect to single or full load
        data = mfile.y(65:69,:);
        ecg = data(1,:);
        respiration = data(4,:);
        sound = data(5,:);
        
        raw_data = struct();
        car = struct();
        res = struct();
        
        %% Extraction of sound event
        [sound_events] = extract_sound_info(sound, true, sub_name, night, [path_save 'check_plots']);

        % Load the sleep stages
        if convertCharsToStrings(selected_cond) == "sleep"
            files = dir(fullfile(sel_path, '*.mat')); % Or '*.txt', etc.
            match_idx = ~cellfun(@isempty, regexp({files.name}, ['^' sub_name '_allsleep_n\d+_slscore.mat$']));
            matched_files = files(match_idx);
            sleep_labels = load([matched_files.folder '/' matched_files.name]);
            score_labels = sleep_labels.score_labels;
        else
            score_labels = zeros(1, length(ecg));
        end
        
        raw_data.Awake.logic_selection = score_labels==0;
        raw_data.Awake.idx = find(raw_data.Awake.logic_selection == 1);
        raw_data.Awake.perc = sum(raw_data.Awake.logic_selection)/sum(score_labels~=0)*100;
        
        %% s22 remotion of outliers section
        if convertCharsToStrings(sub_name) == "s22" && convertCharsToStrings(night) == "n2"
            ecg_temp = ecg(raw_data.Awake.idx);
            res_temp = respiration(raw_data.Awake.idx);
            range_out = 1258520:1693850;
            new_section = ones(1, length(range_out))*-1667;
            ecg_temp(range_out) = new_section;
            res_temp(range_out) = new_section;

            ecg(raw_data.Awake.idx) = ecg_temp;
            respiration(raw_data.Awake.idx) = res_temp;
        end
        
        [c_pks0, c_locs0, ~, ~, car.Awake.data_cln, car.Awake.mean_bpm] = clean_data_find_peaks(sf_car, fs, ecg(raw_data.Awake.idx), 'Awake N0', "cardiac", "no");
        [car.Awake.pks, car.Awake.locs, car.Awake.p_R_out] = filter_R_peaks(c_pks0, c_locs0, RR_window_pks, RR_window_len, car.Awake.data_cln, 'Awake', "plot", [path_checks '/R_peaks_' sub_name '_Awake']);
        [res.Awake.max_pks, res.Awake.max_locs, res.Awake.min_pks, res.Awake.min_locs, res.Awake.data_cln, res.Awake.mean_bpm] = clean_data_find_peaks(sf_res, fs, respiration(raw_data.Awake.idx), 'Awake N0', "respiration", "no");
        [res.Awake.cycles_max, res.Awake.cycles_min, res.Awake.perc_remotion_min] = filter_breathing_cycles(res.Awake.data_cln, res.Awake.max_pks, res.Awake.max_locs, res.Awake.min_pks, res.Awake.min_locs, fs, 'Awake', "plot", [path_checks '/BH_' sub_name '_Awake']);
        f0 = phase_R(res.Awake.cycles_min, res.Awake.data_cln, car.Awake.locs, 0, 'N0',"no");

        if convertCharsToStrings(selected_cond) == "sleep"
            raw_data.n1.logic_selection = score_labels==1;
            raw_data.n2.logic_selection = score_labels==2;
            raw_data.n3.logic_selection = score_labels==3;
            raw_data.REM.logic_selection = score_labels==4;

            raw_data.n1.idx = find(raw_data.n1.logic_selection == 1);
            raw_data.n2.idx = find(raw_data.n2.logic_selection == 1);
            raw_data.n3.idx = find(raw_data.n3.logic_selection == 1);
            raw_data.REM.idx = find(raw_data.REM.logic_selection == 1);

            raw_data.n1.perc = sum(raw_data.n1.logic_selection)/sum(score_labels~=0)*100;
            raw_data.n2.perc = sum(raw_data.n2.logic_selection)/sum(score_labels~=0)*100;
            raw_data.n3.perc = sum(raw_data.n3.logic_selection)/sum(score_labels~=0)*100;
            raw_data.REM.perc = sum(raw_data.REM.logic_selection)/sum(score_labels~=0)*100;

            [c_pks1, c_locs1, ~, ~, car.n1.data_cln, car.n1.mean_bpm] = clean_data_find_peaks(sf_car, fs, ecg(raw_data.n1.idx), 'N1', "cardiac", "no");
            [c_pks2, c_locs2, ~, ~, car.n2.data_cln, car.n2.mean_bpm] = clean_data_find_peaks(sf_car, fs, ecg(raw_data.n2.idx), 'N2', "cardiac", "no");
            [c_pks3, c_locs3, ~, ~, car.n3.data_cln, car.n3.mean_bpm] = clean_data_find_peaks(sf_car, fs, ecg(raw_data.n3.idx), 'N3', "cardiac", "no");
            [c_pks4, c_locs4, ~, ~, car.REM.data_cln, car.REM.mean_bpm] = clean_data_find_peaks(sf_car, fs, ecg(raw_data.REM.idx), 'N4', "cardiac", "no");
        
            [car.n1.pks, car.n1.locs, car.n1.p_R_out] = filter_R_peaks(c_pks1, c_locs1, RR_window_pks, RR_window_len, car.n1.data_cln, 'N1', "plot", [path_checks '/R_peaks_' sub_name '_N1']);
            [car.n2.pks, car.n2.locs, car.n2.p_R_out] = filter_R_peaks(c_pks2, c_locs2, RR_window_pks, RR_window_len, car.n2.data_cln, 'N2', "plot", [path_checks '/R_peaks_' sub_name '_N2']);
            [car.n3.pks, car.n3.locs, car.n3.p_R_out] = filter_R_peaks(c_pks3, c_locs3, RR_window_pks, RR_window_len, car.n3.data_cln, 'N3', "plot", [path_checks '/R_peaks_' sub_name '_N3']);
            [car.REM.pks, car.REM.locs, car.REM.p_R_out] = filter_R_peaks(c_pks4, c_locs4, RR_window_pks, RR_window_len, car.REM.data_cln, 'N4', "plot", [path_checks '/R_peaks_' sub_name '_N4']);
   
            [res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, res.n1.data_cln, res.n1.mean_bpm] = clean_data_find_peaks(sf_res, fs, respiration(raw_data.n1.idx), 'N1', "respiration", "no");
            [res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, res.n2.data_cln, res.n2.mean_bpm] = clean_data_find_peaks(sf_res, fs, respiration(raw_data.n2.idx), 'N2', "respiration", "no");
            [res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, res.n3.data_cln, res.n3.mean_bpm] = clean_data_find_peaks(sf_res, fs, respiration(raw_data.n3.idx), 'N3', "respiration", "no");
            [res.REM.max_pks, res.REM.max_locs, res.REM.min_pks, res.REM.min_locs, res.REM.data_cln, res.REM.mean_bpm] = clean_data_find_peaks(sf_res, fs, respiration(raw_data.REM.idx), 'N4', "respiration", "no");

            [res.n1.cycles_max, res.n1.cycles_min, res.n1.perc_remotion_min] = filter_breathing_cycles(res.n1.data_cln, res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, fs, 'N1', "plot", [path_checks '/BH_' sub_name '_N1']);
            [res.n2.cycles_max, res.n2.cycles_min, res.n2.perc_remotion_min] = filter_breathing_cycles(res.n2.data_cln, res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, fs, 'N2', "plot", [path_checks '/BH_' sub_name '_N2']);
            [res.n3.cycles_max, res.n3.cycles_min, res.n3.perc_remotion_min] = filter_breathing_cycles(res.n3.data_cln, res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, fs, 'N3', "plot", [path_checks '/BH_' sub_name '_N3']);
            [res.REM.cycles_max, res.REM.cycles_min, res.REM.perc_remotion_min] = filter_breathing_cycles(res.REM.data_cln, res.REM.max_pks, res.REM.max_locs, res.REM.min_pks, res.REM.min_locs, fs, 'N4', "plot", [path_checks '/BH_' sub_name '_N4']);
 
            f1 = phase_R(res.n1.cycles_min, res.n1.data_cln, car.n1.locs, 0, 'N1',"no");
            f2 = phase_R(res.n2.cycles_min, res.n2.data_cln, car.n2.locs, 0, 'N2',"no");
            f3 = phase_R(res.n3.cycles_min, res.n3.data_cln, car.n3.locs, 0, 'N3',"no");
            f4 = phase_R(res.REM.cycles_min, res.REM.data_cln, car.REM.locs, 0, 'N4',"no");
        
            polar_hist_stages(f0,f1,f2,f3,f4, 60, path_save);
        else
            polar_hist_stages(f0,0,0,0,0, 60, path_save);
        end

        %% Extract sync data
        result = struct();
        
        for c = 1:length(combinations)
            match = regexp(combinations(c), 'm(\d+)n', 'tokens');
            m = str2double(match{1}{1});
            match = regexp(combinations(c), 'n(\d+)', 'tokens');
            n = str2double(match{1}{1});
            
%             if c==6
%                 disp('t')
%             end
            
            for i = 1:length(sleep_stages)
                cycles = res.(sleep_stages{i}).cycles_min;
                R_locs = car.(sleep_stages{i}).locs;
                data = res.(sleep_stages{i}).data_cln;

                [phase, R_res_cycle, avg_w, std_w, saved_windows, m_cycle] = sync_phase1(cycles, R_locs, data, T, m, n, fs);
                [perc_sync, sync_cycle]= sync_phase2(m_cycle, phase, R_locs, std_w, saved_windows, m, n, delta, sleep_stages{i}, false);
                sound_event_table = sync_phase3(m_cycle, sync_cycle, sound_events);
                
                %% Save sleep stage data output
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_perc = perc_sync;
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_cycle = sync_cycle; 
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).m_cycle = m_cycle;
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).cycle = cycles;
                %% Perctentage outliers
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).perc_out_R = car.(sleep_stages{i}).p_R_out;
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).perc_out_B = res.(sleep_stages{i}).perc_remotion_min;

                %% Save the signals ECG and respiratory
                if c == 1
                    result.sleep_data.(sleep_stages{i}).phase = phase;
                    result.sleep_data.(sleep_stages{i}).R_locs = R_locs;
                    result.sleep_data.(sleep_stages{i}).h_bmp = car.(sleep_stages{i}).mean_bpm;
                    result.sleep_data.(sleep_stages{i}).r_bmp = res.(sleep_stages{i}).mean_bpm;
                    result.sleep_data.(sleep_stages{i}).night_phase_perc = round(raw_data.(sleep_stages{i}).perc,1);
%                     result.sleep_data.(sleep_stages{i}).RR_window_pks = RR_window_pks;
%                     result.sleep_data.(sleep_stages{i}).RR_window_len = RR_window_len;
                end
                
                %% Save sound events results
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).sound_table = sound_event_table;

                %% Save the syncro parameters
                result.(combinations{c}).parameters.m = m;
                result.(combinations{c}).parameters.n = n;
                result.(combinations{c}).parameters.T = T;
                result.(combinations{c}).parameters.delta = delta;
            end
        
            %% Percentage of sync
            perc_sync_all = zeros(size(sleep_stages, 1), 1);
            for i = 1:length(sleep_stages)
                perc_sync_all(i) = result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_perc;
            end
   
            [sleepTable] = bar_sleep(sleep_stages, sub_name, night, m, n, sound_cond, result.(combinations{c}).sleep_stages, path_save);            
        end
        %% Save configuration
        result.combinations = combinations;
        
        %% Save the sound events data
        result.sound_events = sound_events;
        
        %% Save general details
        result.details.night = night;
        result.details.path = sel_path;
        result.details.id = sub_name;

        %% Save
        save([path_save 'result.mat'], 'result');
 
    end
    time_sub = toc(tstart);
    fprintf('Progress: %6.2f%%   -   completed sub =%4s   -   time = %8.1fs\n', round((k/length(d))*100,2), sub_name, time_sub);
end

% try
%     load('/home/piero/Desktop/raw_data.mat')
% catch ME
%     disp('=== FULL ERROR REPORT ===')
%     disp(getReport(ME, 'extended'))
%     
%     % Try to read HDF5 info directly
%     try
%         info = h5info('/home/piero/Desktop/raw_data.mat');
%         disp('HDF5 structure is readable')
%     catch ME2
%         disp('=== HDF5 ERROR ===')
%         disp(ME2.message)
%     end
% end
% 
% % Load the file to see structure
% m = matfile('/home/piero/Desktop/sa/corrupted_raw_data.mat');
% 
% % Test each column
% bad_cols = [];
% for i = 1700000:2100000
%     try
%         temp = m.y(69, i);  % Try to read column i
%         if mod(i, 1000) == 0
%             fprintf('Column %d: OK\n', i);
%         end
%     catch ME
%         fprintf('Column %d: CORRUPTED - %s\n', i, ME.message);
%         bad_cols = [bad_cols, i];
%     end
% end
% 
% fprintf('\nCorrupted columns: ');
% disp(bad_cols);