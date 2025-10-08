function [result] = sync_phase3(new_cycles, sync_cycles, sound_events)
%SYNC_PHASE3 Summary of this function goes here
% Per ogni ciclo accettato vedo in che parte di suono si trova, poi faccio
% statistica su stimolazione sonora che ha la syncronia maggiore
    
    %% Initialization
    result = table();
    sound_cycles = ones(length(sound_events.vector), 1);
    sound_cond = {'nan', 'sync', 'async', 'isoc', 'baseline'};
    sound_codes = [0, 96, 160, 128, 192];
    
    if not(isempty(sync_cycles))
        total_sample_sync = sum( diff(new_cycles(sync_cycles,:)') ) +1; %%check

        for a=1:length(sync_cycles)
            range_selection = new_cycles(sync_cycles(a),1): new_cycles(sync_cycles(a),2);
            sound_cycles(range_selection) = sound_events.vector(range_selection);
        end
        
        [unique_vals, ~, idx] = unique(sound_cycles);
        counts = accumarray(idx, 1);
        percentages = (counts / total_sample_sync) * 100;

        selection = ismember(unique_vals, sound_codes);
        unique_vals = unique_vals(selection);
        counts = counts(selection);
        percentages = percentages(selection);
                
        positions = ismember(sound_codes, unique_vals);
        condition_labels = sound_cond(positions);

        % Build result table
        result = table(unique_vals, condition_labels', counts, percentages, ...
        'VariableNames', {'Code', 'Condition', 'Count', 'Percentage'});

        result(result.Code == 0, :) = [];
    end
end

