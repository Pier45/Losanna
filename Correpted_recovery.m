clear
close all
clc

conditions = ['sleep'; 'awake'];
selected_cond = conditions(1,:);

path_folder = ['/mnt/HDD2/CardioAudio_sleepbiotech/data/', selected_cond];
d = dir([path_folder '/s*']);
is_match = ~cellfun(@isempty, regexp({d.name}, '^s\d+$'));
d = d(is_match, :);

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

failedFiles = {};
number_folder = 2;

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
        
        %% Loading in this way is faster x5 respect to single or full load
        % Initialize a cell array to store failed file names

        try
            data = load(raw_data_path);
        catch
            warning('Failed to load file: %s', raw_data_path);
            failedFiles{end+1} = raw_data_path;  % Append the path to failedFiles
        end

    end
end