clear
close all
clc

%% Select folder to be analysed
conditions = ['sleep'; 'awake'];
selected_cond = conditions(2,:);
name_file = 'raw_data.mat'; %name of the file to be checked

%% Path identification
path_folder = ['/mnt/HDD2/CardioAudio_sleepbiotech/data/', selected_cond];
d = dir([path_folder '/s*']);
is_match = ~cellfun(@isempty, regexp({d.name}, '^s\d+$'));
d = d(is_match, :);

%% s31 removed
d(strcmp({d.name}, 's31')) = [];

if selected_cond == 2
    number_folder = 2;
else
    number_folder = 1;
end

failedFiles = {};
barLength = 50;  % Length of the progress bar
tstart = tic;

for k = 1:length(d)
    
    raw_data = struct();
    res = struct();
    car = struct();
    sub_name = d(k).name;
    
    for j = 1:number_folder
        if number_folder > 1
            night = ['n' num2str(j)];
            sel_path = [d(k).folder '/' sub_name '/' night '/process/'];

            %% Create a folder for the subject
            path_save = ['../data/sleep/' sub_name '/' night '/process/'];

            if not(exist(path_save, 'dir'))
                status = mkdir(path_save);        
            end
        else
            path_save = ['../data/awake/' sub_name '/process/'];
            
            if not(exist(['../data/awake/'  sub_name '/process/'], 'dir'))
                status = mkdir(['../data/awake/'  sub_name '/process/']);        
            end
            
            sel_path = [d(k).folder '/' sub_name '/process/'];
            night = 'n0';
        end
            
        raw_data_path = [sel_path name_file];
        
        %% Loading i
        
        try
            data = load(raw_data_path);
            ecg = y(65,:);
            respiration = y(68,:);
            sound = y(69,:);

            save([path_save 'raw_data.mat'], 'ecg', 'respiration', 'sound');
        catch
            warning('Failed to load file: %s', raw_data_path);
            failedFiles{end+1} = raw_data_path;  % Append the path to failedFiles
        end
        

    end

    fprintf('Progress: %6.2f%%   -   completed sub =%4s   -   time = %8.1fs\n', round((k/length(d))*100,2), sub_name, time_sub);

    % Build progress bar
%     percentDone = round((k/length(d)),2);
%     numChars = round(barLength * percentDone);
%     
%     progressBar = ['[', repmat('#', 1, numChars), repmat('-', 1, barLength - numChars), ']'];
%     clc
%     fprintf('Progress:\n\r%s %3.0f%%\n', progressBar, percentDone*100);
end
time_sub = toc(tstart);

