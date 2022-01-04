
P = prepParameters();
Path = 'D:\Data\ICATEST';
VISPath = fullfile(Path, 'P15_Sleep_NightPre');
[BadData, strScores] = loadVIS(VISPath);

File = 'P15_NightPre_Filtered_ICA.set';
OldEEG = pop_loadset(fullfile(Path, File));
load('StandardChanlocs128.mat','StandardChanlocs')
OldEEG.chanlocs = StandardChanlocs;

OldEEG = pop_select(OldEEG, 'nochannel', [49 56 107 113 48 119 126 127]);

OldEEG = eeg_checkset(OldEEG);
strScores_4s = reshape(repmat(strScores', 1, 5)', [], 1)'; % assigns score to each 4s epoch

Transitions = findTransitions(strScores_4s);
strScores_4s(Transitions) = nan;

EEG = rmNoise_Sleep(OldEEG, BadData);
Bad = reshape(BadData', [], 1)==49;
strScores_4s(Bad) = [];


%% get small ICA data

Keep = 3;

fs_4s = 1/4;

% 3 min wake
[Starts, Ends] = data2windows(strScores_4s=='0');
Starts = Starts-1;
Wake = pop_select(EEG, 'time', [Starts(:), Ends(:)]/fs_4s);
Filename_Destination = 'Wake.set';
pop_saveset(Wake, 'filename', Filename_Destination,  'filepath', Path, ...
    'check', 'on', 'savemode', 'onefile', 'version', '7.3');

Wake_3m = pop_select(Wake, 'time', [0, Keep*60]);
Filename_Destination = ['Wake_', num2str(Keep) 'min.set'];
pop_saveset(Wake_3m, 'filename', Filename_Destination,  'filepath', Path, ...
    'check', 'on', 'savemode', 'onefile', 'version', '7.3');

%%

Keep = 4;
Stages = {'1', '2', '3', 'r'};
Names = {'N1', 'N2', 'N3', 'REM'};
Point_Names = {'Start', 'Middle', 'End'};

for Indx_S = 1:numel(Stages)
    [Starts, Ends] = data2windows(strScores_4s==Stages{Indx_S});
    Starts = Starts-1;
    Stage = pop_select(EEG, 'time', [Starts(:), Ends(:)]/fs_4s);
    Filename_Destination = [Names{Indx_S}, '.set'];
    pop_saveset(Stage, 'filename', Filename_Destination,  'filepath', Path, ...
        'check', 'on', 'savemode', 'onefile', 'version', '7.3');

    Points = linspace(0, size(Stage.data, 2)-Keep*60*Stage.srate, 3); % first, middle and last points of data

    for Indx_P = 1:numel(Points)
        Stage_3m = pop_select(EEG, 'point', [Points(Indx_P), Points(Indx_P)+Keep*60*Stage.srate]);

        Filename_Destination = [Names{Indx_S}, '_', num2str(Keep), 'min_', Point_Names{Indx_P}, '.set'];
        pop_saveset(Stage_3m, 'filename', Filename_Destination,  'filepath', Path, ...
            'check', 'on', 'savemode', 'onefile', 'version', '7.3');
    end
end


%%


load('Cz.mat', 'CZ')
Stages = {'1', '2', '3', 'r'};
Names = {'N1', 'N2', 'N3', 'REM'};
Point_Names = {'Start', 'Middle', 'End'};

IC_Brain_Threshold = 0.1; % %confidence of automatic IC classifier in determining a brain artifact
IC_Other_Threshold = 0.6; % %confidence of automatic IC classifier in determining a brain artifact

IC_Max = 60; % limit of components automatically considered for elimination

for Indx_S = 1:numel(Stages)
    for Indx_P = 1:numel(Points)
        Filename = strjoin({Names{Indx_S}, '4min', Point_Names{Indx_P}}, '_');
        Filepath = fullfile(Path, [Filename, '.set']);
        EEG = pop_loadset(Filepath);

        % add Cz
        EEG.data(end+1, :) = zeros(1, size(EEG.data, 2));
        EEG.chanlocs(end+1) = CZ;
        EEG = eeg_checkset(EEG);

        % rereference to average
        EEG = pop_reref(EEG, []);

        % run ICA (takes a while)
        Rank = sum(eig(cov(double(EEG.data'))) > 1E-7);
        if Rank ~= size(EEG.data, 1)
            warning(['Applying PCA reduction for ', Filename])
        end

        % calculate components
        EEG = pop_runica(EEG, 'runica', 'pca', Rank);

        % classify components
        EEG = iclabel(EEG);


         EEG.reject.gcompreject = ...
        EEG.etc.ic_classification.ICLabel.classifications(:, 1)' < IC_Brain_Threshold;
    
    % switch to good any of the bad channels with "other" too high
    Other = EEG.reject.gcompreject & ...
        EEG.etc.ic_classification.ICLabel.classifications(:, end)' > IC_Other_Threshold;
    EEG.reject.gcompreject(Other) = 0;
    
    EEG.reject.gcompreject(IC_Max+1:end) = 0; % don't do anything to smaller components


        pop_saveset(EEG, 'filename', [Filename, '_ICA.set'],  'filepath', Path, ...
            'check', 'on', 'savemode', 'onefile', 'version', '7.3');
    end
end
















