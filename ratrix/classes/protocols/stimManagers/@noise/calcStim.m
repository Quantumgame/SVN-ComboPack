function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks,sounds] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,targetPorts,distractorPorts,details,text)

% Irrelevant but necessary declarations
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

if strcmp(stimulus.soundType, 'noise')  
    details.toneFreq = [];
end

details.rightAmplitude = stimulus.amplitude;
details.leftAmplitude = stimulus.amplitude;

% fid=fopen('miketest.txt', 'a+t')
% fprintf(fid, '\nintensity discrim/calcstim: laserON=%d',details.laserON)
% fclose(fid)
switch stimulus.soundType
    case {'noise'}
        sSound = soundClip('stimSoundBase','speechWav', [details.toneFreq]);
   end
stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude,details.toneFreq},{sSound,details.rightAmplitude,details.toneFreq});




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
