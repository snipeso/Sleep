% plot spectrums of: NREM1, NREM2, NREM3, REM, Fix, Game for 3 ROIs

clear
clc
close all

P = sleepAnalysisParameters();

Paths = P.Paths;
PlotProps = P.Manuscript;

Participants = P.Participants;
TitleTag = 'SimpleSpectra';
Stages = [-1 -2 -3  0, 1]; % NREM1, NREM2, NREM3, REM
Sessions = {'Baseline', 'NightPre', 'NightPost'};
WindowLength = 10;
Channels.Front = [1 6];
Channels.Center = [2 5];
Channels.Back = [3 4];
TotHours = 6;

ChLabels = fieldnames(Channels);

Results = fullfile(Paths.Results, 'BasicSpectra');
if ~exist("Results", 'dir')
    mkdir(Results)
end

StageLabels = {'NREM1', 'NREM2', 'NREM3', 'REM', 'Wake'};

% load data
AllPower = nan(numel(Participants), numel(Sessions), numel(StageLabels), numel(ChLabels), 1025);
HourPower = nan(numel(Participants), numel(Sessions), TotHours, numel(ChLabels), 1025);


for Indx_P = 1:numel(Participants)
    for Indx_N = 1:numel(Sessions)
        Night = Sessions{Indx_N};

        % sleep
        Source = fullfile(Paths.Data, 'EEG', 'Unlocked', ['window', num2str(WindowLength), 's_full'], 'Sleep');
        Filename = strjoin({Participants{Indx_P}, 'Sleep', [Night, '.mat']}, '_');

        if ~exist(fullfile(Source, Filename), 'file')
            warning(['Missing ', Filename])
        else
            load(fullfile(Source, Filename), 'Power', 'Freqs', 'Chanlocs', 'visnum')

%             NREM = find(ismember(visnum, [-2 -3]));
 NREM = find(ismember(visnum, [-3]));
            Hours = discretize(NREM, linspace(1, max(NREM), TotHours+1));

            % average power for each stage
            for Indx_Ch = 1:numel(ChLabels)

                for Indx_S = 1:numel(Stages)
                    % all epochs
                    Epochs =  find(ismember(visnum, Stages(Indx_S)));
                    Data = Power(Channels.(ChLabels{Indx_Ch}), Epochs, :);
                    AllPower(Indx_P, Indx_N, Indx_S, Indx_Ch, :) = squeeze(mean(mean(Data, 1, 'omitnan'), 2, 'omitnan'));

                end

                for Indx_H = 1:TotHours
                    % split by hour
                    Epochs = NREM(Hours==Indx_H);
                    Data = Power(Channels.(ChLabels{Indx_Ch}), Epochs, :);
                    HourPower(Indx_P, Indx_N, Indx_H, Indx_Ch, :) = squeeze(mean(mean(Data, 1, 'omitnan'), 2, 'omitnan'));
                end
            end
        end
    end
    disp(['Finished ', Participants{Indx_P}])
end

nStages = size(AllPower, 3);

nROI = numel(ChLabels);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots


%% plot each stage for each participant, log-log

Grid = [nROI, nStages];
xLims = [0.1 30];
YLims = [-4 7];

figure('Units','normalized','OuterPosition',[0 0 1 1])
for Indx_Ch = 1:nROI
    for Indx_S = 1:nStages
        A = subfigure([], Grid, [Indx_Ch, Indx_S], [], true, ...
            PlotProps.Indexes.Letters{Indx_S}, PlotProps);
        Data = log(squeeze(chData(:, Indx_S, Indx_Ch, :)));
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


%% plot all overlapping

Grid = [1 3];
BL_Indx = 1;
% yLim = [-1.2, 4];
yLim = [-4 6];
yLog = true;
xLog = true;


Colors = [flip(getColors([1 3], '', 'blue')); getColors(1, '', 'green'); getColors([1, 2], '', 'red'); getColors(1, '', 'yellow')];

figure('Units','normalized','Position',[0 0 1 .5])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    Data = log(squeeze(AllPower(:, 1, :, Indx_Ch, :)));
    spectrumDiff(Data, Freqs, BL_Indx, StageLabels, Colors, xLog, PlotProps, P.StatsP, P.Labels);
    title([ChLabels{Indx_Ch}])
    ylim(yLim)
    if Indx_Ch>1
        legend off
        ylabel('')
    end
end

saveFig(strjoin({TitleTag, 'AllSpectra', 'raw'}, '_'), Results, PlotProps)




%% official figure
PlotProps = P.Manuscript;
% PlotProps.Line.Width = 5;
PlotProps.Line.Width = 2;

Plot = 1:numel(StageLabels);

TitleTag2 = 'All';

Grid = [1 3];
BL_Indx = 1;
% yLim = [-1.2, 4];
yLim = [-4 9];
% yLim = [-4 4];
xLog = true;
yLog = true;
% xLog = false;
% yLog = false;

Colors = [flip(getColors([1 3], '', 'blue')); getColors(1, '', 'green'); ...
    flip(getColors([1 2], '', 'red')); getColors(1, '', 'orange')];
Colors = Colors(Plot, :);

% figure('Units','normalized','Position',[0 0 .4 .26])
figure('Units','normalized','Position',[0 0 .5 .32])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    Data = squeeze(AllPower(:, 1, Plot, Indx_Ch, :));
    spectrumDiff(Data, Freqs, BL_Indx, StageLabels(Plot), Colors, xLog, yLog, PlotProps, [], P.Labels);
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
    xlim(log([.2 40]))
end

Results = 'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Thesis\Figures\MATLAB';
% saveFig(strjoin({TitleTag, 'SleepSpectra', 'raw', TitleTag2}, '_'), Results, PlotProps)



%% Hour by hour changes
PlotProps = P.Manuscript;
PlotProps.Line.Width = 2;


TitleTag2 = '';

Grid = [1 3];
BL_Indx = 1;
yLim = [-4 9];
xLog = true;
yLog = true;
Plot = 1:6;
Night = 3;

Colors = getColors([1 numel(Plot)], '', 'blue');
Colors = Colors(Plot, :);
figure('Units','normalized','Position',[0 0 .5 .32])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    Data = squeeze(HourPower(:, Night, Plot, Indx_Ch, :));
    spectrumDiff(Data, Freqs, BL_Indx, [], Colors, xLog, yLog, PlotProps, [], P.Labels);
    title([ChLabels{Indx_Ch}])
    ylim(yLim)
    legend off
    ylabel('Power (log)')
 xlim(log([.2 40]))
    xlabel('Frequency (log)')
    axis square
end

% saveFig(strjoin({TitleTag, 'SleepSpectra', 'raw', TitleTag2}, '_'), Results, PlotProps)



%% plot BL vs SD hour by hour

PlotProps = P.Manuscript;
PlotProps.Line.Width = 2;

TitleTag2 = '';

Grid = [1 3];
BL_Indx = 1;
yLim = [-4 9];
xLog = true;
yLog = true;
Plot = 1:5;
xLims = [0.1 30];

PlotProps.Patch.Alpha = 0.75;

Colors = getColors([1 numel(Plot)], '', 'blue');
Colors = Colors(Plot, :);
figure('Units','normalized','Position',[0 0 .5 .32])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    
    Data = squeeze(mean(HourPower(:, [1, 3], Plot, Indx_Ch, :), 1, 'omitnan'));
    Data = permute(Data, [2 1 3]);

    Data = log(Data);

plotSpectrumMountains(Data, Freqs, xLog, xLims, PlotProps, Colors, P.Labels, false)
title([ChLabels{Indx_Ch}])
    ylim(yLim)
    legend off
    ylabel('Power (log)')
 xlim(log([.2 40]))
    xlabel('Frequency (log)')
    axis square
end


%% N2 vs N3

PlotProps = P.Manuscript;
PlotProps.Line.Width = 2;

TitleTag2 = '';

Grid = [1 3];
BL_Indx = 1;
yLim = [-0 11];
xLog = true;
yLog = true;
Plot = 1:5;
xLims = [0.1 30];
Night = 1;

PlotProps.Patch.Alpha = 0.1;

Colors = getColors([1 numel(Plot)], '', 'blue');
Colors = Colors(Plot, :);
figure('Units','normalized','Position',[0 0 .5 .32])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    
    Data = squeeze(AllPower(:, Night, [2 3], Indx_Ch, :));

    Data = log(Data);

plotSpectrumMountains(Data, Freqs, xLog, xLims, PlotProps, PlotProps.Color.Participants, P.Labels, true)
title([ChLabels{Indx_Ch}])
    ylim(yLim)
    legend off
    ylabel('Power (log)')
 xlim(log([.2 20]))
    xlabel('Frequency (log)')
    axis square
end


%% FOOOF

figure('Units','normalized','Position',[0 0 1 .32])
for Indx_S = 1:numel(Stages)
    subplot(1, numel(Stages), Indx_S)
Data = squeeze(mean(AllPower(:, 1, Indx_S, 2, :), 1, 'omitnan'));
[Slope, Intercept] = fooofFit(Freqs, Data, [0.1 40], true);
title(StageLabels{Indx_S})
set(gca, 'xscale', 'log')
xlim([.2 40])
ylim([-2 4])
end


%% manual fit

Plot = 1:numel(Stages);
Colors = [flip(getColors([1 3], '', 'blue')); getColors(1, '', 'green'); ...
    flip(getColors([1 2], '', 'red')); getColors(1, '', 'orange')];
Colors = Colors(Plot, :);

figure('Units','normalized','Position',[0 0 1 .32])
for Indx_S = 1:numel(Stages)
    subplot(1, numel(Stages), Indx_S)
    D = squeeze(AllPower(:, 1, Indx_S, 2, :));
    D = permute(D, [1 3 2]);
Data = squeeze(mean(AllPower(:, 1, Indx_S, 2, :), 1, 'omitnan'));
% Range = dsearchn(Freqs', [0.1:0.1:0.4, 20:40]');
Range = dsearchn(Freqs', [0.1 20:40]');

plot(log(Freqs), log(Data))
[Slope, Intercept] = quickFit(log(Freqs(Range)), log(Data(Range)), true);
title(StageLabels{Indx_S})
% set(gca, 'xscale', 'log')
xlim(log([.1 40]))
ylim([-4 12])

  xticks(log(P.Labels.logBands))
    xticklabels(P.Labels.logBands)
    xlim(log([P.Labels.logBands(1), P.Labels.logBands(end)]))
end


