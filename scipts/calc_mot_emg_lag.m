function calc_mot_emg_lag(pt)

% Load data ---------------------------------------------------------------
load([pt '/output/' pt '_Hilbert_v2.mat'])
load([pt '/output/' pt '_emg_epochs.mat'])
load([pt '/output/' pt '_rising_phases.mat'])
load([pt '/output/' pt '_OMP_recon.mat'])

% Loop through channels ---------------------------------------------------
mov_types = {'hand', 'tongue', 'foot'};

for k = 1:length(mov_types)
    type = mov_types{k};
    
    for chan = 1:length(mta_traces)
        
        if ~isempty(dChan_rising(chan).(type).mta_win)

        % Extract signal
        eeg       = mta_traces(chan).(type).mean_trace;
        deeg      = diff(eeg, 1); deeg = [0 deeg];
        tmp       = dChan_rising(chan).(type).mta_win;
        searchwin = tmp(1):tmp(2);

        % Important time points
        timeIdx1  = tmp(1);
        [~, tt]   = max(deeg(searchwin)); 
        timeIdx2  = tt + tmp(1);
        
        onset1    = floor((timeIdx1 + timeIdx2)/2); 
        latency1  = round((onset1 - abs(mov_win(1))) * 1000/srate, 0);
       
        % Store  values
        emg_latency(chan).(type).idx = onset1;
        emg_latency(chan).(type).lag = latency1;

        else    
        emg_latency(chan).(type).idx = [];
        emg_latency(chan).(type).lag = [];
        end
    end
end

% Save output -------------------------------------------------------------
save([pt '/output/' pt '_emg_lag.mat'], 'emg_latency')

disp('-------------------')
disp('Data saved!')
disp('-------------------')

end
