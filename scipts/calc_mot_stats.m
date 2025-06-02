function rvals = calc_mot_stats(pt, bonfen)

% This function calculates R^2 and p-values between movement and rest,
% per movement type, in the following frequency bands:
%   a) HFB: 65-115 Hz
%   b) LFB: 8-32 Hz
% 
% Delay task has a separate section to account for rest, preparatory and 
%   execution phase. 
% 
% Output is saved in a struct. 

% Load relevant data files ------------------------------------------------
load([pt '/' pt '_trials.mat'], 'tr_sc')
load([pt '/output/' pt '_psd.mat'])

% Define frequency ranges of interest -------------------------------------
HFB_range = 65:115;
LFB_range = 8:32;

% Define HFB and LFB trials -----------------------------------------------
num_chans = size(nps, 1);
HFB_trials = squeeze(mean(nps(:, HFB_range, :), 2));
LFB_trials = squeeze(mean(nps(:, LFB_range, :), 2));

% Calculate statistics 
% Specify move and rest trials -
hand_move = find(tr_sc == 1); hand_rest = find(tr_sc == 10);
tongue_move = find(tr_sc == 2); tongue_rest = find(tr_sc == 20);
foot_move = find(tr_sc == 3); foot_rest = find(tr_sc == 30);

% Comparisons -
rvals = [];
for chan = 1:num_chans
    
    if isempty(hand_move) ~= 1
        rvals.r_hand_HFB(chan) =rsa(HFB_trials(chan, hand_move), HFB_trials(chan, hand_rest));
        rvals.r_hand_LFB(chan) = rsa(LFB_trials(chan, hand_move), LFB_trials(chan, hand_rest));        
        [~, rvals.p_hand_HFB(chan)] = ttest2(HFB_trials(chan, hand_move), HFB_trials(chan, hand_rest));
        [~, rvals.p_hand_LFB(chan)] = ttest2(LFB_trials(chan, hand_move), LFB_trials(chan, hand_rest)); 
    else, rvals.r_hand_HFB = []; rvals.r_hand_LFB = []; rvals.p_hand_HFB = []; rvals.p_hand_LFB = []; end
    
    if isempty(tongue_move) ~= 1 
        rvals.r_tongue_HFB(chan) = rsa(HFB_trials(chan, tongue_move), HFB_trials(chan, tongue_rest));
        rvals.r_tongue_LFB(chan) = rsa(LFB_trials(chan, tongue_move), LFB_trials(chan, tongue_rest));        
        [~, rvals.p_tongue_HFB(chan)] = ttest2(HFB_trials(chan, tongue_move), HFB_trials(chan, tongue_rest));
        [~, rvals.p_tongue_LFB(chan)] = ttest2(LFB_trials(chan, tongue_move), LFB_trials(chan, tongue_rest));  
    else, rvals.r_tongue_HFB = []; rvals.r_tongue_LFB = []; rvals.p_tongue_HFB = []; rvals.p_tongue_LFB = []; end
    
    if isempty(foot_move) ~= 1   
        rvals.r_foot_HFB(chan) = rsa(HFB_trials(chan, foot_move), HFB_trials(chan, foot_rest));
        rvals.r_foot_LFB(chan) = rsa(LFB_trials(chan, foot_move), LFB_trials(chan, foot_rest));        
        [~, rvals.p_foot_HFB(chan)] = ttest2(HFB_trials(chan, foot_move), HFB_trials(chan, foot_rest));
        [~, rvals.p_foot_LFB(chan)] = ttest2(LFB_trials(chan, foot_move), LFB_trials(chan, foot_rest));          
    else, rvals.r_foot_HFB = []; rvals.r_foot_LFB = []; rvals.p_foot_HFB = []; rvals.p_foot_LFB = []; end

    % Feature maps -
    for freq = 1:length(f)
        rvals.rmap_hand(chan, freq) = rsa(nps(chan, freq, hand_move), nps(chan, freq, hand_rest));
        rvals.rmap_tongue(chan, freq) = rsa(nps(chan, freq, tongue_move), nps(chan, freq, tongue_rest));
        rvals.rmap_foot(chan, freq) = rsa(nps(chan, freq, foot_move), nps(chan, freq, foot_rest));
        rvals.rmap_HvsT(chan, freq) = rsa(nps(chan, freq, hand_move), nps(chan, freq, tongue_move));
        rvals.rmap_HvsF(chan, freq) = rsa(nps(chan, freq, hand_move), nps(chan, freq, foot_move));
        rvals.rmap_TvsF(chan, freq) = rsa(nps(chan, freq, tongue_move), nps(chan, freq, foot_move));
    end

end

% Bonferroni-correction
if bonfen == 'y'
    rvals.p_hand_HFB = rvals.p_hand_HFB * num_chans;
    rvals.p_hand_LFB = rvals.p_hand_LFB * num_chans;
    rvals.p_tongue_HFB = rvals.p_tongue_HFB * num_chans;
    rvals.p_tongue_LFB = rvals.p_tongue_LFB * num_chans;
    rvals.p_foot_HFB = rvals.p_foot_HFB * num_chans;
    rvals.p_foot_LFB = rvals.p_foot_LFB * num_chans;
end


% Save output -------------------------------------------------------------
save([pt '/output/' pt '_rvals.mat'], 'rvals')

disp('-----------')
disp('Data saved!')
disp('-----------')

end





