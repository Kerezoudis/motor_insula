function [epochs] = data2epochs_v2(data, starts, win)

% Window size
n_samples = win(2) - win(1) + 1;

% Get dimensions
n_channels = size(data, 2);
n_trials   = length(starts);

% Initialize single 3D array for all trials
epochs = nan(n_trials, n_channels, n_samples);

% Extract and z-score epochs
for trial = 1:n_trials
    onset = starts(trial);
    if (onset + win(1)) >= 1 && (onset + win(2)) <= size(data, 1)
        % Extract data
        epoch_data = data((onset+win(1)):(onset+win(2)), :)';
        
        % For each channel
        for chan = 1:n_channels
            epochs(trial, chan, :) = epoch_data(chan, :);
        end
    end
end