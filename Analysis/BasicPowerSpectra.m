% plot spectrums of: NREM1, NREM2, NREM3, REM, Fix, Game for 3 ROIs


clear
clc
close all

P = sleepAnalysisParameters();

Paths = P.Paths;
PlotProps = P.Manuscript;

Participants = P.Participants;
TitleTag = 'SimpleSpectra';
Night = 'Baseline';
Stages = [-1 -2 -3 0]; % NREM1, NREM2, NREM3, REM
Tasks = {'Fixation', 'Standing', 'Game'};
Sessions = {'BaselinePre', 'BaselinePre', 'Baseline'};
ChLabels = {'Front', 'Center', 'Back'};

Results = 'G:\Data\Results\Sleep';
StageLabels = {'NREM1', 'NREM2', 'NREM3', 'REM', 'Wake (eyes open)', 'Wake (eyes closed)', 'Game'};

load('Keep.mat', 'Keep')

% load data
AllPower = nan(numel(Participants), 7, 119, 513);

for Indx_P = 1:numel(Participants)

    % sleep
    Source = fullfile(Paths.Data, 'EEG', 'Unlocked', 'window4s_full', 'Sleep');
    Filename = strjoin({Participants{Indx_P}, 'Sleep', Night, 'Welch.mat'}, '_');

    if ~exist(fullfile(Source, Filename), 'file')
        warning(['Missing ', Filename])
    else
        load(fullfile(Source, Filename), 'Power', 'Freqs', 'Chanlocs', 'visnum')
        KeepChannels = labels2indexes(Keep, Chanlocs);

        % average power for each stage
        for Indx_S = 1:numel(Stages)
            Epochs =  find(ismember(visnum, Stages(Indx_S)));
            AllPower(Indx_P, Indx_S, :, :) = squeeze(mean(Power(KeepChannels, Epochs, :), 2, 'omitnan'));
        end
    end

    % wake
    for Indx_T = 1:numel(Tasks)
        Source = fullfile(Paths.Data, 'EEG', 'Unlocked', 'window4s_duration4m', Tasks{Indx_T});
        Filename = strjoin({Participants{Indx_P},  Tasks{Indx_T}, Sessions{Indx_T}, 'Welch.mat'}, '_');

        if ~exist(fullfile(Source, Filename), 'file')
            warning(['Missing ', Filename])
            continue
        end

        load(fullfile(Source, Filename), 'Power', 'Freqs', 'Chanlocs')
        KeepChannels = labels2indexes(Keep, Chanlocs);
        AllPower(Indx_P, Indx_T+numel(Stages), :, :) = Power(KeepChannels, :);

    end
    disp(['Finished ', Participants{Indx_P}])
end

Chanlocs = Chanlocs(KeepChannels);

zData = zScoreData(AllPower, 'last');
chData = meanChData(zData, Chanlocs, P.Channels.preROI, 3);
bData = squeeze(bandData(chData, Freqs, P.Bands, 'last'));

raw_chData = meanChData(AllPower, Chanlocs, P.Channels.preROI, 3);
raw_bData = squeeze(bandData(raw_chData, Freqs, P.Bands, 'last'));


nStages = size(bData, 2);

ChLabels = fieldnames(P.Channels.preROI);
nROI = numel(ChLabels);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots


%% plot each stage for each participant, log-log

Grid = [nROI, nStages];
xLims = [1 30];
YLims = [-4 7];

figure('Units','normalized','OuterPosition',[0 0 1 1])
for Indx_Ch = 1:nROI
    for Indx_S = 1:nStages
        A = subfigure([], Grid, [Indx_Ch, Indx_S], [], true, ...
            PlotProps.Indexes.Letters{Indx_S}, PlotProps);
        Data = log(squeeze(raw_chData(:, Indx_S, Indx_Ch, :)));
        plotAngelHair(log(Freqs), Data, PlotProps.Color.Participants, {}, PlotProps)
        title([StageLabels{Indx_S}, ' ', ChLabels{Indx_Ch}])
         set(gca, 'XGrid', 'on', 'YGrid', 'on', 'XTick', log(P.Labels.logBands))
        xlim(log(xLims))
        ylim(YLims)
            xticks(log(P.Labels.logBands))
    xticklabels(P.Labels.logBands)
    end
end

saveFig(strjoin({TitleTag, 'individuals', 'raw'}, '_'), Results, PlotProps)


%% idem but z-scored

Grid = [3, nStages];
xLog = true;
xLims = [1 30];
BL_Indx = 1;

figure('Units','normalized','Position',[0 0 1 .8])
for Indx_Ch = 1:3
    for Indx_S = 1:nStages
        A = subfigure([], Grid, [Indx_Ch, Indx_S], [], true, ...
            PlotProps.Indexes.Letters{Indx_S}, PlotProps);
        Data = squeeze(chData(:, Indx_S, Indx_Ch, :));
        plotAngelHair(Freqs, Data, PlotProps.Color.Participants, {}, PlotProps)
        title([StageLabels{Indx_S}, ' ', ChLabels{Indx_Ch}])
        xlim(xLims)
    end
end

saveFig(strjoin({TitleTag, 'individuals', 'z-scored'}, '_'), Results, PlotProps)


%% plot all overlapping

Grid = [1 3];
BL_Indx = 1;
% yLim = [-1.2, 4];
yLim = [-4 6];



Colors = [flip(getColors([1 3], '', 'blue')); getColors(1, '', 'green'); getColors([1, 2], '', 'red'); getColors(1, '', 'yellow')];

figure('Units','normalized','Position',[0 0 1 .5])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    Data = log(squeeze(raw_chData(:, :, Indx_Ch, :)));
    spectrumDiff(Data, Freqs, BL_Indx, StageLabels, Colors, xLog, PlotProps, P.StatsP, P.Labels);
    title([ChLabels{Indx_Ch}])
    ylim(yLim)
    if Indx_Ch>1
        legend off
        ylabel('')
    end
end

saveFig(strjoin({TitleTag, 'AllSpectra', 'raw'}, '_'), Results, PlotProps)



%% idem z-scored


Grid = [1 3];
BL_Indx = 1;
yLim = [-1.2, 4];


Colors = [flip(getColors([1 3], '', 'blue')); getColors(1, '', 'green'); getColors([1, 2], '', 'red'); getColors(1, '', 'yellow')];

figure('Units','normalized','Position',[0 0 1 .5])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    Data = squeeze(chData(:, :, Indx_Ch, :));
    spectrumDiff(Data, Freqs, BL_Indx, StageLabels, Colors, xLog, PlotProps, P.StatsP, P.Labels);
    title([ChLabels{Indx_Ch}])
    ylim(yLim)
    if Indx_Ch>1
        legend off
        ylabel('')
    end
end

saveFig(strjoin({TitleTag, 'AllSpectra', 'zscored'}, '_'), Results, PlotProps)



%% official figure
PlotProps = P.Manuscript;
% PlotProps.Line.Width = 5;
PlotProps.Line.Width = 2;

StageLabels = {'NREM 1', 'NREM 2', 'NREM 3', 'REM', 'Wake (EO)', 'Wake (EC)', 'Game'};
Plot = [1 4 5];
Plot = [6, 7, 1:4];

TitleTag2 = 'All';

Grid = [1 3];
BL_Indx = 1;
% yLim = [-1.2, 4];
yLim = [-4.5 6.5];
% yLim = [-4 4];
xLog = true;

Colors = [flip(getColors([1 3], '', 'blue')); getColors(1, '', 'green'); ...
    flip(getColors([1 2], '', 'red')); getColors(1, '', 'orange')];
Colors = Colors(Plot, :);

% figure('Units','normalized','Position',[0 0 .4 .26])
figure('Units','normalized','Position',[0 0 .5 .32])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    Data = log(squeeze(raw_chData(:, Plot, Indx_Ch, :)));
    spectrumDiff(Data, Freqs, BL_Indx, StageLabels(Plot), Colors, xLog, PlotProps, [], P.Labels);
    title([ChLabels{Indx_Ch}])
    ylim(yLim)
    if Indx_Ch>1
        legend off
        ylabel('')
    else
         set(legend, 'ItemTokenSize', [10 10])
         ylabel('Power (log)')
    end
    xlabel('Frequency (log)')
    axis square
end

Results = 'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Thesis\Figures\MATLAB';
saveFig(strjoin({TitleTag, 'SleepSpectra', 'raw', TitleTag2}, '_'), Results, PlotProps)


%%
StageLabels = {'NREM1', 'NREM2', 'NREM3', 'REM', 'Wake (eyes open)', 'Wake', 'Game'};
Plot = [6, 1 2 3 4 7];

Grid = [1 3];
BL_Indx = 1;
yLim = [-1.2, 5];
% yLim = [-5 7];

Colors = [getColors(1, '', 'red'); flip(getColors([1 3], '', 'blue')); getColors(1, '', 'yellow'); getColors(1, '', 'green')];

figure('Units','normalized','Position',[0 0 .55 .35])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    Data = squeeze(chData(:, Plot, Indx_Ch, :));
    spectrumDiff(Data, Freqs, BL_Indx, StageLabels(Plot), Colors, xLog, PlotProps, P.StatsP, P.Labels);
    title([ChLabels{Indx_Ch}])
    ylim(yLim)
    if Indx_Ch>1
        legend off
        ylabel('')
    else
         set(legend, 'ItemTokenSize', [10 10])
         ylabel('log power')
    end
end

saveFig(strjoin({TitleTag, 'SleepSpectra', 'zscored'}, '_'), Results, PlotProps)


