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
for k = 1:length(d)
    
    raw_data = struct();
    res = struct();
    car = struct();
    sub_name = d(k).name;
    
    tstart = tic;
    for j = 1:number_folder
        if number_folder > 1
            night = ['n' num2str(j)];
            sel_path = [d(k).folder '/' sub_name '/' night '/process/'];
        else
            sel_path = [d(k).folder '/' sub_name '/process/'];
            night = 'n0';
        end
            
        raw_data_path = [sel_path name_file];
        
        %% Loading in this way is faster x5 respect to single or full load
        % Initialize a cell array to store failed file names

        try
            data = load(raw_data_path);
        catch
            warning('Failed to load file: %s', raw_data_path);
            failedFiles{end+1} = raw_data_path;  % Append the path to failedFiles
        end

    end
    time_sub = toc(tstart);
    fprintf('Progress: %6.2f%%   -   completed sub =%4s   -   time = %8.1fs\n', round((k/length(d))*100,2), sub_name, time_sub);
end


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

