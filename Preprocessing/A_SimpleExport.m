% Sorts files by relevant folder, and applies selected preprocessing to
% selected task batch.

% close all
clc
clear
P = prepParameters();
Paths = P.Paths;
Folders = P.RawFolders;
new_fs = 200;
lowpass = new_fs/2; % just for anti-aliasing
Channels = [24 36 70 83 104 124];
Labels = ["F3", "C3", "O1", "O2", "C4" "F4"];

Reference = [57 100];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Task = 'Sleep'; % select this if you only need to filter one folder
% Tasks = allTasks;

Destination_Format = 'Simple'; % chooses which filtering to do
% options: 'Scoring', 'Cutting', 'ICA', 'Power'

Refresh = false; % redo files that are already in destination folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Consider only relevant subfolders
Folders.Subfolders(~contains(Folders.Subfolders, Task)) = [];
Folders.Subfolders(~contains(Folders.Subfolders, 'EEG')) = [];

[Channels, Order] = sort(Channels); % make sure in order, to avoid problems
Labels = Labels(Order);

for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders

        %%%%%%%%%%%%%%%%%%%%%%%%
        %%% Check if data exists

        Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});

        % skip rest if folder not found
        if ~exist(Path, 'dir')
            warning([deblank(Path), ' does not exist'])
            continue
        end

        % identify meaningful folders traversed
        Levels = split(Folders.Subfolders{Indx_F}, '\');
        Levels(cellfun('isempty',Levels)) = []; % remove blanks
        Levels(strcmpi(Levels, 'EEG')) = []; % remove uninformative level that its an EEG

        Task = Levels{1}; % task is assumed to be the first folder in the sequence

        % if does not contain EEG, then skip
        Content = ls(Path);
        SET = contains(string(Content), '.set');
        if ~any(SET)
            if any(strcmpi(Levels, 'EEG')) % if there should have been an EEG file, be warned
                %%% ELIAS: you remove the EEG information from Levels in line 55
                %%% so you would never enter this if statement, no?
                warning([Path, ' is missing SET file'])
            end
            continue
        elseif nnz(SET) > 1 % if there's more than one set file, you'll need to fix that
            warning([Path, ' has more than one SET file'])
            continue
        end

        Filename_SET = Content(SET, :);

        % set up destination location
        Destination = fullfile(Paths.Preprocessed, Destination_Format, Task);
        Filename_Core = join([Folders.Datasets{Indx_D}, Levels(:)'], '_');
        Filename_Destination = [Filename_Core{1}, '.mat'];

        % create destination folder
        if ~exist(Destination, 'dir')
            mkdir(Destination)
        end

        % skip filtering if file already exists
        if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
            disp(['***********', 'Already did ', Filename_Core, '***********'])
            continue
        end


        %%%%%%%%%%%%%%%%%%%
        %%% process the data

        EEG = pop_loadset('filepath', Path, 'filename', Filename_SET);
        Original = EEG; % TEMP

        % get mastoid channels
        Refs = mean(EEG.data(Reference, :), 1);

        % select only subset of channels
        EEG = pop_select(EEG, 'channel', Channels);
        for Indx_Ch = 1:numel(Channels) % relabel
            EEG.chanlocs(Indx_Ch).labels = Labels(Indx_Ch);
        end

        % re-reference to mastoids
        EEG.data = EEG.data - Refs;
        EEG.ref = Reference;

        % low-pass filter
        EEG = pop_eegfiltnew(EEG, [], lowpass); % this is a form of antialiasing, but it not really needed because usually we use 40hz with 256 srate

        % notch filter for line noise
        EEG = lineFilter(EEG, 50, false);

        % resample
        EEG = pop_resample(EEG, new_fs);

        EEG = eeg_checkset(EEG);


        % save preprocessing info in eeg structure
        EEG.setname = Filename_Core{1};
        EEG.filename = Filename_Destination;
        EEG.original.filename = Filename_SET;
        EEG.original.filepath = Path;
        EEG.filtering = lowpass;

        % get preprocessing info
        NoisePath = fullfile(Paths.Core, 'Outliers', Task, [Filename_Core{1}, '_Cutting_artndxn.mat']);
        try
        load(NoisePath, 'artndxn', 'scoringlen', 'visnum');
        artndxn = artndxn(Channels, :);
        catch
            continue
        end

        % save EEG
        save(fullfile(Destination, Filename_Destination), 'EEG', 'artndxn', 'scoringlen', 'visnum')
    end


    disp(['************** Finished ',  Folders.Datasets{Indx_D}, '***************'])
end