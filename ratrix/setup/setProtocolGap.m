function r = setProtocolGap(r,subjIDs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2AFC between white noise and white noise w/ varying gap durations
%
% Step 1: Free Drinks
% Step 2: Req. Rewards
% Step 3: Full task, 1-128ms
%
% When gap is present, begins after 200ms of white noise. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize
if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Parameters

% Stimuli Parameters
stimParams.soundType = 'gap';
stimParams.freq      = [];
stimParams.duration  = 500;
stimParams.amp       = 10.^((60-80)/20);
stimParams.gapDurs   = [1,2,4,8,16,32,64,128];

%Easy Stimuli Parameters
stimParamsEasy128=stimParams;
stimParamsEasy128.gapDurs   = [128];
stimParamsEasy64=stimParams;
stimParamsEasy64.gapDurs   = [64 128];
stimParamsEasy32=stimParams;
stimParamsEasy32.gapDurs   = [32 64 128];

% Task Parameters
freeDrinkLikelihood  = 0;
allowRepeats         = false;
reward               = 45; %in ms
requestMode          = 'first';
msPenalty            = 2000;

% Irrelevant/Placeholder Parameters
ph1                  = 1;
ph5                  = 0.5;
msAirpuff            = msPenalty;
maxWidth             = 1920; %Leftovers from vision days, dk what these do but if they're not there nothing works.
maxHeight            = 1080;
scaleFactor          = 0;
eyeController        = [];
dropFrames           = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Managers

% Sound Manager
sm=makeBlankSoundManager; %No sounds

% Reward Manager
reqRewards = constantReinforcement(reward,reward,...
    requestMode,msPenalty,ph1,ph1,ph1,msPenalty); %they get a reward for reQuesting in center port
regRewards = constantReinforcement(reward,0,...
    requestMode,msPenalty,ph1,ph1,ph1,msPenalty); %reGular rewards

% Trial Managers
fd = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,reqRewards);
nafc1 = nAFC(sm,ph5,reqRewards,eyeController,{'off'},dropFrames,'ptb','center');
nafc2 = nAFC(sm,ph5,regRewards,eyeController,{'off'},dropFrames,'ptb','center');  

% Stim Manager
gapStim = gap(ph5,stimParams,maxWidth,maxHeight,scaleFactor,ph5);
gapStimEasy128 = gap(ph5,stimParamsEasy128,maxWidth,maxHeight,scaleFactor,ph5);
gapStimEasy64 = gap(ph5,stimParamsEasy64,maxWidth,maxHeight,scaleFactor,ph5);
gapStimEasy32 = gap(ph5,stimParamsEasy32,maxWidth,maxHeight,scaleFactor,ph5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Task

% Training Steps
ts1 = trainingStep(fd, gapStim, numTrialsDoneCriterion(100),  noTimeOff(), svnRev, svnCheckMode); %Request Free Drinks
ts2 = trainingStep(nafc1, gapStimEasy128, numTrialsDoneCriterion(400),  noTimeOff(), svnRev, svnCheckMode); %Noise stim w/ request reward
ts3 = trainingStep(nafc2, gapStimEasy128, performanceCriterion(.75, int8(200)),  noTimeOff(), svnRev, svnCheckMode); %Noise stim w/o req reward
ts4 = trainingStep(nafc2, gapStimEasy64, performanceCriterion(.75, int8(200)),  noTimeOff(), svnRev, svnCheckMode); %Noise stim w/o req reward
ts5 = trainingStep(nafc2, gapStimEasy32, performanceCriterion(.75, int8(200)),  noTimeOff(), svnRev, svnCheckMode); %Noise stim w/o req reward
ts6 = trainingStep(nafc2, gapStim, repeatIndefinitely(),  noTimeOff(), svnRev, svnCheckMode); %Noise stim w/o req reward

% Protocol
p=protocol('gap',{ts1,ts2,ts3,ts4,ts5,ts6});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Mouse Protocol

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [~,t] = getProtocolAndStep(subj);
    if t>0 && t<=6
        stepNum = uint8(t);
    elseif t>6
        stepNum = uint8(2); % If we don't know what's up, req rewards always a good call.
    else
        stepNum = uint8(1);
    end
    [subj r]=setProtocolAndStep(subj,p,true,true,true,stepNum,r,'call to setProtocolGap','edf');
end


