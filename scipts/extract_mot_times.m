function extract_mot_times(pt, pt_task)

% Load related datafiles --------------------------------------------------
load([pt '/' pt '_trials.mat']);
load([pt '/' pt '_' pt_task '_nondp_data.mat'], 'stim')
load([pt '/' pt '_EMG_segm.mat'], 'beh')

% Behavioral vector -------------------------------------------------------
[~, behPts] = extract_start(tr_sc, trialnr);

% Stimulus vector ---------------------------------------------------------
[stimnr, stim_sc, ~] = mk_tr_vec(stim);
[~, stimPts] = extract_start(stim_sc, stimnr);

% Matrix with stim onset, mvmt onset and mvm type -------------------------
movMatrix = zeros(size(behPts, 1), 3); 
movMatrix(:, [2 3]) = behPts(:, [1 3]);

for k = 1:size(behPts, 1)
    mvmt_onset = movMatrix(k, 2);
%     mvmt_type = movMatrix(k, 3);

    % Find the cue with the closest cue start time to the mvmt onset
    [~, closest_idx] = min(abs(stimPts(:, 1) - mvmt_onset));
    
    % Extract the closest cue start time
    closest_cue_start = stimPts(closest_idx, 1);
    
    % Fill in
    movMatrix(k, 1) = closest_cue_start;
end

% Matrix with reaction times per movement trial ---------------------------
reactMatrix = zeros(size(behPts, 1), 2); 
reactMatrix(:, 2) = movMatrix(:, 3);
reactMatrix(:, 1) = movMatrix(:, 2) - movMatrix(:, 1);

% Extract mean reaction times per movement type ---------------------------
for k = 1:3
    temp = find(reactMatrix(:, 2) == k);
    meanReact(k, 1) = round(mean(reactMatrix(temp, 1)));
end

% Save screen cue & mvmt onset times in struct per movement type ----------
q = {'hand', 'tongue', 'foot'};
for j = 1:length(q)
    temp = movMatrix(:, 3) == j;
    movTimes.(q{j})(:, 1:2) = movMatrix(temp, 1:2);
    movTimes.(q{j})(:, 3) = movMatrix(temp, 2) - movMatrix(temp, 1);
end

% save output -------------------------------------------------------------
save([pt '/output/' pt '_movTimes.mat'], 'movTimes', 'meanReact', 'movMatrix', 'reactMatrix')

end





