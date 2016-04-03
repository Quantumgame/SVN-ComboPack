function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks,sounds] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,targetPorts,distractorPorts,details,text)

global freqDurable;

indexPulses=[];
imagingTasks=[];

LUT=makeStandardLUT(LUTbits);

[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

updateSM=0;
toggleStim=true;

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case 'freeDrinks'
        type='cache';
    case 'nAFC'
        type='loop';%int32([10 10]); % This is 'timedFrames'
    otherwise
        error('unknown trial manager class')
end

details.laserON=0; %set to be 0, modify if necessary
details.responseTime=0;
details.soundONTime=0;
details.toneFreq = [];

if strcmp(stimulus.soundType, 'speechWav') 
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    switch stimulus.stimLevel %Choose stim, mapped in getClip
        case 1 %base
            r1 = 1; %One speaker (Jonny)
            r2 = 1; %One Vowel Context (/I/)
            r3 = 3; %One Recording (best of Jonny's /bI/)
        case 2 %2 recordings
            r1 = 1;
            r2 = 1;
            r3 = randi(2,1) + 1; %get recording 2 or 3
        case 3 %2 vowels/2 recordings of /I/, one of /o/
            r1 = 1;
            r2 = randi(2,1);
            if r2 == 2 
                r3 = 3; %one recording of /o/
            else
                r3 = randi(2,1) + 1;
            end
        case 4 %2 speakers/2 vowels/2 recordings of prev speak,1 of new
            r1 = randi(2,1);
            r2 = randi(2,1);
            if r1 == 2 %one recording if second speaker this time
                r3 = 3;
            else
                r3 = randi(2,1) + 1;
            end
        case 5 %2 speakers/3 vowels/2 recordings of prev vowel, 1 of new.
            r1 = randi(2,1);
            r2 = randi(3,1);
            if r2 == 3
                r3 = 3;
            else
                r3 = randi(2,1) + 1;
            end
    end
    
    if lefts >= rights %choose a left stim (/g/)
        details.toneFreq = [1, r1, r2, r3];
        freqDurable = [1, r1, r2, r3];

    elseif rights>lefts %choose a right stim (/b/)
        details.toneFreq = [2, r1, r2, r3];
        freqDurable = [2, r1, r2, r3];
    end
end


if strcmp(stimulus.soundType, 'tone')
    %For when only tone in discrim phase, phoneme will be played as
    %'correct sound' if used w/ soundmanager "makeSpeechSM_PhonCorrect"
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    
    %default case (e.g. rights==lefts )
    
    tones = [2000 7000];
    
    if lefts>=rights %choose a left stim (wav1)
        details.toneFreq = tones(1);
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = tones(2);
    end
    
end

if strcmp(stimulus.soundType, 'phoneTone')
    %For when phoneme should come after tone
    %Tone & speech details are in getClip.
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    type = 'cache';
    %Want to base amount of pure tone on how well they're doing until they
    %graduate at 75% (0ms obvs)
    correx = [];
    if length(trialRecords) > 52
        try
            for i = 1:51
                try
                    correx(i) = trialRecords((length(trialRecords)-i)).trialDetails.correct;
                end
            end
        catch
            try
                correx = trialRecords(end-51:end-1).correct;
            end
        end
    else
        correx = trialRecords(:).correct;
    end
    pctcorrex = mean(correx,1);
    
    duration = [];
    if pctcorrex < .5
        duration = 500;
    elseif pctcorrex>=.5 & pctcorrex<.6
        duration = 300;
    elseif pctcorrex>=.6 & pctcorrex<.7
        duration = 100;
    elseif pctcorrex>=.7
        duration = 0;
    else     
        duration = 300;
    end
    
    if lefts>=rights %choose a left stim (wav1)
        details.toneFreq = [1, duration];
        freqDurable = [1,duration];
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = [2, duration];
        freqDurable = [2, duration];
    end  
end


details.rightAmplitude = stimulus.amplitude;
details.leftAmplitude = stimulus.amplitude;

% fid=fopen('miketest.txt', 'a+t')
% fprintf(fid, '\nintensity discrim/calcstim: laserON=%d',details.laserON)
% fclose(fid)
switch stimulus.soundType
    case {'allOctaves','tritones'}
        sSound = soundClip('stimSoundBase','allOctaves',[stimulus.freq],20000);
    case {'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'}
        sSound = soundClip('stimSoundBase',stimulus.soundType);
        details.rightAmplitude = 10.^((40 - 80)/20);
        details.leftAmplitude = 10.^((40 - 80)/20);
    case {'wmReadWav'}
        sSound = soundClip('stimSoundBase','wmReadWav', [details.toneFreq]);
    case {'phoneTone'}
        sSound = soundClip('stimSoundBase','phoneTone', [details.toneFreq]);
    case {'speechWav'}
        sSound = soundClip('stimSoundBase','speechWav', [details.toneFreq]);
    case {'speechWavLaser'}
        sSound = soundClip('stimSoundBase','speechWavLaser', [details.toneFreq]);
    case {'speechWavLaserMulti'}
        sSound = soundClip('stimSoundBase','speechWavLaserMulti', [details.toneFreq]);
    case {'speechWavReversedReward'} %%%shit shit shit shit
        sSound = soundClip('stimSoundBase','speechWavReversedReward', [details.toneFreq]);
    case {'tone'}
        sSound = soundClip('stimSoundBase','tone', [details.toneFreq]);
    case {'toneLaser'}
        sSound = soundClip('stimSoundBase','toneLaser', [details.toneFreq]);
end
stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude,details.toneFreq},{sSound,details.rightAmplitude,details.toneFreq});

%modify penalty sound amplitude here

%do not want this line when laser enabled!
%parameterize it as "multi" and "reinforce"?
%make sure to figure out the falsed out stuff in getSoundsToPlay
sounds={stimulus.stimSound};

out=zeros(min(height,getMaxHeight(stimulus)),min(width,getMaxWidth(stimulus)),2);
out(:,:,1)=stimulus.mean;
out(:,:,2)=stimulus.mean;

discrimStim=[];
discrimStim.stimulus=out;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;
%discrimStim.autoTrigger=[];

preRequestStim=[];
preRequestStim.stimulus=interTrialLuminance;
preRequestStim.stimType='loop';
preRequestStim.scaleFactor=0;
preRequestStim.startFrame=0;
%preRequestStim.autoTrigger=[];
preRequestStim.punishResponses=false;

preResponseStim=discrimStim;
preResponseStim.punishResponses=false;