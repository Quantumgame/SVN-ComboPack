function Make2ToneWNProtocol(numamplitudes, ...
    minamplitude, maxamplitude, duration, ramp, isi, nrepeats, numprobeamplitudes, ...
    minprobeamplitude, maxprobeamplitude, SOA)
%usage: Make2ToneProtocol(numfreqs, minfreq, maxfreq, numamplitudes, ...
%     minamplitude, maxamplitude, duration, ramp, isi, nrepeats, probefreq, numprobeamplitudes, ...
%     minprobeamplitude, maxprobeamplitude, SOA)
%
% modified from Make2ToneProtocol to use WN only (Make2ToneProtocol does not allow WN)
% mw 10.30.2015
%
% creates an exper2 stimulus protocol file for a 2 tone protocol stimulus
% with probe tones of single frequency but multiple amplitudes
% no white noise used
% mw 070506
% inputs:
%    (all stimuli are WN)
% numamplitudes: number of masker amplitude steps
% minamplitude: maximum masker amplitude in dB SPL (requires system to be calibrated)
% maxamplitude: maximum masker amplitude in dB SPL (requires system to be calibrated)
% duration: masker duration in ms
% ramp: on-off ramp duration in ms
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% numprobeamplitudes: number of probe tone amplitude steps
% minprobeamplitude: minimum probe tone amplitude in dB SPL
% maxprobeamplitude: maximum probe tone amplitude in dB SPL
% SOA: Stimulus Onset Asynchrony in ms = time between masker onset and probe tone onset
%
% outputs:
% creates a suitably named stimulus protocol in experhome\exper2.2\protocols
%
%
%example calls:
% Make2ToneWNProtocol(1, 70, 70, 25, 3, 1000, 10, 1, 70,70, 100)
% Make2ToneWNProtocol(1, 70, 70, 400, 3, 1000, 10, 1, 70,70, 500)

global pref
if nargin~=11 error('\nMake2ToneProtocol: wrong number of arguments.'); end

% logspacedfreqs = logspace( log10(minfreq) , log10(maxfreq) , numfreqs );
linspacedamplitudes = linspace( minamplitude , maxamplitude , numamplitudes );
linspacedprobeamplitudes = linspace( minprobeamplitude , maxprobeamplitude , numprobeamplitudes );

[Amplitudes,ProbeAmps]=meshgrid( linspacedamplitudes ,linspacedprobeamplitudes );
neworder=randperm( numamplitudes *numprobeamplitudes );
amplitudes=zeros(1,length(neworder)*nrepeats);
probeamps=zeros(1,length(neworder)*nrepeats);

tdur=numprobeamplitudes * numamplitudes*(2*duration+isi+SOA)/1000;%duration per repeat

for nn=1:nrepeats
    neworder=randperm( numamplitudes *numprobeamplitudes );
    amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    probeamps( prod(size(ProbeAmps))*(nn-1) + (1:prod(size(ProbeAmps))) ) = ProbeAmps( neworder );
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('2TPWN-%da(%d-%d)-%dms-%dpa(%d-%d)-isi%d-SOA%d',...
    numamplitudes,minamplitude, maxamplitude, duration,...
    numprobeamplitudes, minprobeamplitude, maxprobeamplitude, isi, SOA);
stimuli(1).param.description=sprintf(...
    '2ToneWN Protocol, %d ampl. (%d-%d dB SPL), %dms duration, %d probe ampl (%d-%d dB SPL), %dSOA', ...
    numamplitudes,minamplitude, maxamplitude, duration, ...
    numprobeamplitudes, minprobeamplitude, maxprobeamplitude, SOA);
% filename=sprintf('2TP-%df(%d-%d)-%da(%d-%d)-%dms-pf%d-%dpa(%d-%d)-SOA%d',...
%     numfreqs,minfreq,maxfreq, numamplitudes,minamplitude, maxamplitude, duration,...
%     probefreq, numprobeamplitudes, minprobeamplitude, maxprobeamplitude, SOA);
filename=stimuli(1).param.name;

%add probe tones alone at beginning (should interleave them in, but not now)
ProbeAmps2=meshgrid(linspacedprobeamplitudes, 1:nrepeats);
neworder2=randperm(  nrepeats *numprobeamplitudes );
probeamps2=ProbeAmps2(neworder2);

stimorder=randperm(nrepeats*2 *numprobeamplitudes); %order of single tone and 2Tone, random
nn=0;
for k=1:length(probeamps2)
    nn=nn+1;
    kk=stimorder(nn);
    kk=kk+1;
    stimuli(kk).type='whitenoise';
    stimuli(kk).param.frequency=-1;
    stimuli(kk).param.amplitude=probeamps2(k);
    stimuli(kk).param.duration=duration;
    stimuli(kk).param.ramp=ramp;
    stimuli(kk).param.next=isi;
    stimuli(kk).param.SOA=SOA;
end

for k=1:length(amplitudes)
    nn=nn+1;
    kk=stimorder(nn);
    kk=kk+1;
    stimuli(kk).type='2tone';
    stimuli(kk).param.frequency=-1;
    stimuli(kk).param.amplitude=amplitudes(k);
    stimuli(kk).param.duration=duration;
    stimuli(kk).param.ramp=ramp;
    stimuli(kk).param.next=isi;
    stimuli(kk).param.probefreq=-1;
    stimuli(kk).param.probeamp=probeamps(k);
    stimuli(kk).param.SOA=SOA;
end


Prefs
cd(pref.stimuli) %where stimulus protocols are saved
if exist('2Tone Protocols')~=7
    mkdir('2Tone Protocols')
end
cd('2Tone Protocols')
save(filename, 'stimuli')


% keyboard