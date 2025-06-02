function tf = gen_spectrogram(data, events, win)

% This script calculates the average time-resolved power, triggered by 
%   the screen cue or the behavior (movement, speech etc). 
% 
% Inputs:
%   1) input voltage data (vector format)
%   2) events (time indices of screen cues or behavioral onsets)
%   3) win (time window (prior and after) w.r.t to events of interest)
%
% original version by KJM, modified by PK, CaMP lab, 2024. 

% Set up basic parameters -------------------------------------------------
fmax = 150;
srate = 1200;

% Initialize time-frequency matrix ----------------------------------------
tf = zeros(length(win(1):win(2)), fmax);

% Loop through frequencies (in descending order)
for freq = fmax:-1:1
    
    % Mother wavelet of 5 cycles
    t = 1:floor(5*srate/freq); 
    
    % Create Morlet wavelet
    wvlt = exp(1i*2*pi*(freq/srate) * (t-floor(2.5*srate/freq))) .* ...
        exp(-((t-floor(2.5*srate/freq)).^2)/(2*(srate/freq)^2)); 
    
    % Calculate convolution with entire dataset
    tconv = conv(wvlt, data);
    
    % Eliminate edges
    tconv([1:(floor(length(wvlt)/2)-1) floor(length(tconv)-length(wvlt)/2+1):length(tconv)])=[];  
    
    % Obtain power
    tconv = abs(tconv) .^ 2;
    
    % Calculate baseline power in window [-1.5s, -0.5s] before each event
    baseline_window = round([-1.5*srate, -0.5*srate]); % Set the baseline window in samples
    baseline_power = zeros(length(events), 1);
    for k = 1:length(events)
        baseline_power(k) = mean(tconv(events(k) + baseline_window(1):events(k) + baseline_window(2)));
    end
    baseline_mean = mean(baseline_power); % Average baseline power across events
    
    % Normalize by baseline mean
    tconv = tconv / baseline_mean;

    % Initialize matrix of average power
    tconvt = zeros(length(win(1):win(2)), 1);

    % Loop through events (screen cues or behavior onsets)
    for k = 1:length(events)
        tconvt = tconvt + tconv(events(k) + [win(1):win(2)]);
    end
    
    % Average over trials 
    tf(:, freq) = tconvt / k;
    
end












end