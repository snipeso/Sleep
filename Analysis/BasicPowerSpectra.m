% plot spectrums of: NREM1, NREM2, NREM3, REM, Fix, Game for 3 ROIs


clear
clc
close all

P = analysisParameters();

Paths = P.Paths;
PlotProps = P.Manuscript;

Participants = P.Participants;
Night = 'Baseline';
Stages = [-1 -2 -3 1]; % NREM1, NREM2, NREM3, REM
Tasks = {'Fixation', 'Standing', 'Game'};
ChLabels = {'Front', 'Center', 'Back'};

StageLabels = {'NREM1', 'NREM2', 'NREM3', 'REM', 'Wake (eyes open)', 'Wake (eyes closed)', 'Game'};

% load data
AllPower = nan(numel(Participants), 7, 122, 513);

for Indx_P = 1:numel(Participants)

    % sleep
    Source = fullfile(Paths.Data, 'EEG', 'Unlocked', 'window4s_full', 'Sleep');
    Filename = strjoin({Participants{Indx_P}, 'Sleep', Night, 'Welch.mat'}, '_');

    if ~exist(fullfile(Source, Filename), 'file')
        warning(['Missing ', Filename])
    else
        load(fullfile(Source, Filename), 'Power', 'Freqs', 'Chanlocs', 'visnum')

        % average power for each stage
        for Indx_S = 1:numel(Stages)
            Epochs =  find(ismember(visnum, Stages(Indx_S)));
            AllPower(Indx_P, Indx_S, :, :) = squeeze(mean(Power(:, Epochs, :), 2, 'omitnan'));
        end
    end

    % wake
    for Indx_T = 1:numel(Tasks)
        Source = fullfile(Paths.Data, 'EEG', 'Unlocked', 'window4s_4m', 'Sleep');
        Filename = strjoin({Participants{Indx_P}, 'Sleep', Night, 'Welch.mat'}, '_');

        if ~exist(fullfile(Source, Filename), 'file')
            warning(['Missing ', Filename])
            continue
        end

        load(fullfile(Source, Filename), 'Power', 'Freqs', 'Chanlocs')
        AllPower(Indx_P, Indx_T+numel(Stages), :, :) = Power;

    end
end


zData = zScoreData(AllPower, 'last');
chData = meanChData(zData, Chanlocs, Channels.All, 4);
bData = squeeze(bandData(chData, Freqs, Bands, 'last'));

raw_chData = meanChData(SWA_first, Chanlocs, Channels.All, 4);
raw_bData = squeeze(bandData(raw_chData, Freqs, Bands, 'last'));


nStages = size(bData, 2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots


%% plot each stage for each participant, log-log

Grid = [3, nStages];
xLog = true;
xLims = [1 40];

figure('Units','normalized','Position',[0 0 .8 1])
for Indx_Ch = 1:3
    for Indx_S = 1:nStages
        A = subfigure([], Grid, [Indx_Ch, Indx_S], [], true, ...
            PlotProps.Indexes.Letters{Indx_S}, PlotProps);
        Data = log(squeeze(raw_chData(:, Indx_S, Indx_Ch, :)));
        plotSpectrumMountains(Data, Freqs, xLog, xLims, PlotProps, P.Labels)
        title([StageLabels{Indx_S}, ' ', ChLabels{Indx_Ch}])
    end
end


%% idem but z-scored

figure('Units','normalized','Position',[0 0 .8 1])
for Indx_Ch = 1:3
    for Indx_S = 1:nStages
        A = subfigure([], Grid, [Indx_Ch, Indx_S], [], true, ...
            PlotProps.Indexes.Letters{Indx_S}, PlotProps);
        Data = log(squeeze(chData(:, Indx_S, Indx_Ch, :)));
        plotSpectrumMountains(Data, Freqs, xLog, xLims, PlotProps, P.Labels)
        title([StageLabels{Indx_S}, ' ', ChLabels{Indx_Ch}])
    end
end

%% plot all overlapping

Grid = [1 3];
BL_Indx = 5;


figure('Units','normalized','Position',[0 0 .8 1])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [Indx_Ch, Indx_S], [], true, ...
        PlotProps.Indexes.Letters{Indx_S}, PlotProps);
    Data = squeeze(chData(:, :, Indx_Ch, :));
    spectrumDiff(Data, Freqs, BL_Indx, [], getColors([1 size(Data, 2)]), xLog, PlotProps, [], P.Labels);
    title([ChLabels{Indx_Ch}])
end


%% idem z-scored




