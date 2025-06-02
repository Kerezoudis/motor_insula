function calc_mot_spectrogram(pt, pt_task)

% Load relevant data files ------------------------------------------------
load([pt '/output/' pt '_movTimes.mat']); 
load([pt '/' pt '_' pt_task '_nondp_data.mat'], 'stim')
load([pt '/' pt '_' pt_task '_dp_data.mat'], 'dp_data', 'srate', 'dp_lbls')
data2 = ieeg_highpass(dp_data, srate); 
data  = ieeg_notch(data2, srate, 60); clear dp_data data2

% Set up parameters and time points ---------------------------------------
f = 1:150;
q = {'hand', 'tongue', 'foot'};
for k = 1:length(q)
    stim_pts.(q{k}) = movTimes.(q{k})(:, 1); 
    mov_pts.(q{k}) = movTimes.(q{k})(:, 2); 
end

% Calculate MTA for each timeseries ---------------------------------------
mta_win            = [-1.5*srate 1.5*srate];
mta                = struct(); 
[cues, cue_labels] = findSegmentStarts(stim);
cues2move          = cues(cue_labels ~=0);

for k = 1:length(q)
    type = q{k};

    % Filter out excluded trials
    exclude = exclude_trial(pt, type);
    keep    = setdiff(1:length(mov_pts.(type)), exclude);
    pts     = mov_pts.(type)(keep);

    disp(['Calculating MTA responses for ' type])
    for chan = 1:size(data, 2)
        disp(['Working on channel ' num2str(chan) ' / ' num2str(size(data, 2))])

    % Time-frequency plots
    mta.("tf_" + type)(:, :, chan) = gen_spectrogram(data(:, chan), pts, mta_win);
    
    end
end

% Save data and clear variables -------------------------------------------
save([pt '/output/' pt '_mta_tf_power.mat'], 'mta', 'mta_win', 'f')

end