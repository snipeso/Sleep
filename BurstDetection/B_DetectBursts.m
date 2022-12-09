% loads in filtered data, finds the bursts in each channel, removes the
% overlapping ones.

clear
clc
close all


Info = burstParameters();

Paths = Info.Paths;
Bands = Info.Bands;
BandLabels = fieldnames(Bands);

Tasks = {'Sleep'};
Refresh = false;

% Parameters for bursts
BT = Info.BurstThresholds;
Min_Peaks = Info.Min_Peaks;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get bursts

for Indx_T = 1:numel(Tasks)
    Task = Tasks{Indx_T};

    % folder locations
    Source = fullfile(Paths.Preprocessed, 'Clean', 'Waves', Task); % normal data
    Source_Filtered = fullfile(Paths.Preprocessed, 'Clean', 'Waves_Filtered', Task); % extremely filtered data
    Source_Cuts = 'E:\Data\Outliers\Sleep'; % timepoints marked as artefacts
    Destination = fullfile(Paths.Data, 'EEG', 'Bursts_AllChannels', Task);

    if ~exist(Destination, 'dir')
        mkdir(Destination)
    end

    Content = getContent(Source);
    for Indx_F = 1:numel(Content)

        % load data
        Filename_Source = Content{Indx_F};
        Filename_Filtered = replace(Filename_Source, 'Clean.mat', 'Filtered.mat');
        Filename_Destination = replace(Filename_Source, 'Clean.mat', 'Bursts.mat');
        Filename_Cuts = replace(Filename_Source, 'Clean.mat', 'Cutting_artndxn.mat');

        if exist(fullfile(Destination, Filename_Destination), 'file') && ~Refresh
            disp(['Skipping ', Filename_Destination])
            continue
        elseif contains(Filename_Source, 'P00')
            continue
        else
            disp(['Loading ', Filename_Source])
        end

        load(fullfile(Source, Filename_Source), 'EEG', 'artndxn', 'visnum')
        fs = EEG.srate;
        Keep_Points = ones(1, EEG.pnts);

        % need to concatenate structures
        FiltEEG = EEG;
        FiltEEG.Band = [];

        for Indx_B = 1:numel(BandLabels) % get bursts for all provided bands

            % load in filtered data
            Band = Bands.(BandLabels{Indx_B});
            F = load(fullfile(Source_Filtered, BandLabels{Indx_B}, Filename_Filtered));
            FiltEEG(Indx_B) = F.FiltEEG;
        end

        % get bursts in all data
        AllBursts = getAllBursts(EEG, FiltEEG, BT, Min_Peaks, Bands, Keep_Points);

        % keep track of how much data is being used
        EEG.keep_points = Keep_Points;
        EEG.clean_t = nnz(Keep_Points);

        EEG.data = []; % only save the extra ICA information

        % save structures
        save(fullfile(Destination, Filename_Destination), 'AllBursts', 'EEG',  'artndxn', 'visnum')
    end
end

