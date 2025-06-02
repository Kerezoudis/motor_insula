function calc_mot_Hilbert(pt, pt_task)

% This function transforms the recorded signal into analytic using the 
%   Filter-Hilbert transform, based on a 3rd order forward-reverse
%   Butterworth filter. 
% 
% Outputs: power timeseries in LFB(12-20 Hz) and HFB BB (65-115 Hz). 
%
% Panos Kerezoudis, CaMP lab, 2024. 

% Load relevant data files ------------------------------------------------
load([pt '/' pt '_EMG_segm.mat'], 'beh')
load([pt '/' pt '_' pt_task '_dp_data.mat']); 
data2 = ieeg_highpass(dp_data, srate); 
data = ieeg_notch(data2, srate, 60); clear dp_data data2

% Set up frequency boundaries and power -----------------------------------
highfreq = [65 75;75 85;85 95;95 105;105 115]; % Broadband
lowfreq = [8 12;12 16;16 20;20 24;24 28;28 32]; % Low-freq rhythm
% lowfreq = [12 16;16 20]; 

for k = 1:size(data, 2)
    [bb_power(:, k), ~]   = ieeg_getHilbert(data(:, k), highfreq, srate, 'power');
    [beta_power(:, k), ~] = ieeg_getHilbert(data(:, k), lowfreq, srate, 'power');
end

clear k *freq 

% Set up parameters -------------------------------------------------------
% Screen cues
pre_cue_win         = [-0.5*srate 0];
[cues, cue_labels]  = findSegmentStarts(stim);
mov_cues            = cues(cue_labels ~= 0);

% Movement onsets
[mov_starts, mov_labels] = findSegmentStarts(beh);
movement_labels          = [1 2 3];
movement_names           = {'hand', 'tongue', 'foot'};
nboots                   = 1e3;

% Movement offsets
[mov_ends, end_labels] = findSegmentEnds(beh);

% Smooth Hilbert time series ----------------------------------------------
winlength   = floor(srate/2);

for chan = 1:size(bb_power, 2)
    clear block
    
    disp(['Normalizing chan ' num2str(chan) '/' num2str(size(bb_power, 2))])

    bb1 = bb_power(:, chan);
    
    bb2 = log(bb1); % log
    bb3 = conv(bb2, gausswin(winlength), 'same'); % gaussian smooth

    % Normalize to 500ms leading into cue
    for k = 1:length(mov_cues)
        block(k, :) = bb3(mov_cues(k)+(pre_cue_win(1):pre_cue_win(2)));
    end

    block = sort(block(:));
    a = length(block); tmp_inds = floor(.1*a):floor(.9*a);
    block = block(tmp_inds); clear a tmp_inds

    % Extract mean and SD
    bsl_mean = mean(block);
    bsl_std  = std(block);

    % Z-score entire run to global pre-cue baseline
    Zpower(:, chan) = (bb3 - bsl_mean)/bsl_std;
end

% Convert to 3D array -----------------------------------------------------
cue_win = [-1.5*srate 3*srate]; 
    cue_epochs = data2epochs_v2(Zpower, cues, cue_win);
mov_win = [-1.5*srate 3*srate];
    mov_epochs = data2epochs_v2(Zpower, mov_starts, mov_win);
stop_win = [-0.5*srate 1*srate]; 
    stop_epochs = data2epochs_v2(Zpower, mov_ends, stop_win);

% Mean traces with 95% Confidence Interval --------------------------------
n_channels     = size(mov_epochs, 2); 
sta_traces     = struct();
mta_traces     = struct();
stop_traces    = struct();

% Screen cue-triggered 
for chan = 1:n_channels

    disp(['STA Traces for channel ' num2str(chan) '/' num2str(n_channels)])
    % For each movement type
    for cue_idx = 1:length(movement_labels)
        label   = movement_labels(cue_idx);
        name    = movement_names{cue_idx};
        
        % Get trials for this cue
        cue_trials = squeeze(cue_epochs(cue_labels == label, chan, :));
        
        % Trials to keep
        exclude = exclude_trial(pt, name);
        keep    = setdiff(1:size(cue_trials, 1), exclude);

        cue_trials = cue_trials(keep, :);

        % Calculate mean trace
        sta_traces(chan).(name).mean_trace = mean(cue_trials, 1);
        
        % Calculate bootstrap CI
        % bootci returns [lower_ci; upper_ci]
        rng(123)
        ci = bootci(nboots, {@mean, cue_trials}, 'Alpha', 0.05);
        sta_traces(chan).(name).lower_ci = ci(1,:);
        sta_traces(chan).(name).upper_ci = ci(2,:);
    end
end

% Movement-triggered 
for chan = 1:n_channels

    disp(['MTA Traces for channel ' num2str(chan) '/' num2str(n_channels)])
    % For each movement type
    for mov_idx   = 1:length(movement_labels)
        mov_label = movement_labels(mov_idx);
        mov_name  = movement_names{mov_idx};
        
        % Get trials for this movement
        mov_trials = squeeze(mov_epochs(mov_labels == mov_label, chan, :));
        
        % Trials to keep
        exclude = exclude_trial(pt, name);
        keep    = setdiff(1:size(mov_trials, 1), exclude);

        mov_trials = mov_trials(keep, :);

        % Calculate mean trace
        mta_traces(chan).(mov_name).mean_trace = mean(mov_trials, 1);
        
        % Calculate bootstrap CI
        % bootci returns [lower_ci; upper_ci]
        rng(123)
        ci = bootci(nboots, {@mean, mov_trials}, 'Alpha', 0.05);
        mta_traces(chan).(mov_name).lower_ci = ci(1,:);
        mta_traces(chan).(mov_name).upper_ci = ci(2,:);
    end
end

% Offset-triggered 
for chan = 1:n_channels

    disp(['Offset Traces for channel ' num2str(chan) '/' num2str(n_channels)])
    % For each movement type
    for mov_idx   = 1:length(movement_labels)
        mov_label = movement_labels(mov_idx);
        mov_name  = movement_names{mov_idx};
        
        % Get trials for this movement
        stop_trials = squeeze(stop_epochs(end_labels == mov_label, chan, :));
        
        % Calculate mean trace
        stop_traces(chan).(mov_name).mean_trace = mean(stop_trials, 1);
        
        % Calculate bootstrap CI
        % bootci returns [lower_ci; upper_ci]
        rng(123)
        ci = bootci(nboots, {@mean, stop_trials}, 'Alpha', 0.05);
        stop_traces(chan).(mov_name).lower_ci = ci(1,:);
        stop_traces(chan).(mov_name).upper_ci = ci(2,:);
    end
end

% Save output -------------------------------------------------------------
save([pt '/output/' pt '_Hilbert_v2.mat'], 'Zpower', '*traces', '*epochs', ...
    '*win', '*labels', 'srate')

disp('-------------')
disp('Data Saved!')
disp('-------------')

end

