function [ends, labels] = findSegmentEnds(beh)

% Find where the behavior vector changes value
changes = diff(beh);

% Find non-zero elements (where changes occur)
change_idx = find(changes ~= 0);

% The end points are exactly at the change indices
% Also add the end of vector if the last segment isn't zero
if beh(end) ~= 0
    ends = [change_idx; length(beh)];
    labels = [beh(change_idx); beh(end)];
else
    ends = change_idx;
    labels = beh(change_idx);
end

% Ensure ends and labels are column vectors
ends = ends(:);
labels = labels(:);
end