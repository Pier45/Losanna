function [cond] = extract_sound_info(y)
%EXTRACT_SOUND_INFO
    cond = struct();

    [~, cond.sound_locs] = find(or(y(69,:)==16, y(69,:)==32));

    %synch_start
    cond.sync.start=find(y(69,:)==96); 
    %synch_stop
    cond.sync.stop=find(y(69,:)==112);
    %asynch_start
    cond.asynch.stop=find(y(69,:)==160); 
    %asynch_stop
    cond.asynch.stop=find(y(69,:)==176); 
    %isoch_start
    cond.isoch.stop=find(y(69,:)==128); 
    %isoch_stop
    cond.isoch.stop=find(y(69,:)==144); 
    %baseline_start
    cond.baseline_start.stop=find(y(69,:)==192);
    %baseline_stop
    cond.baseline_start.stop=find(y(69,:)==208);
end

