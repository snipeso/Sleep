% Calculate power for each 20s window
clear
clc
close all


Core = 'E:\Data\Preprocessed\';
Source = fullfile(Core, 'Power\MAT\Sleep');
Source_Tag = 'Power';
Source_Cuts = 'E:\Data\Outliers\Sleep';

Destination = 'E:\Data\Final\EEG\Unlocked';

Refresh = false;

WelchWindow = 4; % in seconds
Overlap = 0.5;

FinalFreqs = 513; % to pre-allocate;

Destination = fullfile(Destination, ['window', num2str(WelchWindow), 's_full'], 'Sleep');

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

    % todo skip if refresh 
    if exist(fullfile(Destination, Filename_Destination), 'file') && ~Refresh
        disp(['Skipping ', Filename_Source])
        continue
    end

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
        Chanlocs = EEG.chanlocs;

   artndxn = assign_bad_channels_epochs(artndxn, BadChannel_Threshold, BadWindow_Threshold, EdgeChannels);


    % loop through epochs, calculate power
   [Power, Freqs] = sleep_power(EEG, artndxn, scoringlen, WelchWindow, Overlap);


    if all(isnan(Power(:)))
        warning(['no data left in ', Filename_Destination])
        Freqs = [];
        Power = [];
    end

    % save TODO parsave
    save(fullfile(Destination, Filename_Destination), 'Power', 'fs', 'Chanlocs', 'Freqs', 'visnum')

end