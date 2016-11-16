function makeLEDpulseProtocol2(start, width, height, npulses, isi, next) 

global pref
%usage: makeLEDpulseProtocol(pulsedur, amplitude, isi) 

 
% inputs:
% pulsedur: duration of the pulse in ms
% amplitude:  amplitude of the pulse, in V
% isi: inter-pulse-interval
%
%creates an exper2 stimulus protocol file of a single pulse
% for an LED. 
%total duration of the file is twice the pulse duration
%
% outputs:
% creates a suitably named stimulus protocol in \exper2.2\protocols\AO Protocols
%
%
%example call: makeLEDpulseProtocol2(100, 500, 5, 1, 1,1000)

% samplingrate=10e3; %
% t=1:2*pulsedur*samplingrate/1000;
% t=t/samplingrate;
% s=zeros(size(t));
% s(1:pulsedur*samplingrate/1000)=5;

%s(end)=0; %leave last value at ground
% sample.param.description=sprintf('pulse LED stimulus, %dms, %d%%', pulsedur, amplitude);
% sample.sample=s;

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('LEDpulse_%d_%d_%d', width, height, npulses);
stimuli(1).param.description= sprintf('pulse LED stimulus, %dms, %dV, n%d', width, height, npulses);

filename=sprintf('AO protocols\\LEDpulse_protocol_%d_%d_%d', width, height, npulses);

stimuli(2).type='aopulse';
stimuli(2).param.start=start;  %all in ms
stimuli(2).param.width=width;
stimuli(2).param.height=height; % in V???
stimuli(2).param.isi=isi;
stimuli(2).param.npulses=npulses;
stimuli(2).param.duration=npulses*(width+isi)+start; 
stimuli(2).param.next=next;


Prefs
cd (pref.stimuli)
%cd ('AO protocols')
save(filename, 'stimuli');


