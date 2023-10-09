function pressures = PressureCalc(currents)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    c = 278.6323;
    m = 18.93263;
    psiToPa = 6894.75729;
    pressures = (currents * m + c)*psiToPa;
end

