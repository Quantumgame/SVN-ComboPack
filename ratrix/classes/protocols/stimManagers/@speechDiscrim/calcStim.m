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
    elseif stimMap == 3
        names = {'Anna','Theresa','Dani','Jonny','Ira'};
    elseif stimMap == 4
        names = {'Dani','Anna','Theresa','Jonny','Ira'};
    elseif stimMap == 5
        names = {'Ira', 'Dani', 'Jonny', 'Anna', 'Theresa'};
    elseif stimMap == 6
        names = {'Theresa', 'Jonny', 'Ira', 'Anna', 'Dani'};
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
        r0 = 1;
    elseif rights>lefts %choose a right stim (/b/)
        details.toneFreq = [2, r1, r2, r3];
        freqDurable = [2, r1, r2, r3];
        r0 = 2;
    end

    %Print current stim

    text = [text, sprintf('   Current Stim: %s, Speaker: %s, Token: %d   ',map{r0,r2},names{r1},r3)];
end


if strcmp(stimulus.soundType, 'speechWavAll')
    stimMap = stimulus.stimMap;
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    pctLearned = .1;
    pctNovel   = .1;

    if lefts >= rights %choose a left stim (/g/)
        r0 = 1;
    elseif rights>lefts %choose a right stim (/b/)
        r0 = 2;
    end

    map = {'gI', 'go', 'ga', 'gae', 'ge', 'gu'; 'bI', 'bo', 'ba', 'bae', 'be', 'bu'};
    if stimMap == 1
        names = {'Jonny','Ira','Anna','Dani','Theresa'};
    elseif stimMap == 2
        names = {'Theresa','Dani','Jonny','Ira','Anna'};
    elseif stimMap == 3
        names = {'Anna','Theresa','Dani','Jonny','Ira'};
    elseif stimMap == 4
        names = {'Dani','Anna','Theresa','Jonny','Ira'};
    elseif stimMap == 5
        names = {'Ira', 'Dani', 'Jonny', 'Anna', 'Theresa'};
    elseif stimMap == 6
        names = {'Theresa', 'Jonny', 'Ira', 'Anna', 'Dani'};
    end

    %Check if we're going to give an expt. stimulus, then check which type
    pctExpt = pctLearned+pctNovel;
    rndn = rand;
    if rndn>pctExpt
        %For now, set base level as lvl 4 difficulty
        %Changed to lvl 5 9/15/16 -JLS
        r1 = randi(2,1);
        r2 = randi(3,1);
        if r2 == 3
            r3 = 1;
        else
            r3 = randi(2,1);
        end
        r4 = 1; %tells us it's not expt

    elseif rndn>pctNovel
        %Is Learned vowel, but novel token/speaker
        r1 = randi(5,1); %five speakers (Anna, Dani, Ira, Jonny, Theresa as of 5.21.16)
        r2 = randi(3,1);

        %Exclude base tokens
        if (r1 == 1)|(r1 == 2) % If base speakers
            if (r2 == 1)|(r2 == 2) % And lower level vowel
                r3 = 3; %Only pick the third token
            elseif (r2 == 3)
                r3 = randi(2,1)+1; %Only pick the last two
            end
        else % If novel speaker, we can pick any token.
            % First how many tokens available for this speaker (all have 3 but Anna only has 2 gae -JLS09152016)
            foldir = char(strcat('C:\Users\nlab\Desktop\ratrixSounds\phonemes\',names(r1),'\CV\',map(r0,r2),'\*.wav'));
            recs = numel(dir(foldir));
            r3 = randi(recs,1);
        end
        r4 = 2; %tells us it's learned

    else
        %Is Novel vowel
        if stimulus.stimMap == 1
            r1 = randi(4,1)+1; % Shouldn't use any of Jonny's recordings b/c only has 3 vowels
        elseif stimulus.stimMap == 2
            r1 = randsample([1,2,4,5],1); % Again don't want Jonny's recordings
        end

        r2 = randi(3,1)+3; % All novel vowel contexts (Implicitly excludes base tokens)

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

if strcmp(stimulus.soundType, 'speechWavAllUniform')
    % Sample all generalization tookens with equal probability
    stimMap = stimulus.stimMap;
    [lefts, rights] = getBalance(responsePorts,targetPorts);

    if lefts >= rights %choose a left stim (/g/)
        r0 = 1;
    elseif rights>lefts %choose a right stim (/b/)
        r0 = 2;
    end

    map = {'gI', 'go', 'ga', 'gae', 'ge', 'gu'; 'bI', 'bo', 'ba', 'bae', 'be', 'bu'};
    % stimMap doesn't matter for uniform sampling, use default for simplicity
    names = {'Jonny','Ira','Anna','Dani','Theresa'};

    % Get list of all cvs
    if r0 == 1
        all_cvs = getFilenames('C:\Users\nlab\Desktop\ratrisSounds\cv_consonant_split\g');
    elseif r0 == 2
        all_cvs = getFilenames('C:\Users\nlab\Desktop\ratrisSounds\cv_consonant_split\b');
    end

    % Pick one
    this_cv = datasample(all_cvs,1);

    % Backfill toneFreq parameters
    % Split path
    cv_file_parts = regexp(this_cv{1}, filesep, 'split');

    % Get name
    name_ind = strfind(names, cv_file_parts{end-2});
    r1 = find(not(cellfun('isempty', name_ind)));

    % Get vowel
<<<<<<< a16e0a142f2c2665cdce89964b358e3842a1e9b0
    vow_ind = find(strcmp(map, cv_file_parts{end-1}));
    %vow_ind = find(not(cellfun('isempty', vow_ind)));
    if mod(vow_ind,2)==0
        r2 = vow_ind/2;
    else
        if vow_ind==1
            r2=1;
        elseif vow_ind==3
            r2=2;
        elseif vow_ind==5
            r2=3;
        elseif vow_ind==7
            r2=4;
        elseif vow_ind==9
            r2=5;
        elseif vow_ind==11
            r2 = 6;
        end
    end

    % Get token
    tok_name = cv_file_parts{end};
    r3 = str2num(tok_name(end-4));


    details.toneFreq = [r0, r1, r2, r3];
    freqDurable = [r0, r1, r2, r3];


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
    map = {'gI', 'go', 'ga', 'gae', 'ge', 'gu'; 'bI', 'bo', 'ba', 'bae', 'be', 'bu'};
    if stimMap == 1
        names = {'Jonny','Ira','Anna','Dani','Theresa'};
    elseif stimMap == 2
        names = {'Theresa','Dani','Jonny','Ira','Anna'};
    elseif stimMap == 3
        names = {'Anna','Theresa','Dani','Jonny','Ira'};
    elseif stimMap == 4
        names = {'Dani','Anna','Theresa','Jonny','Ira'};
    elseif stimMap == 5
        names = {'Ira', 'Dani', 'Jonny', 'Anna', 'Theresa'};
    elseif stimMap == 6
        names = {'Theresa', 'Jonny', 'Ira', 'Anna', 'Dani'};
    end

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
                correx(i) = trialRecords(i).trialDetails.correct;
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
        r0 = 1;
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = [2, duration];
        freqDurable = [2, duration];
        r0 = 2;
    end

     %Print current stim
    text = [text, sprintf('   Current Stim: %s, Speaker: %s, Token: %d   ',map{r0,1},names{1},1)];
end

if strcmp(stimulus.soundType, 'tone') %files specified in getClip-just need to indicate sad/dad


    [lefts, rights] = getBalance(responsePorts,targetPorts);

    %default case (e.g. rights==lefts )

    tones = [4000 13000];


    if lefts>rights %choose a left stim (wav1)
        details.toneFreq = tones(1);
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = tones(2);
    end
    if lefts == rights %left
        details.toneFreq = tones(1);
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
    case {'speechWavAllUniform'}
        sSound = soundClip('stimSoundBase','speechWavAllUniform', [details.toneFreq]);
    case {'phoneTone'}
        sSound = soundClip('stimSoundBase','phoneTone', [details.toneFreq]);
    case {'toneThenSpeech'}
        sSound = soundClip('stimSoundBase','toneThenSpeech', [details.toneFreq]);
    case {'morPhone'}
        sSound = soundClip('stimSoundBase','morPhone', [details.toneFreq]);
    case {'speechComponent'}
        sSound = soundClip('stimSoundBase','speechComponent', [details.toneFreq]);
    case {'tone'}
        sSound = soundClip('stimSoundBase','tone', [details.toneFreq]);
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
