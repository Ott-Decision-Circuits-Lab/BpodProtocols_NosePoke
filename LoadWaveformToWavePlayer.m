function LoadWaveformToWavePlayer(ClickLength)
global BpodSystem
global TaskParameters

if nargin == 0
    ClickLength = 1; % in sampling frame
end

if ~BpodSystem.EmulatorMode
    [Player, fs] = SetupWavePlayer();
    
    % load white noise
    PunishSound = rand(1, fs*TaskParameters.GUI.EarlyWithdrawalTimeOut)*2 - 1;
    SoundIndex = 1;
    Player.loadWaveform(SoundIndex, PunishSound);
    
    % load auditory stimuli
    SoundLevel = 0.6;
    
    LeftSound = [];
    RightSound = [];
    
    if TaskParameters.GUI.PlayStimulus == 2 % click task
        [LeftSound, RightSound] = GetClickStimulus(TaskParameters.GUI.SampleTime, fs, ClickLength);
    end
    
    LeftSound = LeftSound * SoundLevel;
    RightSound = RightSound * SoundLevel;
    
    SoundIndex = 2;
    Player.loadWaveform(SoundIndex, LeftSound);

    SoundIndex = 3;
    Player.loadWaveform(SoundIndex, RightSound);

    % load error sound
    ErrorSound = [] * SoundLevel;
    SoundIndex = 4;
    Player.loadWaveform(SoundIndex, ErrorSound);

    SoundChannels = [3 1 2 3];  % Array of channels for each sound: play on left (1), right (2), or both (3)
    LoadSoundMessages(SoundChannels);
end
end