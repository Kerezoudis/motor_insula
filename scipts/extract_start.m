function [kpts, pts] = extract_start(tr_sc, trialnr)

% [kpts] = extract_start(tr_sc, trialnr)
%
% This function extracts the first time points of the input vector 
% that correspond to movements trials. 
% 
% Panos Kerezoudis, CaMP lab, 2024. 

% Set up parameters and time points ---------------------------------------
uplim = 4800;
moveTrial = find(tr_sc == 1 | tr_sc == 2 | tr_sc == 3);
pts = zeros(size(moveTrial, 2), 3);

% Extract start and end times for each movement type ----------------------
for i = 1:size(moveTrial, 2)
    block = find(trialnr == moveTrial(i));
    pts(i, 1) = block(1); pts(i, 2) = block(end); 
    if tr_sc(moveTrial(i)) == 1,  pts(i, 3) = 1;
    elseif tr_sc(moveTrial(i)) == 2,  pts(i, 3) = 2;
    elseif tr_sc(moveTrial(i)) == 3,  pts(i, 3) = 3;
    end
end

clear i block

% Define starting points for each movement type ---------------------------
q = {'hand', 'tongue', 'foot'};
for k = 1:length(q)
    kpts.(q{k}) = pts(find(pts(:, 3) == k), 1);
    temp = kpts.(q{k});
    kpts.(q{k}) = [temp(1) temp(find(diff(temp) > uplim) + 1)'];
end


end