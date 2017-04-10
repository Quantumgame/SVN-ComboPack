function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks,sounds] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,targetPorts,distractorPorts,details,text)


global freqCon

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
    case {'tone615'}
    case {'phoneToneConor'}   
    case {'toneThenPhoneme'}
    case {'toneLaser'}
        %this is for pure tone control protocol
        details.laserON = rand>0.9; %laser is on for 10% of trials
        details.laser_duration=.5; %seconds
        details.laser_start_time=Inf;
        details.laser_off_time=Inf;
        details.laser_start_window=0;
        details.laser_wait_start_time=Inf;
    case {'phonemeWav'}
    case {'phonemeWavLaser'}
        details.laserON = rand>.9; %laser is on for 10% of trials
        details.laser_duration=.5; %seconds
        details.laser_start_time=Inf;
        details.laser_off_time=Inf;
        details.laser_start_window=0;
        details.laser_wait_start_time=Inf;
    case {'phonemeWavReversedReward'}
    case {'phonemeWavLaserMulti'}
        details.laserON = rand>.8;
        details.laser_start_window=RandSample([0 .14]); %randomly choose one of the start points
        %details.laser_duration=(stimulus.freq(2)-stimulus.freq(1))*.001; %spacing between start times determines the interval length
        details.laser_duration=.14;
        details.laser_start_time=Inf;
        details.laser_wait_start_time=Inf;
        details.laser_off_time=Inf;
end






if stimulus.duration==50  %stimulus.freq empty for phoneme, [1] for phonemelaser
    %special case for laserCal
    details.laserON = 1; %laser is on for 10% of trials
    details.laser_duration=30; %seconds
    details.laser_start_time=Inf;
    details.laser_off_time=Inf;
end



details.toneFreq = [];

if strcmp(stimulus.soundType, 'phonemeWav')  %files specified in getClip-just need to indicate sad/dad
    %this code works for no laser condition - below for laser
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    
    %default case (e.g. rights==lefts )
    
    if lefts>rights %choose a left stim (wav1)
        details.toneFreq = 1;
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = 0;
    end
    if lefts == rights %left
        details.toneFreq = 1;
    end
end

if strcmp(stimulus.soundType, 'phonemeWavReversedReward') %files specified in getClip-just need to indicate sad/dad
    %this code works for no laser condition - below for laser
    %same as above for now, duplicated for future potential modifications
    %CO 5-6
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    
    %default case (e.g. rights==lefts )
    
    if lefts>rights %choose a left stim (wav1)
        details.toneFreq = 1;
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = 0;
    end
    if lefts == rights %left
        details.toneFreq = 1;
    end
end


if strcmp(stimulus.soundType, 'toneLaser') %files specified in getClip-just need to indicate sad/dad
    
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
    
    if details.laserON
        details.toneFreq=RandSample(tones);
    end
    
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

if strcmp(stimulus.soundType, 'tone615') %files specified in getClip-just need to indicate sad/dad
    
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    
    %default case (e.g. rights==lefts )
    
    tones = [6000 15000];
    
    if lefts>rights %choose a left stim (wav1)
        details.toneFreq = tones(1);
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = tones(2);
    end
    if lefts == rights %left
        details.toneFreq = tones(1);
    end

end


if strcmp(stimulus.soundType, 'phonemeLaser') || strcmp(stimulus.soundType, 'phonemeLaserMulti') %laser assignment - random stimulus for laser trials
    
    
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    
    %default case (e.g. rights==lefts )
    
    if lefts>rights %choose a left stim (wav1)
        details.toneFreq = 1;
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = 0;
    end
    
    if lefts == rights %left
        details.toneFreq = 1;
    end
    
    if details.laserON %randomly reward by choosing random stimulus
        details.toneFreq=RandSample(0:1);
    end
    
    
end


if strcmp(stimulus.soundType, 'toneThenPhoneme')
   
    %For when only tone in discrim phase, phoneme will be played as
    %'correct sound' if used w/ soundmanager "makePhonCorrectSoundManager"
    %Also need to calc phone. params and store them in freqCon for
    %getClip, otherwise doesn't know what freq means what phoneme
    [lefts, rights] = getBalance(responsePorts,targetPorts);
    updateSM=1;
    %default case (e.g. rights==lefts )
    duration=500;
    tones = [2000 7000];
    
    if lefts>=rights %choose a left stim (wav1)
        details.toneFreq = tones(1);
        freqCon = [1, duration];
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = tones(2);
        freqCon = [0, duration];
    end
end

if strcmp(stimulus.soundType, 'phoneToneConor') 
    
    
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
        freqCon = [1,duration];
    elseif rights>lefts %choose a right stim (wav2)
        details.toneFreq = [0, duration];
        freqCon = [0, duration];
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
    case {'wmReadWav'}
        sSound = soundClip('stimSoundBase','wmReadWav', [details.toneFreq]);
    case {'phonemeWav'}
        sSound = soundClip('stimSoundBase','phonemeWav', [details.toneFreq]);
    case {'toneThenPhoneme'}
        sSound = soundClip('stimSoundBase','toneThenPhoneme', [details.toneFreq]);
    case {'phoneToneConor'}
        sSound = soundClip('stimSoundBase','phoneToneConor', [details.toneFreq]);
    case {'phonemeWavLaser'}
        sSound = soundClip('stimSoundBase','phonemeWavLaser', [details.toneFreq]);
    case {'phonemeWavLaserMulti'}
        sSound = soundClip('stimSoundBase','phonemeWavLaserMulti', [details.toneFreq]);
    case {'phonemeWavReversedReward'} %%%shit shit shit shit
        sSound = soundClip('stimSoundBase','phonemeWavReversedReward', [details.toneFreq]);
    case {'tone'}
        sSound = soundClip('stimSoundBase','tone', [details.toneFreq]);
    case {'tone615'}
        sSound = soundClip('stimSoundBase','tone615', [details.toneFreq]);
    case {'toneLaser'}
        sSound = soundClip('stimSoundBase','toneLaser', [details.toneFreq]);
end
stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude},{sSound,details.rightAmplitude});


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