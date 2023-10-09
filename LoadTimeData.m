function [time, pressure, flowRate, manTemp, tankTemp] = LoadTimeData(timeDataPath)
%LOADTIMEDATA Summary of this function goes here
%   Detailed explanation goes here
timeData = table2array(readtable(timeDataPath));

time = timeData(7:end, 1) - timeData(7,1);
pressure = PressureCalc(timeData(7:end, 5));
flowRate = FlowCalc(timeData(7:end, 4));
manTemp = timeData(7:end, 2);
tankTemp = timeData(7:end, 3);
end

