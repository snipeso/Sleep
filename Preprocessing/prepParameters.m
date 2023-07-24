function P = prepParameters()
% prepare paramters for sleep scoring

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paths

Paths = struct();

% raw data
RawCore = 'D:\LSM\Data\';
Paths.Datasets = fullfile(RawCore, 'Raw');

% where to put preprocessed data
PrepCore = RawCore;

Paths.Preprocessed = fullfile(PrepCore, 'Preprocessed');
Paths.Core = PrepCore;

% where current functions are
Paths.Analysis = mfilename('fullpath');
Paths.Analysis = fullfile(extractBefore(Paths.Analysis, '\Preprocessing\'));

% add to path all folders in functions
Content = deblank(string(ls(fullfile(Paths.Analysis, 'functions'))));
for Indx = 1:numel(Content)
    addpath(fullfile(Paths.Analysis, 'functions', Content{Indx}))
end

P.Paths = Paths;


% Folders for raw data

RawFolders = struct();

RawFolders.Template = 'PXX';
RawFolders.Ignore = {'CSVs', 'other', 'Lazy', 'P00', 'Applicants'};

[RawFolders.Subfolders, RawFolders.Datasets] = AllFolderPaths(Paths.Datasets, ...
    RawFolders.Template, false, RawFolders.Ignore);

P.RawFolders = RawFolders;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Format.FontName = 'Tw Cen MT'; % use something else for papers

% plot sizes depending on which screen I'm using
Pix = get(0,'screensize');
if Pix(3) < 2000
    Format.FontSize = 12;
    Format.TitleSize = 15;
    Format.BarSize = 10;
    Format.TopoRes = 150;
    Format.LW = 2;
    Format.Topo.Sig = 2; % marker size
    Format.ScatterSize = 70; % TODO: seperate features for small or big screen
    Format.OSize = 5; % Spaghetti O
    
else
    Format.FontSize = 25;
    Format.TitleSize = 30;
    Format.BarSize = 18;
    Format.TopoRes = 300;
    Format.LW = 4;
    Format.Topo.Sig = 5; % marker size
    Format.ScatterSize = 200; % TODO: seperate features for small or big screen
    Format.OSize = 20; % Spaghetti O
end


%%% colors and colormaps

% colormaps
Format.Colormap.Linear = flip(colorcet('L17'));
Format.Colormap.Monochrome = colorcet('L2');
Format.Colormap.Divergent = colorcet('D1A');
Format.Colormap.Rainbow = unirainbow;

% discrete color steps for topoplot colormaps
Format.Steps.Linear = 20;
Format.Steps.Divergent = 30;
Format.Steps.Monochrome = 20;

Format.Colorbar = 'west'; % location

Format.Alpha.Participants = .3; % transparency when plotting all participants together
Format.Alpha.Channels = .15; % transparency when plotting all participants together


% colors for levels in M2S task
Format.Colors.Levels = getColors([1 3], 'rainbow', 'red'); % M2S red
Format.Colors.spEpochs = getColors([1 2], 'rainbow', 'green'); % speech green

% other colors
Format.Colors.SigStar = [0 0 0];
Format.Colors.Generic = [.5 .5 .5];
Format.Colors.Background = [1 1 1];


P.Format = Format;

Bands.Delta = [1 4];
Bands.Theta = [4 8];
Bands.Alpha = [8 12];
Bands.Beta = [15 25];

P.Bands = Bands;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters




