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
% Created: [Insert Date, e.g., 2025-09-11]
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

path_folder = '/mnt/HDD2/CardioAudio_sleepbiotech/data/sleep';
d = dir([path_folder '/s*']);
is_match = ~cellfun(@isempty, regexp({d.name}, '^s\d+$'));
d = d(is_match, :);

fs = 1024;
T = 30;
m = 1; n = 4;
delta = 5;

sleep_stages_names = {'Awake', 'n1', 'n2', 'n3', 'REM'};

for k = 1:length(d)
    
    raw_data = struct();
    res = struct();
    car = struct();
    
    for j = 1:2
        night = ['n' num2str(j)];
        % Create a folder for the subject
        status = mkdir(['output/' d(k).name '/' night]);
        save_path = ['output/' d(k).name '/' night '/'];
        
        % Load restricted part of the mat file
        sel_path = [d(k).folder '/' d(k).name '/' night '/process/'];
        raw_data_path = [sel_path 'raw_data.mat'];
        mfile = matfile(raw_data_path);
        sound = mfile.y(69,:);
        ecg = mfile.y(65,:);
        respiration = mfile.y(68,:);
        
        % Extraction of sound event
        [sound_events] = extract_sound_info(sound);

        % Load the sleep stages
        files = dir(fullfile(sel_path, '*.mat')); % Or '*.txt', etc.
        match_idx = ~cellfun(@isempty, regexp({files.name}, ['^' d(k).name '_allsleep_n\d+_slscore.mat$']));
        matched_files = files(match_idx);
        load([matched_files.folder '/' matched_files.name]);
        
        % Extract car res
        raw_data.n0.logic_selection = score_labels==0;
        raw_data.n1.logic_selection = score_labels==1;
        raw_data.n2.logic_selection = score_labels==2;
        raw_data.n3.logic_selection = score_labels==3;
        raw_data.n4.logic_selection = score_labels==4;

        raw_data.n0.idx = find(raw_data.n0.logic_selection == 1);
        raw_data.n1.idx = find(raw_data.n1.logic_selection == 1);
        raw_data.n2.idx = find(raw_data.n2.logic_selection == 1);
        raw_data.n3.idx = find(raw_data.n3.logic_selection == 1);
        raw_data.n4.idx = find(raw_data.n4.logic_selection == 1);

        raw_data.n1.perc = sum(raw_data.n1.logic_selection)/sum(score_labels~=0)*100;
        raw_data.n2.perc = sum(raw_data.n2.logic_selection)/sum(score_labels~=0)*100;
        raw_data.n3.perc = sum(raw_data.n3.logic_selection)/sum(score_labels~=0)*100;
        raw_data.n4.perc = sum(raw_data.n4.logic_selection)/sum(score_labels~=0)*100;
        
        %% Denoising of the ECG and identification of R peaks
        [c_pks0, c_locs0, ~, ~, car.n0.data_cln, car.n0.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.n0.idx), 'Awake N0', "cardiac", "no");
        [c_pks1, c_locs1, ~, ~, car.n1.data_cln, car.n1.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.n1.idx), 'N1', "cardiac", "no");
        [c_pks2, c_locs2, ~, ~, car.n2.data_cln, car.n2.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.n2.idx), 'N2', "cardiac", "no");
        [c_pks3, c_locs3, ~, ~, car.n3.data_cln, car.n3.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.n3.idx), 'N3', "cardiac", "plot");
        [c_pks4, c_locs4, ~, ~, car.n4.data_cln, car.n4.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.n4.idx), 'N4', "cardiac", "plot");

        %% Cleaning of R peaks from outliers
        [car.n0.pks, car.n0.locs, car.n0.p_R_out] = filter_R_peaks(c_pks0, c_locs0, 30, 10, car.n0.data_cln, "no");
        [car.n1.pks, car.n1.locs, car.n1.p_R_out] = filter_R_peaks(c_pks1, c_locs1, 30, 10, car.n1.data_cln, "no");
        [car.n2.pks, car.n2.locs, car.n2.p_R_out] = filter_R_peaks(c_pks2, c_locs2, 20, 10, car.n2.data_cln, "no");
        [car.n3.pks, car.n3.locs, car.n3.p_R_out] = filter_R_peaks(c_pks3, c_locs3, 30, 10, car.n3.data_cln, "plot");
        [car.n4.pks, car.n4.locs, car.n4.p_R_out] = filter_R_peaks(c_pks4, c_locs4, 30, 10, car.n4.data_cln, "plot");

        %% Need some changes
        % Now compute the cycles between the peaks not considering the outliers.
        % boxplot4stages(car.n0.locs_cln, car.n1.locs_cln, car.n2.locs_cln, car.n3.locs_cln, car.n4.locs_cln, fs)

        %% Denoising of respiration signal and identification of the cycles
        % The respiratory signal is filtered with a low pass filter to remove the
        % noise at 0.5Hz; to identify the mean of the signal another low pass
        % filter at 0.07Hz is applied.
        [res.n0.max_pks, res.n0.max_locs, res.n0.min_pks, res.n0.min_locs, res.n0.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.n0.idx), 'Awake N0', "respiration", "no");
        [res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, res.n1.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.n1.idx), 'N1', "respiration", "no");
        [res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, res.n2.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.n2.idx), 'N2', "respiration", "no");
        [res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, res.n3.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.n3.idx), 'N3', "respiration", "plot");
        [res.n4.max_pks, res.n4.max_locs, res.n4.min_pks, res.n4.min_locs, res.n4.data_cln] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.n4.idx), 'N4', "respiration", "no");

        %% Breathing cycles cleaning from outliers, for both maximum and minimum
        [res.n0.cycles_max, res.n0.cycles_min] = filter_breathing_cycles(res.n0.data_cln, res.n0.max_pks, res.n0.max_locs, res.n0.min_pks, res.n0.min_locs, fs, "no");
        [res.n1.cycles_max, res.n1.cycles_min] = filter_breathing_cycles(res.n1.data_cln, res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, fs, "no");
        [res.n2.cycles_max, res.n2.cycles_min] = filter_breathing_cycles(res.n2.data_cln, res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, fs, "no");
        [res.n3.cycles_max, res.n3.cycles_min] = filter_breathing_cycles(res.n3.data_cln, res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, fs, "no");
        [res.n4.cycles_max, res.n4.cycles_min] = filter_breathing_cycles(res.n4.data_cln, res.n4.max_pks, res.n4.max_locs, res.n4.min_pks, res.n4.min_locs, fs, "no");

        %% Plot in polar coordianates the the R peaks signals in a respiratory cycle. 
        f0 = phase_R(res.n0.cycles_min, res.n0.data_cln, car.n0.locs, 0, 'N0',"no");
        f1 = phase_R(res.n1.cycles_min, res.n1.data_cln, car.n1.locs, 0, 'N1',"no");
        f2 = phase_R(res.n2.cycles_min, res.n2.data_cln, car.n2.locs, 0, 'N2',"no");
        f3 = phase_R(res.n3.cycles_min, res.n3.data_cln, car.n3.locs, 0, 'N3',"no");
        f4 = phase_R(res.n4.cycles_min, res.n4.data_cln, car.n4.locs, 0, 'N4',"no");
        
        polar_hist_stages(f0,f1,f2,f3,f4, 60, true, save_path);
        sleep_stages = fieldnames(res(1));

        %% Extract sync data
        result = struct();
        for i = 1:length(sleep_stages)
            cycles = res.(sleep_stages{i}).cycles_min;
            R_locs = car.(sleep_stages{i}).locs;
            data = res.(sleep_stages{i}).data_cln;

            [phase, R_res_cycle, avg_w, std_w, saved_windows, m_cycle] = sync_phase1(cycles, R_locs, data, T, m, n, fs);
            [perc_sync, sync_cycle]= sync_phase2(m_cycle, phase, R_locs, std_w, saved_windows, m, n, delta, sleep_stages_names{i}, fs);
        
            %% Save sleep stage data output
            result.sleep_stages.(sleep_stages_names{i}).sync_perc = perc_sync;
            result.sleep_stages.(sleep_stages_names{i}).sync_cycle = sync_cycle; 
            result.sleep_stages.(sleep_stages_names{i}).m_cycle = m_cycle;
            result.sleep_stages.(sleep_stages_names{i}).cycle = cycles;
        
            %% Save the signals ECG and respiratory
            result.sleep_stages.(sleep_stages_names{i}).phase = phase;
            result.sleep_stages.(sleep_stages_names{i}).R_locs = R_locs;
        end
        
        %% Save the syncro parameters
        result.parameters.m = m;
        result.parameters.n = n;
        result.parameters.T = T;
        result.parameters.delta = delta;
        
        %% Save the sound events data
        result.sound_events = sound_events;
        
        %% Save general details
        result.details.night = night;
        result.details.path = sel_path;
        result.details.id = d(k).name;
        
        %% Percentage of sync
        perc_sync_all = zeros(1, size(sleep_stages_names, 2));
        for i = 1:length(sleep_stages_names)
            perc_sync_all(i) = result.sleep_stages.(sleep_stages_names{i}).sync_perc;
        end
        
        fig2 = figure;
        bar(categorical(sleep_stages_names), perc_sync_all, 'FaceColor', [0.2 0.8 0.8], 'EdgeColor', 'w')
        ylabel('breathing cycles sync %')
        ylim([0, 30])
        title(['Subject ' result.details.id ' - ' result.details.night])
        print(fig2, [save_path 'perc_sync_bar.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution

        %% Save
        save([save_path 'result.mat'], 'result');
 
    end
end
