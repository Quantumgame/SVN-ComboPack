function r = setProtocolSpeech(r,subjIDs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Phoneme discrimination task w/ multiple speakers & vowel contexts
% Last Updated JLS 03.05.16
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Training Stimuli Levels:
% Same Consonant pair throughout, only # vowel context changes
% 1: One Speaker, One CV combo, One recording of each
% 2: One Speaker, One CV combo, Two recordings of each
% 3: One Speaker, Two CV combos, Two recordings of first one of second
% 4: Two Speakers, Two CV combos, Two recordings of prev one of new
% 5: Two Speakers, Three CV combos, Two recordings of prev, one of new
% 
% Experimental Stimuli Levels:
% To test generalization of learning in ephys/imaging
% Always include the stims. from Training levels, just additions described
% 6: All speakers (or specifid #) randomly cycled, same stim/# recordings
% 7: All CVs randomly cycled, same speakers/# recordings
% 8: All recordings cycled, same speakers/# recordings
% 9: All (or specified #) speakers AND all CVs randomly cycled, one recording of each
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Training Steps & Leveling Criteria:
% Free Water
% 1) Automatic FW - gives drops and only gives more after lick & delay
%     -Advance w/ 10 trials
% 2) Request FW - gives small drinks only after requesting & 'ding' w/
% exaggerated delay, startle stim & buzz if lick before ding
%     -Advance w/ 100 trials
% 3) Task FW - plays L1 Stim on request & automatically gives small drinks
% in correct port, plays startle stim & buzz if wrong/too early
%     -Advance w/ 400 Trials
%
% nAFC
% 4) Basic Task w/ L1 Stim & reg size drinks, startle stim & buzz if wrong/too
% early
%     -Advance after 400 trials
% 5) Timeout Task w/ L1 Stim & reg size drinks, startle stim & buzz if
% wrong/too early
%     -Advance after 75% correct in 100 trials
% 6) Step 5 w/ smaller drinks
%     -Advance after above 70% in 200 Trials
% 7) Timeout Task w/ L2 Stim & small drinks, startle stim etc. 
%     -Advance after above 70% in 200 Trials
% 8-10) "" w/ L3,4,5 Stim
%     -Advance after above 70% in 200 Trials
%
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
soundParams.soundType = 'speechWav';
soundParams.freq      = [];
soundParams.duration  = 500; %ms
maxSPL                = 80; %measured max level attainable by speakers; in reality, seems to be 67.5dB at head, 74.6dB 1" from earbuds
ampsdB                = 60; %requested amps in dB
amplitude             = 10.^((ampsdB -maxSPL)/20); %amplitudes = line level, 0 to 1
soundParams.amp       = amplitude; %for intensityDisrim
noiseParams.amp       = amplitude;

% Reinforcement Parameters
largeReward        = 80;
medReward          = 60;
smallReward        = 40;
noReward           = 0;
requestMode        = 'first';
msShortPenalty     = 2000;
msLongPenalty      = 5000;
fractionSoundOn    = 1;
fractionPenaltyOn  = 1;
scalar             = 1;
msAirpuff          = msShortPenalty;
allowRepeats       = false;
% nAFC specific parameters
pctCorrectTrials   = .5;
maxWidth           = 1920;
maxHeight          = 1080;
interTrialLum      = .5;
scaleFactor        = 0;
eyeController      = [];
dropFrames         = false;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Stimuli and Reinforcement Managers
% Make Stimuli
% Identify level for Stimuli
% stimLevel determines how calcStim chooses the sound filefor getClip
%clear speechDiscrim %for some reason need to clear because of added soundParams.stimLevel
for i = 1:5
    soundParams.stimLevel = i;
    switch i %Extremely inelegant way to change name of speechStim variable
        case 1
            speechStim1 = speechDiscrim(interTrialLum,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
        case 2
            speechStim2 = speechDiscrim(interTrialLum,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
        case 3
            speechStim3 = speechDiscrim(interTrialLum,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
        case 4
            speechStim4 = speechDiscrim(interTrialLum,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
        case 5
            speechStim5 = speechDiscrim(interTrialLum,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
    end
end
% Make Trial Sound Manager
sm=makeSpeechSoundManager(noiseParams);

%Make Reinforcement Managers 
%w/o request rewards
largeReqRewards = constantReinforcement(largeReward,largeReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
medReqRewards = constantReinforcement(medReward,medReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
smallReqRewards = constantReinforcement(smallReward,smallReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
%w/o request rewards
largeRewards = constantReinforcement(largeReward,noReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
medRewards = constantReinforcement(medReward,noReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
smallRewards = constantReinforcement(smallReward,noReward,...
    requestMode,msShortPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
%w/o request rewards and long timeout
largeRewardsLT = constantReinforcement(largeReward,noReward,...
    requestMode,msLongPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
medRewardsLT = constantReinforcement(medReward,noReward,...
    requestMode,msLongPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);
smallRewardsLT = constantReinforcement(smallReward,noReward,...
    requestMode,msLongPenalty,fractionSoundOn,fractionPenaltyOn,scalar,msAirpuff);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make Step Managers
%Need to make small water punishment steps

%Step 1
%Have to edit freedrinklikelihood parameter to not dispense if no lick
freeDrinkLikelihood=0.0004; %p per frame
fd1 = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,largeReqRewards);

%Step 2
freeDrinkLikelihood=0;
fd2 = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,medReqRewards);

%Step 3 - task w/ request reward
nafc3 = nAFC(sm,pctCorrectTrials,largeReqRewards,eyeController,{'off'},dropFrames,'ptb','center'); 

%Step 4 - no request reward
nafc4 = nAFC(sm,pctCorrectTrials,medRewards,eyeController,{'off'},dropFrames,'ptb','center');

%Step 5 - long timeout
nafc5 = nAFC(sm,pctCorrectTrials,medRewardsLT,eyeController,{'off'},dropFrames,'ptb','center',[],[],[]);

%Steps 7-10 use step 6's step manager

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make Trial managers
ts1  = trainingStep(fd1,   speechStim1, numTrialsDoneCriterion(10),           noTimeOff(), svnRev,svnCheckMode); %Auto Free Drinks
ts2  = trainingStep(fd2,   speechStim1, numTrialsDoneCriterion(100),          noTimeOff(), svnRev,svnCheckMode); %Request Free Drinks
ts3  = trainingStep(nafc3, speechStim1, numTrialsDoneCriterion(400),          noTimeOff(), svnRev,svnCheckMode); %Basic Task Intro
ts4  = trainingStep(nafc4, speechStim1, numTrialsDoneCriterion(400),          noTimeOff(), svnRev,svnCheckMode); %No Req Reward
ts5  = trainingStep(nafc5, speechStim1, performanceCriterion(.7,int8(200)),  noTimeOff(), svnRev,svnCheckMode); %Long timeout
ts6  = trainingStep(nafc5, speechStim2, performanceCriterion(.7, int8(200)),  noTimeOff(), svnRev,svnCheckMode); %Harder task
ts7  = trainingStep(nafc5, speechStim3, performanceCriterion(.7, int8(200)),  noTimeOff(), svnRev,svnCheckMode); %etc...
ts8  = trainingStep(nafc5, speechStim4, performanceCriterion(.7, int8(200)),  noTimeOff(), svnRev,svnCheckMode);
ts9  = trainingStep(nafc5, speechStim5, performanceCriterion(.7, int8(200)),  noTimeOff(), svnRev,svnCheckMode);

%p=protocol('mouse intensity discrimation',{ ts3, ts4, ts5});
p=protocol('mouse speech discrimination',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9});

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    stepNum=uint8(5);
    [subj r]=setProtocolAndStep(subj,p,true,true,true,stepNum,r,'call to setProtocolSpeech','edf');
end


%%%%%%%%%%%%%%%%%%
%Zombie Code
%[w,h]=rat(maxWidth/maxHeight);