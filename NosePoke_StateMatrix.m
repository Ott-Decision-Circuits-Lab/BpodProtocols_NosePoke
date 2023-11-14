function sma = NosePoke_StateMatrix(iTrial)

global BpodSystem
global TaskParameters

TrialData = BpodSystem.Data.Custom.TrialData;

%% Define ports
LeftPort = floor(mod(TaskParameters.GUI.Ports_LMR/100,10));
CenterPort = floor(mod(TaskParameters.GUI.Ports_LMR/10,10));
RightPort = mod(TaskParameters.GUI.Ports_LMR,10);

LeftPortOut = strcat('Port',num2str(LeftPort),'Out');
CenterPortOut = strcat('Port',num2str(CenterPort),'Out');
RightPortOut = strcat('Port',num2str(RightPort),'Out');

LeftPortIn = strcat('Port',num2str(LeftPort),'In');
CenterPortIn = strcat('Port',num2str(CenterPort),'In');
RightPortIn = strcat('Port', num2str(RightPort),'In');

LeftLight = strcat('PWM',num2str(LeftPort));
CenterLight = strcat('PWM',num2str(CenterPort));
RightLight = strcat('PWM',num2str(RightPort));

LeftValve = 2^(LeftPort-1);
CenterValve = 2^(CenterPort-1);
RightValve = 2^(RightPort-1);

%% Calculate value time for ports in different situations
LeftValveTime  = GetValveTimes(TrialData.RewardMagnitude(1, iTrial), LeftPort);
CenterValveTime = GetValveTimes(TrialData.CenterPortRewardAmount(iTrial), CenterPort);
RightValveTime = GetValveTimes(TrialData.RewardMagnitude(2, iTrial), RightPort);

%% Sound Output action
if ~BpodSystem.EmulatorMode
    if TaskParameters.GUI.PlayStimulus == 2 %click
        if BpodSystem.Data.Custom.AOModule
            StimStartOutput = {'WavePlayer1', ['P' 3]}; %play the 4th profile
        else
            StimStartOutput = {};
        end
    % elseif TaskParameters.GUI.PlayStimulus == 3 %freq
    %     StimStartOutput = {};
    %     StimStopOutput = {};
    %     StimStart2Output = {};
    end

    if TaskParameters.GUI.LightGuided
        if BpodSystem.Data.Custom.AOModule
            IncorrectChoiceAction = {'WavePlayer1', ['P' 4]};
        else
            IncorrectChoiceAction = {};
        end
    end
end

%% reward available?
% The followings variables are state names
RightWaitAction = 'IncorrectChoice';
LeftWaitAction = 'IncorrectChoice';

DelayTime = 30;
if TrialData.RewardAvailable(iTrial)
    DelayTime = TrialData.RewardDelay(iTrial);
    
    if TaskParameters.GUI.LightGuided && TaskParameters.GUI.RandomReward %dummy state added for plotting
            if TrialData.LightLeft(iTrial)
                LeftWaitAction = 'RandomReward_water_L';
            elseif ~TrialData.LightLeft(iTrial)
                RightWaitAction = 'RandomReward_water_R';
            end
    elseif TaskParameters.GUI.LightGuided && ~TaskParameters.GUI.RandomReward
            if TrialData.LightLeft(iTrial)
                LeftWaitAction = 'water_L';
            elseif ~TrialData.LightLeft(iTrial)
                RightWaitAction = 'water_R';
            end
    elseif ~TaskParameters.GUI.LightGuided && TaskParameters.GUI.RandomReward
        LeftWaitAction = 'RandomReward_water_L';
        RightWaitAction = 'RandomReward_water_R';
    elseif ~TaskParameters.GUI.LightGuided && ~TaskParameters.GUI.RandomReward
        LeftWaitAction = 'water_L';
        RightWaitAction = 'water_R';
    end
end

%% Set up state matrix    
sma = NewStateMatrix();

sma = AddState(sma, 'Name', 'PreITI',...
    'Timer', TaskParameters.GUI.PreITI,...
    'StateChangeConditions', {'Tup', 'WaitCIn'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'WaitCIn',...
    'Timer', TaskParameters.GUI.WaitCInMax,...
    'StateChangeConditions', {CenterPortIn, 'StartSampling',...
                              'Tup', 'ITI'},...
    'OutputActions', {CenterLight, 255});

sma = SetGlobalTimer(sma, 1, TaskParameters.GUI.SamplingTarget);

sma = AddState(sma, 'Name', 'StartSampling',... % dummy state for trigger GlobalTimer1
    'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'Sampling',...
                              'GlobalTimer1_End', 'StillSampling'},...
    'OutputActions', {'GlobalTimerTrig', 1});

SamplingAction = {};
switch TaskParameters.GUIMeta.Stimulus.String{TaskParameters.GUI.Stimulus}
    case 'None' % no adjustmnet needed
        
    case 'DelayDuration'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            SamplingAction = {'HiFi1', ['P' 4]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            SamplingAction = {'WavePlayer1', ['P' 4]};
        elseif BpodSystem.EmulatorMode
            disp('BpodSystem is in EmulatorMode. No Sampling Stimulus for DelayDuration is played.');
        else
            disp('Neither HiFi nor analog module is setup. No Sampling Stimulus for DelayDuration is played.');
        end
        
    case 'EndBeep'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            SamplingAction = {'HiFi1', ['P' 4]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            SamplingAction = {'WavePlayer1', ['P' 4]};
        elseif BpodSystem.EmulatorMode
            disp('BpodSystem is in EmulatorMode. No Sampling EndBeep is played.');
        else
            disp('Neither HiFi nor analog module is setup. No Sampling EndBeep is played.');
        end
        
end
sma = AddState(sma, 'Name', 'Sampling',...
    'Timer', TaskParameters.GUI.SamplingTarget,...
    'StateChangeConditions', {CenterPortOut, 'SamplingGrace',...
                              'Tup', 'StillSampling',...
                              'GlobalTimer1_End', 'StillSampling'},...
    'OutputActions', SamplingAction);

sma = AddState(sma, 'Name', 'SamplingGrace',...
    'Timer', TaskParameters.GUI.SamplingGrace,...
    'StateChangeConditions', {CenterPortIn, 'Sampling',...
                              'Tup', 'EarlyWithdrawal',...
                              'GlobalTimer1_End', 'BrokeFixation',...
                              LeftPortIn, 'BrokeFixation',...
                              RightPortIn, 'BrokeFixation'},...
    'OutputActions', {});

BrokeFixationAction = {};
switch TaskParameters.GUIMeta.BrokeFixationFeedback.String{TaskParameters.GUI.BrokeFixationFeedback}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            BrokeFixationAction = {'HiFi1', ['P' 0]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            BrokeFixationAction = {'WavePlayer1', ['P' 0]};
        elseif BpodSystem.EmulatorMode
            disp('BpodSystem is in EmulatorMode. No BrokeFixation WhiteNoise is played.');
        else
            disp('Neither HiFi nor analog module is setup. No BrokeFixation WhiteNoise is played.');
        end
        
end
sma = AddState(sma, 'Name', 'BrokeFixation',...
    'Timer', TaskParameters.GUI.BrokeFixationTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', BrokeFixationAction);

%% light guided task
LeftLightValue = 255;
RightLightValue = 255;
if TaskParameters.GUI.LightGuided 
    if TrialData.LightLeft(iTrial) == 1
        RightLightValue = 0;
    elseif TrialData.LightLeft(iTrial) == 0
        LeftLightValue = 0;
    end
end

%% jackpot
if TaskParameters.GUI.Jackpot == 1 % Jackpot == none
    sma = AddState(sma, 'Name', 'StillSampling',...
        'Timer', TaskParameters.GUI.ChoiceDeadline,...
        'StateChangeConditions', {CenterPortOut, 'stop_stim', 'Tup', 'stop_stim'},...
        'OutputActions', StimStart2Output);
    
    sma = AddState(sma, 'Name', 'stop_stim',...
        'Timer', 0.001,...
        'StateChangeConditions', {'Tup', 'WaitSIn'},...
        'OutputActions', [StimStopOutput {LeftLight, LeftLightValue, RightLight, RightLightValue}]);
    
elseif TaskParameters.GUI.Jackpot == 2 || TaskParameters.GUI.Jackpot == 3 % Jackpot activated (either Fixed or Decremental)
    sma = AddState(sma, 'Name', 'StillSampling',...
        'Timer', TaskParameters.GUI.JackpotTime - TaskParameters.GUI.SampleTime,...
        'StateChangeConditions', {CenterPortOut, 'stop_stim', 'Tup', 'stillSamplingJackpot'},...
        'OutputActions', StimStart2Output);
    
    sma = AddState(sma, 'Name', 'StillSamplingJackpot',...
        'Timer', TaskParameters.GUI.ChoiceDeadline - TaskParameters.GUI.JackpotTime - TaskParameters.GUI.SampleTime,...
        'StateChangeConditions', {CenterPortOut, 'stop_stim_jackpot', 'Tup', 'ITI'},...
        'OutputActions', StimStart2Output);
    
    sma = AddState(sma, 'Name', 'stop_stim_jackpot',...
        'Timer', 0.001,...
        'StateChangeConditions', {'Tup', 'WaitSInJackpot'},...
        'OutputActions', [StimStopOutput {LeftLight, LeftLightValue, RightLight, RightLightValue}]);
    
    sma = AddState(sma, 'Name', 'stop_stim',...
        'Timer', 0.001,...
        'StateChangeConditions', {'Tup', 'WaitSIn'},...
        'OutputActions', [StimStopOutput {LeftLight, LeftLightValue, RightLight, RightLightValue}]);
    
elseif TaskParameters.GUI.Jackpot == 4 % Centre port reward
    sma = AddState(sma, 'Name', 'StillSampling',...
        'Timer', CenterValveTime,...
        'StateChangeConditions', {'Tup', 'lat_Go_signal'},...
        'OutputActions', [StimStopOutput {'ValveState', CenterValve}]);
    
    sma = AddState(sma, 'Name', 'lat_Go_signal',...
        'Timer', 0.001,...
        'StateChangeConditions', {'Tup', 'WaitSIn'},...
        'OutputActions', {LeftLight, LeftLightValue, RightLight, RightLightValue});
end

%%
sma = AddState(sma, 'Name', 'WaitSIn',...
    'Timer', TaskParameters.GUI.ChoiceDeadline,...
    'StateChangeConditions', {LeftPortIn, 'wait_L_start',...
                              RightPortIn, 'wait_R_start',...
                              'Tup', 'IncorrectChoice'},...
    'OutputActions', {LeftLight, LeftLightValue, RightLight, RightLightValue});

sma = SetGlobalTimer(sma, 2, DelayTime);

sma = AddState(sma, 'Name', 'wait_L_start',... % dummy state for trigger GlobalTimer2
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'wait_L'},...
    'OutputActions', {'GlobalTimerTrig', 2});

sma = AddState(sma, 'Name', 'wait_L',...
    'Timer', DelayTime,...
    'StateChangeConditions', {'Tup', LeftWaitAction,...
                              'GlobalTimer2_End', LeftWaitAction,...
                              LeftPortOut, 'wait_L_grace'},...
    'OutputActions', {LeftLight, 0});

sma = AddState(sma, 'Name', 'wait_L_grace',...
    'Timer', TaskParameters.GUI.DelayGracePeriod,...
    'StateChangeConditions', {'Tup', LeftWaitAction,...
                              'GlobalTimer2_End', LeftWaitAction,...
                              LeftPortIn, 'wait_L'},...
    'OutputActions',{});

sma = AddState(sma, 'Name', 'wait_R_start',... % dummy state for trigger GlobalTimer1
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'wait_R'},...
    'OutputActions', {'GlobalTimerTrig', 2});

sma = AddState(sma, 'Name', 'wait_R',...
    'Timer', DelayTime,...
    'StateChangeConditions', {'Tup', RightWaitAction,...
                              'GlobalTimer2_End', RightWaitAction,...
                              RightPortOut, 'wait_R_grace'},...
    'OutputActions', {RightLight, 0});

sma = AddState(sma, 'Name', 'wait_R_grace',...
    'Timer', TaskParameters.GUI.DelayGracePeriod,...
    'StateChangeConditions', {'Tup', RightWaitAction,...
                              'GlobalTimer2_End', RightWaitAction,...
                              RightPortIn, 'wait_R'},...
    'OutputActions', {});

%% water rewards and grace period for drinking
%dummy states for photometry alignment
sma = AddState(sma, 'Name', 'RandomReward_water_L',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','water_L'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'RandomReward_water_R',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','water_R'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'water_L',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','DrinkingL'},...
    'OutputActions', {'ValveState', LeftValve});

sma = AddState(sma, 'Name', 'water_R',...
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','DrinkingR'},...
    'OutputActions', {'ValveState', RightValve});

sma = AddState(sma, 'Name', 'DrinkingL',...
    'Timer', TaskParameters.GUI.DrinkingTime,...
    'StateChangeConditions', {'Tup', 'ITI', LeftPortOut,  'DrinkingGraceL'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'DrinkingR',...
    'Timer', TaskParameters.GUI.DrinkingTime,...
    'StateChangeConditions', {'Tup', 'ITI', RightPortOut, 'DrinkingGraceR'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'DrinkingGraceR',...
    'Timer', TaskParameters.GUI.DrinkingGrace,...
    'StateChangeConditions', {'Tup', 'ITI', RightPortIn, 'DrinkingR'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'DrinkingGraceL',...
    'Timer', TaskParameters.GUI.DrinkingGrace,...
    'StateChangeConditions', {'Tup', 'ITI', LeftPortIn, 'DrinkingL'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'WaitSInJackpot',...
    'Timer', TaskParameters.GUI.ChoiceDeadline,...
    'StateChangeConditions', {LeftPortIn, 'water_LJackpot',...
                              RightPortIn, 'water_RJackpot',...
                              'Tup', 'ITI'},...
    'OutputActions', {LeftLight, 255, RightLight, 255});

sma = AddState(sma, 'Name', 'water_LJackpot',...
    'Timer', LeftValveTimeJackpot,...
    'StateChangeConditions', {'Tup', 'DrinkingL'},...
    'OutputActions', {'ValveState', LeftValve});

sma = AddState(sma, 'Name', 'water_RJackpot',...
    'Timer', RightValveTimeJackpot,...
    'StateChangeConditions', {'Tup','DrinkingR'},...
    'OutputActions', {'ValveState', RightValve});

IncorrectChoiceAction = {};
if TaskParameters.GUI.LightGuided
    if BpodSystem.Data.Custom.SessionMeta.AOModule
        IncorrectChoiceAction = {'WavePlayer1', ['P' 4]};
    elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
        IncorrectChoiceAction = {'WavePlayer1', ['P' 4]};
    elseif BpodSystem.EmulatorMode
        IncorrectChoiceAction = {};
    else
        error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
    end
end
sma = AddState(sma, 'Name', 'IncorrectChoice',...
    'Timer', TaskParameters.GUI.EarlyWithdrawalTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', IncorrectChoiceAction);

ITITimer = TaskParameters.GUI.ITI;
if TaskParameters.GUI.VI
    ITITimer = exprnd(TaskParameters.GUI.ITI);
end
sma = AddState(sma, 'Name', 'ITI',...
    'Timer', ITITimer,...
    'StateChangeConditions', {'Tup', 'exit'},...
    'OutputActions', {});

end % StateMatrix