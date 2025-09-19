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
delta = 5;

combinations = {'m1n3', 'm1n4','m1n5', 'm2n5','m2n7'};
sleep_stages = {'Awake', 'n1', 'n2', 'n3', 'REM'};

%% s31 at the moment has only one night
d(strcmp({d.name}, 's31')) = [];

%% s28 0 samples in n3 sleep stage
d(strcmp({d.name}, 's28')) = [];
%%

for k = 1:length(d)
        
    if k==3
        disp('test')
    end
    
    raw_data = struct();
    res = struct();
    car = struct();
    sub_name = d(k).name;
    
    disp(['Subjects analysed: ' num2str(round((k/length(d))*100,2)) '%     -    ' sub_name]);

    parfor j = 1:2
        night = ['n' num2str(j)];
        %% Create a folder for the subject
        status = mkdir(['output/'  sub_name '/' night]);
        save_path = ['output/' sub_name '/' night '/'];
        
        %% Load restricted part of the mat file
        sel_path = [d(k).folder '/' sub_name '/' night '/process/'];
        raw_data_path = [sel_path 'raw_data.mat'];
        mfile = matfile(raw_data_path);
        sound = mfile.y(69,:);
        ecg = mfile.y(65,:);
        respiration = mfile.y(68,:);
        
        %% Extraction of sound event
        [sound_events] = extract_sound_info(sound);

        % Load the sleep stages
        files = dir(fullfile(sel_path, '*.mat')); % Or '*.txt', etc.
        match_idx = ~cellfun(@isempty, regexp({files.name}, ['^' sub_name '_allsleep_n\d+_slscore.mat$']));
        matched_files = files(match_idx);
        sleep_labels = load([matched_files.folder '/' matched_files.name]);
        score_labels = sleep_labels.score_labels;
        
        raw_data = struct();
        car = struct();
        res = struct();
        % Extract car res
        raw_data.Awake.logic_selection = score_labels==0;
        raw_data.n1.logic_selection = score_labels==1;
        raw_data.n2.logic_selection = score_labels==2;
        raw_data.n3.logic_selection = score_labels==3;
        raw_data.REM.logic_selection = score_labels==4;

        raw_data.Awake.idx = find(raw_data.Awake.logic_selection == 1);
        raw_data.n1.idx = find(raw_data.n1.logic_selection == 1);
        raw_data.n2.idx = find(raw_data.n2.logic_selection == 1);
        raw_data.n3.idx = find(raw_data.n3.logic_selection == 1);
        raw_data.REM.idx = find(raw_data.REM.logic_selection == 1);

        raw_data.Awake.perc = sum(raw_data.Awake.logic_selection)/sum(score_labels~=0)*100;
        raw_data.n1.perc = sum(raw_data.n1.logic_selection)/sum(score_labels~=0)*100;
        raw_data.n2.perc = sum(raw_data.n2.logic_selection)/sum(score_labels~=0)*100;
        raw_data.n3.perc = sum(raw_data.n3.logic_selection)/sum(score_labels~=0)*100;
        raw_data.REM.perc = sum(raw_data.REM.logic_selection)/sum(score_labels~=0)*100;
        
        %% Denoising of the ECG and identification of R peaks
        [c_pks0, c_locs0, ~, ~, car.Awake.data_cln, car.Awake.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.Awake.idx), 'Awake N0', "cardiac", "no");
        [c_pks1, c_locs1, ~, ~, car.n1.data_cln, car.n1.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.n1.idx), 'N1', "cardiac", "no");
        [c_pks2, c_locs2, ~, ~, car.n2.data_cln, car.n2.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.n2.idx), 'N2', "cardiac", "no");
        [c_pks3, c_locs3, ~, ~, car.n3.data_cln, car.n3.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.n3.idx), 'N3', "cardiac", "no");
        [c_pks4, c_locs4, ~, ~, car.REM.data_cln, car.REM.mean_bpm] = clean_data_find_peaks(20, 0.5, fs, ecg(raw_data.REM.idx), 'N4', "cardiac", "no");

        %% Cleaning of R peaks from outliers
        [car.Awake.pks, car.Awake.locs, car.Awake.p_R_out] = filter_R_peaks(c_pks0, c_locs0, 30, 10, car.Awake.data_cln, "no");
        [car.n1.pks, car.n1.locs, car.n1.p_R_out] = filter_R_peaks(c_pks1, c_locs1, 30, 10, car.n1.data_cln, "no");
        [car.n2.pks, car.n2.locs, car.n2.p_R_out] = filter_R_peaks(c_pks2, c_locs2, 20, 10, car.n2.data_cln, "no");
        [car.n3.pks, car.n3.locs, car.n3.p_R_out] = filter_R_peaks(c_pks3, c_locs3, 30, 10, car.n3.data_cln, "no");
        [car.REM.pks, car.REM.locs, car.REM.p_R_out] = filter_R_peaks(c_pks4, c_locs4, 30, 10, car.REM.data_cln, "no");

        %% Need some changes
        % Now compute the cycles between the peaks not considering the outliers.
        % boxplot4stages(car.Awake.locs_cln, car.n1.locs_cln, car.n2.locs_cln, car.n3.locs_cln, car.REM.locs_cln, fs)

        %% Denoising of respiration signal and identification of the cycles
        % The respiratory signal is filtered with a low pass filter to remove the
        % noise at 0.5Hz; to identify the mean of the signal another low pass
        % filter at 0.07Hz is applied.
        [res.Awake.max_pks, res.Awake.max_locs, res.Awake.min_pks, res.Awake.min_locs, res.Awake.data_cln, res.Awake.mean_bpm] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.Awake.idx), 'Awake N0', "respiration", "no");
        [res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, res.n1.data_cln, res.n1.mean_bpm] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.n1.idx), 'N1', "respiration", "no");
        [res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, res.n2.data_cln, res.n2.mean_bpm] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.n2.idx), 'N2', "respiration", "no");
        [res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, res.n3.data_cln, res.n3.mean_bpm] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.n3.idx), 'N3', "respiration", "no");
        [res.REM.max_pks, res.REM.max_locs, res.REM.min_pks, res.REM.min_locs, res.REM.data_cln, res.REM.mean_bpm] = clean_data_find_peaks(0.5, 0.07, fs, respiration(raw_data.REM.idx), 'N4', "respiration", "no");

        %% Breathing cycles cleaning from outliers, for both maximum and minimum
        [res.Awake.cycles_max, res.Awake.cycles_min, res.Awake.perc_remotion_min] = filter_breathing_cycles(res.Awake.data_cln, res.Awake.max_pks, res.Awake.max_locs, res.Awake.min_pks, res.Awake.min_locs, fs, "no");
        [res.n1.cycles_max, res.n1.cycles_min, res.n1.perc_remotion_min] = filter_breathing_cycles(res.n1.data_cln, res.n1.max_pks, res.n1.max_locs, res.n1.min_pks, res.n1.min_locs, fs, "no");
        [res.n2.cycles_max, res.n2.cycles_min, res.n2.perc_remotion_min] = filter_breathing_cycles(res.n2.data_cln, res.n2.max_pks, res.n2.max_locs, res.n2.min_pks, res.n2.min_locs, fs, "no");
        [res.n3.cycles_max, res.n3.cycles_min, res.n3.perc_remotion_min] = filter_breathing_cycles(res.n3.data_cln, res.n3.max_pks, res.n3.max_locs, res.n3.min_pks, res.n3.min_locs, fs, "no");
        [res.REM.cycles_max, res.REM.cycles_min, res.REM.perc_remotion_min] = filter_breathing_cycles(res.REM.data_cln, res.REM.max_pks, res.REM.max_locs, res.REM.min_pks, res.REM.min_locs, fs, "no");

        %% Plot in polar coordianates the the R peaks signals in a respiratory cycle. 
        f0 = phase_R(res.Awake.cycles_min, res.Awake.data_cln, car.Awake.locs, 0, 'N0',"no");
        f1 = phase_R(res.n1.cycles_min, res.n1.data_cln, car.n1.locs, 0, 'N1',"no");
        f2 = phase_R(res.n2.cycles_min, res.n2.data_cln, car.n2.locs, 0, 'N2',"no");
        f3 = phase_R(res.n3.cycles_min, res.n3.data_cln, car.n3.locs, 0, 'N3',"no");
        f4 = phase_R(res.REM.cycles_min, res.REM.data_cln, car.REM.locs, 0, 'N4',"no");
        
        polar_hist_stages(f0,f1,f2,f3,f4, 60, true, save_path);

        %% Extract sync data
        result = struct();
        
        for c = 1:length(combinations)
            match = regexp(combinations(c), 'm(\d+)n', 'tokens');
            m = str2double(match{1}{1});
            match = regexp(combinations(c), 'n(\d+)', 'tokens');
            n = str2double(match{1}{1});
            
        
            for i = 1:length(sleep_stages)
                cycles = res.(sleep_stages{i}).cycles_min;
                R_locs = car.(sleep_stages{i}).locs;
                data = res.(sleep_stages{i}).data_cln;

                [phase, R_res_cycle, avg_w, std_w, saved_windows, m_cycle] = sync_phase1(cycles, R_locs, data, T, m, n, fs);
                [perc_sync, sync_cycle]= sync_phase2(m_cycle, phase, R_locs, std_w, saved_windows, m, n, delta, sleep_stages{i}, fs, false);
                sound_event_table = sync_phase3(R_locs, phase, m_cycle, sync_cycle, sleep_stages{i}, sound_events);

                
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
            perc_sync_all = zeros(1, size(sleep_stages, 2));
            for i = 1:length(sleep_stages)
                perc_sync_all(i) = result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_perc;
            end

            fig2 = figure;
            bar(categorical(sleep_stages), perc_sync_all, 'FaceColor', [0.2 0.8 0.8], 'EdgeColor', 'w')
            ylabel('breathing cycles sync %')
            ylim([0, 30])
            title(['Subject ' sub_name ' ' night ' - m=' num2str(m) ' n=' num2str(n)])
            print(fig2, [save_path 'perc_sync_bar_m' num2str(m) '_n' num2str(n) '.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
            close(fig2)
            
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
        parsave([save_path 'result.mat'], result);
 
    end
end

function parsave(filename, result)
    save(filename, 'result');
end
