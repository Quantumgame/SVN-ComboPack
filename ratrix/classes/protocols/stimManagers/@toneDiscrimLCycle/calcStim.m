function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks,sounds] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,targetPorts,distractorPorts,details,text)

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

details.LaserTurnON=0; %set to be 0, modify if necessary
details.LaserTurnOFF=0;

details.responseTime=0;
details.soundONTime=0;

switch stimulus.soundType

    case {'toneLCycle10'}
        details.cycPeriod =10;

end

details.TrialInCyc=1; %set in case it doesn't exist

sessionNum = trialRecords(end).sessionNumber; %find the current session
details.TrialNum = trialRecords(end).trialNumber; %find the current trial

for i = 1:size(trialRecords,2)
    sesh(i) = trialRecords(i).sessionNumber;

end

if sessionNum > 1
    details.TrialNumSStart = find(sesh==sessionNum,1,'last');
else
    details.TrialNumSStart = find(sesh==sessionNum,1);
end

details.TrialInSes = details.TrialNum-details.TrialNumSStart+1; %1 is first trial



if details.TrialInSes > 1
    details.TrialInCyc= mod(details.TrialInSes, 2*details.cycPeriod) ;
    if details.TrialInCyc == details.cycPeriod + 1 %11th trial, turn on laser
         details.LaserTurnON = 1;
    elseif details.TrialInCyc == 0 %turn off at end of the 20th trial?
    elseif details.TrialInCyc == 1 %or start of the 21st?
         details.LaserTurnOFF =1;
    end

end





% %decide randomly if we issue a laser pulse on this trial or not







details.toneFreq = [];


if strcmp(stimulus.soundType, 'toneLCycle10') %files specified in getClip-just need to indicate sad/dad

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
    case {'tone'}
        sSound = soundClip('stimSoundBase','tone', [details.toneFreq]);
    case {'toneLaser'}
        sSound = soundClip('stimSoundBase','toneLaser', [details.toneFreq]);
    case {'toneLCycle10'}
        sSound = soundClip('stimSoundBase','toneLCycle10', [details.toneFreq]);
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
