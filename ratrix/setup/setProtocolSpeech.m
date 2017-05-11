function r = setProtocolSpeech(r,subjIDs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Phoneme discrimination task w/ multiple speakers & vowel contexts
% Last Updated JLS 06.02.16: Updating w/ new training phonemes
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
% 1) Request FW - gives small drinks only after requesting
%     -Advance w/ 100 trials
%
% Shaping
% 2) Tone w/ Req Rewards - plays pure tone on request & phoneme if correct
%     -Advance w/ 400 Trials
% 3) Tone w/o Req Rewards
%     -Advance w/ 80% correct in 300 trials
% 4) PhoneTone - plays pure tone of varying length depending on % correct,
% plays phoneme immediately after
%     -Advance w/ 75% in 300 trials
%
% nAFC
% 5) Basic Task w/ L1 Stim & reg size drinks, startle stim & buzz if wrong/too
% early
%     -Advance after 400 trials
% 6) Basic Task w/ less water
%     -Advance w/ 70% in 300 trials
% 7-8) L2 stim; 9-10) L3 stim; 11-12) L4 stim; 13) L5 stim
%
% Experimental Trials
% 14) Perceptual Boundary Test - 10% of trials are whole-sound morphs, 10%
% of trials are VOT morphs, both w/ 7 levels of morphing between the two
% most accurate CV pairs
% 15) Generalization Verification - 10% of trials are tokens from trained
% CVs (incl. untrained speakers, etc.), 10% of trials are tokens from
% untrained CVs. Spaced such that repetition is not close together
% 16) Component Tests - 10% of trials are CV pairs w/ formant/frequency
% band removed, 10% of trials are singular formant/frequency band.
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
phTParams.soundType   = 'phoneTone';
phTParams.freq        = [];
phTParams.duration    = 1000;
phTParams.amp         = amplitude;

% Morph Parameters (for step 14)
morphParams.soundType = 'morPhone';
morphParams.freq      = [];
morphParams.duration  = 500;
morphParams.amp       = amplitude;
morphParams.pctVOT    = .1; %Percent of trials that are VOT morphs
morphParams.pctMorph  = .1; %Percent of trials that are whole-sound morphs
morphParams.stimLevel = 6;

% Generalization Parameters (for step 15)
genParams.soundType   = 'speechWavAll';
genParams.freq        = [];
genParams.duration    = 500;
genParams.amp         = amplitude;
genParams.pctLearned  = .1; %Percent of trials that have a novel token from a learned CV pair
genParams.pctNovel    = .1; %Percent of trials that have a novel token from a novel CV pair
genParams.stimLevel   = 6;

% Uniform stimulus sampling (for step 16)
unifParams.soundType = 'speechWavAllUniform';
unifParams.freq      = [];
unifParams.duration  = 500;
unifParams.amp       = amplitude;
%unifParams.pctSingle = .1; %pct of trials that have only one formant/frequency band
unifParams.stimLevel = 6;

% Mapping parameter - New mice are training w/ a different set of phonemes
oldmice = {'6896','6897','6898','6899','6900',...
           '6924','6925','6926','6927','6928',...
           '6960','6961','6962','6963','6964',...
           '6965','6966','6967','6982','6983'};
% Experimenting with alternate training combinations
%    Anna->Theresa
alt1    = {'7265','7281','7285','7320'};
%    Dani->Anna
alt2    = {'7328','7330','7334','7428'};
%    Ira -> Dani
alt3    = {'7473','7475','7324','7610','7570'};
%    Theresa -> Jonny
alt4    = {'7477','7568','7639','7321','7268'};


%Set to new stim and change if we're just updating an old mouse
soundParams.stimMap = 2;
toneParams.stimMap = 2;
phTParams.stimMap = 2;
morphParams.stimMap = 2;
genParams.stimMap = 2;
unifParams.stimMap = 2;

for i = 1:length(subjIDs)
    if ~all(cellfun('isempty',strfind(oldmice,subjIDs{i})))
        soundParams.stimMap = 1;
        toneParams.stimMap = 1;
        phTParams.stimMap = 1;
        morphParams.stimMap = 1;
        genParams.stimMap = 1;
        unifParams.stimMap = 1;
        break
    elseif ~all(cellfun('isempty',strfind(alt1,subjIDs{i})))
        soundParams.stimMap = 3;
        toneParams.stimMap = 3;
        phTParams.stimMap = 3;
        morphParams.stimMap = 3;
        genParams.stimMap = 3;
        unifParams.stimMap = 3;
        break
    elseif ~all(cellfun('isempty',strfind(alt2,subjIDs{i})))
        soundParams.stimMap = 4;
        toneParams.stimMap = 4;
        phTParams.stimMap = 4;
        morphParams.stimMap = 4;
        genParams.stimMap = 4;
        unifParams.stimMap = 4;
        break
    elseif ~all(cellfun('isempty',strfind(alt3,subjIDs{i})))
        soundParams.stimMap = 5;
        toneParams.stimMap = 5;
        phTParams.stimMap = 5;
        morphParams.stimMap = 5;
        genParams.stimMap = 5;
        unifParams.stimMap = 5;
        break
    elseif ~all(cellfun('isempty',strfind(alt4,subjIDs{i})))
        soundParams.stimMap = 6;
        toneParams.stimMap = 6;
        phTParams.stimMap = 6;
        morphParams.stimMap = 6;
        genParams.stimMap = 6;
        unifParams.stimMap = 6;
        break
    end
end

% Reinforcement Parameters
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
ExpStim1 = speechDiscrim(interTrialLum,morphParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
ExpStim2 = speechDiscrim(interTrialLum,genParams,maxWidth,maxHeight,scaleFactor,interTrialLum);
ExpStim3 = speechDiscrim(interTrialLum,unifParams,maxWidth,maxHeight,scaleFactor,interTrialLum);

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
sm2=makeSpeechSM_PhonCorrect(soundParams,noiseParams);


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

%Steps 5-9 use step 6's step manager

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make Training Steps
ts1  = trainingStep(fd,    STStim1    , numTrialsDoneCriterion(100)        ,  noTimeOff(), svnRev,svnCheckMode); %Request Free Drinks
ts2  = trainingStep(nafc2, STStim1    , numTrialsDoneCriterion(200)        ,  noTimeOff(), svnRev,svnCheckMode); %PhonTones Req Rwds
ts3  = trainingStep(nafc3, STStim1    , performanceCriterion(.8, int8(300)),  noTimeOff(), svnRev,svnCheckMode); %PhonTones w/o req
ts4  = trainingStep(nafc4, STStim2    , performanceCriterion(.75, int8(400)),  noTimeOff(), svnRev,svnCheckMode); %Phoneme after tone
ts5  = trainingStep(nafc4, speechStim1, numTrialsDoneCriterion(400)        ,  noTimeOff(), svnRev,svnCheckMode); %Long timeout
ts6  = trainingStep(nafc5, speechStim1, performanceCriterion(.75, int8(400)),  noTimeOff(), svnRev,svnCheckMode); %Long timeout
ts7  = trainingStep(nafc4, speechStim2, numTrialsDoneCriterion(400)        ,  noTimeOff(), svnRev,svnCheckMode); %Harder task
ts8  = trainingStep(nafc5, speechStim2, performanceCriterion(.75, int8(400)),  noTimeOff(), svnRev,svnCheckMode); %etc...
ts9  = trainingStep(nafc4, speechStim3, numTrialsDoneCriterion(400)        ,  noTimeOff(), svnRev,svnCheckMode); %etc...
ts10 = trainingStep(nafc5, speechStim3, performanceCriterion(.75, int8(400)),  noTimeOff(), svnRev,svnCheckMode);
ts11 = trainingStep(nafc4, speechStim4, numTrialsDoneCriterion(400)        ,  noTimeOff(), svnRev,svnCheckMode);
ts12 = trainingStep(nafc5, speechStim4, performanceCriterion(.75, int8(400)),  noTimeOff(), svnRev,svnCheckMode);
ts13 = trainingStep(nafc4, speechStim5, performanceCriterion(.99, int8(210)),  noTimeOff(), svnRev,svnCheckMode);

%Experimental Training Steps
%Perceptual Boundary - VOT and whole-sound morphs
ts14 = trainingStep(nafc5, ExpStim1, performanceCriterion(.99, int8(210)),  noTimeOff(), svnRev,svnCheckMode);
%Generalization Validation
ts15 = trainingStep(nafc5, ExpStim2, performanceCriterion(.99, int8(210)),  noTimeOff(), svnRev,svnCheckMode);
%Parameter Testing
ts16 = trainingStep(nafc5, ExpStim3, performanceCriterion(.99, int8(210)),  noTimeOff(), svnRev,svnCheckMode);


%p=protocol('mouse intensity discrimation',{ ts3, ts4, ts5});
p=protocol('mouse speech discrimination ',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9, ts10, ts11, ts12, ts13, ts14, ts15, ts16});

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


%%%%%%%%%%%%%%%%%%
%Zombie Code
%[w,h]=rat(maxWidth/maxHeight);
