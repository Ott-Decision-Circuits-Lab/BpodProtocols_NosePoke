function UpdateCustomDataFields(iTrial)

global BpodSystem
global TaskParameters

BpodSystem.Data.TrialTypes(iTrial)=1;

%% OutcomeRecord
statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});
BpodSystem.Data.Custom.TrialData.ST(iTrial) = NaN;
BpodSystem.Data.Custom.TrialData.MT(iTrial) = NaN;
BpodSystem.Data.Custom.TrialData.DT(iTrial) = NaN;
BpodSystem.Data.Custom.TrialData.GracePeriod(1:50,iTrial) = NaN(50,1);
if any(strcmp('Sampling',statesThisTrial))
    if any(strcmp('stillSampling',statesThisTrial)) && any(strcmp('lat_Go_signal',statesThisTrial))==0
        if any(strcmp('stillSamplingJackpot',statesThisTrial))
            BpodSystem.Data.Custom.TrialData.ST(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.stillSamplingJackpot(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.StartSampling(1,1);
        else
            BpodSystem.Data.Custom.TrialData.ST(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.stillSampling(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.StartSampling(1,1);
        end
    else
            BpodSystem.Data.Custom.TrialData.ST(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.Sampling(1,end) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.StartSampling(1,1); 
    end
end

% Compute grace period:
if any(strcmp('GracePeriod',statesThisTrial))
    for nb_graceperiod =  1: size(BpodSystem.Data.RawEvents.Trial{iTrial}.States.GracePeriod,1)
        BpodSystem.Data.Custom.TrialData.GracePeriod(nb_graceperiod,iTrial) = (BpodSystem.Data.RawEvents.Trial{iTrial}.States.GracePeriod(nb_graceperiod,2)...
            -BpodSystem.Data.RawEvents.Trial{iTrial}.States.GracePeriod(nb_graceperiod,1));
    end
end  


if any(strncmp('wait_L',statesThisTrial,6))
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.TrialData.MT(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_L_start(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_Sin(1,1);
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.wait_L_start;
    BpodSystem.Data.Custom.TrialData.DT(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
elseif any(strncmp('wait_R',statesThisTrial,6))
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.TrialData.MT(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_R_start(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_Sin(1,1);
    FeedbackPortTimes = BpodSystem.Data.RawEvents.Trial{end}.States.wait_R_start;
    BpodSystem.Data.Custom.TrialData.DT(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
elseif any(strcmp('EarlyWithdrawal',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(iTrial) = true;
end



if any(strncmp('water_L',statesThisTrial,7)) 
    BpodSystem.Data.Custom.TrialData.Rewarded(iTrial) = true;
elseif any(strncmp('water_R',statesThisTrial,7)) 
    BpodSystem.Data.Custom.TrialData.Rewarded(iTrial) = true;
end

if any(strcmp('water_LJackpot',statesThisTrial)) || any(strcmp('water_RJackpot',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.Jackpot(iTrial) = true;
    BpodSystem.Data.Custom.TrialData.Rewarded(iTrial) = true;
    if any(strcmp('water_LJackpot',statesThisTrial))
        BpodSystem.Data.Custom.TrialData.MT(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.water_LJackpot(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_SinJackpot(1,1);
    elseif any(strcmp('water_LJackpot',statesThisTrial))
        BpodSystem.Data.Custom.TrialData.MT(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.water_RJackpot(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_SinJackpot(1,1);
    end
end

if any(strcmp('lat_Go_signal',statesThisTrial))
    BpodSystem.Data.Custom.TrialData.CenterPortRewarded(iTrial) = true;
end

% correct/error?
BpodSystem.Data.Custom.TrialData.Correct(iTrial) = true; %any choice is correct
if TaskParameters.GUI.LightGuided
    if BpodSystem.Data.Custom.TrialData.LightLeft(iTrial)==1 && BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial)==1
        BpodSystem.Data.Custom.TrialData.Correct(iTrial) = true;
    elseif BpodSystem.Data.Custom.TrialData.LightLeft(iTrial)==0 && BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial)==0
        BpodSystem.Data.Custom.TrialData.Correct(iTrial) = true;
    elseif BpodSystem.Data.Custom.TrialData.LightLeft(iTrial)==1 && BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial)==0
        BpodSystem.Data.Custom.TrialData.Correct(iTrial) = false;
    elseif BpodSystem.Data.Custom.TrialData.LightLeft(iTrial)==0 && BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial)==1
        BpodSystem.Data.Custom.TrialData.Correct(iTrial) = false;
    end
else
    BpodSystem.Data.Custom.TrialData.Correct(iTrial) = true;
end

% %what trials are randomly rewarded
% if any(strcmp('RandomReward_water_L',statesThisTrial)) || any(strcmp('RandomReward_water_R',statesThisTrialde))
%     BpodSystem.Data.Custom.TrialData.RandomReward(iTrial)=true;
%     BpodSystem.Data.Custom.TrialData.Rewarded(iTrial) = true;
% else
%     BpodSystem.Data.Custom.TrialData.RandomReward(iTrial)=false;
% end



%% initialize next trial values
BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial+1) = NaN;
BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(iTrial+1) = false;
BpodSystem.Data.Custom.TrialData.Jackpot(iTrial+1) = false;
BpodSystem.Data.Custom.TrialData.ST(iTrial+1) = NaN;
BpodSystem.Data.Custom.TrialData.MT(iTrial+1) = NaN;
BpodSystem.Data.Custom.TrialData.DT(iTrial+1) = NaN;
BpodSystem.Data.Custom.TrialData.Rewarded(iTrial+1) = false;
BpodSystem.Data.Custom.TrialData.CenterPortRewarded(iTrial+1) = false;
BpodSystem.Data.Custom.TrialData.GracePeriod(1:50,iTrial+1) = NaN(50,1);
BpodSystem.Data.Custom.TrialData.LightLeft(iTrial+1) = rand(1,1)<0.5;

BpodSystem.Data.Custom.TrialData.RewardAvailable(iTrial+1) = rand(1,1)<TaskParameters.GUI.RewardProb;
BpodSystem.Data.Custom.TrialData.RewardDelay(iTrial+1) = abs( randn(1,1)*TaskParameters.GUI.DelaySigma+TaskParameters.GUI.DelayMean);
BpodSystem.Data.Custom.TrialData.RandomThresholdPassed(iTrial+1)=rand(1)<TaskParameters.GUI.RandomRewardProb;

%stimuli
% if ~BpodSystem.EmulatorMode
%     if TaskParameters.GUI.PlayStimulus == 2
%         [BpodSystem.Data.Custom.SessionMeta.RightClickTrain,BpodSystem.Data.Custom.SessionMeta.LeftClickTrain] = getClickStimulus(BpodSystem.Data.Custom.SessionMeta.MaxSampleTime);
%         SendCustomPulseTrain(1, BpodSystem.Data.Custom.SessionMeta.RightClickTrain, ones(1,length(BpodSystem.Data.Custom.SessionMeta.RightClickTrain))*5);
%         SendCustomPulseTrain(2, BpodSystem.Data.Custom.SessionMeta.LeftClickTrain, ones(1,length(BpodSystem.Data.Custom.SessionMeta.LeftClickTrain))*5);
%     elseif TaskParameters.GUI.PlayStimulus == 3
%         InitiatePsychtoolbox();
%         BpodSystem.Data.Custom.SessionMeta.FreqStimulus = getFreqStimulus(BpodSystem.Data.Custom.SessionMeta.MaxSampleTime);
%         PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.SessionMeta.FreqStimulus);
%     end
% end

%jackpot time
if  TaskParameters.GUI.Jackpot ==2 || TaskParameters.GUI.Jackpot ==3
    if sum(~isnan(BpodSystem.Data.Custom.TrialData.ChoiceLeft(1:iTrial)))>10
        TaskParameters.GUI.JackpotTime = max(TaskParameters.GUI.JackpotMin,quantile(BpodSystem.Data.Custom.TrialData.ST,0.95));
    else
        TaskParameters.GUI.JackpotTime = TaskParameters.GUI.JackpotMin;
    end
end
%%
%%REWARD

%% depletion
%if a random reward appears - it does not disrupt the previous depletion
%train and depletion is calculated by multiplying from the normal reward
%amount and not the surprise reward amount (e.g. reward amount for all
%right choices 25 - 20 -16- 12.8 - 10.24 -8.192 - 5.2429 - 37.5 - 4.194

if TaskParameters.GUI.Deplete
    if BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial,:)>[TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount]
        if length(BpodSystem.Data.Custom.TrialData.ChoiceLeft)>1 && BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial)==BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial-1)
            DummyRewardMag=BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial-1,:);
        else
            DummyRewardMag=[TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount];
        end
        
    else
        DummyRewardMag=BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial,:);
    end


    if  BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) == 1 && TaskParameters.GUI.Deplete
        BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial+1,1) = DummyRewardMag(1,1)*TaskParameters.GUI.DepleteRateLeft;
        BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial+1,2) = TaskParameters.GUI.rewardAmount;
    elseif BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) == 0 && TaskParameters.GUI.Deplete
        BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial+1,2) = DummyRewardMag(1,2)*TaskParameters.GUI.DepleteRateRight;
        BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial+1,1) = TaskParameters.GUI.rewardAmount;
    elseif isnan(BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial)) && TaskParameters.GUI.Deplete
        BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial+1,:) = BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial,:);
    else
        BpodSystem.Data.Custom.TrialData.RewardMagnitude(iTrial+1,:) = [TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount];
    end
end
%center port reward amount
BpodSystem.Data.Custom.TrialData.CenterPortRewAmount(iTrial+1) =TaskParameters.GUI.CenterPortRewAmount;

%increase sample time
if TaskParameters.GUI.AutoIncrSample
    History = 50; % Rat: History = 50
    Crit = 0.8; % Rat: Crit = 0.8
    if iTrial<5
        ConsiderTrials = iTrial;
    else
        ConsiderTrials = max(1,iTrial-History):1:iTrial;
    end
    ConsiderTrials = ConsiderTrials(~isnan(BpodSystem.Data.Custom.TrialData.ChoiceLeft(ConsiderTrials))|BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(ConsiderTrials));
    if sum(~BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(ConsiderTrials))/length(ConsiderTrials) > Crit % If SuccessRate > crit (80%)
        if ~BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(iTrial) % If last trial is not EWD
            BpodSystem.Data.Custom.TrialData.SampleTime(iTrial+1) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,BpodSystem.Data.Custom.TrialData.SampleTime(iTrial) + TaskParameters.GUI.MinSampleIncr)); % SampleTime increased
        else % If last trial = EWD
            BpodSystem.Data.Custom.TrialData.SampleTime(iTrial+1) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,BpodSystem.Data.Custom.TrialData.SampleTime(iTrial))); % SampleTime = max(MinSampleTime or SampleTime)
        end
    elseif sum(~BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(ConsiderTrials))/length(ConsiderTrials) < Crit/2  % If SuccessRate < crit/2 (40%)
        if BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(iTrial) % If last trial = EWD
            BpodSystem.Data.Custom.TrialData.SampleTime(iTrial+1) = max(TaskParameters.GUI.MinSampleTime,min(TaskParameters.GUI.MaxSampleTime,BpodSystem.Data.Custom.TrialData.SampleTime(iTrial) - TaskParameters.GUI.MinSampleDecr)); % SampleTime decreased
        else
            BpodSystem.Data.Custom.TrialData.SampleTime(iTrial+1) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,BpodSystem.Data.Custom.TrialData.SampleTime(iTrial))); % SampleTime = max(MinSampleTime or SampleTime)
        end
    else % If crit/2 < SuccessRate < crit
        BpodSystem.Data.Custom.TrialData.SampleTime(iTrial+1) =  BpodSystem.Data.Custom.TrialData.SampleTime(iTrial); % SampleTime unchanged
    end
else
    BpodSystem.Data.Custom.TrialData.SampleTime(iTrial+1) = TaskParameters.GUI.MinSampleTime;
end
if BpodSystem.Data.Custom.TrialData.Jackpot(iTrial) % If last trial is Jackpottrial
    BpodSystem.Data.Custom.TrialData.SampleTime(iTrial+1) = BpodSystem.Data.Custom.TrialData.SampleTime(iTrial+1)+0.05*TaskParameters.GUI.JackpotTime; % SampleTime = SampleTime + 5% JackpotTime
end
TaskParameters.GUI.SampleTime = BpodSystem.Data.Custom.TrialData.SampleTime(iTrial+1); % update SampleTime

%send bpod status to server
% try
% script = 'receivebpodstatus.php';
% %create a common "outcome" vector
% outcome = BpodSystem.Data.Custom.TrialData.ChoiceLeft(1:iTrial); %1=left, 0=right
% outcome(BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(1:iTrial)) = 3; %early withdrawal=3
% outcome(BpodSystem.Data.Custom.TrialData.Jackpot(1:iTrial)) = 4;%jackpot=4
% SendTrialStatusToServer(script,BpodSystem.Data.Info.Rig,outcome,BpodSystem.Data.Info.Subject,BpodSystem.CurrentProtocolName);
% catch
% end

end