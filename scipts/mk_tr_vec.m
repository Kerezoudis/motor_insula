function [trialnr, tr_sc, trials] = mk_tr_vec(data)

% [trialnr, tr_sc, trials] = mk_tr_vec(data)
% 
% This function creates a trial vector from the input. 
%   input is usually either the 'stimulus' or the behavioral vector, 
%   such as the segmented EMG. 
%
% Panos Kerezoudis, CaMP lab, 2024.

% Initialize variables
trialnr = 0*data; tr_sc = 0; 
trtemp = 1; trialnr(1) = trtemp;

% Create trial vector 
for n = 2:length(data)
    if data(n) ~= data(n-1),
        trtemp = trtemp + 1; tr_sc = [tr_sc data(n)];
    end
    trialnr(n) = trtemp;
end
trials = unique(trialnr);

end