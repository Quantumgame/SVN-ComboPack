function makeAOpulseProtocol(width, height,  isi, varargin)

%usage: makeAOpulseProtocol(width, height, isi, [numreps], [npulses][, [ipi] )
% inputs:
% width: duration of the pulse in ms
% height:  amplitude of the pulse, in V
% isi: interstimulus interval (between pulses for single pulse or between
% trains for a pulse train)
% optional input:
% numreps: number of repetitions
% optional inputs if you want a train of pulses:
% npulses: number of pulses in the train
% ipi: inter-pulse-interval within the train
%
%creates an exper2 stimulus protocol file for pulses on analog output (DAC0 or DAC1out depending on prefs).
%
%
%Note: the stimulus Type is aopulse
%
% outputs:
% creates a suitably named stimulus protocol in
% \protocols|AO Protocols
%
%Note: changed from 'led' stimulus Type to AOPulse stimulus Type mw 12-16-2011
%
%example calls: 
%makeAOpulseProtocol(10, 5, 1500) %one 10 ms pulse
%makeAOpulseProtocol(10, 5, 1500, 50) %fifty 10 ms pulses
%makeAOpulseProtocol(10, 5, 1500, 5, 10) %train of 5 10ms pulses

if nargin==3
    n=1;
    npulses=1;
    ipi=0;
elseif nargin==4
    n=varargin{1};
    npulses=1;
    ipi=0;
elseif nargin==6
    n=varargin{1};
    npulses=varargin{2};
    ipi=varargin{3};
else
error('makeAOpulseProtocol: wrong number of arguments')
end
global pref

if isempty(n) n=1;end

channel=1;
for c=1:length(pref.ao_channels)
    if strcmp(pref.ao_channels(c).name, 'ledchannel')
        channel=c;
    end
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('AOpulse_%d_%d_%d_%d_%d', width, height, isi, npulses, ipi);
stimuli(1).param.description= sprintf('AO pulse stimulus, %dms, %dV, %disi, %d reps, %dpulses in train, %d ipi in train', width, height, isi, n, npulses, ipi);

filename=sprintf('AOpulse_protocol_%d_%d_%d_%d_%d_n%d', width, height, isi, npulses, ipi, n);

for nn=1:n
    stimuli(1+nn).type='aopulse';
stimuli(1+nn).param.width=width;
stimuli(1+nn).param.height=height;
stimuli(1+nn).param.npulses=npulses;
stimuli(1+nn).param.isi=ipi;
stimuli(1+nn).param.start=0;
stimuli(1+nn).param.duration=2*width; %in ms, =2700s=45minutes
stimuli(1+nn).param.channel=channel;
stimuli(1+nn).param.next=isi;
end

Prefs
cd (pref.stimuli)
cd ('AO protocols')
save(filename, 'stimuli');


