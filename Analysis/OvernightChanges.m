% plot spectrums of: NREM1, NREM2, NREM3, REM, Fix, Game for 3 ROIs


clear
clc
close all

P = sleepAnalysisParameters();

Paths = P.Paths;
PlotProps = P.Manuscript;

Participants = P.Participants;
TitleTag = 'SimpleSpectra_hours';
Night = 'Baseline';
Stages = [-1 -2 -3 1]; % NREM1, NREM2, NREM3, REM
ChLabels = {'Front', 'Center', 'Back'};
TotHours = 6;

Results = 'G:\Data\Results\Sleep';

load('Keep.mat', 'Keep')

% load data
AllPower = nan(numel(Participants), TotHours, 119, 513);

for Indx_P = 1:numel(Participants)

    % sleep
    Source = fullfile(Paths.Data, 'EEG', 'Unlocked', 'window4s_full', 'Sleep');
    Filename = strjoin({Participants{Indx_P}, 'Sleep', Night, 'Welch.mat'}, '_');

    if ~exist(fullfile(Source, Filename), 'file')
        warning(['Missing ', Filename])
    else
        load(fullfile(Source, Filename), 'Power', 'Freqs', 'Chanlocs', 'visnum')
        KeepChannels = labels2indexes(Keep, Chanlocs);

        % assign bin for each epoch
        NREM = find(ismember(visnum, [-2 -3]));
        Hours = discretize(NREM, linspace(1, max(NREM), TotHours+1));

        % average power for each stage
        for Indx_H = 1:TotHours
            Epochs = NREM(Hours==Indx_H);
            AllPower(Indx_P, Indx_H, :, :) = squeeze(mean(Power(KeepChannels, Epochs, :), 2, 'omitnan'));
        end
    end

    disp(['Finished ', Participants{Indx_P}])
end

Chanlocs = Chanlocs(KeepChannels);

zData = zScoreData(AllPower, 'last');
chData = meanChData(zData, Chanlocs, P.Channels.preROI, 3);
bData = squeeze(bandData(chData, Freqs, P.Bands, 'last'));

raw_chData = meanChData(AllPower, Chanlocs, P.Channels.preROI, 3);
raw_bData = squeeze(bandData(raw_chData, Freqs, Bands, 'last'));


nStages = size(bData, 2);

ChLabels = fieldnames(P.Channels.preROI);
nROI = numel(ChLabels);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plots





%% official figure
PlotProps = P.Manuscript;
PlotProps.Line.Width = 5;


TitleTag2 = '';

Grid = [1 3];
BL_Indx = 1;
% yLim = [-1.2, 4];
yLim = [-4.5 6.5];
% yLim = [-4 4];
xLog = true;
Plot = 1:6;

Colors = getColors([1 numel(Plot)], '', 'blue');
Colors = Colors(Plot, :);

figure('Units','normalized','Position',[0 0 .4 .26])
for Indx_Ch = 1:3
    A = subfigure([], Grid, [1, Indx_Ch], [], true, ...
        PlotProps.Indexes.Letters{Indx_Ch}, PlotProps);
    Data = log(squeeze(raw_chData(:, Plot, Indx_Ch, :)));
    spectrumDiff(Data, Freqs, BL_Indx, [], Colors, xLog, PlotProps, [], P.Labels);
    title([ChLabels{Indx_Ch}])
    ylim(yLim)
    legend off
    ylabel('Power (log)')

    xlabel('Frequency (log)')
    axis square
end

saveFig(strjoin({TitleTag, 'SleepSpectra', 'raw', TitleTag2}, '_'), Results, PlotProps)



%% 



figure('Units','normalized','Position',[0 0 .4 .26])
for Indx_B = 1:numel(Band)
