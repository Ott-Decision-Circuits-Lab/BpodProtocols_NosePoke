function NosePoke()
% Learning to Nose Poke side ports

global BpodSystem
global TaskParameters

TaskParameters = GUISetup();  % Set experiment parameters in GUISetup.m
NosePoke_PlotSideOutcome(BpodSystem.GUIHandles,'init');

if ~BpodSystem.EmulatorMode
    if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
        ChannelNumber = 4;
        [Player, ~] = SetupWavePlayer(ChannelNumber); % 25kHz =sampling rate of 8Ch with 8Ch fully on; 50kHz for 4Ch; 100kHZ for 2Ch
    elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
        [Player, ~] = SetupHiFi(192000); % 192kHz = max sampling rate
    else
        warning('Warning: To run this protocol with sound, you must first pair a Analog Output Module or a HiFi Module(hardware) with its USB port. Click the USB config button on the Bpod console.')
    end
    LoadIndependentWaveform(Player);
end

if TaskParameters.GUI.Photometry
    [FigNidaq1,FigNidaq2]=InitializeNidaq();
end

% --------------------------Main loop------------------------------ %
RunSession = true;
iTrial = 1;

while RunSession
    InitializeCustomDataFields(iTrial); % Initialize data (trial type) vectors and first values
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    if ~BpodSystem.EmulatorMode && BpodSystem.Data.Custom.AOModule
        LoadTrialDependentWaveform(Player, iTrial, 5, 2); % Load white noise, stimuli trains, and error sound to wave player if not EmulatorMode
    end    
    
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
            Nidaq2Data = [];
        end
        % save separately per trial (too large/slow to save entire history to disk)
        if BpodSystem.Status.BeingUsed ~= 0 %only when bpod still active (due to how bpod stops a protocol this would be run again after the last trial)
            [DataFolder, DataName, ~] = fileparts(BpodSystem.Path.CurrentDataFile);
            NidaqDatafolder = [DataFolder, '\', DataName];
            if ~isdie(NidaqDataFolder)
                mkdir(NidaqDataFolder)
            end
            fname = fullfile(NidaqDataFolder, ['NidaqData', num2str(iTrial),'.mat']);
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