function calc_mot_emg_epochs(pt, pt_task)

% Load data ---------------------------------------------------------------
load([pt '/' pt '_' pt_task '_dp_data.mat']); 
data2 = ieeg_highpass(dp_data, srate); 
data = ieeg_notch(data2, srate, 60); clear dp_data data2

load([pt '_' pt_task '_nondp_data.mat'], 'emg', 'stim');
display_emg = emg_processing(emg, srate);

load([pt '/' pt '_EMG_segm.mat'], 'beh')

% Set up variables/windows ------------------------------------------------
% Screen cues
pre_cue_win         = [-0.5*srate 0];
[cues, cue_labels]  = findSegmentStarts(stim);
mov_cues            = cues(cue_labels ~= 0);

    % Fix for selected patients
    switch pt
        case {'POC', 'TYL', 'VLB'}
            mov_cues(1) = []; cues(1:2) = []; cue_labels(1:2) = [];
    end

% Movement onsets
[mov_starts, mov_labels] = findSegmentStarts(beh);
movement_labels          = [1 2 3];
movement_names           = {'hand', 'tongue', 'foot'};
nboots                   = 1e3;

% Prepare EMG -------------------------------------------------------------
winlength   = floor(0.1*srate);

for chan = 1:size(display_emg, 2)
    clear block
    
    % Pre-processing
    emg1 = display_emg(:, chan);
    emg2 = log(emg1);
    emg3 = conv(emg2, gausswin(winlength), 'same');

    % Normalize to 500ms leading into cue
    for k = 1:length(mov_cues)
        block(k, :) = emg3(mov_cues(k)+(pre_cue_win(1):pre_cue_win(2)));
    end

    block = sort(block(:));
    a = length(block); tmp_inds = floor(.1*a):floor(.9*a);
    block = block(tmp_inds); clear a tmp_inds
    
    % Extract mean and SD
    bsl_mean = mean(block);
    bsl_std  = std(block);

    % Z-score entire run to global pre-cue baseline
    Zemg(:, chan) = (emg3 - bsl_mean)/bsl_std;
end

% Convert to 3D array -----------------------------------------------------
cue_win = [-1.5*srate 3*srate]; 
    cue_emg_epochs = data2epochs_v2(Zemg, cues, cue_win);
mov_win = [-1.5*srate 3*srate]; 
    mov_emg_epochs = data2epochs_v2(Zemg, mov_starts, mov_win);

% Mean traces with 95% CI -------------------------------------------------
sta_emg_traces = struct();
mta_emg_traces = struct();

% Modified version that handles Inf values
for chan = 1:size(cue_emg_epochs, 2)
    for cue_idx = 1:length(movement_labels)
        label = movement_labels(cue_idx);
        name = movement_names{cue_idx};
        
        % Get trials
        cue_trials = squeeze(cue_emg_epochs(cue_labels == label, chan, :));
        
        % Remove Inf values or replace with max finite value
        max_finite = max(cue_trials(~isinf(cue_trials(:))));
        cue_trials(isinf(cue_trials)) = max_finite;  % Or you could use nan() instead
        
        % Calculate mean trace
        sta_emg_traces(chan).(name).mean_trace = mean(cue_trials, 1);
        
        % Calculate bootstrap CI
        if size(cue_trials, 1) >= 2
            ci = bootci(nboots, {@mean, cue_trials}, 'Alpha', 0.05);
            sta_emg_traces(chan).(name).lower_ci = ci(1,:);
            sta_emg_traces(chan).(name).upper_ci = ci(2,:);
        end
    end
end

% Movement-triggered
for chan = 1:size(mov_emg_epochs, 2)
    for mov_idx = 1:length(movement_labels)
        mov_label = movement_labels(mov_idx);
        mov_name = movement_names{mov_idx};
        
        % Get smoothed trials for this movement
        mov_trials = squeeze(mov_emg_epochs(mov_labels == mov_label, chan, :));
        
        % Calculate mean trace
        mta_emg_traces(chan).(mov_name).mean_trace = mean(mov_trials, 1);
        
        % Calculate bootstrap CI
        ci = bootci(nboots, {@mean, mov_trials}, 'Alpha', 0.05);
        mta_emg_traces(chan).(mov_name).lower_ci = ci(1,:);
        mta_emg_traces(chan).(mov_name).upper_ci = ci(2,:);
    end
end

% Save output -------------------------------------------------------------
save([pt '/' 'output/' pt '_emg_epochs.mat'], 'pre_cue_win', '*win', 'cues', ...
    'cue_labels', '*starts', '*labels', '*traces', '*epochs', 'srate')

disp('-------------------')
disp('Data saved!')
disp('-------------------')

end

