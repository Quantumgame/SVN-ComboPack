function MakeToneInWNProtocol(noiseamp)
% usage MakeToneInWNProtocol(noiseamp)
%
% creates an exper2 stimulus protocol file for Tones In White Noise.
% which is basically any stimulus protocol you want, presented over the top
% of continuous background white noise.
% A dialog box will open for you to select
% the protocol for the stimuli you want to embed in noise (e.g. a tuning
% curve protocol)
% mw 021508
% see also MakeToneInNoiseProtocol
% inputs:
% noiseamp: amplitude of the continuous white noise, in dB SPL
%
% outputs:
% creates a suitably named stimulus protocol in D:\lab\exper2.2\protocols\ToneInNoise Protocols
%
%
%example calls:

%MakeToneInNoiseProtocol(60, 12e3, 1e3)

global pref
if nargin~=1 error('\nMakeToneInWNProtocol: wrong number of arguments.'); end
Prefs
cd(pref.stimuli)
cd ('Tuning Curve protocols')
[tcfilename, tcpathname] = uigetfile('*.mat', 'Choose Tuning Curve to incorporate into Voltage Clamp protocol:');
if isequal(tcfilename,0) || isequal(tcpathname,0)
    disp('User pressed cancel')
    return
else
    disp(['User selected ', fullfile(tcpathname, tcfilename)])
end
tc=load(fullfile(tcpathname, tcfilename));



%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('ToneInWN, noiseamp%ddB/%s',noiseamp, tc.stimuli(1).param.name);
stimuli(1).param.description=sprintf('ToneInNoise stimulus protocol noise amplitude:%ddB, %s',...
    noiseamp, tc.stimuli(1).param.description);
filename=sprintf('ToneInWN-namp%d-%s',noiseamp, tcfilename);


stimuli(2).type='whitenoise';
stimuli(2).param.amplitude=noiseamp;
stimuli(2).param.ramp=.1; 
stimuli(2).param.next=500;
stimuli(2).param.loop_flg=1;
stimuli(2).param.triggernum=2; %to allow multiple simultaneous sounds
stimuli(2).param.duration=1000;

%  insert tuning curve (triggernum defaults to 1)
for nn=2:length(tc.stimuli)
    tone=tc.stimuli(nn);
    stimuli(nn+1)=tone;
end


cd(pref.stimuli) %where stimulus protocols are saved
cd('ToneInNoise Protocols')
save(filename, 'stimuli')


%  keyboard