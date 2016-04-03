function r = setProtocolSpeech(r,subjIDs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Phoneme discrimination task w/ multiple speakers & vowel contexts
% JLS 03.05.16
%
% 1.2: 03.22.16: Training is rough, starting w/ tone discrim tied to
% phonemes
% 1.1: 03.09.16: Mice getting biased, increased correction trial
% penalty, includes update to nAFC's "assignPorts"
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Training Stimuli Levels:
% Same Consonant pair throughout, only # vowel context changes
% 0: Tones w/ lvl 1
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
% PhoneTones Training
% 1) Request FW - gives small drinks only after requesting w/ tones
%     -Advance w/ 20 trials/min
% 2) TonePhones w/ req rewards - plays tones on request & plays phonemes if guessed
% correctly. Gives water w/ request
% 3) TonePhones w/o req rewards- plays tones on request & plays phonemes if guessed
% correctly
% in correct port, plays startle stim & buzz if wrong/too early
%     -Advance w/ 400 Trials
% 4) Switch to PhoneTones - plays tones and then phonemes after req, varies
% length of tones depending on % accuracy
%
% Real Live Phoneme Discrimination
% 5) Basic Task w/ L1 Stim & reg size drinks, startle stim & buzz if wrong/too
% early
%     -Advance after 400 trials to long timeout
% 5) Timeout Task w/ L1 Stim & reg size drinks, startle stim & buzz if
% wrong/too early
%     -Advance after 70% correct in 100 trials
% 6-10) Timeout Task w/ L2 (and higher) Stim & med, startle stim etc. 
%     -Advance after above 70% in 150 Trials - # of trials progresses so
%     that criter isn't met immediately.
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
% Stimli
% Make Stimuli - Speech
soundParams.soundType = 'speechWav';
soundParams.freq      = [];
soundParams.duration  = 500; %ms
maxSPL                = 80; %measured max level attainable by speakers; in reality, seems to be 67.5dB at head, 74.6dB 1" from earbuds
ampsdB                = 60; %requested amps in dB
amplitude             = 10.^((ampsdB -maxSPL)/20); %amplitudes = line level, 0 to 1
soundParams.amp       = amplitude; %for intensityDisrim
noiseParams.amp       = amplitude*.75; %make it a lil quieter for the boys

% Make Stimuli - Tones
toneParams.soundType  = 'tone';
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
pctCorrectionTrials   = .5; %Actually is pct NOT correction trials
maxWidth           = 1920;
maxHeight          = 1080;
interTrialLum      = .5;
scaleFactor        = 0;
eyeController      = [];
dropFrames         = false;

% Class Stim Managers, first for phonemes & tones - Phase logic is
% determined in the modified speech manager (makeSpeechSM_PhonCorrect)
STStim1 = speechDiscrim(interTrialLum,toneParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
STStim2 = speechDiscrim(interTrialLum,phTParams,maxWidth,maxHeight,scaleFactor,interTrialLum);

% Identify level
% stimLevel determines how calcStim chooses the sound filefor getClip
for i = 1:5
    soundParams.stimLevel = i;
    switch i
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
noiseParams.duration = msShortPenalty;
sm2 = makeSpeechSM_PhonCorrect(soundParams,noiseParams);
sm  = makeSpeechSoundManager(noiseParams);
noiseParams.duration = msLongPenalty;
sm3 = makeSpeechSoundManager(noiseParams);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
%Make Trial Managers
%Need to make small water punishment steps

%Step 1 - FW w/ manually dispensed first drinks.
freeDrinkLikelihood=0;
fd = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,medReqRewards);

%Step 2 - Tone&Phoneme task w/ request reward
nafc2 = nAFC(sm2,pctCorrectionTrials,largeReqRewards,eyeController,{'off'},dropFrames,'ptb','center');  

%Step 3 - Tone&Phoneme task w/o req reward
nafc3 = nAFC(sm2,pctCorrectionTrials,medRewards,eyeController,{'off'},dropFrames,'ptb','center');

%Step 4 - Tone&Phoneme task w/ phoneme played after tone
nafc4 = nAFC(sm,pctCorrectionTrials,medRewards,eyeController,{'off'},dropFrames,'ptb','center');

%Step 5 - Just phoneme task w/ med rewards
nafc5 = nAFC(sm,pctCorrectionTrials,medRewards,eyeController,{'off'},dropFrames,'ptb','center',[],[],[]);

%Step 6 - long timeout
nafc6 = nAFC(sm3,pctCorrectionTrials,medRewardsLT,eyeController,{'off'},dropFrames,'ptb','center',[],[],[]);


%Steps 7-10 use step 6's step manager

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make Training Steps
ts1  = trainingStep(fd,    STStim1    , rateCriterion(20,1)                ,  noTimeOff(), svnRev,svnCheckMode); %Request Free Drinks
ts2  = trainingStep(nafc2, STStim1    , rateCriterion(20,1)                ,  noTimeOff(), svnRev,svnCheckMode); %PhonTones Req Rwds
ts3  = trainingStep(nafc3, STStim1    , performanceCriterion(.7, int8(100)),  noTimeOff(), svnRev,svnCheckMode); %PhonTones w/o req
ts4  = trainingStep(nafc4, STStim2    , performanceCriterion(.7, int8(200)),  noTimeOff(), svnRev,svnCheckMode); %Phoneme after tone
ts5  = trainingStep(nafc5, speechStim1, numTrialsDoneCriterion(400)        ,  noTimeOff(), svnRev,svnCheckMode); %Basic Task Intro
ts6  = trainingStep(nafc6, speechStim1, performanceCriterion(.7, int8(100)),  noTimeOff(), svnRev,svnCheckMode); %Long timeout
ts7  = trainingStep(nafc6, speechStim2, performanceCriterion(.7, int8(150)),  noTimeOff(), svnRev,svnCheckMode); %Harder task
ts8  = trainingStep(nafc6, speechStim3, performanceCriterion(.7, int8(175)),  noTimeOff(), svnRev,svnCheckMode); %etc...
ts9  = trainingStep(nafc6, speechStim4, performanceCriterion(.7, int8(200)),  noTimeOff(), svnRev,svnCheckMode);
ts10 = trainingStep(nafc6, speechStim5, performanceCriterion(.99, int8(210)),  noTimeOff(), svnRev,svnCheckMode);

%p=protocol('mouse intensity discrimation',{ ts3, ts4, ts5});
p=protocol('mouse speech discrimination ',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9, ts10});

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    stepNum=uint8(5);
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolSpeech','edf');
end


%%%%%%%%%%%%%%%%%%
%Zombie Code
%[w,h]=rat(maxWidth/maxHeight);