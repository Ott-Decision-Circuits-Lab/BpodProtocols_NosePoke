function NosePoke_LoadWaveform(Player, Mode, iTrial)
% EarlyWithdrawalSound -> Sound Index 1
% NoDecisionSound      -> 2
% IncorrectChoiceSound -> 3
% SkippedFeedbackSound -> 4 (Not implement yet}
% Sound Index 5 onwards are reserved for trial-dependent waveform (Max index for HiFi: 20; for Analog: 64)

global BpodSystem
global TaskParameters

if nargin < 3
    iTrial = 0;
end

% load auditory stimuli
fs = Player.SamplingRate;

switch Mode
    case 'TrialIndependent'
        %%
        SoundIndex = 1;
        EarlyWithdrawalSound = [];
        if isfield(TaskParameters.GUI, 'EarlyWithdrawalTimeOut') && TaskParameters.GUI.EarlyWithdrawalTimeOut > 0
            switch TaskParameters.GUIMeta.EarlyWithdrawalFeedback.String{TaskParameters.GUI.EarlyWithdrawalFeedback}
                case 'None' % no adjustment

                case 'WhiteNoise'
                    EarlyWithdrawalSound = rand(1, fs*TaskParameters.GUI.EarlyWithdrawalTimeOut)*2 - 1;
            end
        end

        if ~isempty(EarlyWithdrawalSound)
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, EarlyWithdrawalSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
                Player.load(SoundIndex, EarlyWithdrawalSound);
            end
        end

        %%
        SoundIndex = 2;
        NoDecisionSound = [];
        if isfield(TaskParameters.GUI, 'NoDecisionTimeOut') && TaskParameters.GUI.NoDecisionTimeOut > 0
            switch TaskParameters.GUIMeta.NoDecisionFeedback.String{TaskParameters.GUI.NoDecisionFeedback}
                case 'None' % no adjustment

                case 'WhiteNoise'
                    NoDecisionSound = rand(1, fs*TaskParameters.GUI.NoDecisionTimeOut)*2 - 1;
            end
        end

        if ~isempty(NoDecisionSound)
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, NoDecisionSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
                Player.load(SoundIndex, NoDecisionSound);
            end
        end

        %%
        SoundIndex = 3;
        IncorrectChoiceSound = [];
        if isfield(TaskParameters.GUI, 'IncorrectChoiceTimeOut') && TaskParameters.GUI.IncorrectChoiceTimeOut > 0
            switch TaskParameters.GUIMeta.IncorrectChoiceFeedback.String{TaskParameters.GUI.IncorrectChoiceFeedback}
                case 'None' % no adjustment

                case 'WhiteNoise'
                    IncorrectChoiceSound = rand(1, fs*TaskParameters.GUI.IncorrectChoiceTimeOut)*2 - 1;
            end
        end

        if ~isempty(IncorrectChoiceSound)
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, IncorrectChoiceSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
                Player.load(SoundIndex, IncorrectChoiceSound);
            end
        end
        
        %% (NOT IMPLEMENT YET)
        SoundIndex = 4;
        SkippedFeedbackSound = [];

    case 'TrialDependent'
        %%
        SoundIndex = 5;

end % end switch
end % end function