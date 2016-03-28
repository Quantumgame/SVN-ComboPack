function sm=makeSpeechSoundManager(noiseparams)
% this is a manager for auditory intensity discrimination
% where we want tight control over sounds

sm=soundManager({soundClip('correctSound','empty'), ...
            soundClip('keepGoingSound','empty'), ...
            soundClip('trySomethingElseSound','empty'), ...
            soundClip('wrongSound','pulseAndNoise',noiseparams),... 
            soundClip('earlywrongSound','pulseAndNoise',noiseparams),...
            soundClip('trialStartSound','empty')});