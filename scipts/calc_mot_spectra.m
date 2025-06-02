function [ps, mps, nps, f] = calc_mot_spectra(pt, pt_task)

% This function calculates power spectra based on pwelch function. 
% Output is a PSD matrix: channels x frequencies (1-150 Hz) x trials. 
%
% Panos Kerezoudis, CaMP lab, 2024. 

% Load relevant datasets --------------------------------------------------
load([pt '/' pt '_' pt_task '_dp_data.mat'], 'dp_data', 'dp_lbls'), srate = 1200;
data2 = ieeg_highpass(dp_data, srate); 
data  = ieeg_notch(data2, srate, 60); clear dp_data data2
load([pt '/' pt '_trials.mat']);

% Create PSD related variables --------------------------------------------
f        = 1:150;
num_chan = size(data, 2); % N of channels
bsize    = srate/2; % window size for spectral calculation
win_fxn  = hann(bsize); % create Hann window
noverlap = floor(bsize/2); % overlap in windowing

% Run pwelch function -----------------------------------------------------
for chan = 1:num_chan  
    disp(['Getting power spectrum for channel ' num2str(chan) ' / ' num2str(size(data, 2))])
    [mps(chan, :), f] = pwelch(data(:, chan), win_fxn, noverlap, f, srate); % mean power spectrum across whole experiment
    
        for curr_trial = 1:max(trials) % calculate spectra for each trial
        curr_data = data(find(trialnr == curr_trial), chan);
        
        if length(curr_data) < length(win_fxn) % zero pad to window size if needed
            curr_data = [curr_data; zeros(length(win_fxn)-length(curr_data), 1)];
        end        
        
        ps(chan, :, curr_trial) = pwelch(curr_data, win_fxn, noverlap, f, srate); % single trial power spectra
        nps(chan, :, curr_trial) = ps(chan, :, curr_trial) ./ mps(chan, :); % normalized single trial power spectra
        end
end

% Create new directory and save output ------------------------------------
gpath = pwd; myfolder = 'output';
folder = mkdir(fullfile(gpath, myfolder));
gpath  = fullfile(gpath, myfolder);

save([pt '/output/' pt '_psd.mat'], 'ps','nps', 'mps', 'f')

disp('-----------')
disp('Data saved!')
disp('-----------')

end
