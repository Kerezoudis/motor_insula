function calc_mot_rising_phases(pt)

% Load data ---------------------------------------------------------------
load([pt '/output/' pt '_Hilbert_v2.mat'], 'mta_traces')

% Initialize parameters ---------------------------------------------------
names = fieldnames(mta_traces);

% Prepare data * Use MTA traces -------------------------------------------
disp('*** WORKING WITH MEAN TRACES ***')
for k = 1:length(names)
    name = names{k};
    disp(['* Working on ' names{k} ' activity *'])
    
    for chan1 = 1:length(mta_traces)

    % Extract traces
    mtaA = mta_traces(chan1).(name).mean_trace;
    [mta_zxA, mta_dA_rising] = isolation_by_rising_phase_pk_v4(pt, mtaA, srate);    

    for chan2 = 1:length(mta_traces)
    
    % Extract traces    
    mtaB = mta_traces(chan2).(name).mean_trace;
    [mta_zxB, mta_dB_rising] = isolation_by_rising_phase_pk_v4(pt, mtaB, srate);    

    % Extract lags
    C = conv(mta_dA_rising, mta_dB_rising(end:-1:1));
    [~, indx] = max(C); 
    mta_lag.(name)(chan1, chan2) = (indx-length(mtaA))*1000/srate;

    end

    % Store rising phases for future analysis
    dChan_rising(chan1).(name).mta     = mta_dA_rising;
    dChan_rising(chan1).(name).mta_win = mta_zxA;

    end
end

clear mtaA mtaB mta_zx* C

% Save output ---------------------------------------------------------------
save([pt '/output/' pt '_rising_phases.mat'], 'mta_lag*', 'dChan_rising', 'omp_*')

disp('-------------------')
disp('Data saved!')
disp('-------------------')

end
