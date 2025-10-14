function [sound_events] = extract_sound_info(sound, save_plot, sub_name, night, save_path)
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
    
    if convertCharsToStrings(sub_name) == "s12" && convertCharsToStrings(night) == "n1"
        %% s12 lack of a stop event in baseline 
        sound_events.baseline.start(15) = [];
    elseif convertCharsToStrings(sub_name) == "s21" && convertCharsToStrings(night) == "n2"
        %% s21 n2 lask of 1 stop event in the sync array
        sound_events.sync.start(6) = [];        
    end

    %% Create a vector for each condition
    sound_events.vector = zeros(length(sound), 1);
    for s=1:size(sound_cond)
        for r=1:size(sound_events.(sound_cond{s}).start,2)
            if convertCharsToStrings(sound_cond{s}) == "sync"
                sasa = 96;
            elseif convertCharsToStrings(sound_cond{s}) == "asynch"
                sasa = 160;
            elseif convertCharsToStrings(sound_cond{s}) == "isoch"
                sasa = 128;
            elseif convertCharsToStrings(sound_cond{s}) == "baseline"
                sasa = 192;
            end
            sound_events.vector(sound_events.(sound_cond{s}).start(r):sound_events.(sound_cond{s}).stop(r)) = sasa;
        end
    end
    
    if save_plot
        if contains(save_path, 's') 
            fig2 = figure('doublebuffer','off', 'Visible','Off');
        else
            fig2 = figure();
        end 
        set(fig2,'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

        plot(sound_events.vector, 'k') % plot in black for visibility

        hold on;

        % Add horizontal reference lines
        yline(192, '-', 'baseline', 'Color', [.7 .7 .7]);
        yline(128, '-', 'isoc', 'Color', 'b');
        yline(160, '-', 'async', 'Color', 'k');
        yline(96, '-', 'sync', 'Color', 'r');

        % Define values to highlight and corresponding colors
        target_values = [192, 128, 160, 96];
        colors = {[.7 .7 .7], 'b', 'k', 'r'}; % pastel shades

        for i = 1:length(target_values)
            val = target_values(i);
            color = colors{i};

            % Find all indices where the vector equals the target value
            idx = find(sound_events.vector == val);

            % Group consecutive indices into segments
            if ~isempty(idx)
                d = diff(idx);
                edges = [0, find(d > 1)', length(idx)];
                for j = 1:length(edges)-1
                    start_idx = idx(edges(j)+1);
                    end_idx = idx(edges(j+1));
                    width = end_idx - start_idx + 1;

                    % Draw rectangle
                    rectangle('Position', [start_idx, min(ylim), width, val], ...
                              'FaceColor', color, 'EdgeColor', 'none');
                end
            end
        end

        % Plot again on top for visibility
        plot(sound_events.vector, 'k', 'LineWidth', 1.2);

        hold off;
        title("Sound blocks")
        ax = gca; % Get current axes
        set(ax, 'LooseInset', get(gca, 'TightInset')) % tight layout
        ax.FontSize = 14;
        
        print(fig2, [save_path '/Sound_blocks_check.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
        close(fig2)
    end


end
