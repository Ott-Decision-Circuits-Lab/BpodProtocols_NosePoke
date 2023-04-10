function NosePoke()
% Learning to Nose Poke side ports

global BpodSystem
global TaskParameters
% global Player

% ------------------------Setup Stimuli--------------------------------%
% if ~BpodSystem.EmulatorMode
%     [Player, fs] = SetupWavePlayer();
%     PunishSound = rand(1, fs*TaskParameters.GUI.EarlyWithdrawalTimeOut)*2 - 1;  % white noise
%     % PunishSound = GeneratePoissonClickTrain(20, TaskParameters.GUI.SampleTime, fs, 5);
%     SoundIndex=1;
%     Player.loadWaveform(SoundIndex, PunishSound);
%     SoundChannels = [3];  % Array of channels for each sound: play on left (1), right (2), or both (3)
%     LoadSoundMessages(SoundChannels);
% end
% ---------------------------------------------------------------------%
% Configuring PulsePal
% load PulsePalParamStimulus.mat
% load PulsePalParamFeedback.mat
% BpodSystem.Data.Custom.PulsePalParamStimulus=PulsePalParamStimulus;
% BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
% clear PulsePalParamFeedback PulsePalParamStimulus
% if ~BpodSystem.EmulatorMode
%     ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
%     SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain, ones(1,length(BpodSystem.Data.Custom.RightClickTrain))*5);
%     SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain))*5); 
%     if TaskParameters.GUI.PlayStimulus == 3
%         InitiatePsychtoolbox();
%         PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.FreqStimulus);
%     end
% end

TaskParameters = GUISetup();  % Set experiment parameters in GUISetup.m
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';
InitializePlots();

if ~BpodSystem.EmulatorMode
    ChannelNumber = 4;
    [Player, fs]=SetupWavePlayer(ChannelNumber); % 25kHz =sampling rate of 8Ch with 8Ch fully on
    LoadIndependentWaveform(Player);
    LoadTriggerProfileMatrix(Player);
end
    
if TaskParameters.GUI.Photometry
    [FigNidaq1,FigNidaq2]=InitializeNidaq();
end

% --------------------------Main loop------------------------------ %
RunSession = true;
iTrial = 1;

while RunSession
    InitializeCustomDataFields(iTrial); % Initialize data (trial type) vectors and first values
    
    if ~BpodSystem.EmulatorMode
        LoadTrialDependentWaveform(Player, iTrial, 5, 2); % Load white noise, stimuli trains, and error sound to wave player if not EmulatorMode
        InitiatePsychtoolbox();
    end
    
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    sma = StateMatrix(iTrial);
    SendStateMatrix(sma);
    
    % NIDAQ Get nidaq ready to start
    if TaskParameters.GUI.Photometry
        Nidaq_photometry('WaitToStart');
    end
    
    % Run Trial
    RawEvents = RunStateMatrix;
    
    % NIDAQ Stop acquisition and save data in bpod structure
    if TaskParameters.GUI.Photometry
        Nidaq_photometry('Stop');
        [PhotoData,Photo2Data] = Nidaq_photometry('Save');
        NidaqData = PhotoData;
        if TaskParameters.GUI.DbleFibers || TaskParameters.GUI.RedChannel
            Nidaq2Data = Photo2Data;
        else
            Nidaq2Data=[];
        end
         % save separately per trial (too large/slow to save entire history to disk)
        if BpodSystem.Status.BeingUsed ~= 0 %only when bpod still active (due to how bpod stops a protocol this would be run again after the last trial)
            [DataFolder, DataName, ~] = fileparts(BpodSystem.Path.CurrentDataFile);
            NidaqDataFolder = [DataFolder, '\', DataName];
            if ~isdir(NidaqDataFolder)
                mkdir(NidaqDataFolder)
            end
            fname = fullfile(NidaqDataFolder, ['NidaqData',num2str(iTrial),'.mat']);
            save(fname,'NidaqData','Nidaq2Data')
        end
    end
   
    % Bpod save and update custom data fields for this trial
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        InsertSessionDescription(iTrial);
        UpdateCustomDataFields(iTrial);
        SaveBpodSessionData;
    end

    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.

    if BpodSystem.Status.BeingUsed == 0
        return
    end
        
    % update figures
    NosePoke_PlotSideOutcome(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    
    %% update photometry plots
    if TaskParameters.GUI.Photometry
        PlotPhotometryData(iTrial, FigNidaq1,FigNidaq2, PhotoData, Photo2Data);
    end
    
    iTrial = iTrial + 1;    
end % Main loop

clear Player % release the serial port (done automatically when function returns)

if TaskParameters.GUI.Photometry
    CheckPhotometry(PhotoData, Photo2Data);
end

end % NosePoke()