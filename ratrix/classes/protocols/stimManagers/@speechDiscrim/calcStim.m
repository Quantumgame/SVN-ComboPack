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




% %decide randomly if we issue a laser pulse on this trial or not

switch stimulus.soundType
    case {'tone'}
    case {'toneLaser'}
        %this is for pure tone control protocol
        details.laserON = rand>.9; %laser is on for 10% of trials
        details.laser_duration=.5; %seconds
        details.laser_start_time=Inf;
        details.laser_off_time=Inf;
        details.laser_start_window=0;
        details.laser_wait_start_time=Inf;
    case {'speechWav'}
    case {'speechWavLaser'}
        details.laserON = rand>.9; %laser is on for 10% of trials
        details.laser_duration=.5; %seconds
        details.laser_start_time=Inf;
        details.laser_off_time=Inf;
        details.laser_start_window=0;
        details.laser_wait_start_time=Inf;
    case {'speechWavReversedReward'}
    case {'speechWavLaserMulti'}
        details.laserON = rand>.8;
        details.laser_start_window=RandSample([0 .14]); %randomly choose one of the start points
        %details.laser_duration=(stimulus.freq(2)-stimulus.freq(1))*.001; %spacing between start times determines the interval length
        details.laser_duration=.14;
        details.laser_start_time=Inf;
        details.laser_wait_start_time=Inf;
        details.laser_off_time=Inf;
end






if stimulus.duration==50  %stimulus.freq empty for speech, [1] for speechlaser
    %special case for laserCal
    details.laserON = 1; %laser is on for 10% of trials
    details.laser_duration=30; %seconds
    details.laser_start_time=Inf;
    details.laser_off_time=Inf;
end



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

if strcmp(stimulus.soundType, 'speechWavReversedReward') %files specified in getClip-just need to indicate sad/dad
    %this code works for no laser condition - below for laser
    %same as above for now, duplicated for future potential modifications
    %CO 5-6
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    
    %default case (e.g. rights==lefts )
    
    %randomly choose stim, mapped in getClip
    r1 = 1; %speaker, 1 for now, only Jonny
    %r2 = randi(3,1); %vowel context
   % r3 = randi(3,1); %recording
   r2 = 1;
   r3 = 3; %simplifying task -JLS030316
    
    if lefts >= rights %choose a left stim (/g/)
        details.toneFreq = [1, r1, r2, r3];
        freqDurable = [1, r1, r2, r3];
    end
end

if strcmp(stimulus.soundType, 'tone')
    %Do not use w/ speechdiscrim tone training, use toneThenSpeech below
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    updateSM=1;
    %default case (e.g. rights==lefts )
    
    tones = [4000 13000];
    
    if lefts>=rights %choose a left stim (wav1)
        details.toneFreq = tones(1);
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = tones(2);
    end
    
end

if strcmp(stimulus.soundType, 'toneThenSpeech')
    %For when only tone in discrim phase, phoneme will be played as
    %'correct sound' if used w/ soundmanager "makeSpeechSM_PhonCorrect"
    %Also need to calc phone. params and store them in freqDurable for
    %getClip, otherwise doesn't know what freq means what phoneme
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    updateSM=1;
    %default case (e.g. rights==lefts )
    
    tones = [2000 7000];
    
    %Always have lvl.1 speech difficulty settings in this type
    r1 = 1; %One speaker (Jonny)
    r2 = 1; %One Vowel Context (/I/)
    r3 = 3; %One Recording (best of Jonny's /bI/)
    
    if lefts>=rights %choose a left stim (wav1)
        details.toneFreq = tones(1);
        freqDurable = [1, r1, r2, r3];
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = tones(2);
        freqDurable = [2, r1, r2, r3];
    end
end


if strcmp(stimulus.soundType, 'phoneTone') %files specified in getClip-just need to indicate sad/dad
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    %Calculate percent correct
    correx = [];
    if length(trialRecords) > 52
        try
            for i = 1:50
                correx(i) = trialRecords(end-i).trialDetails.correct;
            end
        catch
            correx = trialRecords(:).correct;
        end
    else
        try
            for i = 1:length(trialRecords)
                correx(i) = trialRecords(end-i+1).trialDetails.correct;
            end
        catch
            correx = trialRecords(:).correct;
        end
    end
    correx(isnan(correx)) = []; %take out nans so the mean works
    pctcorrex = mean(correx);
    
    %Calc length of tone.
    duration = [];
    if pctcorrex <= .5  
        duration = 500;
    elseif pctcorrex>.5 & pctcorrex<.7
        duration = 500-((pctcorrex-.5)*2500); %linear decrease from 500ms to 0ms as they improve 
    elseif pctcorrex>=.7
        duration = 0;
    else     
        duration = 100;
        text = [text 'couldnt get corrects!'];
    end
    
    stimulus.duration = duration+500; %Total clip will be dur+500 ms long b/c adding phoneme
    
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
    case {'speechWav'}
        sSound = soundClip('stimSoundBase','speechWav', [details.toneFreq]);
    case {'phoneTone'}
        sSound = soundClip('stimSoundBase','phoneTone', [details.toneFreq]);
    case {'speechWavLaser'}
        sSound = soundClip('stimSoundBase','speechWavLaser', [details.toneFreq]);
    case {'speechWavLaserMulti'}
        sSound = soundClip('stimSoundBase','speechWavLaserMulti', [details.toneFreq]);
    case {'speechWavReversedReward'} %%%shit shit shit shit
        sSound = soundClip('stimSoundBase','speechWavReversedReward', [details.toneFreq]);
    case {'tone'}
        sSound = soundClip('stimSoundBase','tone', [details.toneFreq]);
    case {'toneThenSpeech'}
        sSound = soundClip('stimSoundBase','toneThenSpeech', [details.toneFreq]);
    case {'toneLaser'}
        sSound = soundClip('stimSoundBase','toneLaser', [details.toneFreq]);
end
stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude,details.toneFreq},{sSound,details.rightAmplitude,details.toneFreq});

%{
%%%%%%
%Make Figure for display
%Get all corrects
try
    for i = 1:(length(trialRecords)-1)
        correx(i) = trialRecords(end-i).trialDetails.correct;
    end
catch
    correx = trialRecords(:).correct;
end
correx(isnan(correx)) = [];

%Get windowed average & confidence intervals
if length(trialRecords)>50
    winSize = 50;
elseif length(trialRecords)>5
    winSize = 50;
else
    winSize = 1;
end
for i = winSize:length(correx)
    win50(i) = (sum(correx(i+1-winSize:i)))/winSize;
end
winconf = [];
winSizeVec = [];
winSizeVec(1:length(win50)) = winSize;
[~,winconf]=binofit(win50.*winSize, winSizeVec,.05);

%Make Figure
hfig = figure;
set(hfig, 'Visible', 'off');
set(hfig, 'Position', [1, 1, width, height]);
subplot(3,1,2)
plot(1:length(win50),win50)
xlim([1 length(win50)])
confplot=plot(winconf, ':');

%}


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
