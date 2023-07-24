function [Power, Freqs] = sleep_power(EEG, artndxn, scoringlen, WelchWindow, Overlap)
% calculates power for each scoring epoch.
% Power is ch x epoch x f
% EEG is eeglab structure
% artndxn is ch x epoch matrix of 1s and 0s, where 1 is an artefact
% scoringlen (seconds) is duration of an epoch
% WelchWindow (seconds) is duration of window over which to calculate FFT
% Overlap (0-1) is amount of overlap of welchwindow.

Starts = 1:fs*scoringlen:size(EEG.data, 2);
Ends = Starts+fs*scoringlen-1;

if numel(Starts) ~= size(artndxn, 2)
    warning('mismatch between EEG size and artefact matrix')
end

Power = nan(size(artndxn, 1), size(artndxn, 2), FinalFreqs);
for Indx_E = 1:size(artndxn, 2)
    KeepCh = artndxn(:, Indx_E);

    % skip if all nans
    if ~any(KeepCh==1)
        continue
    end

    ShortEEG = pop_select(EEG, 'point', [Starts(Indx_E), Ends(Indx_E)]);

    % remove bad channels/timepoints for epoch
    ShortEEG = pop_select(ShortEEG, 'channel', find(KeepCh));

    % interpolate missing data
    ShortEEG = pop_interp(ShortEEG, EEG.chanlocs);

    % rereference to average
    ShortEEG = pop_reref(ShortEEG, []);

    % FFT
    if Indx_E == 1 % TEMP because I'm stupid
        [Pwr, Freqs] = quickPower(ShortEEG.data, fs, WelchWindow, Overlap);
        Power = nan(size(artndxn, 1), size(artndxn, 2), FinalFreqs);
        Power(:, Indx_E, :) = Pwr;
    else
        [Power(:, Indx_E, :), ~] = quickPower(ShortEEG.data, fs, WelchWindow, Overlap);
    end
end

