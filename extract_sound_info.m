function [sound_events] = extract_sound_info(sound)
%%  EXTRACT_SOUND_INFO 
%   Extracts various synchronization points from the input sound data.
%   The function takes a vector 'sound' as input and returns a structure 'sound_events' 
%   containing the locations of sound events. The structure includes fields  
%   sound locations, synchronization points (sync), async
%   for asyncronus points (asynch), isochronous points (isoch), and baseline 
%   start/stop points. Each field contains the indices in the 'sound' 
%   vector where specific sound events occur, identified by their unique 
%   values.

    sound_events = struct();

    [~, sound_events.sound_locs] = find(or(sound==16, sound==32));

    % synch_start
    sound_events.sync.start=find(sound==96); 
    % synch_stop
    sound_events.sync.stop=find(sound==112);
    % asynch_start
    sound_events.asynch.start=find(sound==160); 
    % asynch_stop
    sound_events.asynch.stop=find(sound==176); 
    % isoch_start
    sound_events.isoch.start=find(sound==128); 
    % isoch_stop
    sound_events.isoch.stop=find(sound==144); 
    % baseline_start
    sound_events.baseline.start=find(sound==192);
    % baseline_stop
    sound_events.baseline.stop=find(sound==208);
    
    %% Retrive the fieldnames of the sound events
    sound_cond = fieldnames(rmfield(sound_events, 'sound_locs'));
    
    %% Create a vector for each condition
    sound_events.vector = zeros(length(sound), 1);
    for s=1:size(sound_cond)
        for r=1:size(sound_events.(sound_cond{s}).start,2)
            if convertCharsToStrings(sound_cond{s}) == "sync"
                sasa = 96;
            elseif convertCharsToStrings(sound_cond{s}) == "async"
                sasa = 160;
            elseif convertCharsToStrings(sound_cond{s}) == "isoch"
                sasa = 128;
            elseif convertCharsToStrings(sound_cond{s}) == "baseline"
                sasa = 192;
            end
            sound_events.vector(sound_events.(sound_cond{s}).start(r):sound_events.(sound_cond{s}).stop(r)) = sasa;
        end
    end
    
%     figure, 
%     plot(sound_events.vector)
%     hold on
%     yline(192, '-','baseline')
%     yline(128, '-','isoc')
%     yline(160, '-','async')
%     yline(96, '-','sync')
    

end
