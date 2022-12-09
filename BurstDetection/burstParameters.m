function Info = burstParameters()
% parameters for detecting bursts

Info = struct();

Info.Tasks = {'Fixation', 'Standing', 'Oddball'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Burst Parameters

%%% parameters to find bursts in single channels

Info.Min_Peaks = 4;

Info.Max_Minutes = 6; % first number of clean minutes to look for bursts in

BurstThresholds = struct();
BurstThresholds.monotonicity = .6;
BurstThresholds.periodConsistency = .6;
BurstThresholds.periodMeanConsistency = .6;
BurstThresholds.efficiency = .6;
BurstThresholds.truePeak = 1;
BurstThresholds.flankConsistency = .5;
BurstThresholds.ampConsistency = .6;
Info.BurstThresholds = BurstThresholds;


%%% Parameters to aggregate across channels
Info.MinCoherence = .7;
Info.MinCorr = .8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations

if exist( 'D:\Data\Raw', 'dir')
    Core = 'D:\Data\';
elseif exist( 'F:\Data\Raw', 'dir')
    Core = 'F:\Data\';
elseif  exist( 'E:\Data\Raw', 'dir')
    Core = 'E:\Data\';
else
    error('no data disk!')
    % Core = 'E:\'
end

Paths.Preprocessed = fullfile(Core, 'Preprocessed');
Paths.Core = Core;

Paths.Datasets = 'G:\LSM\Data\Raw';
Paths.Data  = fullfile(Core, 'Final'); % where data gets saved once its been turned into something else
Paths.Results = fullfile(Core, 'Results', 'Theta_Bursts');

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

% same for matcycle scripts, saved to a different repo (https://github.com/hubersleeplab/matcycle)
addMatcyclePaths()

% get path where these scripts were saved
CD = mfilename('fullpath');
% Paths.Analysis = fullfile(extractBefore(Paths.Analysis, 'Analysis'));
Paths.Analysis = fullfile(extractBefore(CD, 'Sleep'), 'Sleep');

% get all folders in functions
Subfolders = deblank(string(ls(fullfile(Paths.Analysis, 'functions')))); % all content
Subfolders(contains(Subfolders, '.')) = []; % remove all files

for Indx_F = 1:numel(Subfolders)
    addpath(fullfile(CD, Subfolders{Indx_F}))
end

Info.Paths = Paths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EEG info

% bands used to get bursts
Bands.ThetaLow = [2 6];
Bands.Theta = [4 8];
Bands.ThetaAlpha = [6 10];
Bands.Alpha = [8 12];
Bands.SigmaLow = [10 14];
Bands.Sigma = [12 16];
Bands.SigmaHigh = [14 18];

% % bands used to
% PowerBands.Delta = [1 4];
% PowerBands.Theta = [4 8];
% PowerBands.Alpha = [8 12];
% PowerBands.Beta = [15 25];
% Info.PowerBands = PowerBands;

Info.Bands = Bands;


