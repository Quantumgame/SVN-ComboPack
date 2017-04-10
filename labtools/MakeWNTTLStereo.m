% script for making an RLF wav file to play during an experiment on Cris' TDT setup
% TTL triggers are on channel 2...


MakeTuningCurve(0, 0, 0, 9, 0, 80, 25, 3, 1, 500, 20)
fn='tuning-curve-tones+WN-1f_0-0Hz-9a_0-80dB-1d_25ms-isi500ms-n20.mat';
load(fn)
samplerate=44100;

s=[];
for i=2:length(stimuli)
    param=stimuli(i).param;
wn=MakeWhiteNoise(param, samplerate);
ttl=.9*ones(size(wn));
s=[s [wn; ttl]];

silence=zeros(2, param.next*44100/1000);
s=[s silence];

end

%cd /Users/mikewehr/Documents/Analysis/wehrtools
wavwrite(s', 44100, 16, 'RLF_9a_0-80dB-25ms-isi500ms.wav')