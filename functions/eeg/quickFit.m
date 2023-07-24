function [Slope, Intercept] = quickFit(X, Y, Plot)
% can use as quickFit(log(Freqs), log(Data))


 Coefficients = polyfit(X,Y,1);

 Slope = Coefficients(1);
 Intercept = Coefficients(2);

 if exist('Plot', 'var') && Plot

     Y1 = polyval(Coefficients, X);
     hold on
     plot(X,Y, '.', 'Color','k')
     plot(X,Y1, 'Color','red')
 end

