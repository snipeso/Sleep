% filters data for analysis, ICA, and Sven's cleaning

% TEMP: run filtering on 1 file to try out different ICAs
P = prepParameters();
Path = 'D:\Data\Raw\P15\Sleep\NightPre\EEG';
File = 'P15_night1.set';
Destination = 'D:\Data\ICATEST';

OldEEG = pop_loadset(fullfile(Path, File));

Parameters = struct();

Parameters.Wake.Format = 'Wake'; % reference name
Parameters.Wake.fs = 250; % new sampling rate
Parameters.Wake.lp = 40; % low pass filter
Parameters.Wake.hp = 0.5; % high pass filter
Parameters.Wake.hp_stopband = 0.25; % high pass filter

% ICA: heavily filtered data for getting ICA components
Parameters.ICA.Format = 'ICA'; % reference name
Parameters.ICA.fs = 250; % new sampling rate
Parameters.ICA.lp = 80; % low pass filter
Parameters.ICA.hp = 2.5; % high pass filter
Parameters.ICA.hp_stopband = .5; % high pass filter


Destination_Formats = {'ICA', 'Wake'}; % chooses which filtering to do

%%

Indx_D = 9;

for Indx_DF = 2%1:numel(Destination_Formats)
    Destination_Format = Destination_Formats{Indx_DF};
    
    % set selected parameters
    new_fs = Parameters.(Destination_Format).fs;
    lowpass = Parameters.(Destination_Format).lp;
    highpass = Parameters.(Destination_Format).hp;
    hp_stopband = Parameters.(Destination_Format).hp_stopband;
    
    
    %     for Indx_D = 1:size(Folders.Datasets,1) % loop through participants
    %         for Indx_F = 1:size(Folders.Subfolders, 1) % loop through all subfolders
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %%% Check if data exists
    
    %             Path = fullfile(Paths.Datasets, Folders.Datasets{Indx_D}, Folders.Subfolders{Indx_F});
    %
    %             % skip rest if folder not found
    %             if ~exist(Path, 'dir')
    %                 warning([deblank(Path), ' does not exist'])
    %                 continue
    %             end
    %
    % identify meaningful folders traversed
    %             Levels = split(Folders.Subfolders{Indx_F}, '\');
    %             Levels(cellfun('isempty',Levels)) = []; % remove blanks
    %             Levels(strcmpi(Levels, 'EEG')) = []; % remove uninformative level that its an EEG
    %
    %             Task = Levels{1}; % task is assumed to be the first folder in the sequence
    
    % if does not contain EEG, then skip
    %             Content = ls(Path);
    %             SET = contains(string(Content), '.set');
    %             if ~any(SET)
    %                 if any(strcmpi(Levels, 'EEG')) % if there should have been an EEG file, be warned
    %                     warning([Path, ' is missing SET file'])
    %                 end
    %                 continue
    %             elseif nnz(SET) > 1 % if there's more than one set file, you'll need to fix that
    %                 warning([Path, ' has more than one SET file'])
    %                 continue
    %             end
    %
    %             Filename_SET = Content(SET, :);
    
    % set up destination location
    %             Destination = fullfile(Paths.Preprocessed, Destination_Format, 'SET', Task);
    
    %             Filename_Core = join([Folders.Datasets{Indx_D}, Levels(:)', Destination_Format], '_');
    %             Filename_Destination = [Filename_Core{1}, '.set'];
    Filename_Destination = strjoin({'P9', 'NightPre', 'Filtered', Destination_Format}, '_');
    
    %             % create destination folder
    %             if ~exist(Destination, 'dir')
    %                 mkdir(Destination)
    %             end
    
%     % skip filtering if file already exists
%     if ~Refresh && exist(fullfile(Destination, Filename_Destination), 'file')
%         disp(['***********', 'Already did ', Filename_Core, '***********'])
%         continue
%     end
    
    
    %%%%%%%%%%%%%%%%%%%
    %%% process the data
    
    %             EEG = pop_loadset('filepath', Path, 'filename', Filename_SET);
    EEG = OldEEG; % TEMP
    
    % low-pass filter
    EEG = pop_eegfiltnew(EEG, [], lowpass); % this is a form of antialiasing, but it not really needed because usually we use 40hz with 256 srate
    
    % notch filter for line noise
    EEG = lineFilter(EEG, 50, false);
    
    % resample
    EEG = pop_resample(EEG, new_fs);
    
    % high-pass filter
    % NOTE: this is after resampling, otherwise crazy slow.
    EEG = hpEEG(EEG, highpass, hp_stopband);
    
    EEG = eeg_checkset(EEG);
    
    
    % save preprocessing info in eeg structure
%     EEG.setname = Filename_Core;
%     EEG.filename = Filename_Destination;
%     EEG.original.filename = Filename_SET;
%     EEG.original.filepath = Path;
    EEG.filtering = Parameters.(Destination_Format);
    
    % save EEG
    pop_saveset(EEG, 'filename', Filename_Destination, ...
        'filepath', Destination, ...
        'check', 'on', ...
        'savemode', 'onefile', ...
        'version', '7.3');
end

disp(['************** Finished ',  Folders.Datasets{Indx_D}, '***************'])
%     end
% end