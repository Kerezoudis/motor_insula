function calc_mot_rising_score(pt)

% Load data ---------------------------------------------------------------
load([pt '/output/' pt '_rising_phases.mat'], 'mta_lag');
load([pt '/output/' pt '_rvals.mat']);

% Load channels 
chans = chans_for_rol(pt);
hand  = struct(); tongue = struct();

% For hand movement -------------------------------------------------------
if isfield(chans, 'm1hand') == 1
    for jj = 1:length(chans.m1hand)
        chan1 = chans.m1hand(jj);
        
        for qq = 1:length(chans.hins)
            chan2 = chans.hins(qq);

        % Subset to hand rvals
        r2vals = rvals.r_hand_HFB;
        
        % Weighting
        hand.wts(jj, qq) = sqrt(r2vals(chan1) * r2vals(chan2));

        % Extract lag
        hand.lags(jj, qq) = (mta_lag.('hand')(chan1, chan2));
 
        end
    end

hand.wts   = hand.wts(:);
hand.lags  = hand.lags(:);

% Average hand chan weight (to be used for group analysis later)
hand.avg_wt = mean(hand.wts);

% Normalize weights to sum to 1
hand.norm_wts = hand.wts / sum(hand.wts);

% Calculate expected value with normalized weights
hand.lag_score = sum(hand.norm_wts .* hand.lags);

end

clear wts norm* r2vals chan1 chan2 jj qq

% For tongue movement -----------------------------------------------------
if isfield(chans, 'm1tongue') == 1
    for jj = 1:length(chans.m1tongue)
        chan1 = chans.m1tongue(jj);
        
        for qq = 1:length(chans.tins)
        chan2 = chans.tins(qq);

        % Subset to hand rvals
        r2vals = rvals.r_tongue_HFB;
        
        % Weighting
        tongue.wts(jj, qq) = sqrt(r2vals(chan1) * r2vals(chan2));

        % Extract lag
        tongue.lags(jj, qq) = (mta_lag.('tongue')(chan1, chan2));

        end
    end

tongue.wts  = tongue.wts(:);
tongue.lags = tongue.lags(:);

% Average hand chan weight (to be used for group analysis later)
tongue.avg_wt = mean(tongue.wts);

% Normalize weights to sum to 1
tongue.norm_wts = tongue.wts / sum(tongue.wts);

% Calculate expected value with normalized weights
tongue.lag_score = sum(tongue.norm_wts .* tongue.lags);

end

% Save output -------------------------------------------------------------
save([pt '/output/' pt '_rising_score.mat'], 'hand', 'tongue')

disp('-------------------')
disp('Data saved!')
disp('-------------------')

end
