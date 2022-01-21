function EEG = rmNoise_Sleep(EEG, BadData)

fsBad = 1/4;

Bad = reshape(BadData', [], 1)==49;

[Starts, Ends] = data2windows(Bad);

Starts = Starts-1;

EEG = pop_select(EEG, 'notime', [Starts(:), Ends(:)]/fsBad);











