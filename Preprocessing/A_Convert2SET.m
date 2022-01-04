% creates a set file in the folder in which the sleep file is located

% TEMP

Path = 'F:\Data\Raw\P15\Sleep\NightPre\EEG';




load('StandardChanlocs128.mat', 'StandardChanlocs') % has channel locations in StandardChanlocs


 Content = ls(Path);
        VHDR = contains(string(Content), '.vhdr');
        if ~any(VHDR)
            if any(strcmpi(Levels, 'EEG'))
                warning([Path, ' is missing EEG files'])
            end
%             continue
        elseif nnz(VHDR) > 1 % or if there's more than 1 file
            warning([Path, ' has more than one eeg file'])
%             continue
        end
        
        % load EEG file
        Filename.VHDR = Content(VHDR, :);
        Filename.Core = extractBefore(Filename.VHDR, '.');
        Filename.SET = [Filename.Core, '.set'];
        

        % load EEG
        EEG = pop_loadbv(Path, Filename.VHDR);
        
        
          pop_saveset(EEG, 'filename', Filename.SET, ...
                'filepath', Path, ...
                'check', 'on', ...
                'savemode', 'onefile', ...
                'version', '7.3');