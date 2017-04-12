function sm=makeBlankSoundManager()
% this is a manager for auditory intensity discrimination
% where we want tight control over sounds

sm=soundManager({soundClip('correctSound','empty'), ...
            soundClip('keepGoingSound','empty'), ...
            soundClip('trySomethingElseSound','empty'), ...
            soundClip('wrongSound','empty'),... 
            soundClip('earlywrongSound','empty'),...
            soundClip('trialStartSound','empty')});