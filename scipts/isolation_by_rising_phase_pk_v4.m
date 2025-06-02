function [final_intervals, signalOut] = isolation_by_rising_phase_pk_v4(pt, signal, srate)

% Time zero is at 1.5*srate
t_zero = round(1.5 * srate);

% Define windows for min and max
if ismember(pt, ["BRB", "TOS", "ROR", "OSN", "POC"])
    min_window = round(0.5 * srate); 
elseif ismember(pt, "WFR")
    min_window = floor(1/3  * srate); 
elseif ismember(pt, ["TNJ", "FOD"])
    min_window = round(0.75 * srate);
else
    min_window = round(1 * srate); 
end

max_window = round(1 * srate);  % 1.5s for max

% Find global max within window after t=0
max_window_start = t_zero;
max_window_end = min(length(signal), t_zero + max_window);

[~, local_max_idx] = max(signal(max_window_start:max_window_end));
global_max_idx = local_max_idx + max_window_start - 1;

% Find global min around t=0 (±500ms)
min_window_start = max(1, t_zero - min_window);
min_window_end = min(length(signal), t_zero + min_window);

[~, local_min_idx] = min(signal(min_window_start:min_window_end));
global_min_idx = local_min_idx + min_window_start - 1;

% Signal format check
if size(signal, 1) > size(signal, 2)
    signal = signal';
end

% Parameters
min_duration = 0.1;  % 100ms minimum duration
min_samples = round(min_duration * srate);

% First derivative
deriv = diff(signal)';
deriv = [0; deriv];

% Keep positive changes
pos_deriv = deriv;
pos_deriv(pos_deriv < 0) = 0;

% Create final interval from global min to global max
final_intervals = [global_min_idx, global_max_idx];

% Validate interval duration
interval_duration = final_intervals(2) - final_intervals(1);
min_duration = round(0.2 * srate);  % 200ms minimum duration

if interval_duration < min_duration
    final_intervals = [];
    signalOut = zeros(size(signal));
    return;
end

% Create output signal
signalOut = zeros(size(deriv));
if ~isempty(final_intervals)
    signalOut(final_intervals(1):final_intervals(2)) = pos_deriv(final_intervals(1):final_intervals(2));
end
signalOut = signalOut';

end
