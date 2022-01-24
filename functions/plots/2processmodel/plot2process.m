function [Curve, Time] = plot2process(SleepStarts, SleepEnds, SleepMidpoint, PriorWakeHours, PlotComponent, PlotProperties)
% function for plotting elements of the 2 process model of sleep. By Sophia
% Snipes and Jelena Skorucek, 21.01.22.

% TODO
% - use sleep windows instead of seperate variable start and end
% - explain better list of hours: from 0
% - explain what format contains


% SleepStarts is a list of hours indicating the sleep onset windows.
% SleepEnds is a list the same length as SleepStarts, indicating the end of
% the sleep windows.
% SleepMidpoint is a value in hours which is the middle of the sleep period
% according to the circadian rhythm. It can be dissociated from the actual
% middle of the sleep periods specified in SleepStarts/Ends.
% StartPressure is the number of hours spent awake at timepoint 0.
% PlotComponent is a string indicating what element to plot. Options include:
% - 'circadian'
% - 'homeostatic'
% - 'pressure'
% - 'labels'
% The function returns the appropriate Curve values according to the 
% PlotComponent.
% PlotProperties ... TODO

% additional plot properties
Resolution = 2; % number of points plotted per hour
SleepLabelHeight = 0.5;
PatchAlpha = 0.3; % transparency of shading e.g. for sleep pressure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Calculate all curves

% create time vector
Windows = [SleepStarts(:)'; SleepEnds(:)'];
AllTimePoints = Windows(:);

EndTime = max(AllTimePoints);
Time = linspace(0, EndTime, Resolution*EndTime);

% create circadian curve
C = circadian(Time, SleepMidpoint);

% create homeostatic curve
S = homeostatic(Time, PriorWakeHours);


%%% Plot
switch PlotComponent
    case 'circadian'
        plot(Time, C, 'Color', PlotProperties.Color, 'LineWidth', PlotProperties.LW, 'DisplayName', 'Process C')
        Curve = C;
        
    case 'homeostatic'
        plot(Time, S, 'Color', PlotProperties.Color, 'LineWidth', PlotProperties.LW, 'DisplayName', 'Process S')
        Curve = S;
        
    case 'pressure'
        patch([Time fliplr(Time)], [C fliplr(S)], PlotProperties.Color, 'FaceAlpha', PatchAlpha, ...
            'EdgeColor', PlotProperties.Color, 'EdgeColor', 'none', 'DisplayName', 'Sleep pressure')
        
        Curve = [C(:), S(:)];
        
    case 'labels' % plot sleep/wake labels
        
        % handle if first sleep end is before a sleep start
        if SleepEnds(1) < SleepStarts(1)
            SleepStarts = [0, SleepStarts];
        end
        
        % handle if last value is a sleep start
        if SleepEnds(end) < SleepStarts(end)
            SleepEnds = [SleepEnds, EndTime];
        end
        
        % plot nights
        for Indx_S = 1:numel(SleepStarts)
            NightDuration = SleepEnds(Indx_S)-SleepStarts(Indx_S);
            rectangle('Position', [SleepStarts(Indx_S) 0 NightDuration SleepLabelHeight], ...
                'FaceColor', 'k', 'EdgeColor', 'k')
            
            if NightDuration > 1
                Midpoint = SleepStarts(Indx_S) + NightDuration/2;
                text(Midpoint, SleepLabelHeight/2, 'Sleep', 'Color', 'w', ...
                    'FontWeight', 'bold', 'FontName', PlotProperties.FontName, ...
                    'FontSize', PlotProperties.FontSize, 'HorizontalAlignment', 'center')
            end
        end
        
        % plot days
        for Indx_S = 1:numel(SleepEnds)-1
            DayDuration =  SleepStarts(Indx_S+1)-SleepEnds(Indx_S);
            
            if DayDuration > 1
                Midpoint = SleepEnds(Indx_S) + DayDuration/2;
                text(Midpoint, SleepLabelHeight/2, 'Wake', 'Color', 'k', ...
                    'FontWeight', 'bold', 'FontName', PlotProperties.FontName, ...
                    'FontSize', PlotProperties.FontSize, 'HorizontalAlignment', 'center')
            end
        end
end

% hide y axis
ax1 = gca;
ax1.YAxis.Visible = 'off';
ylim([0 5]) % temp

% plot x axis
xticks(AllTimePoints)
xticklabels(mod(AllTimePoints, 24))
xlim([0 EndTime])
xlabel('Time of day')
set(gca, 'FontSize', PlotProperties.FontSize, 'FontName', PlotProperties.FontName, 'XGrid', 'on')
set(gcf, 'Color', 'w')

end


function C = circadian(T, Midpoint)
% @ Jelena

Day = 24;

C = cos(T*2*pi*1/Day - pi*Midpoint/(Day/2));
C = C + 2;

end


function S = homeostatic(T, StartPressure)
% @ Jelena

S = T/24 + StartPressure;


end


