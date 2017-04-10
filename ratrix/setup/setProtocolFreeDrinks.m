function r = setProtocolFreeDrinks(r,subjIDs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Protocol to give free drinks forever
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

% Relevant Parameters
freeDrinkLikelihood  = 0;
allowRepeats         = false;
reward               = 55; %in ms
noiseParams.soundType= 'noise';
noiseParams.freq     = [];
noiseParams.duration = 500;
noiseParams.amp      = 10.^((60-80)/20);

% Irrelevant/Placeholder Parameters
ph1                  = 1;
ph5                  = 0.5;
requestMode          = 'first';
msPenalty            = 2000;
msAirpuff            = msPenalty;
maxWidth             = 1920; %Leftovers from vision days, dk what these do but if they're not there nothing works.
maxHeight            = 1080;
scaleFactor          = 0;
toneParams.soundType = 'tone';
toneParams.freq      = [];
toneParams.duration  = 500;
toneParams.amp       = 10.^((60-80)/20);
toneParams.stimMap   = 2;
eyeController        = [];
dropFrames           = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Managers

% Sound Manager
sm=makeBlankSoundManager; %No sounds

% Reward Manager
reqRewards = constantReinforcement(reward,reward,...
    requestMode,msPenalty,ph1,ph1,ph1,msPenalty);
regRewards = constantReinforcement(reward,0,...
    requestMode,msPenalty,ph1,ph1,ph1,msPenalty);

% Trial Managers
fd = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,reqRewards);
nafc1 = nAFC(sm,ph5,reqRewards,eyeController,{'off'},dropFrames,'ptb','center');
nafc2 = nAFC(sm,ph5,regRewards,eyeController,{'off'},dropFrames,'ptb','center');  

% Stim Manager - using speechDiscrim's b/c it's a known quantity.
STStim1 = speechDiscrim(ph5,toneParams,maxWidth,maxHeight,scaleFactor,ph5);
noiseStim = noise(ph5,noiseParams,maxWidth,maxHeight,scaleFactor,ph5);

% Training Step
ts1 = trainingStep(fd, STStim1, numTrialsDoneCriterion(200),  noTimeOff(), svnRev, svnCheckMode); %Request Free Drinks
ts2 = trainingStep(nafc1, noiseStim, numTrialsDoneCriterion(300),  noTimeOff(), svnRev, svnCheckMode); %Noise stim w/ request reward
ts3 = trainingStep(nafc2, noiseStim, repeatIndefinitely(),  noTimeOff(), svnRev, svnCheckMode); %Noise stim w/o req reward

% Protocol
p=protocol('free drinks',{ts1,ts2,ts3});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Mouse Protocol

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [~,t] = getProtocolAndStep(subj);
    if t>0
        stepNum = uint8(t);
    else
        stepNum=uint8(1);
    end
    [subj r]=setProtocolAndStep(subj,p,true,true,true,stepNum,r,'call to setProtocolSpeech','edf');
end


