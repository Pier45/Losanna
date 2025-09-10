function [cond] = extract_sound_info(sound)
%EXTRACT_SOUND_INFO Summary of this function goes here
    cond = struct();

    [~, cond.sound_locs] = find(or(sound==16, sound==32));

    %synch_start
    cond.sync.start=find(sound==96); 
    %synch_stop
    cond.sync.stop=find(sound==112);
    %asynch_start
    cond.asynch.stop=find(sound==160); 
    %asynch_stop
    cond.asynch.stop=find(sound==176); 
    %isoch_start
    cond.isoch.stop=find(sound==128); 
    %isoch_stop
    cond.isoch.stop=find(sound==144); 
    %baseline_start
    cond.baseline_start.stop=find(sound==192);
    %baseline_stop
    cond.baseline_start.stop=find(sound==208);
end

