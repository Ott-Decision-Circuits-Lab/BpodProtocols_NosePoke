function NosePoke_PlotSideOutcome(AxesHandles, Action, varargin)
global BpodSystem
global TaskParameters
global nTrialsToShow %this is for convenience

% colour palette (suitable for most colourblind people)
scarlet = [254, 60, 60]/255; % for incorrect/unbaited sign, contracting with azure
denim = [31, 54, 104]/255; % mainly for neutral signs
azure = [0, 162, 254]/255; % for rewarded sign

neon_green = [26, 255, 26]/255; % for NotBaited
neon_purple = [168, 12, 180]/255; % for SkippedBaited

sand = [225, 190 106]/255; % for left-right
turquoise = [64, 176, 166]/255;

switch Action
    case 'init'
        %% initialize Outcome Figure
        BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position + [-100, 400, 800, -050],...
                                                               'name', 'Outcome plot',...
                                                               'numbertitle', 'off',...
                                                               'MenuBar', 'none',...
                                                               'Resize', 'off');
        BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',      [  .055          .15 .91 .3]);
        BpodSystem.GUIHandles.OutcomePlot.HandleGracePeriod = axes('Position',  [1*.05           .6  .1  .3], 'Visible', 'off');
        BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',    [3*.05 + 2*.08   .6  .1  .3], 'Visible', 'off');
        BpodSystem.GUIHandles.OutcomePlot.HandleSampleTime = axes('Position',   [5*.05 + 4*.08   .6  .1  .3], 'Visible', 'off');
        BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime = axes('Position',     [7*.05 + 6*.08   .6  .1  .3], 'Visible', 'off');
        
        nTrialsToShow = 90; %default number of trials to display
        if nargin >= 3 %custom number of trials
            nTrialsToShow =varargin{1};
        end
        
        AxesHandles = BpodSystem.GUIHandles.OutcomePlot;
        
        %% Outcome Plot
        axes(AxesHandles.HandleOutcome);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle = line(-1, 0.5,...
                                                                    'LineStyle', 'none', 'Marker', 'o',...
                                                                    'MarkerEdge', 'k', 'MarkerFace', [1 1 1], 'MarkerSize', 6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross = line(-1, 0.5,...
                                                                   'LineStyle', 'none', 'Marker', '+',...
                                                                   'MarkerEdge', 'k', 'MarkerFace', [1 1 1], 'MarkerSize', 6);
        BpodSystem.GUIHandles.OutcomePlot.RewardedL = line(-1, 1,...
                                                           'LineStyle', 'none', 'Marker', 'o',...
                                                           'MarkerEdge', 'g', 'MarkerFace', 'g', 'MarkerSize', 6);
        BpodSystem.GUIHandles.OutcomePlot.RewardedR = line(-1, 0,...
                                                           'LineStyle', 'none', 'Marker', 'o',...
                                                           'MarkerEdge', 'g', 'MarkerFace', 'g', 'MarkerSize', 6);
%         BpodSystem.GUIHandles.OutcomePlot.SurpriseR = line(-1, 1, 'LineStyle', 'none', 'Marker', '+', 'MarkerEdge', 'r', 'MarkerFace', 'r', 'MarkerSize', 6);
%         BpodSystem.GUIHandles.OutcomePlot.SurpriseL = line(-1, 0, 'LineStyle', 'none', 'Marker', '+', 'MarkerEdge', 'r', 'MarkerFace', 'r', 'MarkerSize', 6);
        
        BpodSystem.GUIHandles.OutcomePlot.UnrewardedL = line(-1, 1,...
                                                             'LineStyle', 'none', 'Marker', 'o',...
                                                             'MarkerEdge', scarlet, 'MarkerFace', scarlet, 'MarkerSize', 6);
        BpodSystem.GUIHandles.OutcomePlot.UnrewardedR = line(-1, 0,...
                                                             'LineStyle', 'none', 'Marker', 'o',...
                                                             'MarkerEdge', scarlet, 'MarkerFace', scarlet, 'MarkerSize', 6);
        BpodSystem.GUIHandles.OutcomePlot.NoDecision =line(-1, 0.5, ...
                                                           'LineStyle', 'none', 'Marker', 'o', ...
                                                           'MarkerEdge', scarlet, 'MarkerFace', 'w', 'MarkerSize', 6);

        BpodSystem.GUIHandles.OutcomePlot.SkippedL =  line(-1, 1,...
                                                           'LineStyle', 'none', 'Marker', 'o',...
                                                           'MarkerEdge', 'w', 'MarkerFace', 'w', 'MarkerSize', 4);
        BpodSystem.GUIHandles.OutcomePlot.SkippedR = line(-1, -1,...
                                                          'LineStyle', 'none', 'Marker', 'o',...
                                                          'MarkerEdge', 'w', 'MarkerFace', 'w', 'MarkerSize', 4);

        BpodSystem.GUIHandles.OutcomePlot.BrokeFixation = line(-1, 0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);

%         BpodSystem.GUIHandles.OutcomePlot.Jackpot = line(-1,0, 'LineStyle','none','Marker','x','MarkerEdge','r','MarkerFace','r', 'MarkerSize',7);
        BpodSystem.GUIHandles.OutcomePlot.CumRwd = text(1, 1, '0 microL',...
                                                        'verticalalignment', 'bottom',...
                                                        'horizontalalignment', 'center');
        set(AxesHandles.HandleOutcome,...
            'TickDir', 'out',...
            'YLim', [-1, 2],...
            'XLim',[0,nTrialsToShow],...
            'YTick', [0 1],...
            'YTickLabel', {'Right','Left'},...
            'FontSize', 16);
        xlabel(AxesHandles.HandleOutcome,...
               'Trial#', 'FontSize', 18);
        hold(AxesHandles.HandleOutcome, 'on');
        
        %% Trial rate
        hold(AxesHandles.HandleTrialRate, 'on')
        BpodSystem.GUIHandles.OutcomePlot.TrialRate = line(AxesHandles.HandleTrialRate, [0], [0], 'LineStyle', '-', 'Color', 'k', 'Visible', 'on'); %#ok<NBRAK>
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'Trial Counts';
        AxesHandles.HandleTrialRate.Title.String = 'Trial Start Rate';

        %% GracePeriod histogram
        hold(AxesHandles.HandleGracePeriod, 'on')
        AxesHandles.HandleGracePeriod.XLabel.String = 'Time (ms)';
        AxesHandles.HandleGracePeriod.YLabel.String = 'Trial Counts';
        AxesHandles.HandleGracePeriod.Title.String = 'GracePeriod duration';
        
        %% ST histogram
        hold(AxesHandles.HandleSampleTime, 'on')
        AxesHandles.HandleSampleTime.XLabel.String = 'Time (ms)';
        AxesHandles.HandleSampleTime.YLabel.String = 'Trial Counts';
        AxesHandles.HandleSampleTime.Title.String = 'Sampling Time';
        
        %% MT histogram
        hold(AxesHandles.HandleMoveTime, 'on')
        AxesHandles.HandleMoveTime.XLabel.String = 'Time (ms)';
        AxesHandles.HandleMoveTime.YLabel.String = 'Trial Counts';
        AxesHandles.HandleMoveTime.Title.String = 'Movement Time';
        
    case 'UpdateTrial'

    case 'UpdateResult'
        
        CurrentTrial = varargin{1};
        ChoiceLeft = BpodSystem.Data.Custom.TrialData.ChoiceLeft;
        Rewarded =  BpodSystem.Data.Custom.TrialData.Rewarded;
        IncorrectChoice =  BpodSystem.Data.Custom.TrialData.IncorrectChoice;
        
        % recompute xlim
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,CurrentTrial,nTrialsToShow);
        
        %Cumulative Reward Amount
        RewardTotal = CalculateCumulativeReward();
        set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, ...
            'position', [CurrentTrial+1 1], ...
            'string', [num2str(RewardTotal) ' microL']);
        
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle,...
            'xdata', CurrentTrial, ...
            'ydata', .5);
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross,...
            'xdata', CurrentTrial, ...
            'ydata', .5);
       
        %Plot past trials
        if ~isempty(ChoiceLeft)
            indxToPlot = mn:CurrentTrial;

            %Plot correct Left
            ndxRwdL = ChoiceLeft(indxToPlot) == 1 & IncorrectChoice(indxToPlot) == 0;
            Xdata = indxToPlot(ndxRwdL);
            Ydata = ones(1,sum(ndxRwdL));
            set(BpodSystem.GUIHandles.OutcomePlot.RewardedL, 'xdata', Xdata, 'ydata', Ydata);

            %Plot correct Right
            ndxRwdR = ChoiceLeft(indxToPlot) == 0  & IncorrectChoice(indxToPlot) == 0;
            Xdata = indxToPlot(ndxRwdR);
            Ydata = zeros(1,sum(ndxRwdR));
            set(BpodSystem.GUIHandles.OutcomePlot.RewardedR, 'xdata', Xdata, 'ydata', Ydata);
            
%             if TaskParameters.GUI.RandomReward ==true
%                 %Plot surprise Left
%                 ndxRwdL = ChoiceLeft(indxToPlot) == 1 & IncorrectChoice(indxToPlot) == 1 & BpodSystem.Data.Custom.TrialData.RandomThresholdPassed(indxToPlot)==1;
%                 Xdata = indxToPlot(ndxRwdL);
%                 Ydata = ones(1,sum(ndxRwdL));
%                 set(BpodSystem.GUIHandles.OutcomePlot.SurpriseL, 'xdata', Xdata, 'ydata', Ydata);
% 
%                 %Plot surprise Right
%                 ndxRwdR = ChoiceLeft(indxToPlot) == 0  & IncorrectChoice(indxToPlot) == 1 & BpodSystem.Data.Custom.TrialData.RandomThresholdPassed(indxToPlot)==1;
%                 Xdata = indxToPlot(ndxRwdR);
%                 Ydata = zeros(1,sum(ndxRwdR));
%                 set(BpodSystem.GUIHandles.OutcomePlot.SurpriseR, 'xdata', Xdata, 'ydata', Ydata);
%             end
            
            %Plot error left
            ndxRwdL = ChoiceLeft(indxToPlot) == 1  & IncorrectChoice(indxToPlot) == 1;
            Xdata = indxToPlot(ndxRwdL);
            Ydata = ones(1, sum(ndxRwdL));
            set(BpodSystem.GUIHandles.OutcomePlot.UnrewardedL,...
                'xdata', Xdata, ...
                'ydata', Ydata);      
            
            %Plot error right
            ndxRwdR = ChoiceLeft(indxToPlot) == 0 & IncorrectChoice(indxToPlot) == 1;
            Xdata = indxToPlot(ndxRwdR);
            Ydata = zeros(1, sum(ndxRwdR));
            set(BpodSystem.GUIHandles.OutcomePlot.UnrewardedR,...
                'xdata', Xdata, ...
                'ydata', Ydata);
            
            %plot if left correct was not rewarded
            ndxRwdL = ChoiceLeft(indxToPlot) == 1 & IncorrectChoice(indxToPlot) == 1 & Rewarded(indxToPlot) == 0;
            Xdata = indxToPlot(ndxRwdL);
            Ydata = ones(1, sum(ndxRwdL));
            set(BpodSystem.GUIHandles.OutcomePlot.SkippedL,...
                'xdata', Xdata, ...
                'ydata', Ydata);
            
            %plot if right correct was not rewarded
            ndxRwdR = ChoiceLeft(indxToPlot) == 0 & IncorrectChoice(indxToPlot) == 1 & Rewarded(indxToPlot) == 0;
            Xdata = indxToPlot(ndxRwdR);
            Ydata = zeros(1, sum(ndxRwdR));
            set(BpodSystem.GUIHandles.OutcomePlot.SkippedR,...
                'xdata', Xdata, ...
                'ydata', Ydata);
            
            %plot if no choice is made
            ndxNoChoice=isnan(ChoiceLeft(indxToPlot));
            Xdata = indxToPlot(ndxNoChoice);
            Ydata = 0.5*ones(1, sum(ndxNoChoice));
            set(BpodSystem.GUIHandles.OutcomePlot.NoDecision,...
                'xdata', Xdata,...
                'ydata', Ydata);
            
        end

        if ~isempty(BpodSystem.Data.Custom.TrialData.BrokeFixation)
            indxToPlot = mn:CurrentTrial;
            ndxEarly = BpodSystem.Data.Custom.TrialData.BrokeFixation(indxToPlot);
            XData = indxToPlot(ndxEarly);
            YData = 0.5*ones(1, sum(ndxEarly));
            set(BpodSystem.GUIHandles.OutcomePlot.BrokeFixation, 'xdata', XData, 'ydata', YData);
        end

%         if ~isempty(BpodSystem.Data.Custom.TrialData.Jackpot)
%             indxToPlot = mn:CurrentTrial;
%             ndxJackpot = BpodSystem.Data.Custom.TrialData.Jackpot(indxToPlot);
%             XData = indxToPlot(ndxJackpot);
%             YData = 0.5*ones(1,sum(ndxJackpot));
%             set(BpodSystem.GUIHandles.OutcomePlot.Jackpot, 'xdata', XData, 'ydata', YData);
%         end
        
        % GracePeriod
        BpodSystem.GUIHandles.OutcomePlot.HandleGracePeriod.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleGracePeriod, 'Children'), 'Visible', 'on');
        cla(AxesHandles.HandleGracePeriod)
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriod = histogram(AxesHandles.HandleGracePeriod,BpodSystem.Data.Custom.TrialData.false_exits(~isnan(BpodSystem.Data.Custom.TrialData.false_exits)&~repmat(BpodSystem.Data.Custom.TrialData.EarlyWithdrawal,50,1))*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriod.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriod.FaceColor = 'g';
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriod.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriodEWD = histogram(AxesHandles.HandleGracePeriod,BpodSystem.Data.Custom.TrialData.false_exits(~isnan(BpodSystem.Data.Custom.TrialData.false_exits)&repmat(BpodSystem.Data.Custom.TrialData.EarlyWithdrawal,50,1))*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriodEWD.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriodEWD.FaceColor = 'r';
        BpodSystem.GUIHandles.OutcomePlot.HistGracePeriodEWD.EdgeColor = 'none';
%         LeftBias = sum(BpodSystem.Data.Custom.TrialData.ChoiceLeft==1)/sum(~isnan(BpodSystem.Data.Custom.TrialData.ChoiceLeft),2);
%         cornertext(AxesHandles.HandleMoveTime,sprintf('Bias=%1.2f',LeftBias))

        %% Trial rate
        BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate, 'Children'), 'Visible', 'on');
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = (BpodSystem.Data.TrialStartTimestamp-min(BpodSystem.Data.TrialStartTimestamp))/60;
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = 1:numel(BpodSystem.Data.Custom.TrialData.ChoiceLeft(1:end));
        
        %% SamplingTime
        BpodSystem.GUIHandles.OutcomePlot.HandleSampleTime.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleSampleTime, 'Children'), 'Visible', 'on');
        cla(AxesHandles.HandleSampleTime)
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly = histogram(AxesHandles.HandleSampleTime, BpodSystem.Data.Custom.TrialData.sample_length(BpodSystem.Data.Custom.TrialData.EarlyWithdrawal)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.FaceColor = 'r';
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistST = histogram(AxesHandles.HandleSampleTime,BpodSystem.Data.Custom.TrialData.sample_length(~BpodSystem.Data.Custom.TrialData.EarlyWithdrawal)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistST.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistST.FaceColor = 'b';
        BpodSystem.GUIHandles.OutcomePlot.HistST.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistSTJackpot = histogram(AxesHandles.HandleSampleTime,BpodSystem.Data.Custom.TrialData.sample_length(BpodSystem.Data.Custom.TrialData.Jackpot)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistSTJackpot.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistSTJackpot.FaceColor = 'g';
        BpodSystem.GUIHandles.OutcomePlot.HistSTJackpot.EdgeColor = 'none';
        EarlyP = sum(BpodSystem.Data.Custom.TrialData.EarlyWithdrawal)/size(BpodSystem.Data.Custom.TrialData.ChoiceLeft,2);
        cornertext(AxesHandles.HandleSampleTime, sprintf('P=%1.2f', EarlyP))
        
        %% MovementTime
        BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime,'Children'),'Visible','on');
        cla(AxesHandles.HandleMoveTime)
        BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime = histogram(AxesHandles.HandleMT,BpodSystem.Data.Custom.TrialData.move_time(~BpodSystem.Data.Custom.TrialData.EarlyWithdrawal)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime.FaceColor = 'b';
        BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime.EdgeColor = 'none';
        LeftBias = sum(BpodSystem.Data.Custom.TrialData.ChoiceLeft==1)/sum(~isnan(BpodSystem.Data.Custom.TrialData.ChoiceLeft),2);
        cornertext(AxesHandles.HandleMoveTime, sprintf('Bias=%1.2f', LeftBias))

end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
    FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
    mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
    mx = mn + nTrialsToShow - 1;
    set(AxesHandle,'XLim',[mn-1 mx+1]);
end

function cornertext(h,str)
    unit = get(h,'Units');
    set(h,'Units','char');
    pos = get(h,'Position');
    if ~iscell(str)
        str = {str};
    end
    for i = 1:length(str)
        x = pos(1)+1;y = pos(2)+pos(4)-i;
        uicontrol(h.Parent,'Units','char','Position',[x,y,length(str{i})+1,1],'string',str{i},'style','text','background',[1,1,1],'FontSize',8);
    end
    set(h,'Units',unit);
end