function makeVanHatterenWNProtocol(duration)
global pref
%usage: makeVanHatterenWNProtocol(duration)

%creates an exper2 stimulus protocol file for a a van hatteren LED
% %intensity time series, except shuffled to create white noise with
% exactly the same distribution as the natural stimulus
% inputs:
% duration (in seconds): how much of the van hatteren time series to use
%   (entire time series are 2700 s long which is the max duration you could enter)
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
%
%example call: makeVanHatterenWNProtocol(120)
prefs
cd(pref.stimuli)
cd ('vanHatteren')


[VHfilename_ext, path] = uigetfile('*.txt', 'please choose van hatteren source file');
 cd (path)
[path, VHfilename]=fileparts(VHfilename_ext);
s=load(VHfilename_ext);
s=s(1:duration*1200); %load only partial stim
s=-10*s/32767; %normalize to [0,-10]
s=s(randperm(length(s)));
s=resample(s, 10e3, 1200); %resample from 1200 Hz to 10kHz

s(end)=0; %leave last value at ground
sample.param.description='van hatteren WN stimulus';
sample.sample=s;

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('vanHatteren_WN_%s_%ds', VHfilename, duration);
stimuli(1).param.description= sprintf('vanHatteren WN intensity time series %s duration=%ds', VHfilename, duration);

filename=sprintf('vanHatteren_WN_protocol_%s_%ds', VHfilename, duration);
sourcefilename=sprintf('vanHatteren_WN_sourcefile_%s_%ds', VHfilename, duration);

stimuli(2).type='led';
stimuli(2).param.file=sourcefilename;
stimuli(2).param.duration=duration*1e3; %in ms, =2700s=45minutes
stimuli(2).param.channel=1; %try chan 2????

%???note: isi not used!!!

cd (pref.stimuli)
save(filename, 'stimuli');
save(sourcefilename, 'sample');


