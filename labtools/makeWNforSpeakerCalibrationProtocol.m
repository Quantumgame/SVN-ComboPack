function makeWNforSpeakerCalibrationProtocol(duration)
global pref
%usage: makeWNforSpeakerCalibrationProtocol(duration)

%creates an exper2 stimulus protocol file for a sample of white noise 
% 

% inputs:
% duration (in seconds): how long WN should be
% outputs:
% creates a suitably named stimulus protocol in D:\wehr\exper2.2\protocols
%
%
%example call: makeWNforSpeakerCalibrationProtocol(60)

params.duration=duration*1000;
params.amplitude=80;
params.ramp=10;
sample=MakeWhiteNoise(params, 2e5);



%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('WN for Speaker Calibration %ds', duration);
stimuli(1).param.description= sprintf('WN for Speaker Calibration duration=%ds, amplitude=%d', duration, params.amplitude);

filename=sprintf('WNforSpeakerCalibration%ds', duration);
sourcefilename=sprintf('WNforSpeakerCalibration_sourcefile_%ds', duration);

stimuli(2).param.file=sourcefilename;
stimuli(2).param.type='soundfile';
stimuli(2).param.duration=duration*1e3; %in ms, =2700s=45minutes


%???note: isi not used!!!

Prefs
cd (pref.stimuli)
save(filename, 'stimuli');
save(sourcefilename, 'sample');


