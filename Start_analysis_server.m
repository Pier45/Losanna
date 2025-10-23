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

%% Json config
fid = fopen('config/config.json');
raw = fread(fid, inf);
str = char(raw');
fclose(fid);
config = jsondecode(str);

%% Settable parameters
path_folder = config.essential.path_folder;
output_dir = config.essential.output_dir;
log_dir = config.essential.log_dir;
selected_cond = config.essential.selected_cond;
sub_remove = config.essential.subjects_remove;

number_folder = config.number_folder;
sleep_stages = config.sleep_stages;
% Contoll for the awake session
if selected_cond == "awake"
    number_folder = 1;
    sleep_stages = "Awake";
end

fs = config.fs;
T = config.sync_parameters.T;
delta = config.sync_parameters.delta;
RR_window_pks = config.filters_parameter.RR_window_pks;
RR_window_len = config.filters_parameter.RR_window_len;
sf_res = config.filters_parameter.sf_res;
sf_car = config.filters_parameter.sf_car;

combinations = config.sync_parameters.combinations;
sound_cond = config.sound_cond;
sound_codes = config.sound_codes;
sleep_score_codes = config.sleep_score_codes;

d = dir([path_folder selected_cond '/s*']);
is_match = ~cellfun(@isempty, regexp({d.name}, '^s\d+$'));
d = d(is_match, :);
for sub=1:length(sub_remove)
    d(strcmp({d.name}, sub_remove{sub})) = [];
end

if not(exist(log_dir, 'dir'))
    mkdir(log_dir)
end

t = datetime;
DateString = datestr(t); 
log_file_name = ['analyis_log_' DateString '.txt'];
diary([log_dir log_file_name]);
diary on

name_folder_T = [selected_cond '/T' num2str(T) '/'];
for k = 1:length(d)
    
    sub_name = d(k).name;
    fprintf('Start analysis %3s\n', sub_name);

    if string(sub_name) == "s10"
        disp('')
    end
    
    tstart = tic;
    for j = 1:number_folder
        if number_folder > 1
            night = ['n' num2str(j)];
            sel_path = [d(k).folder '/' sub_name '/' night '/'];

            %% Create a folder for the subject
            path_checks = [output_dir name_folder_T  sub_name '/' night '/check_plots'];
            path_save = [output_dir name_folder_T sub_name '/' night '/'];

            if not(exist(path_save, 'dir'))
                status = mkdir(path_save);        
            end
        else
            path_checks = [output_dir name_folder_T  sub_name '/check_plots'];
            path_save = [output_dir name_folder_T sub_name '/'];
            
            if not(exist([output_dir name_folder_T  sub_name '/'], 'dir'))
                status = mkdir([output_dir name_folder_T  sub_name '/']);        
            end
            
            sel_path = [d(k).folder '/' sub_name '/'];
            night = "Awake";
        end

        if not(exist(path_checks, 'dir'))
            status2 = mkdir(path_checks);
        end
            
        raw_data_path = [sel_path 'raw_data.mat'];
        load(raw_data_path)
        
        ecg = data.ecg;
        respiration = data.res;
        sound = data.trg;
%         if not(contains(path_folder, 'piero'))
%             %% Loading in this way is faster x5 respect to single or full load
%             mfile = matfile(raw_data_path);
%             data = mfile.y(65:69,:);
%             ecg = data(1,:);
%             respiration = data(4,:);
%             sound = data(5,:);
%         else
%             load(raw_data_path)
%         end
        
        raw_data = struct();
        car = struct();
        res = struct();
        f = struct();
        
        % Load the sleep stages
        if convertCharsToStrings(selected_cond) == "sleep"
%             files = dir(fullfile(sel_path, '*.mat')); % Or '*.txt', etc.
%             match_idx = ~cellfun(@isempty, regexp({files.name}, ['^' sub_name '_allsleep_n\d+_slscore.mat$']));
%             matched_files = files(match_idx);
%             if isempty(matched_files)
%                 error('Error with sleep score file\nThe file should be saved in a file that respect the regex query like: %s', '{sub_name}_allsleep_n{a number}_slscore.mat');
%             end  
%             sleep_labels = load([matched_files.folder '/' matched_files.name]);
%             score_labels = sleep_labels.score_labels;
            score_labels = data.scr;
        else
            score_labels = zeros(1, length(ecg));
        end
        
        %% Extraction of sound event
        [sound_events] = extract_sound_info(sound, score_labels, sub_name, night, true, [path_save 'check_plots']);

        %% s22 remotion of outliers section -> now automatic thanks to clean_data_find_peaks
%         if convertCharsToStrings(sub_name) == "s22" && convertCharsToStrings(night) == "n2"
%             ecg_temp = ecg(raw_data.Awake.idx);
%             res_temp = respiration(raw_data.Awake.idx);
%             range_out = 1258520:1693850;
%             new_section = ones(1, length(range_out))*-1667;
%             ecg_temp(range_out) = new_section;
%             res_temp(range_out) = new_section;
% 
%             ecg(raw_data.Awake.idx) = ecg_temp;
%             respiration(raw_data.Awake.idx) = res_temp;
%         end
        
        for s =1:length(sleep_stages)
            %% Remember, the possible score lables are 0, 1, 2, 3, 4(REM)
            raw_data.(sleep_stages{s}).logic_selection = score_labels == sleep_score_codes(s);
            
            raw_data.(sleep_stages{s}).idx = find(raw_data.(sleep_stages{s}).logic_selection == 1);
            raw_data.(sleep_stages{s}).perc = sum(raw_data.(sleep_stages{s}).logic_selection)/sum(score_labels~=0)*100;
            [c_pks0, c_locs0, ~, ~, car.(sleep_stages{s}).data_cln, car.(sleep_stages{s}).mean_bpm] = clean_data_find_peaks(sf_car, fs, ecg(raw_data.(sleep_stages{s}).idx), sleep_stages{s}, "cardiac", "no");
            [car.(sleep_stages{s}).pks, car.(sleep_stages{s}).locs, car.(sleep_stages{s}).p_R_out] = filter_R_peaks(c_pks0, c_locs0, RR_window_pks, RR_window_len, car.(sleep_stages{s}).data_cln, sleep_stages{s}, "plot", [path_checks '/R_peaks_' sub_name '_' sleep_stages{s}]);
            [res.(sleep_stages{s}).max_pks, res.(sleep_stages{s}).max_locs, res.(sleep_stages{s}).min_pks, res.(sleep_stages{s}).min_locs, res.(sleep_stages{s}).data_cln, res.(sleep_stages{s}).mean_bpm] = clean_data_find_peaks(sf_res, fs, respiration(raw_data.(sleep_stages{s}).idx), sleep_stages{s}, "respiration", "no");
            [res.(sleep_stages{s}).cycles_max, res.(sleep_stages{s}).cycles_min, res.(sleep_stages{s}).perc_remotion_min] = filter_res_cycles(res.(sleep_stages{s}).data_cln, res.(sleep_stages{s}).max_pks, res.(sleep_stages{s}).max_locs, res.(sleep_stages{s}).min_pks, res.(sleep_stages{s}).min_locs, fs, sleep_stages{s}, "plot", [path_checks '/BH_' sub_name '_' sleep_stages{s}]);
            f.(sleep_stages{s}) = phase_res(res.(sleep_stages{s}).cycles_min, res.(sleep_stages{s}).data_cln, car.(sleep_stages{s}).locs, 0, 'N0',"no");
        end
    
        polar_hist_stages(f, 60, path_save);

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
                [perc_sync, sync_cycle, sync_samples, tot_samples]= sync_phase2(m_cycle, phase, R_locs, std_w, saved_windows, m, n, delta, sleep_stages{i}, false);
                sound_event_table = sync_phase3(m_cycle, sync_cycle, sound_events);
                
                %% Save sleep stage data output
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_perc = perc_sync;
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_cycle = sync_cycle; 
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).sync_samples = sync_samples;
                result.(combinations{c}).sleep_stages.(sleep_stages{i}).tot_samples = tot_samples;
                
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
            
            [sleepTable] = table_summary(sleep_stages, sound_cond, result.(combinations{c}).sleep_stages);
            bar_subplot(sleep_stages, sub_name, night, m, n, sound_cond, sleepTable, path_save);  
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
%     fprintf('->%15s - %6.2f%%   -   sub =%3s   -  time = %8.1fs\n','Completed', round((k/length(d))*100,2), sub_name, time_sub);
    
    bar_length = 64;  % Total length of the bar
    perc_comp = round((k/length(d))*100,2);
    filled = round((perc_comp/100) * bar_length);
    barra = ['[' repmat('=', 1, filled) repmat(' ', 1, bar_length-filled) ']'];    
    fprintf('%s %6.2f%%            time %s analysis = %8.1fs\n', barra, perc_comp, sub_name, time_sub);
end

diary off

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