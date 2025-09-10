function [cycles] = create_cycles(locs)
%CREATE_CYCLES 
%   Create couple of columns in which the first one contains the starting
%   point expressed in sample and the second the stop point.
    cycles = [locs(1:end-1)', locs(2:end)'];
end

