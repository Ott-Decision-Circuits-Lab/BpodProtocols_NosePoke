function sma = StateMatrix(iTrial)

global BpodSystem
global TaskParameters

trial_data = BpodSystem.Data.Custom.TrialData;

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

LeftValve = 2^(LeftPort-1);
CenterValve = 2^(CenterPort-1);
RightValve = 2^(RightPort-1);

%% Calculate value time for ports in different situations
LeftValveTime  = GetValveTimes(trial_data.RewardMagnitude(iTrial,1), LeftPort);
if rand(1,1) <= TaskParameters.GUI.CenterPortProb && TaskParameters.GUI.Jackpot == 4
    CenterValveTime  = min([0.1,max([0.001,GetValveTimes(trial_data.CenterPortRewAmount(iTrial), CenterPort)])]);
else
    CenterValveTime=0;
end
RightValveTime  = GetValveTimes(trial_data.RewardMagnitude(iTrial,2), RightPort);

if TaskParameters.GUI.Jackpot == 3 % Decremental Jackpot reward
    JackpotFactor = max(2,10 - sum(trial_data.Jackpot)); 
else 
    JackpotFactor = 2; % Fixed Jackpot reward
end
LeftValveTimeJackpot  = JackpotFactor*GetValveTimes(trial_data.RewardMagnitude(iTrial,1), LeftPort);
RightValveTimeJackpot  = JackpotFactor*GetValveTimes(trial_data.RewardMagnitude(iTrial,2), RightPort);

%% Sound Output action
StimStartOutput = {};
StimStart2Output = {};
StimStopOutput = {};
early_withdrawal_action = {};
Incorrect_Action = {};
if ~BpodSystem.EmulatorMode
    if TaskParameters.GUI.PlayStimulus == 2 %click
        StimStartOutput = {'WavePlayer1', ['P' 3]}; %play the 4th profile
    % elseif TaskParameters.GUI.PlayStimulus == 3 %freq
    %     StimStartOutput = {};
    %     StimStopOutput = {};
    %     StimStart2Output = {};
    end

    if TaskParameters.GUI.EarlyWithdrawalNoise
        early_withdrawal_action = {'WavePlayer1', ['P' 0]}; %play the 1st profile
    end
    
    if TaskParameters.GUI.LightGuided
        Incorrect_Action = {'WavePlayer1', ['P' 4]};
    end
end

%% light guided task
LeftLight = 255;
RightLight = 255;

if TaskParameters.GUI.LightGuided 
    if trial_data.LightLeft(iTrial)
        RightLight = 0;
    elseif ~trial_data.LightLeft(iTrial)
        LeftLight = 0;
    else
        error('Light guided state matrix error');
    end
end

%% reward available?
% The followings variables are state names
RightWaitAction = 'Incorrect_Choice';
LeftWaitAction = 'Incorrect_Choice';

DelayTime = 30;
if trial_data.RewardAvailable(iTrial)
    DelayTime = trial_data.RewardDelay(iTrial);
    
    if TaskParameters.GUI.LightGuided && TaskParameters.GUI.RandomReward %dummy state added for plotting
            if trial_data.LightLeft(iTrial)
                LeftWaitAction = 'RandomReward_water_L';
            elseif ~trial_data.LightLeft(iTrial)
                RightWaitAction = 'RandomReward_water_R';
            end
    elseif TaskParameters.GUI.LightGuided && ~TaskParameters.GUI.RandomReward
            if trial_data.LightLeft(iTrial)
                LeftWaitAction = 'water_L';
            elseif ~trial_data.LightLeft(iTrial)
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
sma = SetGlobalTimer(sma,1,TaskParameters.GUI.SampleTime);
sma = SetGlobalTimer(sma,2,DelayTime);
sma = AddState(sma, 'Name', 'state_0',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'PreITI'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'PreITI',...
    'Timer', TaskParameters.GUI.PreITI,...
    'StateChangeConditions', {'Tup', 'wait_Cin'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', 0,...
    'StateChangeConditions', {CenterPortIn, 'StartSampling'},...
    'OutputActions', {strcat('PWM',num2str(CenterPort)),255});

sma = AddState(sma, 'Name', 'StartSampling',...
    'Timer', 0.01,...
    'StateChangeConditions', {'Tup', 'Sampling'},...
    'OutputActions', {'GlobalTimerTrig',1});
sma = AddState(sma, 'Name', 'Sampling',...
    'Timer', TaskParameters.GUI.SampleTime,...
    'StateChangeConditions', {CenterPortOut, 'GracePeriod','Tup','stillSampling','GlobalTimer1_End','stillSampling'},...
    'OutputActions', StimStartOutput);
sma = AddState(sma, 'Name', 'GracePeriod',...
    'Timer', TaskParameters.GUI.GracePeriod,...
    'StateChangeConditions', {CenterPortIn, 'Sampling','Tup','EarlyWithdrawal','GlobalTimer1_End','EarlyWithdrawal',LeftPortIn,'EarlyWithdrawal',RightPortIn,'EarlyWithdrawal'},...
    'OutputActions',{});

%% jackpot
if TaskParameters.GUI.Jackpot == 1 % Jackpot == none
    sma = AddState(sma, 'Name', 'stillSampling',...
        'Timer', TaskParameters.GUI.ChoiceDeadline,...
        'StateChangeConditions', {CenterPortOut, 'stop_stim','Tup','stop_stim'},...
        'OutputActions', StimStart2Output);
    sma = AddState(sma, 'Name', 'stop_stim',...
        'Timer',0.001,...
        'StateChangeConditions', {'Tup','wait_Sin'},...
        'OutputActions',[StimStopOutput {strcat('PWM',num2str(LeftPort)),255,strcat('PWM',num2str(RightPort)),255}]);
elseif TaskParameters.GUI.Jackpot == 2 || TaskParameters.GUI.Jackpot == 3 % Jackpot activated (either Fixed or Decremental)
    sma = AddState(sma, 'Name', 'stillSampling',...
        'Timer', TaskParameters.GUI.JackpotTime-TaskParameters.GUI.SampleTime,...
        'StateChangeConditions', {CenterPortOut, 'stop_stim','Tup','stillSamplingJackpot'},...
        'OutputActions', StimStart2Output);
    sma = AddState(sma, 'Name', 'stillSamplingJackpot',...
        'Timer', TaskParameters.GUI.ChoiceDeadline-TaskParameters.GUI.JackpotTime-TaskParameters.GUI.SampleTime,...
        'StateChangeConditions', {CenterPortOut, 'stop_stim_jackpot','Tup','ITI'},...
        'OutputActions', StimStart2Output);
    sma = AddState(sma, 'Name', 'stop_stim_jackpot',...
        'Timer',0.001,...
        'StateChangeConditions', {'Tup','wait_SinJackpot'},...
        'OutputActions',[StimStopOutput {strcat('PWM',num2str(LeftPort)),255,strcat('PWM',num2str(RightPort)),255}]);
    sma = AddState(sma, 'Name', 'stop_stim',...
        'Timer',0.001,...
        'StateChangeConditions', {'Tup','wait_Sin'},...
        'OutputActions',[StimStopOutput {strcat('PWM',num2str(LeftPort)),255,strcat('PWM',num2str(RightPort)),255}]);
elseif TaskParameters.GUI.Jackpot ==4 % Centre port reward
    sma = AddState(sma, 'Name', 'stillSampling',...
        'Timer', CenterValveTime,...
        'StateChangeConditions', {'Tup','lat_Go_signal'},...
        'OutputActions', [StimStopOutput {'ValveState', CenterValve}]);
    sma = AddState(sma, 'Name', 'lat_Go_signal',...
        'Timer',0.001,...
        'StateChangeConditions', {'Tup','wait_Sin'},...
        'OutputActions',{strcat('PWM',num2str(LeftPort)),LeftLight,strcat('PWM',num2str(RightPort)),RightLight});
end

%%
sma = AddState(sma, 'Name', 'wait_Sin',...
    'Timer',TaskParameters.GUI.ChoiceDeadline,...
    'StateChangeConditions', {LeftPortIn,'wait_L_start',RightPortIn,'wait_R_start','Tup','Incorrect_Choice'},...
    'OutputActions',{strcat('PWM',num2str(LeftPort)),LeftLight,strcat('PWM',num2str(RightPort)),RightLight});
sma = AddState(sma, 'Name', 'wait_L_start',...
    'Timer',0,...
    'StateChangeConditions', {'Tup','wait_L'},...
    'OutputActions',{'GlobalTimerTrig',2});
sma = AddState(sma, 'Name', 'wait_L',...
    'Timer',DelayTime,...
    'StateChangeConditions', {'Tup',LeftWaitAction,'GlobalTimer2_End',LeftWaitAction,LeftPortOut,'wait_L_grace'},...
    'OutputActions',{strcat('PWM',num2str(LeftPort)),0});
sma = AddState(sma, 'Name', 'wait_L_grace',...
    'Timer',TaskParameters.GUI.DelayGracePeriod,...
    'StateChangeConditions', {'Tup',LeftWaitAction,'GlobalTimer2_End',LeftWaitAction,LeftPortIn,'wait_L'},...
    'OutputActions',{});

sma = AddState(sma, 'Name', 'wait_R_start',...
    'Timer',0,...
    'StateChangeConditions', {'Tup','wait_R'},...
    'OutputActions',{'GlobalTimerTrig',2});
sma = AddState(sma, 'Name', 'wait_R',...
    'Timer',DelayTime,...
    'StateChangeConditions', {'Tup',RightWaitAction,'GlobalTimer2_End',RightWaitAction,RightPortOut,'wait_R_grace'},...
    'OutputActions',{strcat('PWM',num2str(RightPort)),0});
sma = AddState(sma, 'Name', 'wait_R_grace',...
    'Timer',TaskParameters.GUI.DelayGracePeriod,...
    'StateChangeConditions', {'Tup',RightWaitAction,'GlobalTimer2_End',RightWaitAction,RightPortIn,'wait_R'},...
    'OutputActions',{});

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
    'StateChangeConditions', {'Tup','ITI', LeftPortOut,  'DrinkingGraceL'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'DrinkingR',...
    'Timer', TaskParameters.GUI.DrinkingTime,...
    'StateChangeConditions', {'Tup','ITI', RightPortOut, 'DrinkingGraceR'},...
    'OutputActions', {});


sma = AddState(sma, 'Name', 'DrinkingGraceR',...
    'Timer', TaskParameters.GUI.DrinkingGrace,...
    'StateChangeConditions', {'Tup','ITI', RightPortIn, 'DrinkingR'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'DrinkingGraceL',...
    'Timer', TaskParameters.GUI.DrinkingGrace,...
    'StateChangeConditions', {'Tup','ITI', LeftPortIn, 'DrinkingL'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'wait_SinJackpot',...
    'Timer',TaskParameters.GUI.ChoiceDeadline,...
    'StateChangeConditions', {LeftPortIn,'water_LJackpot',RightPortIn,'water_RJackpot','Tup','ITI'},...
    'OutputActions',{strcat('PWM',num2str(LeftPort)),255,strcat('PWM',num2str(RightPort)),255});
sma = AddState(sma, 'Name', 'water_LJackpot',...
    'Timer', LeftValveTimeJackpot,...
    'StateChangeConditions', {'Tup','DrinkingL'},...
    'OutputActions', {'ValveState', LeftValve});
sma = AddState(sma, 'Name', 'water_RJackpot',...
    'Timer', RightValveTimeJackpot,...
    'StateChangeConditions', {'Tup','DrinkingR'},...
    'OutputActions', {'ValveState', RightValve});

sma = AddState(sma, 'Name', 'EarlyWithdrawal',...
    'Timer', TaskParameters.GUI.EarlyWithdrawalTimeOut,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', early_withdrawal_action);

sma = AddState(sma, 'Name', 'Incorrect_Choice',...
    'Timer', TaskParameters.GUI.EarlyWithdrawalTimeOut,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', Incorrect_Action);

if TaskParameters.GUI.VI
    sma = AddState(sma, 'Name', 'ITI',...
        'Timer',exprnd(TaskParameters.GUI.FI),...
        'StateChangeConditions',{'Tup','exit'},...
        'OutputActions',{});
else
    sma = AddState(sma, 'Name', 'ITI',...
        'Timer',TaskParameters.GUI.FI,...
        'StateChangeConditions',{'Tup','exit'},...
        'OutputActions',{});
end

end % StateMatrix
