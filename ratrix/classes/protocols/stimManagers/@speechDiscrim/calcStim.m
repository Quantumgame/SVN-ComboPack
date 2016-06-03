function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks,sounds] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,targetPorts,distractorPorts,details,text)

global freqDurable;
global stimMap;

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

details.toneFreq = [];

if strcmp(stimulus.soundType, 'speechWav') 
    map = {'gI', 'go', 'ga', 'gae', 'ge', 'gu'; 'bI', 'bo', 'ba', 'bae', 'be', 'bu'};
    
    stimMap = stimulus.stimMap;
    
    if stimMap == 1
        names = {'Jonny','Ira','Anna','Dani','Theresa'};
    elseif stimMap == 2
        names = {'Theresa','Dani','Jonny','Ira','Anna'};
    end
    
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    switch stimulus.stimLevel %Choose stim, mapped in getClip
        case 1 %base
            r1 = 1; %One speaker (Jonny)
            r2 = 1; %One Vowel Context (/I/)
            r3 = 1; %One Recording (/bI/)
        case 2 %2 recordings
            r1 = 1;
            r2 = 1;
            r3 = randi(2,1); %get recording 1 or 2
        case 3 %2 vowels/2 recordings of /I/, one of /o/
            r1 = 1;
            r2 = randi(2,1);
            if r2 == 2 
                r3 = 1; %one recording of /o/
            else
                r3 = randi(2,1);
            end
        case 4 %2 speakers/2 vowels/2 recordings of prev speak,1 of new
            r1 = randi(2,1);
            r2 = randi(2,1);
            if r1 == 2 %one recording if second speaker this time
                r3 = 1;
            else
                r3 = randi(2,1);
            end
        case 5 %2 speakers/3 vowels/2 recordings of prev vowel, 1 of new.
            r1 = randi(2,1);
            r2 = randi(3,1);
            if r2 == 3
                r3 = 1;
            else
                r3 = randi(2,1);
            end
        case 6 %Experimental phase - get a shit ton of sound files
            
    end
    
    if lefts >= rights %choose a left stim (/g/)
        details.toneFreq = [1, r1, r2, r3];
        freqDurable = [1, r1, r2, r3];

    elseif rights>lefts %choose a right stim (/b/)
        details.toneFreq = [2, r1, r2, r3];
        freqDurable = [2, r1, r2, r3];
    end
    

    %Print current stim
    text = [text, sprintf('   Current Stim: %s, Speaker: %s, Token: %d   ',map{r0,r2},names{r1},r3)];
end

if strcmp(stimulus.soundType, 'speechWavAll') 
    stimMap = stimulus.stimMap;
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    pctLearned = stimulus.pct1;
    pctNovel   = stimulus.pct2;
    
    if lefts >= rights %choose a left stim (/g/)
        r0 = 1;
    elseif rights>lefts %choose a right stim (/b/)
        r0 = 2;
    end
    
    map = {'gI', 'go', 'ga', 'gae', 'ge', 'gu'; 'bI', 'bo', 'ba', 'bae', 'be', 'bu'};
    if stimulus.stimMap == 1
        names = {'Jonny','Ira','Anna','Dani','Theresa'};
    elseif stimulus.stimMap == 2
        names = {'Theresa','Dani','Jonny','Ira','Anna'};
    end
        

    %Check if we're going to give an expt. stimulus, then check which type
    pctExpt = pctLearned+pctNovel;
    rndn = rand;
    if rndn>pctExpt
        %For now, set base level as lvl 4 difficulty
        r1 = randi(2,1);
        r2 = randi(2,1);
        if r1 == 2 %one recording if second speaker this time
            r3 = 1;
        else
            r3 = randi(2,1);
        end
        r4 = 1; %tells us it's not expt

    elseif rndn>pctNovel
        %Is Learned
        r1 = randi(5,1); %five speakers (Anna, Dani, Ira, Jonny, Theresa as of 5.21.16)
        r2 = randi(2,1); %since base difficulty 4, only 2 vowel contexts atm
        %Need to find how many tokens available for this speaker
        foldir = char(strcat('C:\Users\nlab\Desktop\ratrixSounds\phonemes\',names(r1),'\CV\',map(r0,r2),'\*.wav'));
        recs = numel(dir(foldir));
        r3 = randi(recs,1);
        r4 = 2; %tells us it's learned
    else
        %Is Novel
        r1 = randi(5,1); %six speakers (Anna, Dani, Ira, Jonny, Theresa as of 5.21.16)
        if stimulus.stimMap == 1
            if r1 == 1
                r2 = randi(3,1); %jonny only has 3 vowel contexts cut atm
            else
                r2 = randi(6,1); %all recorded vowel contexts
            end
        elseif stimulus.stimMap ==2
            if r1 == 3
                r2 = randi(3,1); %jonny only has 3 vowel contexts cut atm
            else
                r2 = randi(6,1); %all recorded vowel contexts
            end
        end
        %Need to find how many tokens available for this speaker
        foldir = char(strcat('C:\Users\nlab\Desktop\ratrixSounds\phonemes\',names(r1),'\CV\',map(r0,r2),'\*.wav'));
        recs = numel(dir(foldir));
        r3 = randi(recs,1);
        r4 = 3; %tells us it's novel
    end
    
    details.toneFreq = [r0, r1, r2, r3, r4];
    freqDurable = [r0, r1, r2, r3, r4];
    

    text = [text, sprintf('   Current Stim: %s, Speaker: %s, Token: %d   ',map{r0,r2},names{r1},r3)];
    
end



if strcmp(stimulus.soundType, 'toneThenSpeech')
    stimMap = stimulus.stimMap;
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
    r3 = 1; %One Recording (best of Jonny's /bI/)
    
    if lefts>=rights %choose a left stim (wav1)
        details.toneFreq = tones(1);
        freqDurable = [1, r1, r2, r3];
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = tones(2);
        freqDurable = [2, r1, r2, r3];
    end
end


if strcmp(stimulus.soundType, 'phoneTone') 
    stimMap = stimulus.stimMap;
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
        text = [text, sprintf('Duration: %d',duration)];
    elseif pctcorrex>.5 & pctcorrex<.7
        duration = 500-((pctcorrex-.5)*2500); %linear decrease from 500ms to 0ms as they improve 
        text = [text, sprintf('Duration: %d',duration)];
    elseif pctcorrex>=.7
        duration = 0;
        text = [text, sprintf('Duration: %d',duration)];
    else     
        duration = 0;
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
   
    
if strcmp(stimulus.soundType, 'morPhone')    
    %Not implemented yet...
end

if strcmp(stimulus.soundType, 'speechComponent')    
    %Not implemented yet...
end


details.rightAmplitude = stimulus.amplitude;
details.leftAmplitude = stimulus.amplitude;

% fid=fopen('miketest.txt', 'a+t')
% fprintf(fid, '\nintensity discrim/calcstim: laserON=%d',details.laserON)
% fclose(fid)
switch stimulus.soundType
    case {'speechWav'}
        sSound = soundClip('stimSoundBase','speechWav', [details.toneFreq]);
    case {'speechWavAll'}
        sSound = soundClip('stimSoundBase','speechWavAll', [details.toneFreq]);
    case {'phoneTone'}
        sSound = soundClip('stimSoundBase','phoneTone', [details.toneFreq]);
    case {'toneThenSpeech'}
        sSound = soundClip('stimSoundBase','toneThenSpeech', [details.toneFreq]);
    case {'morPhone'}
        sSound = soundClip('stimSoundBase','morPhone', [details.toneFreq]);
    case {'speechComponent'}
        sSound = soundClip('stimSoundBase','speechComponent', [details.toneFreq]);
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
