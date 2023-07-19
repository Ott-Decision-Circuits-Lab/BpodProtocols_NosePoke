function NosePoke_LoadWaveform(Player)
% global Player
global TaskParameters

fs = Player.SamplingRate;

if TaskParameters.GUI.EarlyWithdrawalTimeOut > 0
    PunishSound = rand(1, fs*TaskParameters.GUI.EarlyWithdrawalTimeOut)*2 - 1;
    SoundIndex = 1;
    
    if ~isempty(PunishSound)
        if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            Player.loadWaveform(SoundIndex, PunishSound);
            Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
        elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
            Player.load(SoundIndex, PunishSound);
        end
    end
end

if TaskParameters.GUI.IncorrectChoiceTimeOut > 0
    SoundLevel = 0.8;
    ErrorSound = rand(1, fs*TaskParameters.GUI.IncorrectChoiceTimeOut)*2 - 1; 
    % ErrorSound = ErrorSound * SoundLevel;
    SoundIndex = 2;
    
    if ~isempty(ErrorSound)
        if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            Player.loadWaveform(SoundIndex, ErrorSound);
            Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
        elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
            Player.load(SoundIndex, ErrorSound);
        end
    end
end 

end