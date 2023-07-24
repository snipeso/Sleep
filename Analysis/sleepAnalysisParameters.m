function P = sleepAnalysisParameters()


% if eeglab has not run, run it so all the subdirectories get added
if ~exist('topoplot', 'file')
    eeglab
    close all
end

% same for plotting scripts, saved to a different repo (https://github.com/snipeso/chart)
if ~exist('addchARTpaths.m', 'file')
    addpath('C:\Users\colas\Projects\chART')
    addchARTpaths()
end


Paths.Code = mfilename('fullpath');
Paths.Code = fullfile(extractBefore(Paths.Analysis, '\Analysis\'));

addpath('C:\Users\Sophia Snipes\Projects\LSM_Analysis\Sleep\functions\eeg')

% get function "getContent" and then use it to loop through other folders
addpath(fullfile(Paths.Analysis, 'functions', 'general'))
Subfunctions = getContent(fullfile(Paths.Analysis, 'functions'));

for Indx_F = 1:numel(Subfunctions)
    addpath(fullfile(Paths.Analysis, 'functions',Subfunctions{Indx_F}))
end

P.Paths = Paths;