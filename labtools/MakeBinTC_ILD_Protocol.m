function MakeBinTC_ILD_Protocol(freq, max_mono_amp, minILD, maxILD, duration, ramp, isi, nrepeats) 
% usage: MakeBinTC_ILD_Protocol(freq, max_mono_amp, minILD, maxILD, duration, ramp, isi, nrepeats)
%
% creates an exper2 stimulus protocol file for a binaural tuning curve
% with physiologically relevant combinations of specified max_mono_amp
% on Right and Left channels.
%
% Theory:
% ILDs of -40 to 40 dB are the maximum perceived by rodents at high frequencies.
% Based on early experiments by this lab, the loudest sounds that can be
% presented (in the rat) is ~50 dB to avoid crosstalk (occurs when one ear
% can hear sounds played to the other ear, through/around the head). But, I
% made a new protocol called MakeBinTC_mono_Protocol so that we can directly
% test the cross-talk. Thus, I've made this so the user passes the max amplitude
% and this function then builds the best ABL/ILD tuning curve. I'm currently
% keeping the mono stimuli but, perhaps I won't (since MakeBinTC_mono_Protocol
% already takes these data.
% Additionally, the minumum perceivable sound by the domestic mouse
% at 16 kHz is 4 dB (Koay et al., 2002); the wild mouse can perceive 16 kHz
% at -7 dB (Heffner & Masterton, 1980). Thus, we should play -5 to 50 dB
% sounds to cover the entire hearing range of the mouse.
% With all of these facts taken into account, the amplitudes specified
% are restricted to -5 to max_mono_amp dB. ABLs are therefore limited to
% roughly 15-30 dB.  Any ABLs or ILDs outside of these ranges are removed
% to avoid wasting time and cpu memory.
%
% Inputs:
% freq: frequency in Hz; use -1 for whitenoise only (can only have a single frequency)
% max_mono_amp: loudest mono sound before cross-talk occurs
% minILD: use multiples of 10, -40 is typical, but -30 or so may be better
% maxILD: use multiples of 10, 40 is typical, but 30 or so may be better
% duration: in ms (can only have a single duration)
% ramp: on-off ramp duration in ms
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
% Pure tone at 8kHz:
% MakeBinTC_ILD_Protocol(8e3, 50, -40, 40, 25, 3, 500, 10)
% WN:
% MakeBinTC_ILD_Protocol(-1, 50, -40, 40, 25, 3, 500, 10)
% for TCHoldCmd with WN: 
% MakeBinTC_ILD_Protocol(-1, 50, -40, 40, 25, 3, 500, 20)

if freq==-1
    include_whitenoise=1;
else
    include_whitenoise=0;
end
amplitudes=[-1000 -5:5:max_mono_amp];
numamplitudes=length(amplitudes);
[RAmplitudes, LAmplitudes]=ndgrid( amplitudes, amplitudes );

ILDs = minILD:10:maxILD;
ABLs = fliplr(max_mono_amp-20:-5:15);
if rem(max_mono_amp,10)==5
    adjust=5;
else
    adjust=0;
end

Rmono1=LAmplitudes(1,1:end);
Rmono10s=rem(Rmono1-adjust,10)==0;
Rmono10s(1)=0;
Lmono1=RAmplitudes(1:end,1);
Lmono10s=rem(Lmono1-adjust,10)==0;
Lmono10s(1)=0;

ABL1(:,:,1)=RAmplitudes;
ABL1(:,:,2)=LAmplitudes;
ABL=mean(ABL1,3);
ABLindex=NaN(numamplitudes , numamplitudes , length(ABLs));
for i=1:length(ABLs)
    ABLindex(:,:,i)=ABL==ABLs(i);
end
ABLindex=sum(ABLindex,3);

ILD=RAmplitudes-LAmplitudes;
ILDindex=NaN(numamplitudes , numamplitudes , length(ILDs));
for i=1:length(ILDs)
    ILDindex(:,:,i)=ILD==ILDs(i);
end

ILDindex=sum(ILDindex,3);
BINindex=ABLindex.*ILDindex;
BINindex(:,1)=Lmono10s;
BINindex(1,:)=Rmono10s;
BINindex=logical(BINindex);

RAmplitudes=RAmplitudes(BINindex)';
LAmplitudes=LAmplitudes(BINindex)';

newsize=sum(sum(BINindex));
Ramplitudes = NaN(1,newsize*nrepeats);
Lamplitudes = NaN(1,newsize*nrepeats);
tdur = newsize *(duration+isi)/1000; % approx. time per repeat

for nn=1:nrepeats
    neworder=randperm( newsize );
    Ramplitudes( prod(size(RAmplitudes))*(nn-1) + (1:prod(size(RAmplitudes))) ) = RAmplitudes( neworder );
    Lamplitudes( prod(size(LAmplitudes))*(nn-1) + (1:prod(size(LAmplitudes))) ) = LAmplitudes( neworder );
end

Monostring=sprintf('%d-', Rmono1(Rmono10s));Monostring=Monostring(1:end-1);
ILDstring=sprintf('%d-', ILDs);ILDstring=ILDstring(1:end-1);
ABLstring=sprintf('%d-', ABLs);ABLstring=ABLstring(1:end-1);

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
if include_whitenoise
    sound='WN';
else
    sound=sprintf('%dHz',round(freq));
end

stimuli(1).param.name= sprintf('Bin TC, %s/%dms/ABLs%s/ILDs%s/%dmsisi/n%d',...
    sound, duration, ABLstring, ILDstring, isi, nrepeats);
stimuli(1).param.description=...
    sprintf('Bin TC, %s, dur:%dms, %dms ramp, %s ABLs, %s ILDs, %d reps, %dms isi, %ds/repeat',...
    sound, duration, ramp, ABLstring, ILDstring, nrepeats, isi, round(tdur));
filename=sprintf('Bin-TC-%s_%dms_%sABLs_%sILDs_%dmsisi_%dn.mat',...
    sound, duration, ABLstring, ILDstring, isi, nrepeats);


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

