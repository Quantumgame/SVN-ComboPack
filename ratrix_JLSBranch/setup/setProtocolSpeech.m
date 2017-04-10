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

% Make Stimuli - Tones
toneParams.soundType  = 'toneThenSpeech'; %Need to calc phone at same time as freq
toneParams.freq       = [];
toneParams.duration   = 500;
toneParams.amp        = amplitude;

% Make Stimuli - Tones & Speech
phTParams.soundType  = 'phoneTone';
phTParams.freq       = [];
phTParams.duration   = 1000;
phTParams.amp        = amplitude;

% Set parameters
% reinforcement
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

% Class Stim Managers, first for phonemes & tones - Phase sounds
% determined in the modified speech manager (makeSpeechSM_PhonCorrect)
STStim1 = speechDiscrim(interTrialLum,toneParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
STStim2 = speechDiscrim(interTrialLum,phTParams,maxWidth,maxHeight,scaleFactor,interTrialLum);


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

%Step 2 - Tone&Phoneme task w/ request reward
nafc2 = nAFC(sm2,pctCorrectionTrials,medReqRewards,eyeController,{'off'},dropFrames,'ptb','center');  

%Step 3 - Tone&Phoneme task w/o req reward
nafc3 = nAFC(sm2,pctCorrectionTrials,medRewardsPT,eyeController,{'off'},dropFrames,'ptb','center');

%Step 4 - Tone&Phoneme task w/ phoneme played after tone
nafc4 = nAFC(sm,pctCorrectionTrials,medRewardsLTPT,eyeController,{'off'},dropFrames,'ptb','center');

%Steps 7-10 use step 6's step manager

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make Training Steps
ts1  = trainingStep(fd,    STStim1    , rateCriterion(20,1)                ,  noTimeOff(), svnRev,svnCheckMode); %Request Free Drinks
ts2  = trainingStep(nafc2, STStim1    , rateCriterion(20,1)                ,  noTimeOff(), svnRev,svnCheckMode); %PhonTones Req Rwds
ts3  = trainingStep(nafc3, STStim1    , performanceCriterion(.7, int8(100)),  noTimeOff(), svnRev,svnCheckMode); %PhonTones w/o req
ts4  = trainingStep(nafc4, STStim2    , performanceCriterion(.7, int8(200)),  noTimeOff(), svnRev,svnCheckMode); %Phoneme after tone
ts5  = trainingStep(nafc6, speechStim1, performanceCriterion(.7, int8(100)),  noTimeOff(), svnRev,svnCheckMode); %Long timeout
ts6  = trainingStep(nafc6, speechStim2, performanceCriterion(.7, int8(150)),  noTimeOff(), svnRev,svnCheckMode); %Harder task
ts7  = trainingStep(nafc6, speechStim3, performanceCriterion(.7, int8(175)),  noTimeOff(), svnRev,svnCheckMode); %etc...
ts8  = trainingStep(nafc6, speechStim4, performanceCriterion(.7, int8(200)),  noTimeOff(), svnRev,svnCheckMode);
ts9  = trainingStep(nafc6, speechStim5, performanceCriterion(.99, int8(210)),  noTimeOff(), svnRev,svnCheckMode);

%p=protocol('mouse intensity discrimation',{ ts3, ts4, ts5});
p=protocol('mouse speech discrimination ',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9});

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    stepNum=uint8(5);
    [subj r]=setProtocolAndStep(subj,p,true,true,true,stepNum,r,'call to setProtocolSpeech','edf');
end


%%%%%%%%%%%%%%%%%%
%Zombie Code
%[w,h]=rat(maxWidth/maxHeight);