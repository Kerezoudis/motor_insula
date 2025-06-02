function calc_mot_group_emg_lag

% Loop through patients and extract data ----------------------------------
% Specify patient list
pt_list = {'BRB', 'CCS', 'EOW', 'DKS', 'FKT', 'FOD', 'JLL', 'OSN', ...
    'POC', 'ROR', 'TOS', 'TNJ', 'VLB', 'WFR'};
pt_task = 'mot';

% Loop through patients ---------------------------------------------------
for k = 1:length(pt_list)
    pt = pt_list{k};
    disp(['Working on patient ' pt])

    % Load insular channels
    switch pt
        case {'BRB', 'CCS', 'EOW', 'FOD', 'JLL', 'POC', 'ROR', 'TOS', 'TNJ', 'TYL', 'VLB'}
            chans = chans_for_rol(pt);
        case {'DKS', 'FKT', 'OSN', 'WFR'}
            chans = chans_for_figs(pt);
    end

    % Load relevant data
    dt_folder = '/Users/kerezoudis.panagiotis/Desktop/motor_insula/';
    load([dt_folder pt '/' pt '_' pt_task '/output/' pt '_emg_lag.mat']);
    
    % M1 hand -------------------------------------------------------------
    if isfield(chans, 'm1hand') && ~all(isnan(chans.m1hand))
        for jj = 1:length(chans.m1hand)
            chan = chans.m1hand(jj);

            latencies.m1hand{k}(jj) = emg_latency(chan).hand.lag;
        end
    else    latencies.m1hand{k} = [];
    end 


    % Ins hand ------------------------------------------------------------
    if isfield(chans, 'hins') == 1 && ~all(isnan(chans.hins))
        for jj = 1:length(chans.hins)
            chan = chans.hins(jj);
            
            latencies.hins{k}(jj) = emg_latency(chan).hand.lag;
        end
    else    latencies.hins{k} = [];
    end

    % M1 tongue -----------------------------------------------------------
    if isfield(chans, 'm1tongue') == 1 && ~all(isnan(chans.m1tongue))
        for jj = 1:length(chans.m1tongue)
            chan = chans.m1tongue(jj);

            latencies.m1tongue{k}(jj) = emg_latency(chan).tongue.lag;
        end
    else    latencies.m1tongue{k} = [];
    end

    % Ins tongue ----------------------------------------------------------
    if isfield(chans, 'tins') == 1 && ~all(isnan(chans.tins))
        for jj = 1:length(chans.tins)
            chan = chans.tins(jj);

            latencies.tins{k}(jj) = emg_latency(chan).tongue.lag;
        end
    else    latencies.tins{k} = [];
    end

end

% Concatenate into vectors ------------------------------------------------
data.m1hand   = cell2mat(latencies.m1hand);
data.hins     = cell2mat(latencies.hins);
data.m1tongue = cell2mat(latencies.m1tongue);
data.tins     = cell2mat(latencies.tins);

% Tabulate data -----------------------------------------------------------
field_names = {'m1hand', 'hins', 'm1tongue', 'tins'};
metric_names = {'Total N', 'Mean', 'Median', '25th percentile', '75th percentile', 'N above zero'};

% Initialize results matrix
results = zeros(length(metric_names), length(field_names));

% Cell array of input vectors for loop processing
data_vectors = {data.m1hand, data.hins, data.m1tongue, data.tins};

% Calculate statistics for each vector
for i = 1:length(data_vectors)
    curr_data = data_vectors{i};

    % Calculate metrics
    results(1,i) = length(curr_data);                    % Total N
    results(2,i) = mean(curr_data, 'omitnan');          % Mean
    results(3,i) = median(curr_data, 'omitnan');        % Median
    percentiles = prctile(curr_data, [25 75]);          % Percentiles
    results(4,i) = percentiles(1);                      % 25th percentile
    results(5,i) = percentiles(2);                      % 75th percentile
    results(6,i) = sum(curr_data > 0);                  % N above zero
end

% Create table
stats_table = array2table(results, 'RowNames', metric_names, 'VariableNames', field_names);

% Save output -------------------------------------------------------------
mkdir([pwd 'group/'])
save('group/mot_group_emg_lags.mat', 'data', 'latencies', 'stats_table')

disp('-------------------')
disp('Data saved!')
disp('-------------------')


end

