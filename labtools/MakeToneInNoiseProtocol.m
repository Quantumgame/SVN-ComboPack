function MakeToneInNoiseProtocol(noiseamp, noisefreq, noisebandwidth)
% usage MakeToneInNoiseProtocol(noiseamp, noisefreq, noisebandwidth)
%
% creates an exper2 stimulus protocol file for Tones In Noise.
% which is basically any stimulus protocol you want, presented over the top
% of continuous band-limited background noise.
% specify the background noise by passing noiseamp, noisefreq,
% noisebandwidth to this function. A dialog box will open for you to select
% the protocol for the stimuli you want to embed in noise (e.g. a tuning
% curve protocol)
% mw 021508
%
% inputs:
% noiseamp: amplitude of the continuous narrowband noise, in dB SPL
% noisefreq: center frequency of the continuous narrowband noise, in Hz
% noisebandwidth: bandwidth of the continuous narrowband noise, in Hz
%
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols\ToneInNoise Protocols
%
%
%example calls:

%MakeToneInNoiseProtocol(60, 12e3, 1e3)

global pref
if nargin~=3 error('\MakeToneInNoiseProtocol: wrong number of arguments.'); end

global pref
Prefs
cd(pref.stimuli)
cd ('Tuning Curve protocols')
[tcfilename, tcpathname] = uigetfile('*.mat', 'Choose Tuning Curve to incorporate into protocol:');
if isequal(tcfilename,0) || isequal(tcpathname,0)
    disp('User pressed cancel')
    return
else
    disp(['User selected ', fullfile(tcpathname, tcfilename)])
end
tc=load(fullfile(tcpathname, tcfilename));



%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('ToneInNoise, noiseamp%ddB/noisefreq%dHz/noisebandwidth%dHz/%s',noiseamp,noisefreq,noisebandwidth, tc.stimuli(1).param.name);
stimuli(1).param.description=sprintf('ToneInNoise stimulus protocol noise amplitude:%ddB, noise center frequency: %dHz, noise bandwidth %dHz, %s',...
    noiseamp, noisefreq, noisebandwidth, tc.stimuli(1).param.description);
filename=sprintf('ToneInNoise-namp%d-nfreq%d-nbw%d-%s',noiseamp,noisefreq,noisebandwidth, tcfilename);


stimuli(2).type='noise';
stimuli(2).param.amplitude=noiseamp;
stimuli(2).param.filter_operation='bandpass';
stimuli(2).param.center_frequency=noisefreq;
stimuli(2).param.lower_frequency=noisefreq-noisebandwidth/2;
stimuli(2).param.upper_frequency=noisefreq+noisebandwidth/2;
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