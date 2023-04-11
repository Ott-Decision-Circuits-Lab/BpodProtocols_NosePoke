function [FigNidaq1,FigNidaq2]=InitializeNidaq()
%% NIDAQ Initialization and Plots

global BpodSystem
global TaskParameters

if (TaskParameters.GUI.DbleFibers+TaskParameters.GUI.Isobestic405+TaskParameters.GUI.RedChannel)*TaskParameters.GUI.Photometry >1
    disp('Error - Incorrect photometry recording parameters')
    return
end

Nidaq_photometry('ini');

FigNidaq1=Online_NidaqPlot('ini','470');
if TaskParameters.GUI.DbleFibers || TaskParameters.GUI.Isobestic405 || TaskParameters.GUI.RedChannel
    FigNidaq2=Online_NidaqPlot('ini','channel2');
else
    FigNidaq2=[];
end

% temp patch for the sake of saving plots
BpodSystem.GUIHandles.Nidaq1=FigNidaq1;
BpodSystem.GUIHandles.Nidaq2=FigNidaq2;

end  % InitializeNidaq()