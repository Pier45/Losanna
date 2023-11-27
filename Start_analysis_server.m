clear
close all
clc

% load('/mnt/HDD2/CardioAudio_sleepbiotech/data/awake/s21/process/raw_data.mat')

%% Select the folder sleep or awake
path_folder = uigetdir('/mnt/HDD2/CardioAudio_sleepbiotech/data/');

d = dir([path_folder '/s*']);
rm_index = [];
for s = 1:length(d)
    if isnan(str2double(d(s).name(2:end)))
        rm_index=[rm_index s];
    end
end

d(rm_index) = [];

for k = 1:length(d)
    sel_path = [d(k).folder '/' d(k).name '/raw_data.mat'];
	% Test the loading of restricted part of the mat file
    load(sel_path)
    status = mkdir(d(k).name);
    % Do processing
    
    % Save
    save();
end

%% Extract sound locs and conditions start/stop
[cond] = extract_sound_info(y);
