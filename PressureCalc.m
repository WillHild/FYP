function pressures = PressureCalc(currents)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    c = 14.7;%278.6323;
    m = 312;
    psiToPa = 6894.75729;
    pressures = ((currents-4) * m + c)*psiToPa;
end

