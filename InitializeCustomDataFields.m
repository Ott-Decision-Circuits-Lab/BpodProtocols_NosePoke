function InitializeCustomDataFields(iTrial)
%{ 
Initializing data (trial type) vectors and first values
%}

global BpodSystem
global TaskParameters

if iTrial == 1
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = NaN;
end

trial_data = BpodSystem.Data.Custom.TrialData;

% Trial data
trial_data.ChoiceLeft(iTrial) = NaN;
trial_data.EarlyWithdrawal(iTrial) = false;
trial_data.Jackpot(iTrial) = false;

trial_data.sample_length(iTrial) = NaN; % old ST
trial_data.move_time(iTrial) = NaN; % poke out from center to poke in at a side, old MT
trial_data.port_entry_delay(iTrial) = NaN;  % delay time , old DT
trial_data.false_exits(1:50,iTrial) = NaN(50,1); % old GracePeriod

trial_data.Rewarded(iTrial) = false;
trial_data.LightLeft(iTrial) = rand(1,1)<0.5;
trial_data.CenterPortRewarded(iTrial)  = false;
trial_data.CenterPortRewAmount(iTrial) = TaskParameters.GUI.CenterPortRewAmount;
trial_data.RewardAvailable(iTrial) = rand(1,1)<TaskParameters.GUI.RewardProb;

if iTrial == 1
    trial_data.RewardDelay(iTrial) = TaskParameters.GUI.DelayMean;
else
    trial_data.RewardDelay(iTrial) = abs(randn(1,1)*TaskParameters.GUI.DelaySigma + TaskParameters.GUI.DelayMean);
end

trial_data.SampleTime(iTrial) = TaskParameters.GUI.MinSampleTime;
trial_data.RandomReward(iTrial) = TaskParameters.GUI.RandomReward;
trial_data.RandomRewardProb(iTrial) = TaskParameters.GUI.RandomRewardProb;
trial_data.RandomThresholdPassed(iTrial) = rand(1) < TaskParameters.GUI.RandomRewardProb;
trial_data.RandomRewardAmount(iTrial, :) = TaskParameters.GUI.RandomRewardMultiplier*[TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount];

%% Reward Magnitude in different situations
trial_data.RewardMagnitude(:, iTrial) = [TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount]';

% depletion
%if a random reward appears - it does not disrupt the previous depletion
%train and depletion is calculated by multiplying from the normal reward
%amount and not the surprise reward amount (e.g. reward amount for all
%right choices 25 - 20 -16- 12.8 - 10.24 -8.192 - 5.2429 - 37.5 - 4.194

if TaskParameters.GUI.Deplete && iTrial > 1
    DummyRewardMag = trial_data.RewardMagnitude(:, iTrial-1);
    
    if  trial_data.ChoiceLeft(iTrial-1) == 1
        trial_data.RewardMagnitude(1, iTrial) = DummyRewardMag(1)*TaskParameters.GUI.DepleteRateLeft;
    elseif trial_data.ChoiceLeft(iTrial-1) == 0
        trial_data.RewardMagnitude(2, iTrial) = DummyRewardMag(2)*TaskParameters.GUI.DepleteRateRight;
    elseif isnan(trial_data.ChoiceLeft(iTrial-1))
        trial_data.RewardMagnitude(:, iTrial) = trial_data.RewardMagnitude(:, iTrial-1);
    end
end

% random reward - no change in state matrix, changes RewardMagnitude on a trial by trial basis

if TaskParameters.GUI.RandomReward == true && trial_data.RandomThresholdPassed(iTrial)==1
    surpriseRewardAmount = TaskParameters.GUI.rewardAmount*TaskParameters.GUI.RandomRewardMultiplier;
    trial_data.RewardMagnitude(:, iTrial) = trial_data.RewardMagnitude(:, iTrial) + surpriseRewardAmount;    
end

% light-guided - with change in state matrix, here only to for data output
if TaskParameters.GUI.LightGuided
    if trial_data.LightLeft(iTrial)
        trial_data.RewardMagnitude(2, iTrial) = 0;
    elseif ~trial_data.LightLeft(iTrial)
        trial_data.RewardMagnitude(1, iTrial) = 0;
    end
end

trial_data.RewardMagnitudeL(iTrial) = trial_data.RewardMagnitude(1, iTrial);
trial_data.RewardMagnitudeR(iTrial) = trial_data.RewardMagnitude(2, iTrial);
%% Auto-Incrementing sample time
if TaskParameters.GUI.AutoIncrSample && iTrial > 1
    History = 50; % Rat: History = 50
    Crit = 0.6; % Rat: Crit = 0.8
    if iTrial<5
        ConsiderTrials = iTrial;
    else
        ConsiderTrials = max(1,iTrial-History):1:iTrial;
    end
    ConsiderTrials = ConsiderTrials(~isnan(trial_data.ChoiceLeft(ConsiderTrials))|trial_data.EarlyWithdrawal(ConsiderTrials));
    if sum(~trial_data.EarlyWithdrawal(ConsiderTrials))/length(ConsiderTrials) > Crit % If SuccessRate > crit (80%)
        if ~trial_data.EarlyWithdrawal(iTrial-1) % If last trial is not EWD
            trial_data.SampleTime(iTrial) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,trial_data.SampleTime(iTrial-1) + TaskParameters.GUI.MinSampleIncr)); % SampleTime increased
        else % If last trial = EWD
            trial_data.SampleTime(iTrial) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,trial_data.SampleTime(iTrial-1))); % SampleTime = max(MinSampleTime or SampleTime)
        end
    elseif sum(~trial_data.EarlyWithdrawal(ConsiderTrials))/length(ConsiderTrials) < Crit/2  % If SuccessRate < crit/2 (40%)
        if trial_data.EarlyWithdrawal(iTrial-1) % If last trial = EWD
            trial_data.SampleTime(iTrial) = max(TaskParameters.GUI.MinSampleTime,min(TaskParameters.GUI.MaxSampleTime,trial_data.SampleTime(iTrial-1) - TaskParameters.GUI.MinSampleDecr)); % SampleTime decreased
        else
            trial_data.SampleTime(iTrial) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,trial_data.SampleTime(iTrial-1))); % SampleTime = max(MinSampleTime or SampleTime)
        end
    else % If crit/2 < SuccessRate < crit
        trial_data.SampleTime(iTrial) =  trial_data.SampleTime(iTrial-1); % SampleTime unchanged
    end
else
    trial_data.SampleTime(iTrial) = TaskParameters.GUI.MinSampleTime;
end

if  TaskParameters.GUI.Jackpot ==2 || TaskParameters.GUI.Jackpot ==3
    if sum(~isnan(trial_data.ChoiceLeft(1:iTrial)))>10
        TaskParameters.GUI.JackpotTime = max(TaskParameters.GUI.JackpotMin,quantile(trial_data.sample_length,0.95));
    else
        TaskParameters.GUI.JackpotTime = TaskParameters.GUI.JackpotMin;
    end
end

if iTrial > 1 && trial_data.Jackpot(iTrial-1) % If last trial is Jackpottrial
    trial_data.SampleTime(iTrial) = trial_data.SampleTime(iTrial)+0.05*TaskParameters.GUI.JackpotTime; % SampleTime = SampleTime + 5% JackpotTime
end
TaskParameters.GUI.SampleTime = trial_data.SampleTime(iTrial); % update SampleTime

trial_data = orderfields(trial_data);
BpodSystem.Data.Custom.TrialData = trial_data;

% Session meta data
% [~,BpodSystem.Data.Custom.Rig] = system('hostname');
% [~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.Path.CurrentDataFile))));
BpodSystem.Data.Custom.SessionMeta.PsychtoolboxStartup = false;
% BpodSystem.Data.Custom.SessionMeta.MaxSampleTime = 1; %only relevant for max stimulus length
% [BpodSystem.Data.Custom.SessionMeta.RightClickTrain, BpodSystem.Data.Custom.SessionMeta.LeftClickTrain] = GetClickStimulus(BpodSystem.Data.Custom.SessionMeta.MaxSampleTime);
% BpodSystem.Data.Custom.SessionMeta.FreqStimulus = GetFreqStimulus(BpodSystem.Data.Custom.SessionMeta.MaxSampleTime);

end