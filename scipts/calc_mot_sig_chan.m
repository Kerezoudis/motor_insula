function calc_mot_sig_chan(pt, pt_task)

% This function sorts channels by decreasing R^2 values as well as 
% saves the hand, tongue and foot rvals and pvals for the insular chans. 
%
% Panos Kerezoudis, CaMP lab, 2024. 

% Load relevant data files ------------------------------------------------
load([pt '/' pt '_' pt_task '_dp_data.mat'], 'ins', 'dp_lbls');
load([pt '/output/' pt '_rvals.mat']);

% Define movement types
q = {'hand', 'tongue', 'foot'};

% Find most significant channels for hand, tongue, foot -------------------
for k = 1:length(q)
    
    [sigchan.(q{k} + "_rval"), sigchan.(q{k} + "_ridx")] = sort(eval(['rvals.r_' q{k} '_HFB']), 'descend');
    
    temp = eval(['rvals.p_' q{k} '_HFB']);
    sigchan.(q{k} + "_pval") = temp(sigchan.(q{k} + "_ridx"));
    sigchan.(q{k} + "_lbls") = dp_lbls(sigchan.(q{k} + "_ridx"));
    
    temp2 = eval(['rvals.r_' q{k} '_HFB']);
    ins.(q{k} + "_ains")= temp2(ins.a{2});
    ins.(q{k} + "_mins")= temp2(ins.m{2});
    ins.(q{k} + "_pins") = temp2(ins.p{2});

end

% Save output -------------------------------------------------------------
save([pt '/output/' pt '_sig_chan.mat' ], 'sigchan', 'ins')

disp('-----------')
disp('Data saved!')
disp('-----------')

end