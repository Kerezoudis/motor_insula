function [starts, labels] = findSegmentStarts(beh)
    
% Find where the behavior vector changes value
changes = diff(beh);

% Find non-zero elements (where changes occur)
change_idx = find(changes ~= 0);

% Add 1 to get the start of new segments
% Also add 1 at the beginning if it's not zero
if beh(1) ~= 0
    starts = [1; change_idx + 1];
    labels = [beh(1); beh(change_idx + 1)];
else
    starts = change_idx + 1;
    labels = beh(change_idx + 1);
end

% Ensure starts and labels are column vectors
starts = starts(:);
labels = labels(:);

end