function MakeConditioningProtocol(iti,delay, tonefreq, toneamp, tonedur, ramp) 
%
%tried to use cell array of multiple stimuli to get rid of delay between consecutive
%stimuli, but stimulus protocol is choking on the cell array at line 223
%this is under development for now
%mw 042507
%
%usage: makeConditioningProtocol(iti,delay, tonefreq, toneamp, tonedur, ramp) 
% makes a protocol of paired pulses and tones
% the pulses are fixed at 10V, 10 ms for triggering the Grass S88
% you can then control the delay/duration/amplitude of the shock(s) with the S88 front panel
% 
% inputs:
% iti: inter-trial-interval, time from one tone to next tone (in ms)
% delay: time between onset of tone and shock (-1 for co-termination)
%
% the following four parameters are for the tone
% tonefreq (Hz), -1 for whitenoise
% toneamp (dB)
% tonedur (ms)
% ramp (ms) 
%
% outputs:
% creates a suitably named stimulus protocol in
% D:\wehr\exper2.2\protocols|AO Protocols
%
%
%example call: MakeConditioningProtocol(20e3,-1, 8000, 80, 200, 5) 

global pref

pulsedur=10; %ms, just a trigger for S88
samplingrate=10e3; %
t=1:2*pulsedur*samplingrate/1000;
t=t/samplingrate;
s=zeros(size(t));
s(1:pulsedur*samplingrate/1000)=10; %10V

%if delay==-1; delay=tonedur; end

s(end)=0; %leave last value at ground
sample.param.description=sprintf('AO pulse stimulus, %dms duration, 10V', pulsedur);
sample.sample=s;

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('Conditioning Protocol_%d_%d_%d_%d_%d', iti, delay, tonefreq, toneamp, tonedur);
stimuli(1).param.description= sprintf('Conditioning pair (pulse+tone), iti %dms, delay %dms, %dHz, %ddB, %dms tone', iti, delay, tonefreq, toneamp, tonedur);

filename=sprintf('AO protocols\\Cond_protocol_%d_%d_%d_%d_%d', iti, delay, tonefreq, toneamp, tonedur);
sourcefilename=sprintf('AO protocols\\Cond_protocol_sourcefile_%d_%d_%d_%d_%d', iti, delay, tonefreq, toneamp, tonedur);
if tonefreq==-1
    stimuli(2).type{1}='whitenoise';
    stimuli(2).param{1}.amplitude=toneamp;
    stimuli(2).param{1}.duration=tonedur;
    stimuli(2).param{1}.ramp=ramp;
    stimuli(2).param{1}.next=delay;
else
    stimuli(2).type{1}='tone';
    stimuli(2).param{1}.frequency=tonefreq;
    stimuli(2).param{1}.amplitude=toneamp;
    stimuli(2).param{1}.duration=tonedur;
    stimuli(2).param{1}.ramp=ramp;
    stimuli(2).param{1}.next=delay;
end
        
stimuli(2).type{2}='led';
stimuli(2).param{2}.file=sourcefilename;
stimuli(2).param{2}.duration=pulsedur; 
stimuli(2).param{2}.channel=1; %try chan 2????
stimuli(2).param{2}.next=iti;


Prefs
cd (pref.stimuli)
save(filename, 'stimuli');
save(sourcefilename, 'sample');


