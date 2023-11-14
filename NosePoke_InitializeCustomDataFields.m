function NosePoke_InitializeCustomDataFields(iTrial)
%{ 
Initializing trial data
%}

global BpodSystem
global TaskParameters

if iTrial == 1
    BpodSystem.Data.Custom.TrialData = struct(); % initializing .TrialData
end

TrialData = BpodSystem.Data.Custom.TrialData;

%% Pre-stimulus delivery
TrialData.NoTrialStart(iTrial) = true; % true = no state StartCIn; false = with state StartCIn.

TrialData.TimeCenterPoke(iTrial) = NaN; % Time when CIn
TrialData.BrokeFixation(iTrial) = NaN; % NaN = no state StartCIn; true = with state BrokeFixation; false = with state Sampling

TrialData.SamplingTarget(iTrial) = TaskParameters.GUI.SamplingTarget;
if TaskParameters.GUI.AutoIncrSamplingTarget
    if iTrial > 1
        History = 50; % Rat: History = 50
        Crit = 0.6; % Rat: Crit = 0.6
        ConsiderTrials = max(1,iTrial-History):1:iTrial-1;
        ConsiderTrials = ConsiderTrials(~isnan(TrialData.BrokeFixation(ConsiderTrials))); % exclude trials did not start
        NotBrokeFixationRate = sum(~TrialData.BrokeFixation(ConsiderTrials))/length(ConsiderTrials);
        
        if NotBrokeFixationRate > Crit
            if TrialData.BrokeFixation(iTrial-1) == false % If last trial is not BrokeFixation nor NaN (e.g. NoTrialStart)
                TrialData.SamplingTarget(iTrial) = TrialData.SamplingTarget(iTrial) + TaskParameters.GUI.SamplingTargetIncrStepSize; % StimulusDelay increased
            end
        elseif NotBrokeFixationRate < Crit/2
            if TrialData.BrokeFixation(iTrial-1) == true % If last trial is Broke Fixation (and not NaN)
                TrialData.SamplingTarget(iTrial) = TrialData.SamplingTarget(iTrial) - TaskParameters.GUI.SamplingTargetDecrStepSize; % StimulusDelay decreased
            end
        end
    end    
end

if TrialData.SamplingTarget(iTrial) > TaskParameters.GUI.SamplingTargetMax % allow adjustment even if StimDelayAutoIncr is off
    TrialData.SamplingTarget(iTrial) = TaskParameters.GUI.SamplingTargetMax;
elseif TrialData.SamplingTarget(iTrial) < TaskParameters.GUI.SamplingTargetMin
    TrialData.SamplingTarget(iTrial) = TaskParameters.GUI.SamplingTargetMin;
end

TaskParameters.GUI.SamplingTarget = TrialData.SamplingTarget(iTrial);
TrialData.SamplingTime(iTrial) = NaN; % Time that stayed CenterPortIn for SamplingTarget
TrialData.SamplingGrace(1,iTrial) = NaN; % old GracePeriod, row is for the n-th time the state is entered, column is for the time in this State

TrialData.CenterPortRewarded(iTrial) = NaN;
TrialData.CenterPortBaited(iTrial) = TaskParameters.GUI.CenterPortProb > rand;
TrialData.CenterPortRewardAmount(iTrial) = TaskParameters.GUI.CenterPortRewardAmount * TrialData.CenterPortBaited(iTrial);

TrialData.LightLeft(iTrial) = NaN; % if true, 1-arm bandit with left poke being correct
if TaskParameters.GUI.SingleSidePoke
    TrialData.LightLeft(iTrial) = rand < 0.5;
end

%% Peri-decision and pre-outcome
TrialData.NoDecision(iTrial) = NaN; % True if no decision made
TrialData.MoveTime(iTrial) = NaN; % from CenterPortOut to SidePortIn(or re-CenterPortIn for StartNewTrial), old MT

TrialData.ChoiceLeft(iTrial) = NaN;

TrialData.port_entry_delay(iTrial) = NaN;  % delay time , old DT
TrialData.false_exits(1:50, iTrial) = NaN(50,1); % old GracePeriod

%% Peri-outcome
if iTrial == 1
    TrialData.FeedbackDelay(iTrial) = TaskParameters.GUI.FeedbackDelayMean;
else
    TrialData.FeedbackDelay(iTrial) = abs(randn(1,1) * TaskParameters.GUI.FeedbackDelaySigma + TaskParameters.GUI.FeedbackDelayMean);
end
TrialData.FeedbackWaitingTime(iTrial) = NaN;

TrialData.SkippedFeedback(iTrial) = false;

%% Reward Magnitude in different situations
TrialData.Baited(:, iTrial) = rand(2,1) < TaskParameters.GUI.RewardProb;
if TrialData.LightLeft(iTrial) == 1 % adjustment by SingleSidePoke, i.e. old Light-guided
    TrialData.Baited(2, iTrial) = 0;
elseif TrialData.LightLeft(iTrial) == 0
    TrialData.Baited(1, iTrial) = 0;
end

if TaskParameters.GUI.BiasControlDepletion && iTrial > 1
    %{
    depletion
    if a random reward appears - it does not disrupt the previous depletion
    train and depletion is calculated by multiplying from the normal reward
    amount and not the surprise reward amount (e.g. reward amount for all
    right choices 25 - 20 -16- 12.8 - 10.24 -8.192 - 5.2429 - 37.5 - 4.194
    %}
    DummyRewardMag = TrialData.RewardMagnitude(:, iTrial-1);
    
    if  TrialData.ChoiceLeft(iTrial-1) == 1
        TrialData.RewardMagnitude(1, iTrial) = DummyRewardMag(1) * TaskParameters.GUI.LeftDepletionRate;
    elseif TrialData.ChoiceLeft(iTrial-1) == 0
        TrialData.RewardMagnitude(2, iTrial) = DummyRewardMag(2) * TaskParameters.GUI.RightDepletionRate;
    elseif isnan(TrialData.ChoiceLeft(iTrial-1))
        TrialData.RewardMagnitude(:, iTrial) = TrialData.RewardMagnitude(:, iTrial-1);
    end
else
    TrialData.RewardMagnitude(:, iTrial) = TaskParameters.GUI.RewardAmount * ones(2,1);
end

TrialData.RewardMagnitude(:, iTrial) = TrialData.RewardMagnitude(:, iTrial).* TrialData.Baited(:, iTrial);

TrialData.RewardMagnitudeL(iTrial) = TrialData.RewardMagnitude(1, iTrial);
TrialData.RewardMagnitudeR(iTrial) = TrialData.RewardMagnitude(2, iTrial);

TrialData.Rewarded(iTrial) = false;
TrialData.TimeReward(iTrial) = NaN;
TrialData.DrinkingTime(iTrial) = NaN;

%%
BpodSystem.Data.Custom.TrialData = TrialData;

end