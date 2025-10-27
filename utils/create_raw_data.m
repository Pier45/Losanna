function create_raw_data(filename_xdf, path_sleep, subj_dir_out, subj, sleep_night, row_sel, consc_label_sel, name_output_file)
%LOAD_RAW Summary of this function goes here
    data = struct();
    if not(subj == 17) || convertCharsToStrings(consc_label_sel)=="sleep"
        all_raw = load_xdf(filename_xdf);
        factor = 1;
    else
        load('/mnt/HDD2/CardioAudio_sleepbiotech/data/awake/s17/process/raw_orig.mat', 'all_raw')
        factor = 1000000;
    end

    if size(all_raw,2)>1 && length(all_raw{1,2}.time_series(1,:))>1000
        data.ecg = all_raw{1,2}.time_series(row_sel(1),:);
        data.res = all_raw{1,2}.time_series(row_sel(2),:);
        data.trg = all_raw{1,2}.time_series(row_sel(3),:)/factor;
    else 
        data.ecg = all_raw{1,1}.time_series(row_sel(1),:);
        data.res = all_raw{1,1}.time_series(row_sel(2),:);
        data.trg = all_raw{1,1}.time_series(row_sel(3),:)/factor;
    end
    
    control_len = length(data.ecg);
    
    if convertCharsToStrings(consc_label_sel)=="sleep"
        files = dir(fullfile([path_sleep '/' consc_label_sel '/s' num2str(subj) '/n' num2str(sleep_night) '/process/' ], '*.mat')); % Or '*.txt', etc.
        match_idx = ~cellfun(@isempty, regexp({files.name}, '_allsleep_n\d+_slscore.mat$'));
        matched_files = files(match_idx);
        load([matched_files.folder '/' matched_files.name], 'score_labels');

        data.scr = score_labels;
        
        if length(data.scr) ~= control_len
            warning(['Problems of length! - ' num2str(subj)])
        end
    end
    
    if not(exist(subj_dir_out, 'dir'))
        mkdir(subj_dir_out);        
    end
    
    save([subj_dir_out name_output_file], 'data')
end

