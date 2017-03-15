function makeLEDpulseProtocol(pulsedur, amplitude, isi) 

global pref
%usage: makeLEDpulseProtocol(pulsedur, amplitude, isi) 

 
% inputs:
% pulsedur: duration of the pulse in ms
% amplitude:  amplitude of the pulse, in %
% isi: inter-pulse-interval, is only accurate for isi> about 500
%       (for isi<500 machine will probably not be able to follow)
%
%creates an exper2 stimulus protocol file of a single pulse
% for an LED. The pulse varies from zero to
%amplitude (in %) where 100%=max AD range=max brightness
%total duration of the file is twice the pulse duration
%
% outputs:
% creates a suitably named stimulus protocol in D:\wehr\exper2.2\protocols
%
%
%example call: makeLEDpulseProtocol(10, 100, 500)

samplingrate=10e3; %
t=1:2*pulsedur*samplingrate/1000;
t=t/samplingrate;
s=zeros(size(t));
s(1:pulsedur*samplingrate/1000)=-10;

s(end)=0; %leave last value at ground
sample.param.description=sprintf('pulse LED stimulus, %dms, %d%%', pulsedur, amplitude);
sample.sample=s;

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('LEDpulse_%d_%d_%d', pulsedur, amplitude, isi);
stimuli(1).param.description= sprintf('pulse LED stimulus, %dms, %d%%, %disi', pulsedur, amplitude, isi);

filename=sprintf('LED protocols\\LEDpulse_protocol_%d_%d_%d', pulsedur, amplitude, isi);
sourcefilename=sprintf('LED protocols\\LEDpulse_sourcefile_%d_%d_%d', pulsedur, amplitude, isi);

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


