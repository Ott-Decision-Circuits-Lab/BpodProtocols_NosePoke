function [RightClickTrain,LeftClickTrain] = GetClickStimulus(Duration, SamplingRate, ClickLength)

if nargin<4
    ClickLength = 1;
end
if nargin<3
    SamplingRate = 25000; % in Hz
end
if nargin<2
    Duration = 1; % in seconds
end

% draw ClickRate for left and right sound
rr = rand(1,1)*0.6+0.2;
LeftClickRate = ceil(rr*100);
RightClickRate = 100 - LeftClickRate;

LeftClickTrain = GeneratePoissonClickTrain(LeftClickRate, Duration, SamplingRate, ClickLength);
RightClickTrain = GeneratePoissonClickTrain(RightClickRate, Duration, SamplingRate, ClickLength);

end