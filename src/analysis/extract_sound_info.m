function [sound_events] = extract_sound_info(sound, sound_cond, sound_codes, sleep_stages, raw_data, sub_name, night, save_plot, save_path)
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
    sound_events.sound_cond = string(sound_cond);
    sound_events.sound_codes = sound_codes;

    [~, sound_events.sound_locs] = find(or(sound==16, sound==32));

    % synch_start
    sound_events.sync.start=find(sound==96); 
    % synch_stop
    sound_events.sync.stop=find(sound==112);
    % asynch_start
    sound_events.async.start=find(sound==160); 
    % asynch_stop
    sound_events.async.stop=find(sound==176); 
    % isoch_start
    sound_events.isoch.start=find(sound==128); 
    % isoch_stop
    sound_events.isoch.stop=find(sound==144); 
    % baseline_start
    sound_events.baseline.start=find(sound==192);
    % baseline_stop
    sound_events.baseline.stop=find(sound==208);
    
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
        if sound_events.sound_cond{s} ~= "nan"
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
    end
    
    if length(sleep_stages) > 1
        for s =1:length(sleep_stages)
            %% Remember, the possible score lables are 0, 1, 2, 3, 4(REM)
            select = sound_events.vector(raw_data.(sleep_stages{s}).logic_selection);
            [unique_codes, ~, idx] = unique(select);
            counts = accumarray(idx, 1);
            
            if size(unique_codes,1) < size(sound_codes,1)
                padded_count = zeros(size(sound_codes,1),1);
                sound_codes = sort(sound_codes);
                for id=1:size(sound_codes,1)
                    log_pos = sound_codes(id) == unique_codes;
                    if any(log_pos)
                        padded_count(id) = counts(log_pos);
                    else
                        padded_count(id) = 0;
                    end
                end
                warning('Very small section of sleep stage unable to find all sound blocks inside %s \nFound only this codes: %s', sleep_stages{s}, num2str(unique_codes'))
            else
                padded_count = counts;
            end
            
            perc_s = ((padded_count)*100)./sum(raw_data.(sleep_stages{s}).logic_selection);
            sound_events.sound_for_sleep_stage.(sleep_stages{s}) = table(sound_events.sound_cond, sound_codes, perc_s, 'VariableNames', {'Sound_events', 'Code', 'Perc'});
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
        yline(128, '-', 'isoch', 'Color', 'b');
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

        if length(sleep_stages) > 1
            if contains(save_path, 's') 
                fig3 = figure('doublebuffer','off', 'Visible','Off');
            else        
                fig3 = figure();
            end
            set(fig3,'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

            colors = [
                0.5 0.5 0.5;  % mustard
                1.0 0.0 0.0;  % red
                0.0 0.0 0.0;  % black
                0.0 0.0 1.0;  % blue
                0.7 0.7 0.7   % gray
            ];
            for s =1:length(sleep_stages)
                subplot(2,3,s)
                bar_single(sound_events.sound_for_sleep_stage.(sleep_stages{s}).Perc, sleep_stages(s), sound_cond, '% sound events',colors)
                title(sleep_stages{s})
            end

            print(fig3, [save_path '/Sound_blocks_vs_sleep_stage.png'], '-dpng', '-r100');  % -r300 sets 300 DPI resolution
            close(fig3)
        end
    end


end
