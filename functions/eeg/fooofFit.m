function [Slope, Intercept] = fooofFit(X, Y, Range, Plot)
% can use as quickFit(log(Freqs), log(Data))


if ~exist("Plot", 'var')
    Plot = false;
end


Results = fooof(X, Y, Range, struct(), Plot);

Slope = -Results.aperiodic_params(2);
Intercept = Results.aperiodic_params(1);

if Plot
    fooof_plot(Results)
end