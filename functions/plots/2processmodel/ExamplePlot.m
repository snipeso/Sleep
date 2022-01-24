% This plots the classic 2 process model figure, but its now modular, so
% you can plot whichever part you want. You can just comment out the part
% you don't want.

close all
clc
clear

Format = struct();
Format.LW = 5;
Format.Color = 'k';
Format.FontSize = 14;
Format.FontName = 'Tw Cen MT';


SleepStarts = [0 24 52 80];
SleepEnds = SleepStarts + [8 4 9 1];
SleepMidpoint = 2;
StartPressure = 3;

figure('units','centimeters','position',[0 0 40, 10])

hold on
% background information
plot2process(SleepStarts, SleepEnds, SleepMidpoint, StartPressure,  'labels', Format);

% sleep pressure coloring
Format.Color = 'y';
plot2process(SleepStarts, SleepEnds, SleepMidpoint, StartPressure,  'pressure', Format);

% circadian cycle
Format.Color = 'k';
plot2process(SleepStarts, SleepEnds, SleepMidpoint, StartPressure, 'circadian',  Format);

% homeostatic curve
Format.Color = 'b';
plot2process(SleepStarts, SleepEnds, SleepMidpoint, StartPressure, 'homeostatic',  Format);


% second homeostatic curve
StartPressure = 3.5;
Format.Color = 'r';
plot2process(SleepStarts, SleepEnds, SleepMidpoint, StartPressure,  'homeostatic', Format);

legend