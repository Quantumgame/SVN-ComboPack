function makeAOpulseProtocol(pulsedur, amplitude, isi) 

%usage: makeAOpulseProtocol(pulsedur, amplitude, isi) 
% inputs:
% pulsedur: duration of the pulse in ms
% amplitude:  amplitude of the pulse, in %
% isi: inter-pulse-interval, is only accurate for isi> about 500
%       (for isi<500 machine will probably not be able to follow)
%
%creates an exper2 stimulus protocol file of a single pulse
% for an analog output (DAC1out). The pulse varies from zero to
%amplitude (in %) where 100%=max AD 
%total duration of the file is twice the pulse duration
%Note: the stimulus Type is 'led', not AOPulse
%
% outputs:
% creates a suitably named stimulus protocol in
% \protocols|AO Protocols
%
%Note: changed from 'led' stimulus Type to AOPulse stimulus Type mw 12-16-2011
%
%example call: makeAOpulseProtocol(10, 100, 500)
global pref

samplingrate=10e3; %
t=1:2*pulsedur*samplingrate/1000;
t=t/samplingrate;
s=zeros(size(t));
s(1:pulsedur*samplingrate/1000)=(amplitude/100)*10;

s(end)=0; %leave last value at ground
sample.param.description=sprintf('AO pulse stimulus, %dms duration, %d%%amplitude', pulsedur, amplitude);
sample.sample=s;

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('AOpulse_%d_%d_%d', pulsedur, amplitude, isi);
stimuli(1).param.description= sprintf('AO pulse stimulus, %dms, %d%%, %disi', pulsedur, amplitude, isi);

filename=sprintf('AO protocols\\AOpulse_protocol_%d_%d_%d', pulsedur, amplitude, isi);
sourcefilename=sprintf('AO protocols\\AOpulse_sourcefile_%d_%d_%d', pulsedur, amplitude, isi);

stimuli(2).type='led';
stimuli(2).param.file=sourcefilename;
stimuli(2).param.duration=2*pulsedur; %in ms, =2700s=45minutes
stimuli(2).param.channel=1; %try chan 2????
stimuli(2).param.next=isi;


Prefs
cd (pref.stimuli)
%cd LED protocols
save(filename, 'stimuli');
save(sourcefilename, 'sample');


