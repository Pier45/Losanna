function [cond] = extract_sound_info(sound)
%%  EXTRACT_SOUND_INFO 
%   Extracts various synchronization points from the input sound data.
%   The function takes a vector 'sound' as input and returns a structure 'cond' 
%   containing the locations of sound events. The structure includes fields  
%   sound locations, synchronization points (sync), async
%   for asyncronus points (asynch), isochronous points (isoch), and baseline 
%   start/stop points. Each field contains the indices in the 'sound' 
%   vector where specific sound events occur, identified by their unique 
%   values.

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
