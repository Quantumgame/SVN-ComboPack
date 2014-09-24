function MakeBinTC_mono_Protocol(freq, mono_amps, duration, ramp, isi, nrepeats)
% usage: MakeBinTC_mono_Protocol(freq, mono_amps, duration, ramp, isi, nrepeats)
% 
% creates an exper2 stimulus protocol file for a binaural tuning curve 
% with only monaurally specified amplitudes on Right and Left channels.
% Thus creating monaural RLFs for each ear.
% This will enable rapid searching for in vivo cross-talk limits. These are
% likely to be around 50 dB.
% Use PlotBinTC_ILD for spiking RLF
% 
% inputs:
% freq: frequency in Hz; use -1 for whitenoise only (can only have a single frequency)
% mono_amps: vector of amplitudes in dB SPL to be used for both Right and
% Left; use -1000 for silence
% duration: in ms (can only have a single duration)
% ramp: on-off ramp duration in ms
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
% 
% example call for binaural experiments:
% Pure tone at 8kHz:
% MakeBinTC_mono_Protocol(8e3, [-10:10:80], 25, 3, 500, 10)
% WN:
% MakeBinTC_mono_Protocol(-1, [-10:10:80], 25, 3, 500, 10)

if freq==-1
    include_whitenoise=1;
else
    include_whitenoise=0;
end
mono_amps=[-1000 mono_amps];

[RAmplitudes, LAmplitudes]=ndgrid( mono_amps , mono_amps );

BINindex=zeros(length(mono_amps) , length(mono_amps));
BINindex(2:end,1)=1;
BINindex(1,2:end)=1;
BINindex=logical(BINindex);

RAmplitudes=RAmplitudes(BINindex)';
LAmplitudes=LAmplitudes(BINindex)';
newsize=sum(sum(BINindex));
Ramplitudes = NaN(1,newsize*nrepeats);
Lamplitudes = NaN(1,newsize*nrepeats);

tdur = (length(mono_amps)-1) * 2 *(duration+isi)/1000; % approx. time per repeat

for nn=1:nrepeats
    neworder=randperm( newsize );
    Ramplitudes( prod(size(RAmplitudes))*(nn-1) + (1:prod(size(RAmplitudes))) ) = RAmplitudes( neworder );
    Lamplitudes( prod(size(LAmplitudes))*(nn-1) + (1:prod(size(LAmplitudes))) ) = LAmplitudes( neworder );
end

Monostring=sprintf('%d-', mono_amps(2:end));Monostring=Monostring(1:end-1);

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
if include_whitenoise
    sound='WN';
else
    sound=sprintf('%dHz',round(freq));
end

stimuli(1).param.name= sprintf('Bin TC Mono, %s/%dms/%sdB(SPL)/%dmsisi/n%d',...
    sound, duration, Monostring, isi, nrepeats);
stimuli(1).param.description=...
    sprintf('Bin TC Mono, %s, dur:%dms, %dms ramp, %s dB(SPL), %d reps, %dms isi, %ds/repeat',...
    sound, duration, ramp, Monostring, nrepeats, isi, round(tdur));
filename=sprintf('Bin-TC-Mono-%s_%dms_%sdBSPL_%dmsisi_%dn.mat',...
    sound, duration, Monostring, isi, nrepeats);


for nn=1:length(Ramplitudes)
    if freq==-1
        stimuli(nn+1).type='binwhitenoise'; %use nn+1 because stimuli(1) is name/description
        stimuli(nn+1).param.Ramplitude=Ramplitudes(nn);
        stimuli(nn+1).param.Lamplitude=Lamplitudes(nn);
        stimuli(nn+1).param.duration=duration;
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    else
        stimuli(nn+1).type='bintone';
        stimuli(nn+1).param.frequency=freq;
        stimuli(nn+1).param.Ramplitude=Ramplitudes(nn);
        stimuli(nn+1).param.Lamplitude=Lamplitudes(nn);
        stimuli(nn+1).param.duration=duration;
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    end
end
global pref
Prefs
cd(pref.stimuli)
cd ('Bin Tuning Curve protocols')
save(filename, 'stimuli')

