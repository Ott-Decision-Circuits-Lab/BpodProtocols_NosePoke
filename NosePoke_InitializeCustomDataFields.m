function NosePoke_InitializeCustomDataFields(iTrial)
%{ 
Initializing data (trial type) vectors and first values
%}

global BpodSystem
global TaskParameters

if iTrial == 1
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = NaN;
end

TrialData = BpodSystem.Data.Custom.TrialData;

% Trial data
TrialData.ChoiceLeft(iTrial) = NaN;
TrialData.EarlyWithdrawal(iTrial) = false;
TrialData.Jackpot(iTrial) = false;

TrialData.sample_length(iTrial) = NaN; % old ST
TrialData.move_time(iTrial) = NaN; % poke out from center to poke in at a side, old MT
TrialData.port_entry_delay(iTrial) = NaN;  % delay time , old DT
TrialData.false_exits(1:50,iTrial) = NaN(50,1); % old GracePeriod

TrialData.Rewarded(iTrial) = false;
TrialData.LightLeft(iTrial) = rand(1,1)<0.5;
TrialData.CenterPortRewarded(iTrial)  = false;
TrialData.CenterPortRewAmount(iTrial) = TaskParameters.GUI.CenterPortRewAmount;
TrialData.RewardAvailable(iTrial) = rand(1,1)<TaskParameters.GUI.RewardProb;

if iTrial == 1
    TrialData.RewardDelay(iTrial) = TaskParameters.GUI.DelayMean;
else
    TrialData.RewardDelay(iTrial) = abs(randn(1,1)*TaskParameters.GUI.DelaySigma + TaskParameters.GUI.DelayMean);
end

TrialData.SampleTime(iTrial) = TaskParameters.GUI.MinSampleTime;
TrialData.RandomReward(iTrial) = TaskParameters.GUI.RandomReward;
TrialData.RandomRewardProb(iTrial) = TaskParameters.GUI.RandomRewardProb;
TrialData.RandomThresholdPassed(iTrial) = rand(1) < TaskParameters.GUI.RandomRewardProb;
TrialData.RandomRewardAmount(iTrial, :) = TaskParameters.GUI.RandomRewardMultiplier*[TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount];

%% Reward Magnitude in different situations
TrialData.RewardMagnitude(:, iTrial) = [TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount]';

% depletion
%if a random reward appears - it does not disrupt the previous depletion
%train and depletion is calculated by multiplying from the normal reward
%amount and not the surprise reward amount (e.g. reward amount for all
%right choices 25 - 20 -16- 12.8 - 10.24 -8.192 - 5.2429 - 37.5 - 4.194

if TaskParameters.GUI.Deplete && iTrial > 1
    DummyRewardMag = TrialData.RewardMagnitude(:, iTrial-1);
    
    if  TrialData.ChoiceLeft(iTrial-1) == 1
        TrialData.RewardMagnitude(1, iTrial) = DummyRewardMag(1)*TaskParameters.GUI.DepleteRateLeft;
    elseif TrialData.ChoiceLeft(iTrial-1) == 0
        TrialData.RewardMagnitude(2, iTrial) = DummyRewardMag(2)*TaskParameters.GUI.DepleteRateRight;
    elseif isnan(TrialData.ChoiceLeft(iTrial-1))
        TrialData.RewardMagnitude(:, iTrial) = TrialData.RewardMagnitude(:, iTrial-1);
    end
end

% random reward - no change in state matrix, changes RewardMagnitude on a trial by trial basis

if TaskParameters.GUI.RandomReward == true && TrialData.RandomThresholdPassed(iTrial)==1
    surpriseRewardAmount = TaskParameters.GUI.rewardAmount*TaskParameters.GUI.RandomRewardMultiplier;
    TrialData.RewardMagnitude(:, iTrial) = TrialData.RewardMagnitude(:, iTrial) + surpriseRewardAmount;    
end

% light-guided - with change in state matrix, here only to for data output
if TaskParameters.GUI.LightGuided
    if TrialData.LightLeft(iTrial)
        TrialData.RewardMagnitude(2, iTrial) = 0;
    elseif ~TrialData.LightLeft(iTrial)
        TrialData.RewardMagnitude(1, iTrial) = 0;
    end
end

TrialData.RewardMagnitudeL(iTrial) = TrialData.RewardMagnitude(1, iTrial);
TrialData.RewardMagnitudeR(iTrial) = TrialData.RewardMagnitude(2, iTrial);
%% Auto-Incrementing sample time
if TaskParameters.GUI.AutoIncrSample && iTrial > 1
    History = 50; % Rat: History = 50
    Crit = 0.8; % Rat: Crit = 0.8
    if iTrial<5
        ConsiderTrials = iTrial;
    else
        ConsiderTrials = max(1,iTrial-History):1:iTrial;
    end
    ConsiderTrials = ConsiderTrials(~isnan(TrialData.ChoiceLeft(ConsiderTrials))|TrialData.EarlyWithdrawal(ConsiderTrials));
    if sum(~TrialData.EarlyWithdrawal(ConsiderTrials))/length(ConsiderTrials) > Crit % If SuccessRate > crit (80%)
        if ~TrialData.EarlyWithdrawal(iTrial-1) % If last trial is not EWD
            TrialData.SampleTime(iTrial) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,TrialData.SampleTime(iTrial-1) + TaskParameters.GUI.MinSampleIncr)); % SampleTime increased
        else % If last trial = EWD
            TrialData.SampleTime(iTrial) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,TrialData.SampleTime(iTrial-1))); % SampleTime = max(MinSampleTime or SampleTime)
        end
    elseif sum(~TrialData.EarlyWithdrawal(ConsiderTrials))/length(ConsiderTrials) < Crit/2  % If SuccessRate < crit/2 (40%)
        if TrialData.EarlyWithdrawal(iTrial-1) % If last trial = EWD
            TrialData.SampleTime(iTrial) = max(TaskParameters.GUI.MinSampleTime,min(TaskParameters.GUI.MaxSampleTime,TrialData.SampleTime(iTrial-1) - TaskParameters.GUI.MinSampleDecr)); % SampleTime decreased
        else
            TrialData.SampleTime(iTrial) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,TrialData.SampleTime(iTrial-1))); % SampleTime = max(MinSampleTime or SampleTime)
        end
    else % If crit/2 < SuccessRate < crit
        TrialData.SampleTime(iTrial) =  TrialData.SampleTime(iTrial-1); % SampleTime unchanged
    end
else
    TrialData.SampleTime(iTrial) = TaskParameters.GUI.MinSampleTime;
end

if  TaskParameters.GUI.Jackpot ==2 || TaskParameters.GUI.Jackpot ==3
    if sum(~isnan(TrialData.ChoiceLeft(1:iTrial)))>10
        TaskParameters.GUI.JackpotTime = max(TaskParameters.GUI.JackpotMin,quantile(TrialData.sample_length,0.95));
    else
        TaskParameters.GUI.JackpotTime = TaskParameters.GUI.JackpotMin;
    end
end

if iTrial > 1 && TrialData.Jackpot(iTrial-1) % If last trial is Jackpottrial
    TrialData.SampleTime(iTrial) = TrialData.SampleTime(iTrial)+0.05*TaskParameters.GUI.JackpotTime; % SampleTime = SampleTime + 5% JackpotTime
end
TaskParameters.GUI.SampleTime = TrialData.SampleTime(iTrial); % update SampleTime

%%
BpodSystem.Data.Custom.TrialData = TrialData;

end