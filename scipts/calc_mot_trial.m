function [tr_sc, trialnr, trials] = calc_mot_trial(pt)

% This function segments the behavioral vector (EMG or screen cue) 
%   into epochs/trials. 
% 
% Segmentation also depends on type of task, ie basic motor vs motor delay
%   vs observation. 

% Load relevant data ------------------------------------------------------
load([pt '/' pt '_EMG_segm.mat'], 'beh');

disp(['Generating move/rest conditions for subject ' pt])

% Create trial-related variables ------------------------------------------
trialnr = 0*beh; tr_sc = 0; 
trtemp = 1; trialnr(1) = trtemp;
for n = 2:length(beh)
    if beh(n) ~= beh(n-1)
        trtemp = trtemp + 1; tr_sc = [tr_sc beh(n)];
    end
    trialnr(n) = trtemp;
end
trials = unique(trialnr);

% Reject short rest periods -----------------------------------------------
lengthtrial = [];
for k = 1:length(trials)
    lengthtrial = [lengthtrial; length(find(trialnr == k))];
end 

% Nullify if any epochs are less than the pre-specified min length --------
min_length = 1200;
shortrest = ((lengthtrial < min_length)' & tr_sc == 0);
tr_sc(find(shortrest)) = -1;

tr_sc(find(tr_sc == 0 & [0 tr_sc(1:(end-1))] == 1)) = 10; % rest after hand block
tr_sc(find(tr_sc == 0 & [0 tr_sc(1:(end-1))] == 2)) = 20; % rest after tongue block
tr_sc(find(tr_sc == 0 & [0 tr_sc(1:(end-1))] == 3)) = 30; % rest after tongue block

save([pt '/' pt '_trials'], 'tr*')

disp('-----------')
disp('Data saved!')
disp('-----------')

end