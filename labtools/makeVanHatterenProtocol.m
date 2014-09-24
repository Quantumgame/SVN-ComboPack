function makeVanHatterenProtocol(duration)
global pref
%usage: makeVanHatterenProtocol(duration)

%creates an exper2 stimulus protocol file for a a van hatteren LED
% %intensity time series
% inputs:
% duration (in seconds): how much of the van hatteren time series to use
%   (entire time series are 2700 s long which is the max duration you could enter)
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
% time series are from http://hlab.phys.rug.nl/tslib/index.html
%
%example call: makeVanHatterenProtocol(120)
prefs
cd(pref.stimuli)
cd ('vanHatteren')


[VHfilename_ext, path] = uigetfile('*.txt', 'please choose van hatteren source file');
 cd (path)
[path, VHfilename]=fileparts(VHfilename_ext);
s=load(VHfilename_ext);
s=s(1:duration*1200); %load only partial stim
%(original VH files were sampled at 1200Hz)
s=-10*s/32767; %normalize to [0,-10]
s=resample(s, 10e3, 1200); %resample from 1200 Hz to 10kHz

s(end)=0; %leave last value at ground
sample.param.description='van hatteren stimulus';
sample.sample=s;

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('vanHatteren_%s_%ds', VHfilename, duration);
stimuli(1).param.description= sprintf('vanHatteren natural intensity time series %s duration=%ds', VHfilename, duration);

filename=sprintf('vanHatteren_protocol_%s_%ds', VHfilename, duration);
sourcefilename=sprintf('vanHatteren_sourcefile_%s_%ds', VHfilename, duration);

stimuli(2).type='led';
stimuli(2).param.file=sourcefilename;
stimuli(2).param.duration=duration*1e3; %in ms, =2700s=45minutes
stimuli(2).param.channel=1; %try chan 2????

%???note: isi not used!!!

cd (pref.stimuli)
save(filename, 'stimuli');
save(sourcefilename, 'sample');


