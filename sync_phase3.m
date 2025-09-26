function [result] = sync_phase3(new_cycles, sync_cycles, sound_events)
%SYNC_PHASE3 Summary of this function goes here
% Per ogni ciclo accettato vedo in che parte di suono si trova, poi faccio
% statistica su stimolazione sonora che ha la syncronia maggiore @

%     figure
%     plot(theta)
%     hold on
%     plot(R_locs, theta(R_locs), 'o', 'MarkerFaceColor','red')
%     draw_xregion(new_cycles(accepted_cycles,1), new_cycles(accepted_cycles,2), ylim, 'b', 0.3);
%     for i = 1:length(index_cycle_selected)
%         xline(new_cycles(index_cycle_selected(i),1), '-', num2str(index_cycle_selected(i)));
%     end
%     title(['Sleep phase ' sleep_stage])
%     ax = gca; % Get current axes
%     ax.FontSize = 14;
    
    if sync_cycles ~= 0
        sound_cond = {'nan', 'sync', 'async', 'isoc', 'baseline'};
        sound_codes = [0, 96, 160, 128, 192];  % Corresponding numeric codes

        result = table();
        sound_cycles = zeros(length(sound_events.vector), 1);
        total_sample_sync = 0;

        if not(isempty(sync_cycles))
            for a=1:length(sync_cycles)
                range_selection = new_cycles(sync_cycles(a),1): new_cycles(sync_cycles(a),2);
                sound_cycles(range_selection) = sound_events.vector(range_selection);
                total_sample_sync = total_sample_sync + numel(range_selection);
            end
            [unique_vals, ~, idx] = unique(sound_cycles);
            counts = accumarray(idx, 1);
            percentages = (counts / total_sample_sync) * 100;

            % Convert numeric codes to labels using mapping
            [~, loc] = ismember(unique_vals, sound_codes);
            condition_labels = sound_cond(loc);  % This gives a cell array of labels

            % Build result table
            result = table(unique_vals, condition_labels', counts, percentages, ...
            'VariableNames', {'Code', 'Condition', 'Count', 'Percentage'});

            result(result.Code == 0, :) = [];
        end
    else
        result = table();
    end
end

