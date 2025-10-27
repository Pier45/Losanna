clear
close all
clc

%% Select folder to be analysed
% conditions = ['sleep'; 'awake'];
% selected_cond = conditions(2,:);
% name_file = 'raw_data.mat'; %name of the file to be checked

%%
consc_sel=2; %1=awake; 2=sleep
consc_label = ['awake'; 'sleep'];

% xdf must be copied from this server in local
% path to the original files is: '/mnt/filearc_eeg/CardioAudio_sleepbiotech/raw_data';
path_xdf = '/mnt/HDD2/piero';

path_sleep = '/mnt/HDD2/CardioAudio_sleepbiotech/data';
path_output = '/data';
row_sel=[65, 68, 69];
row_label=["ecg", "respiration", "sound_triggers"];
name_output_file = 'raw_data.mat';

if consc_sel == 2
    number_folder = 2;
    load([path_sleep '/sleep/sleep_sub_blocks.mat'], 'day')
    n_sub = size(day(2).fileid,1);
else
    number_folder = 1;
    load([path_sleep '/awake/awake_sub_blocks.mat'], 'day')    
    n_sub = size(day(1).fileid,1);
end

t = datetime;
DateString = char(t, "yyyy-MMM-dd_HH:mm:ss"); 
log_file_name = ['creation_dataset_log_' consc_label(consc_sel) '_' DateString '.txt'];
diary([log_dir log_file_name]);
diary on

%% Start Creation
for k = 1:n_sub
    sub_name = ['s' num2str(k)];
    
    tstart = tic;
    for j = 1:number_folder
        if number_folder > 1
            night = ['n' num2str(j)];

            %% Create a folder for the kect
            path_save = ['../data/sleep/' sub_name '/' night '/'];
            filename_xdf = [path_xdf  '/' consc_label(consc_sel, :) '/acquisition/',cell2mat(day(j).fileid{k,1}(1,1)),'/ses-n',num2str(j),'/eeg/sub-',cell2mat(day(j).fileid{k,1}(1,1)),'_ses-n',num2str(j),'_task-sleep_run-001_eeg.xdf']; %input kect filename    

        else
            filename_xdf = [path_xdf '/' consc_label(consc_sel, :) '/' day(1).fileid{k}{1},'/ses-a1/eeg/sub-',day(1).fileid{k}{1},'_ses-a1_task-awake_run-001_eeg.xdf']; %input kect filename    
            path_save = ['../data/awake/' sub_name '/'];
            
        end
        
        %% Loading new
        create_raw_data(filename_xdf, path_sleep, path_save, k, j, row_sel, consc_label(consc_sel, :), name_output_file)

    end
    time_sub = toc(tstart);
    fprintf('Progress: %6.2f%%   -   completed sub =%4s   -   time = %8.1fs\n', round((k/n_sub)*100,2), sub_name, time_sub);

    % Build progress bar
%     percentDone = round((k/length(d)),2);
%     numChars = round(barLength * percentDone);
%     
%     progressBar = ['[', repmat('#', 1, numChars), repmat('-', 1, barLength - numChars), ']'];
%     clc
%     fprintf('Progress:\n\r%s %3.0f%%\n', progressBar, percentDone*100);
end

diary off