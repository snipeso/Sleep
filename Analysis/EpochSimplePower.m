% Calculate power for each 20s window
clear
clc
close all

P = sleepAnalysisParameters();
Paths = P.Paths;

Source = fullfile(Paths.Preprocessed, 'Simple\Sleep');
Destination = fullfile(Paths.Data, 'EEG', 'Unlocked');

Refresh = false;

WelchWindow = 10; % in seconds
Overlap = 0.75;

Destination = fullfile(Destination, ['window', num2str(WelchWindow), 's_full'], 'Sleep');

BadChannel_Threshold = .33; % proportion of bad epochs before it gets counted as a bad channel
BadWindow_Threshold = .5; % proportion of bad channels before its counted as a bad window

if ~exist(Destination, 'dir')
    mkdir(Destination)
end

Files = getContent(Source);

for Indx_F = 1:numel(Files)
    Filename = Files{Indx_F};

    % todo skip if refresh
    if exist(fullfile(Destination, Filename), 'file') && ~Refresh
        disp(['Skipping ', Filename])
        continue
    end

    load(fullfile(Source, Filename), 'EEG', 'artndxn', 'visnum', 'scoringlen');
    fs = EEG.srate;
    Chanlocs = EEG.chanlocs;

    % ssign artefact as either bad channel or bad epoch
    Old = artndxn;
    artndxn = assign_bad_channels_epochs(artndxn, BadChannel_Threshold, BadWindow_Threshold);

    % loop through epochs, calculate power
    [Power, Freqs] = sleep_power(EEG, artndxn, scoringlen, WelchWindow, Overlap);

    if all(isnan(Power(:)))
        warning(['no data left in ', Filename])
        Freqs = [];
        Power = [];
    end

    % save TODO parsave
    save(fullfile(Destination, Filename), 'Power', 'fs', 'Chanlocs', 'Freqs', 'visnum')

end