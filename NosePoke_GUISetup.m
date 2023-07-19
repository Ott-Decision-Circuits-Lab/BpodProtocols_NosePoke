function TaskParameters = NosePoke_GUISetup()

global BpodSystem

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;

if isempty(fieldnames(TaskParameters))
    % general
    TaskParameters.GUI.SessionDescription = 'abc';
    TaskParameters.GUIMeta.SessionDescription.Style = 'edittext';
    TaskParameters.GUI.Ports_LMR = '123';
    TaskParameters.GUI.FI = 0.5; % (s)
    TaskParameters.GUI.PreITI=1.5;
    TaskParameters.GUI.VI = false;
    TaskParameters.GUI.DrinkingTime=0.3;
    TaskParameters.GUI.DrinkingGrace=0.05;
    TaskParameters.GUIMeta.VI.Style = 'checkbox';
    TaskParameters.GUI.ChoiceDeadline = 10;
    TaskParameters.GUI.LightGuided = 0;
    TaskParameters.GUIMeta.LightGuided.Style = 'checkbox';
    TaskParameters.GUIPanels.General = {'SessionDescription','Ports_LMR','FI','PreITI', 'VI', 'DrinkingTime'...
        'DrinkingGrace','ChoiceDeadline','LightGuided'};
    
    %"stimulus"
    TaskParameters.GUI.PlayStimulus = 1;
    TaskParameters.GUIMeta.PlayStimulus.Style = 'popupmenu';
    TaskParameters.GUIMeta.PlayStimulus.String = {'No stim.','Click stim.','Freq. stim.'};
    TaskParameters.GUI.MinSampleTime = 0.01;
    TaskParameters.GUI.MaxSampleTime = 0.6;
    TaskParameters.GUI.AutoIncrSample = true;
    TaskParameters.GUIMeta.AutoIncrSample.Style = 'checkbox';
    TaskParameters.GUI.MinSampleIncr = 0.01;
    TaskParameters.GUI.MinSampleDecr = 0.005;
    TaskParameters.GUI.EarlyWithdrawalTimeOut = 3;
    TaskParameters.GUI.EarlyWithdrawalNoise = true;
    TaskParameters.GUIMeta.EarlyWithdrawalNoise.Style='checkbox';
    TaskParameters.GUI.GracePeriod = 0;
    TaskParameters.GUI.SampleTime = TaskParameters.GUI.MinSampleTime;
    TaskParameters.GUIMeta.SampleTime.Style = 'text';
    TaskParameters.GUIPanels.Sampling = {'PlayStimulus','MinSampleTime','MaxSampleTime','AutoIncrSample','MinSampleIncr','MinSampleDecr','EarlyWithdrawalTimeOut','EarlyWithdrawalNoise','GracePeriod','SampleTime'};
    
    %Reward
    TaskParameters.GUI.rewardAmount = 25;
    TaskParameters.GUI.CenterPortRewAmount = 10;
    TaskParameters.GUI.CenterPortProb = 0.8;
    TaskParameters.GUI.RewardProb = 1;
    TaskParameters.GUI.Deplete = true;
    TaskParameters.GUIMeta.Deplete.Style = 'checkbox';
    TaskParameters.GUI.DepleteRateLeft = 0.8;
    TaskParameters.GUI.DepleteRateRight = 0.8;
    TaskParameters.GUI.RandomReward = false;
    
    TaskParameters.GUIMeta.RandomReward.Style = 'checkbox';
    TaskParameters.GUI.RandomRewardProb = 0.1;
    TaskParameters.GUI.RandomRewardMultiplier = 1;
    
    TaskParameters.GUI.Jackpot = 1;
    TaskParameters.GUIMeta.Jackpot.Style = 'popupmenu';
    TaskParameters.GUIMeta.Jackpot.String = {'No Jackpot','Fixed Jackpot','Decremental Jackpot','RewardCenterPort'};
    TaskParameters.GUI.JackpotMin = 1;
    TaskParameters.GUI.JackpotTime = 1;
    TaskParameters.GUIMeta.JackpotTime.Style = 'text';
    TaskParameters.GUIPanels.Reward = {'rewardAmount','CenterPortRewAmount','CenterPortProb','RewardProb',...
        'Deplete','DepleteRateLeft','DepleteRateRight', 'RandomReward', 'RandomRewardProb', 'RandomRewardMultiplier',...
        'Jackpot','JackpotMin','JackpotTime'};
        
    %Reward Dealy
    TaskParameters.GUI.DelayMean = 0;
    TaskParameters.GUI.DelaySigma=0;
    TaskParameters.GUI.DelayGracePeriod=0;
    TaskParameters.GUIPanels.RewardDelay = {'DelayMean','DelaySigma','DelayGracePeriod'};
    
    %% Photometry
    %photometry general
    TaskParameters.GUI.Photometry=0;
    TaskParameters.GUIMeta.Photometry.Style='checkbox';
    TaskParameters.GUI.DbleFibers=0;
    TaskParameters.GUIMeta.DbleFibers.Style='checkbox';
    TaskParameters.GUIMeta.DbleFibers.String='Auto';
    TaskParameters.GUI.Isobestic405=0;
    TaskParameters.GUIMeta.Isobestic405.Style='checkbox';
    TaskParameters.GUIMeta.Isobestic405.String='Auto';
    TaskParameters.GUI.RedChannel=1;
    TaskParameters.GUIMeta.RedChannel.Style='checkbox';
    TaskParameters.GUIMeta.RedChannel.String='Auto';    
    TaskParameters.GUIPanels.PhotometryRecording={'Photometry','DbleFibers','Isobestic405','RedChannel'};
    
    %plot photometry
    TaskParameters.GUI.TimeMin=-1;
    TaskParameters.GUI.TimeMax=15;
    TaskParameters.GUI.NidaqMin=-5;
    TaskParameters.GUI.NidaqMax=10;
    TaskParameters.GUI.SidePokeIn=1;
	TaskParameters.GUIMeta.SidePokeIn.Style='checkbox';
    TaskParameters.GUI.SidePokeLeave=1;
	TaskParameters.GUIMeta.SidePokeLeave.Style='checkbox';
    TaskParameters.GUI.RewardDelivery=1;
	TaskParameters.GUIMeta.RewardDelivery.Style='checkbox';
    
    TaskParameters.GUI.RandomRewardDelivery=1;
	TaskParameters.GUIMeta.RandomRewardDelivery.Style='checkbox';
    
    TaskParameters.GUI.BaselineBegin=0.5;
    TaskParameters.GUI.BaselineEnd=1.8;
    TaskParameters.GUIPanels.PhotometryPlot={'TimeMin','TimeMax','NidaqMin','NidaqMax','SidePokeIn','SidePokeLeave','RewardDelivery',...
        'RandomRewardDelivery', 'BaselineBegin','BaselineEnd'};
    
    %% Nidaq and Photometry
    TaskParameters.GUI.PhotometryVersion=1;
    TaskParameters.GUI.Modulation=1;
    TaskParameters.GUIMeta.Modulation.Style='checkbox';
    TaskParameters.GUIMeta.Modulation.String='Auto';
	TaskParameters.GUI.NidaqDuration=4;
    TaskParameters.GUI.NidaqSamplingRate=6100;
    TaskParameters.GUI.DecimateFactor=610;
    TaskParameters.GUI.LED1_Name='Fiber1 470-A1';
    TaskParameters.GUIMeta.LED1_Name.Style='edittext';
    TaskParameters.GUI.LED1_Amp=1;
    TaskParameters.GUI.LED1_Freq=211;
    TaskParameters.GUI.LED2_Name='Fiber1 405 / 565';
    TaskParameters.GUIMeta.LED2_Name.Style='edittext';
    TaskParameters.GUI.LED2_Amp=5;
    TaskParameters.GUI.LED2_Freq=531;
    TaskParameters.GUI.LED1b_Name='Fiber2 470-mPFC';
    TaskParameters.GUIMeta.LED1b_Name.Style='edittext';
    TaskParameters.GUI.LED1b_Amp=2;
    TaskParameters.GUI.LED1b_Freq=531;

    TaskParameters.GUIPanels.PhotometryNidaq={'PhotometryVersion','Modulation','NidaqDuration',...
                            'NidaqSamplingRate','DecimateFactor',...
                            'LED1_Name','LED1_Amp','LED1_Freq',...
                            'LED2_Name','LED2_Amp','LED2_Freq',...
                            'LED1b_Name','LED1b_Amp','LED1b_Freq'};
                        
    %% rig-specific
    TaskParameters.GUI.nidaqDev='Dev2';
    TaskParameters.GUIMeta.nidaqDev.Style='edittext';

    TaskParameters.GUIPanels.PhotometryRig={'nidaqDev'};
    
    TaskParameters.GUITabs.General = {'General','Sampling','Reward','RewardDelay'};
    TaskParameters.GUITabs.Photometry = {'PhotometryRecording','PhotometryNidaq','PhotometryPlot','PhotometryRig'};
       
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    TaskParameters.Figures.OutcomePlot.Position = [200, 200, 1000, 400];
end
BpodParameterGUI('init', TaskParameters);

end  % End function