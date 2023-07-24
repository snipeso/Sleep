function P = sleepAnalysisParameters()
% Here is located all the common variables, paths, and parameters that get
% repeatedly called by more than one preprocessing script.
% From Lapse-Causes.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters

P.Parameters.MinTots = 30;
P.Parameters.MinTypes = 15; % minimum number of trials for a given type for some sub-analyses
P.Parameters.MinNanProportion = 0.5;

P.Parameters.Timecourse.Window = [-2, 4];
P.Parameters.Topography.Windows = [-2 0; 0 0.3; 0.3 1; 2 4];


P.Parameters.EC_ConfidenceThreshold = 0.5;
P.Parameters.fs = 250;

P.Parameters.Radius = 4/6; % exclude outer third of trials

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Labels

P.Participants = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', ...
    'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P19'};

P.Nights = {'Baseline', 'NightPre', 'NightPost'};


Labels.logBands = [0.1 0.5 1 2 4 8 16 32 46]; % x markers for plot on log scale
Labels.Bands = [1 4 8 15 25 35 40 46]; % normal scale
Labels.FreqLimits = [0.1 40];
Labels.zPower = 'PSD z-scored';
Labels.Power = 'PSD Amplitude (\muV^2/Hz)';
Labels.Frequency = 'Frequency (Hz)';
Labels.Epochs = {'Encoding', 'Retention1', 'Retention2', 'Probe'}; % for M2S task
Labels.Amplitude = 'Amplitude (\muV)';
Labels.Time = 'Time (s)';
Labels.ES = "Hedge's G";
Labels.t = 't-values';
Labels.Correct = '% Correct';
Labels.RT = 'RT (s)';
P.Labels = Labels;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Locations

% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

% same for plotting scripts, saved to a different repo (https://github.com/snipeso/chart)
if ~exist('addchARTpaths.m', 'file')
    addchARTpaths() % TODO, find in folder automatically
end


if exist( 'D:\Data\Raw', 'dir')
    Core = 'D:\Data\';
elseif exist( 'F:\Data\Raw', 'dir')
    Core = 'F:\Data\';
elseif  exist( 'E:\Data\Raw', 'dir')
    Core = 'E:\Data\';
    elseif  exist( 'G:\Data\Raw', 'dir')
    Core = 'G:\Data\';
else
    error('no data disk!')
end

Paths.Preprocessed = fullfile(Core, 'Preprocessed');
Paths.Core = Core;

Paths.Datasets = 'G:\LSM\Data\Raw';
Paths.Data  = fullfile(Core, 'Final'); % where data gets saved once its been turned into something else
Paths.PaperResults = 'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Paper3\Figures'; % where figures and tables end up
Paths.Paper = 'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Paper3\Figures';
% Paths.Poster = 'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\SSSSC2022\Figures';
% Paths.Powerpoint = 'C:\Users\colas\Dropbox\Research\Projects\HuberSleepLab\LSM\Repeat Figures\MatlabFigures';
% Paths.PaperStats =  'C:\Users\colas\Dropbox\Research\Publications and Presentations\Sleep\Paper2\Stats';
Paths.Scoring = fullfile(Core, 'Scoring');
Paths.Results = fullfile(Core, 'Results\Sleep');

if ~exist(Paths.Results, 'dir')
    mkdir(Paths.Results)
end

Paths.Pool = fullfile(Paths.Data, 'All_Lapse-Causes');

% get path where these scripts were saved
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = fullfile(extractBefore(Paths.Analysis, '\Analysis\'));

% add location of subfunctions
addpath(fullfile(Paths.Analysis, 'functions','general'))
addpath(fullfile(Paths.Analysis, 'functions','eeg'))
addpath(fullfile(Paths.Analysis, 'functions','plots'))
addpath(fullfile(Paths.Analysis, 'functions','stats'))
addpath(fullfile(Paths.Analysis, 'functions','external'))

P.Paths = Paths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plotting settings
% These use chART (https://github.com/snipeso/chART) plots. Each figure
% takes a struct that holds all the parameters for plotting (e.g. font
% names, sizes, etc). These are premade in chART, but can be customized.


% plot sizes depending on which screen being used
Pix = get(0,'screensize');
if Pix(3) < 2000
    Format = getProperties({'LSM', 'SmallScreen'});
else
    Format = getProperties({'LSM', 'LargeScreen'});
end

Manuscript = getProperties({'LSM', 'Manuscript'});
Powerpoint =  getProperties({'LSM', 'Powerpoint'});
Poster =  getProperties({'LSM', 'Poster'});

Manuscript.Color.Types = flip(getColors(3));

P.Manuscript = Manuscript; % for papers
P.Manuscript.Figure.Width = 22;
P.Powerpoint = Powerpoint; % for presentations
P.Poster = Poster;
P.Format = Format; % plots just to view data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Power/EEG information

AllBands.Delta = [1 4];
AllBands.Theta = [4 8];
AllBands.Alpha = [8 12];
AllBands.Beta = [15 25];
AllBands.Gamma = [25 35];

Bands.LowDelta = [1 2];
Bands.HighDelta = [2 4];
Bands.Theta = [4 8];

%%% Channels and Regions of Interest (ROI)
Channels = struct();

Channels.Remove = [17, 48, 119]; % channels to remove before FFT

% ROIs selected independently of data
Frontspot = [22 15 9 23 18 16 10 3 24 19 11 4 124 20 12 5 118 13 6 112];
Backspot = [66 71 76 84 65 70 75 83 90 69 74 82 89];
Centerspot = [129 7 106 80 55 31 30 37 54 79 87 105 36 42 53 61 62 78 86 93 104 35 41 47  52 92 98 103 110, 60 85 51 97];

Channels.preROI.Front = Frontspot;
Channels.preROI.Center = Centerspot;
Channels.preROI.Back = Backspot;

Channels.Hemifield.Right = [1:5, 8:10, 14, 76:80, 82:87, 88:125];
Channels.Hemifield.Left = [12, 13, 18:54, 56:61, 63:71, 73, 74];

Format.Colors.preROI = getColors(numel(fieldnames(Channels.preROI)));

P.Channels = Channels;
P.AllBands = AllBands;
P.Bands = Bands;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stats parameters

StatsP = struct();

StatsP.ANOVA.ES = 'eta2';
StatsP.ANOVA.ES_lims = [0 1];
StatsP.ANOVA.nBoot = 2000;
StatsP.ANOVA.pValue = 'pValueGG';
StatsP.ttest.nBoot = 2000;
StatsP.ttest.dep = 'pdep'; % use 'dep' for ERPs, pdep for power
StatsP.Alpha = .05;
StatsP.Trend = .1;
StatsP.Paired.ES = 'hedgesg';
StatsP.Paired.Benchmarks = -2:.5:2;
StatsP.FreqBin = 1; % # of frequencies to bool in spectrums stats
StatsP.minProminence = .1; % minimum prominence for when finding clusters of g values
P.StatsP = StatsP;


