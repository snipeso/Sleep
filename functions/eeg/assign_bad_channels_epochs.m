function artndxn = assign_bad_channels_epochs(artndxn, BadChannel_Threshold, BadWindow_Threshold, EdgeChannels, Chanlocs)
% from the matrix of artefacts (artndxn), carefully removes either bad
% channels or bad epochs.

%%% bad channels
BadEpochs = sum(artndxn==0, 2, 'omitnan');
badchans = BadEpochs./size(artndxn, 2) >= BadChannel_Threshold;

artndxn(badchans, :) = 0;


%%% bad epochs
Main = artndxn;

% also remove bad epochs if adjacent channels are missing
if exist("EdgeChannels", "var") && ~iempty(EdgeChannels)
    Edges = labels2indexes(EdgeChannels, Chanlocs);
    Holes = findHoles(artndxn, Chanlocs, Edges); % epochs where there are no adjacent electrodes
    Main(Edges, :) = [];
else

    Holes = zeros(1, size(artndxn, 2));
end

BadWindows = sum(Main==0)./size(Main, 1) >=BadWindow_Threshold;


% set to nan holes so they're not counted in BadSnippets
artndxn(:, Holes | BadWindows) = 0;