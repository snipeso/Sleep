% Calculate power for each 20s window



Core = 'E:\Data\Preprocessed\';
Source = fullfile(Core, 'Power\MAT\Sleep');
Source_Tag = 'Power';
Source_Cuts = 'E:\Data\Outliers\Sleep';

Destination = 'E:\Data\Final\EEG\Unlocked';

WelchWindow = 4; % in seconds
Overlap = 0.5;

Destination = fullfile(Destination, ['window', num2str(WelchWindow), 's_full']);

BadChannel_Threshold = .33; % proportion of bad epochs before it gets counted as a bad channel
BadWindow_Threshold = .1; % proportion of bad channels before its counted as a bad window

RemoveChannels = [49 56 107 113 126 127];
EdgeChannels = [48, 63, 68, 73, 81, 88, 94, 99, 119, 125, 128, 8, 25, 17 14 21 48 119 57 100];

if ~exist(Destination, 'dir')
    mkdir(Destination)
end


Files = getContent(Source);

for Indx_F = 1:numel(Files)
    Filename_Source = Files{Indx_F};
    Filename_Cuts = replace(Filename_Source, Source_Tag, 'Cutting_artndxn');
    Filename_Destination = replace(Filename_Source, Source_Tag, 'Welch');

    % load info on whether to keep epochs or not
    if ~exist(fullfile(Source_Cuts, Filename_Cuts), 'file')
        warning(['no cleaning for ', Filename_Source, ' so skipping'])
        continue
    else
        disp(['loading ', Filename_Source])
    end

    load(fullfile(Source, Filename_Source), 'EEG');

    load(fullfile(Source_Cuts, Filename_Cuts), 'artndxn', 'visnum', 'scoringlen')

    % remove pre-selected bad channels so that they also don't get
    % interpolated
    EEG = pop_select(EEG, 'nochannel', RemoveChannels);
    artndxn(RemoveChannels, :) = [];

    fs = EEG.srate;

    % bad channels
    BadEpochs = sum(artndxn==0, 2, 'omitnan');
    badchans = find(BadEpochs./size(artndxn, 2) >= BadChannel_Threshold)';

    artndxn(badchans, :) = 0;

    % bad epochs
    Holes = findHoles(artndxn, EEG.chanlocs, EdgeChannels); % epochs where there are no adjacent electrodes
    BadWindows = sum(artndxn==0)./size(artndxn, 1) >=BadWindow_Threshold;


    % set to nan holes so they're not counted in BadSnippets
    artndxn(:, Holes | BadWindows) = 0;


    % loop through epochs, calculate power
    Starts = 1:fs*scoringlen:size(EEG.data, 2);
    Ends = Starts+fs*scoringlen-1;

    Power = nan(size(artndxn));
    for Indx_E = 1:size(artndxn, 2)

        ShortEEG = pop_select(EEG, 'point', [Starts(Indx_E), Ends(Indx_E)]);

        KeepCh = artndxn(:, Indx_E);

        % skip if all nans
        if ~any(KeepCh)
            continue
        end

        % remove bad channels/timepoints for epoch
        ShortEEG = pop_select(ShortEEG, 'channel', find(KeepCh));

        % interpolate missing data
        ShortEEG = pop_interp(ShortEEG, EEG.chanlocs);

        % rereference to average
        ShortEEG = pop_reref(ShortEEG, []);

        % FFT
        nfft = 2^nextpow2(WelchWindow*fs);
        noverlap = round(nfft*Overlap);
        window = hanning(nfft);
        [P, Freqs] = pwelch(ShortEEG.data', window, noverlap, nfft, fs);
        P = P';
        Freqs = Freqs';
        
        Power(:, Indx_E, 1:numel(Freqs)) = P;
    end
    Chanlocs = EEG.chanlocs;

    % save
    save(fullfile(Destination, Filename_Destination), 'Power', 'fs', 'Chanlocs', 'Freqs', 'visnum')

end