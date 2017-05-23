function r = setProtocolPhonemeShapeRR(r,subjIDs)



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
soundParams.soundType = 'phonemeWavGlobal';
soundParams.freq      = [];
soundParams.duration  = 500; %ms
maxSPL                = 80; %measured max level attainable by speakers; in reality, seems to be 67.5dB at head, 74.6dB 1" from earbuds
ampsdB                = 60; %requested amps in dB
amplitude             = 10.^((ampsdB -maxSPL)/20); %amplitudes = line level, 0 to 1
soundParams.amp       = amplitude; %for intensityDisrim
noiseParams.amp       = amplitude;



% Make Stimuli - Tones
toneParams.soundType  = 'toneThenPhonemeRR'; %Need to calc phone at same time as freq
toneParams.freq       = [];
toneParams.duration   = 500;
toneParams.amp        = amplitude;

% Make Stimuli - Tones & Speech
phTParams.soundType   = 'phoneToneConorRR';
phTParams.freq        = [];
phTParams.duration    = 1000;
phTParams.amp         = amplitude;

%Phoneme Params
phPParams.soundType   = 'phonemeWavRR';
phPParams.freq        = [];
phPParams.duration    = 500;
phPParams.amp         = amplitude;

largeReward        = 80;
medReward          = 55;
smallReward        = 40;
noReward           = 0;
requestMode        = 'first';
msShortPenalty     = 2000;
msLongPenalty      = 5000;
fractionSoundOn    = 1;
fractionSoundOnPT  = 500/medReward;%Got this to work by playing with the msRewardSound option in updateTrialState
fractionPenaltyOn  = 1;
scalar             = 1;
msAirpuff          = msShortPenalty;
allowRepeats       = false;
% nAFC specific parameters
pctCorrectTrials   = .5;
maxWidth           = 1920; %Leftovers from vision days, dk what these do but if they're not there nothing works.
maxHeight          = 1080;
interTrialLum      = .5;
scaleFactor        = 0;
eyeController      = [];
dropFrames         = false;





%%%%Stim Managers
STStim1 = phonemeDiscrim(interTrialLum,toneParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
STStim2 = phonemeDiscrim(interTrialLum,phTParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
PhonemeStim = phonemeDiscrim(interTrialLum,phPParams ,maxWidth,maxHeight,scaleFactor,interTrialLum);

sm=makePhonemeSoundManager(noiseParams);
sm2=makePhonCorrectSoundManager(phTParams,noiseParams);



%Make Reinforcement Managers 
%w/o request rewards
largeReqRewards = constantReinforcement(largeReward,largeReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
medReqRewards = constantReinforcement(medReward,medReward,...
    requestMode,msShortPenalty,fractionSoundOnPT,fractionPenaltyOn,scalar,msAirpuff);
smallReqRewards = constantReinforcement(smallReward,smallReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
%w/o request rewards
largeRewards = constantReinforcement(largeReward,noReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
medRewards = constantReinforcement(medReward,noReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
medRewardsPT = constantReinforcement(medReward,noReward,...
    requestMode,msShortPenalty,fractionSoundOnPT,fractionPenaltyOn,scalar,msAirpuff);

smallRewards = constantReinforcement(smallReward,noReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
%w/o request rewards and long timeout
largeRewardsLT = constantReinforcement(largeReward,noReward,...
    requestMode,msLongPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
medRewardsLT = constantReinforcement(medReward,noReward,...
    requestMode,msLongPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
medRewardsLTPT = constantReinforcement(medReward,noReward,...
    requestMode,msLongPenalty,fractionSoundOnPT,fractionPenaltyOn,scalar,msAirpuff);
smallRewardsLT = constantReinforcement(smallReward,noReward,...
    requestMode,msLongPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);

%Step 1
freeDrinkLikelihood=0;
fd = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,medReqRewards);

%Step 2 - Tone&Phoneme task w/ request reward
nafc2 = nAFC(sm2,pctCorrectTrials,medReqRewards,eyeController,{'off'},dropFrames,'ptb','center');  

%Step 3 - Tone&Phoneme task w/o req reward
nafc3 = nAFC(sm2,pctCorrectTrials,medRewardsPT,eyeController,{'off'},dropFrames,'ptb','center');

%Step 4 - Tone&Phoneme task w/ phoneme played after tone
nafc4 = nAFC(sm,pctCorrectTrials,medRewardsLT,eyeController,{'off'},dropFrames,'ptb','center');

%Step 5 - Full task w/ less water
nafc5 = nAFC(sm,pctCorrectTrials,smallRewardsLT,eyeController,{'off'},dropFrames,'ptb','center');

ts1  = trainingStep(fd,    STStim1    , numTrialsDoneCriterion(100)        ,  noTimeOff(), svnRev,svnCheckMode); %Request Free Drinks
ts2  = trainingStep(nafc2, STStim1    , numTrialsDoneCriterion(200)        ,  noTimeOff(), svnRev,svnCheckMode); %PhonTones Req Rwds
ts3  = trainingStep(nafc3, STStim1    , performanceCriterion(.8, int8(300)),  noTimeOff(), svnRev,svnCheckMode); %PhonTones w/o req
ts4  = trainingStep(nafc4, STStim2    ,  performanceCriterion(.8, int8(200)),  noTimeOff(), svnRev,svnCheckMode); %Phoneme after tone
ts5 = trainingStep(nafc4, PhonemeStim    , repeatIndefinitely(),  noTimeOff(), svnRev,svnCheckMode);
%%%main task step 5


p=protocol('mouse phoneme discrimination with shaping',{ts1, ts2, ts3, ts4, ts5});
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

