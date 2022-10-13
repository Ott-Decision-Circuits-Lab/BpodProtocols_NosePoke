function InitializeCustomDataFields()
%{ 
Initializing data (trial type) vectors and first values
%}

global BpodSystem
global TaskParameters

% Trial data
BpodSystem.Data.Custom.TrialData.ChoiceLeft = NaN;
BpodSystem.Data.Custom.TrialData.SampleTime(1) = TaskParameters.GUI.MinSampleTime;
BpodSystem.Data.Custom.TrialData.EarlyWithdrawal(1) = false;
BpodSystem.Data.Custom.TrialData.Jackpot(1) = false;

BpodSystem.Data.Custom.TrialData.RandomReward=TaskParameters.GUI.RandomReward;
BpodSystem.Data.Custom.TrialData.RandomThresholdPassed(1)=0;
BpodSystem.Data.Custom.TrialData.RandomRewardProb=TaskParameters.GUI.RandomRewardProb;
BpodSystem.Data.Custom.TrialData.RandomRewardAmount=TaskParameters.GUI.RandomRewardMultiplier*[TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount];

BpodSystem.Data.Custom.TrialData.RewardMagnitude = [TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount];
BpodSystem.Data.Custom.TrialData.CenterPortRewAmount =TaskParameters.GUI.CenterPortRewAmount;
BpodSystem.Data.Custom.TrialData.Rewarded = false;
BpodSystem.Data.Custom.TrialData.CenterPortRewarded = false;
BpodSystem.Data.Custom.TrialData.GracePeriod = 0;
BpodSystem.Data.Custom.TrialData.LightLeft = rand(1,1)<0.5;
BpodSystem.Data.Custom.TrialData.RewardAvailable = rand(1,1)<TaskParameters.GUI.RewardProb;
BpodSystem.Data.Custom.TrialData.RewardDelay = TaskParameters.GUI.DelayMean;
BpodSystem.Data.Custom.TrialData = orderfields(BpodSystem.Data.Custom.TrialData);

% Session meta data
% [~,BpodSystem.Data.Custom.Rig] = system('hostname');
% [~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.Path.CurrentDataFile))));
BpodSystem.Data.Custom.SessionMeta.PsychtoolboxStartup = false;
BpodSystem.Data.Custom.SessionMeta.MaxSampleTime = 1; %only relevant for max stimulus length
% [BpodSystem.Data.Custom.SessionMeta.RightClickTrain, BpodSystem.Data.Custom.SessionMeta.LeftClickTrain] = GetClickStimulus(BpodSystem.Data.Custom.SessionMeta.MaxSampleTime);
% BpodSystem.Data.Custom.SessionMeta.FreqStimulus = GetFreqStimulus(BpodSystem.Data.Custom.SessionMeta.MaxSampleTime);

end