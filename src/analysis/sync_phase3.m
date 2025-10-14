function [sound_table] = sync_phase3(new_cycles, sync_cycles, sound_events)
%SYNC_PHASE3 Summary of this function goes here
% Per ogni ciclo accettato vedo in che parte di suono si trova, poi faccio
% statistica su stimolazione sonora che ha la syncronia maggiore
    
    %% Initialization
    sound_table = table();
    sound_cond = {'nan', 'sync', 'async', 'isoc', 'baseline'};
    sound_codes = [0, 96, 160, 128, 192];
    
    if not(isempty(sync_cycles))

        
        logic_selection = false(length(sound_events.vector), 1);
        sel_cycle = new_cycles(sync_cycles, :);

        for l = 1:size(sel_cycle, 1)
            logic_selection(sel_cycle(l,1):sel_cycle(l,2)) = true;  
        end
        
        sound_sel = sound_events.vector(logic_selection);
        if not(isempty(sound_sel))
            counts = zeros(size(sound_codes));
            for g = 1:length(sound_codes)
                counts(g) = sum(sound_sel == sound_codes(g));
            end
            percentages = (counts / length(sound_sel)) * 100;
            sound_table = table(sound_codes', sound_cond', counts', percentages', 'VariableNames', {'Code', 'Condition', 'Count', 'Percentage'});
        end
    end
end

