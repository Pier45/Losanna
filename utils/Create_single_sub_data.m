clear
close all
clc

%% Inital definitions
subj=28; %subject number
consc_sel=2; %1=awake; 2=sleep
consc_label = ['awake'; 'sleep'];
sleep_night=1; %1=day1 sleep; 2=day2 sleep

% path_xdf = '/mnt/filearc_eeg/CardioAudio_sleepbiotech/raw_data';
path_xdf = '/mnt/HDD2/piero';

path_sleep = '/mnt/HDD2/CardioAudio_sleepbiotech/data';
path_output = '/data';
row_sel=[65, 68, 69];
row_label=["ecg", "respiration", "sound_triggers"];
name_output_file = 'raw_data.mat';

if consc_sel==1   
    load([path_sleep '/awake/awake_sub_blocks.mat'], 'day')

    subj_dir_out = ['..' path_output '/' consc_label(consc_sel, :) '/s' num2str(subj) '/']; 
    filename_xdf = [path_xdf '/' consc_label(consc_sel, :) '/' day(1).fileid{subj}{1},'/ses-a1/eeg/sub-',day(1).fileid{subj}{1},'_ses-a1_task-awake_run-001_eeg.xdf']; %input subject filename    

elseif consc_sel==2 
    load([path_sleep '/sleep/sleep_sub_blocks.mat'], 'day')

    subj_dir_out = ['..' path_output '/' consc_label(consc_sel, :) '/s' num2str(subj),'/n', num2str(sleep_night),'/']; 
    filename_xdf = [path_xdf  '/' consc_label(consc_sel, :) '/acquisition/',cell2mat(day(sleep_night).fileid{subj,1}(1,1)),'/ses-n',num2str(sleep_night),'/eeg/sub-',cell2mat(day(sleep_night).fileid{subj,1}(1,1)),'_ses-n',num2str(sleep_night),'_task-sleep_run-001_eeg.xdf']; %input subject filename    
end

tic
create_raw_data(filename_xdf, path_sleep, subj_dir_out, subj, sleep_night, row_sel, consc_label(consc_sel, :), name_output_file)
toc
    
    
