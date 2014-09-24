function Make2ToneProtocol(numfreqs, minfreq, maxfreq, numamplitudes, ...
    minamplitude, maxamplitude, duration, ramp, isi, nrepeats, probefreq, numprobeamplitudes, ...
    minprobeamplitude, maxprobeamplitude, SOA)
%usage: Make2ToneProtocol(numfreqs, minfreq, maxfreq, numamplitudes, ...
%     minamplitude, maxamplitude, duration, ramp, isi, nrepeats, probefreq, numprobeamplitudes, ...
%     minprobeamplitude, maxprobeamplitude, SOA)
%
% creates an exper2 stimulus protocol file for a 2 tone protocol stimulus
% with probe tones of single frequency but multiple amplitudes
% no white noise used
% mw 070506
% inputs:
% numfreqs: number of masker frequency steps, log spaced between minfreq and maxfreq
% minfreq: lowest masker frequency in Hz
% maxfreq: highest masker frequency in Hz
% numamplitudes: number of masker amplitude steps
% minamplitude: maximum masker amplitude in dB SPL (requires system to be calibrated)
% maxamplitude: maximum masker amplitude in dB SPL (requires system to be calibrated)
% duration: masker duration in ms
% ramp: on-off ramp duration in ms
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% probefreq: frequency of probe tone in Hz
% numprobeamplitudes: number of probe tone amplitude steps
% minprobeamplitude: minimum probe tone amplitude in dB SPL 
% maxprobeamplitude: maximum probe tone amplitude in dB SPL
% SOA: Stimulus Onset Asynchrony in ms = time between masker onset and probe tone onset
%
% outputs:
% creates a suitably named stimulus protocol in experhome\exper2.2\protocols
%
%
%example call: Make2ToneProtocol(16, 1000, 40000, 5, 0, 80, 25, 2, 500, 10, 16000, 2, 20, 70, 80)
global pref
if nargin~=15 error('\nMake2ToneProtocol: wrong number of arguments.'); end

logspacedfreqs = logspace( log10(minfreq) , log10(maxfreq) , numfreqs );
linspacedamplitudes = linspace( minamplitude , maxamplitude , numamplitudes );
linspacedprobeamplitudes = linspace( minprobeamplitude , maxprobeamplitude , numprobeamplitudes );

[Amplitudes,Freqs,ProbeAmps]=meshgrid( linspacedamplitudes , logspacedfreqs,linspacedprobeamplitudes );
neworder=randperm( numfreqs * numamplitudes *numprobeamplitudes );
amplitudes=zeros(1,length(neworder)*nrepeats);
freqs=zeros(1,length(neworder)*nrepeats);
probeamps=zeros(1,length(neworder)*nrepeats);

tdur=numprobeamplitudes* numfreqs * numamplitudes*(2*duration+isi+SOA)/1000;%duration per repeat

for nn=1:nrepeats
    neworder=randperm( numfreqs * numamplitudes *numprobeamplitudes );
    amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    freqs( prod(size(Freqs))*(nn-1) + (1:prod(size(Freqs))) ) = Freqs( neworder );
    probeamps( prod(size(ProbeAmps))*(nn-1) + (1:prod(size(ProbeAmps))) ) = ProbeAmps( neworder );
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('2TP-%df(%d-%d)-%da(%d-%d)-%dms-pf%d-%dpa(%d-%d)-SOA%d',...
    numfreqs,minfreq,maxfreq, numamplitudes,minamplitude, maxamplitude, duration,...
    probefreq, numprobeamplitudes, minprobeamplitude, maxprobeamplitude, SOA);
stimuli(1).param.description=sprintf(...
    '2Tone Protocol, %d freq. (%d-%dkHz), %d ampl. (%d-%d dB SPL), %dms duration, %d probefreq, %d probe ampl ((%d-%d dB SPL), %dSOA', ...
    numfreqs, minfreq, maxfreq, numamplitudes,minamplitude, maxamplitude, duration, ...
    probefreq, numprobeamplitudes, minprobeamplitude, maxprobeamplitude, SOA);
% filename=sprintf('2TP-%df(%d-%d)-%da(%d-%d)-%dms-pf%d-%dpa(%d-%d)-SOA%d',...
%     numfreqs,minfreq,maxfreq, numamplitudes,minamplitude, maxamplitude, duration,...
%     probefreq, numprobeamplitudes, minprobeamplitude, maxprobeamplitude, SOA);
filename=stimuli(1).param.name;

%add probe tones alone at beginning (should interleave them in, but not now)
ProbeAmps2=meshgrid(linspacedprobeamplitudes, 1:nrepeats);
neworder2=randperm(  nrepeats *numprobeamplitudes );
probeamps2=ProbeAmps2(neworder2);
nn=1;
for k=1:length(probeamps2)
    nn=nn+1;
    stimuli(nn).type='tone';
    stimuli(nn).param.frequency=probefreq;
    stimuli(nn).param.amplitude=probeamps2(k);
    stimuli(nn).param.duration=duration;
    stimuli(nn).param.ramp=ramp;
    stimuli(nn).param.next=isi;
end

for k=1:length(amplitudes)
    nn=nn+1;
    stimuli(nn).type='2tone';
    stimuli(nn).param.frequency=freqs(k);
    stimuli(nn).param.amplitude=amplitudes(k);
    stimuli(nn).param.duration=duration;
    stimuli(nn).param.ramp=ramp;
    stimuli(nn).param.next=isi;
    stimuli(nn).param.probefreq=probefreq;
    stimuli(nn).param.probeamp=probeamps(k);
    stimuli(nn).param.SOA=SOA;
end


prefs
cd(pref.stimuli) %where stimulus protocols are saved
cd('2Tone Protocols')
save(filename, 'stimuli')


% keyboard