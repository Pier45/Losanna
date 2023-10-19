function [cycles_clean2] = clean_breathing_cycles(cycles, locs, outliers_locs, locs_inside, outliers_locs_inside)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    % Removing the cycles that has as boundary point an outlier
    outliers = locs(outliers_locs);
    cycles_good1 = true(length(cycles),1);
    for j=1:length(outliers)

        cycles_good1(find(cycles(:,1)==outliers(j), 1)) = 0;
        cycles_good1(find(cycles(:,2)==outliers(j), 1)) = 0;

    end
    cycles_clean1 = cycles(cycles_good1, :);
    %locs_clean1 = locs(cycles_good1);

    % Removing form the cleaned cycles, the ones that have an outlier
    % between the two boundary points (if you are searching for example
    % clean cycle between maximums, in the following code check if there is
    % a minimum outlier inside the two maximum that identify the cycle).

    % Identify the couples that have just one peak inside
    good_inside = locs_inside(not(outliers_locs_inside));
    cycles_good2 = false(length(cycles_clean1),1);
    for n=1:size(cycles_clean1, 1) 
        for k=1:length(good_inside)
            if (good_inside(k) > cycles_clean1(n,1)) && (good_inside(k) < cycles_clean1(n,2))
                % Whether the cycle was already flagged as good, it means
                % that another peak was find inside the couple so the cycle
                % must be removed.
                if cycles_good2(n) == 1
                    cycles_good2(n) = 0;
                    break
                else
                    cycles_good2(n) = 1;
                end
            end
        end
    end

    cycles_clean2 = cycles_clean1(cycles_good2, :);
    %locs_clean2 = locs_clean1(cycles_good2);
end

