function calc_group_mot_rising_score

% Loop through patients and extract data ----------------------------------
% Specify patient list
pt_list = {'EOW', 'ROR', 'VLB', 'CCS', 'BRB', 'FOD', 'POC', 'TOS', 'TNJ'};
subj_id = [1 2 4 5 7 12 14 15 16];

% Initialize struct variables ---------------------------------------------
stats.hand.lags       = []; stats.tongue.lags       = []; 
stats.hand.wts        = []; stats.tongue.wts        = [];
stats.hand.ins        = []; stats.tongue.ins        = [];
stats.hand.dp_loc     = []; stats.tongue.dp_loc     = [];
stats.hand.dp_loc_new = []; stats.tongue.dp_loc_new = [];
stats.hand.side       = []; stats.tongue.side       = [];
stats.hand.norm_wts   = []; stats.tongue.norm_wts   = [];

% Loop through patients ---------------------------------------------------
for k = 1:length(pt_list)
    pt = pt_list{k};
    disp(['Working on patient ' pt])

    % Specify pt_task
    switch pt
    case {'BRB', 'CCS', 'EOW', 'FOD', 'POC', 'TOS', 'TNJ', 'VLB'}
        pt_task = 'mot';
    case {'ROR'}
        pt_task = 'mot_ndg';
    end
    
    % Specify side
    switch pt
        case {'BRB', 'EOW', 'FOD', 'ROR', 'TNJ'}
            side = 'R';
        case {'CCS', 'POC', 'TOS', 'VLB'}
            side = 'L';
    end

    % Load insular channels
    chans = chans_for_rol(pt);

    % Clear variables at start of each iteration
    clear hand_lag_score avg_hand_wt tongue_lag_score avg_tongue_wt

    % Load relevant data
    dt_folder = '/Users/kerezoudis.panagiotis/Desktop/motor_insula/';
    load([dt_folder pt '/' pt '_' pt_task '/output/' pt '_rising_score.mat']);
    
    % Load dp_locs
    load([dt_folder pt '/' pt '_' pt_task '/' pt '_' pt_task '_dp_data.mat'], 'dp_locs');

    % Load insular stereotactic space mat files
    rot_folder = '/Users/kerezoudis.panagiotis/Desktop/insular_reslicing/';
    load([rot_folder 'subjects/' pt '/' pt '_T1_rotated_' side '.mat'], 'data_acpc')

    % Rotate dp_locs into insular stereotactic space
    dp_locs_new = conv2InsSpace(dp_locs, data_acpc);

    % Store hand stuff
    if isfield(chans, 'hins')
        stats.hand.lags{k}       = hand.lags;
        stats.hand.wts{k}        = hand.wts;
        stats.hand.ins{k}        = chans.hins;
        stats.hand.dp_loc{k}     = dp_locs(chans.hins, :);
        stats.hand.dp_loc_new{k} = dp_locs_new(chans.hins, :);
        stats.hand.side{k}       = side;
        stats.hand.avg_score{k}  = hand.lag_score;
        stats.hand.subj_id{k}    = subj_id(k);
    end

    % Store tongue stuff 
    if isfield(chans, 'tins')
        stats.tongue.lags{k}       = tongue.lags;
        stats.tongue.wts{k}        = tongue.wts;
        stats.tongue.ins{k}        = chans.tins;
        stats.tongue.dp_loc{k}     = dp_locs(chans.tins, :);
        stats.tongue.dp_loc_new{k} = dp_locs_new(chans.tins, :);
        stats.tongue.side{k}       = side;
        stats.tongue.avg_score{k}  = tongue.lag_score;
        stats.tongue.subj_id{k}    = subj_id(k);
    end
end

% Concatenate stats into table --------------------------------------------
fieldnames  = {'M1hand-hins', 'M1tongue-tins'};

tablag               = struct();
tablag.hand.wts      = vertcat(stats.hand.lags{:});
tablag.hand.mean     = mean(tablag.hand.wts);
tablag.hand.median   = median(tablag.hand.wts);
tablag.hand.range    = [min(tablag.hand.wts) max(tablag.hand.wts)];
tablag.hand.m1lag    = sum(tablag.hand.wts>0); 

tablag.tongue.wts    = vertcat(stats.tongue.lags{:});
tablag.tongue.mean   = mean(tablag.tongue.wts);
tablag.tongue.median = median(tablag.tongue.wts);
tablag.tongue.range  = [min(tablag.tongue.wts) max(tablag.tongue.wts)];
tablag.tongue.m1lag  = sum(tablag.tongue.wts>0); 

% Save output --------------------------------------------------------------
save_folder = '/Users/kerezoudis.panagiotis/Desktop/motor_insula/group/';
save([save_folder 'mot_group_lag_scores.mat'], 'stats', 'tablag')

disp('-------------------')
disp('Data saved!')
disp('-------------------')

end

