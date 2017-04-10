function MakeITDProtocol(numfreqs, minfreq, maxfreq, amplitudes, ...
    itds, durations, ramp, include_whitenoise, isi, nrepeats)

%usage: MakeITDProtocol(numfreqs, minfreq, maxfreq, ...
% amplitudes, itds, durations, ramp, include_whitenoise, isi, nrepeats)
%creates an exper2 stimulus protocol file for a binaural tuning curve 
%pure tones with all possible combinations of specified amplitudes on Right
%and Left channels
% inputs:
% numfreqs: number of frequency steps, log spaced between minfreq and maxfreq
%           use 0 for no tones (whitenoise only)
% minfreq: lowest frequency in Hz
% maxfreq: highest frequency in Hz
% amplitudes: vector of amplitudes in dB SPL (to be used for both Right and
% Left) (use -1000 for silence)
% itds: vector of ITDs to use, in microseconds
% durations: vector of different tone durations (in ms) (can be a single duration)
% ramp: on-off ramp duration in ms
% include_whitenoise: 0 or 1 to include white noise bursts at each amplitude
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
%note: physiological ITD range for an adult rat is about +- 130
%microseconds (Kelly & Phillips 1991, Hearing Research
%Volume 55, Issue 1, September 1991, Pages 39-44 )
%
%example call: 
% MakeITDProtocol(0, 0, 0, 80, [-10000:1000:10000], 25, 3, 1,500, 1)
%

numdurations=length(durations);
logspacedfreqs = logspace( log10(minfreq) , log10(maxfreq) , numfreqs );

if numfreqs==0 logspacedfreqs=[]; end

if include_whitenoise==1
    logspacedfreqs=[logspacedfreqs -1]; %add whitenoise as extra freq=-1
    numfreqs=numfreqs+1;
end

numamplitudes=length(amplitudes);
numitds=length(itds);

[Amplitudes,ITDs,Freqs, Durations]=ndgrid( amplitudes,itds , logspacedfreqs, durations );
neworder=randperm( numfreqs * numamplitudes * numitds * numdurations);
amplitudes1=zeros(size(neworder*nrepeats));
freqs=zeros(size(neworder*nrepeats));
itds1=zeros(size(neworder*nrepeats));
durs=zeros(size(neworder*nrepeats));

tdur=numfreqs * numamplitudes*numitds*numdurations *(mean(durations)+isi)/1000;%approx. duration per repeat

for nn=1:nrepeats
    neworder=randperm( numfreqs * numitds * numamplitudes * numdurations);
    amplitudes1( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    itds1( prod(size(ITDs))*(nn-1) + (1:prod(size(ITDs))) ) = ITDs( neworder );
    freqs( prod(size(Freqs))*(nn-1) + (1:prod(size(Freqs))) ) = Freqs( neworder );
    durs( prod(size(Durations))*(nn-1) + (1:prod(size(Durations))) ) = Durations( neworder );
end

durstring=sprintf('%d-', durations);durstring=durstring(1:end-1);
ampstring=sprintf('%d-', amplitudes);ampstring=ampstring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
if include_whitenoise
    stimuli(1).param.name= sprintf('ITD Tuning curve +WN, %di(%d-%dus)/%df(%d-%dHz)/%da(%sdB)/%dd(%sms)/%dmsisi',...
        numitds, min(itds), max(itds),numfreqs,round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring,isi);
    stimuli(1).param.description=...
        sprintf('ITD tuning curve, Tones +whitenoise, %ditds(%d-%dus), %d freq. (%d-%dkHz), %d ampl. (%s dB SPL), %d durations (%sms), %dms ramp, %d repeats, %dms isi, %ds duration per repeat',...
        numitds, min(itds), max(itds),numfreqs, round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring, ramp, nrepeats, isi, round(tdur));
    filename=sprintf('itd-tones+WN-%di_%d-%dus-%df_%d-%dHz-%da_%sdB-%dd_%sms-isi%dms%dn.mat',...
        numitds, min(itds), max(itds),numfreqs,minfreq, round(maxfreq), numamplitudes,ampstring, numdurations, durstring, isi, nrepeats);
else
    stimuli(1).param.name= sprintf('ITD Tuning curve, %di(%d-%dus)/%df(%d-%dHz)/%da(%sdB)/%dd(%sms)/%dmsisi/%dreps', ...
        numitds, min(itds), max(itds),numfreqs,round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring,isi, nrepeats);
    stimuli(1).param.description=sprintf('ITD tuning curve, Tones only,%ditds(%d-%dus), %d freq. (%d-%dkHz), %d ampl. (%s dB SPL), %d durations (%sms), %d isi, %d repeats',...
        numitds, min(itds), max(itds),numfreqs, round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring, isi, nrepeats);
    filename=sprintf('itd-tones-%di_%d-%dus-%df_%d-%dHz-%da_%sdB-%dd_%sms-isi%dms%dn.mat',...
        numitds, min(itds), max(itds),numfreqs,round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring, isi, nrepeats);
end
for nn=1:length(amplitudes1)
    if freqs(nn)==-1
        stimuli(nn+1).type='itdwhitenoise'; %use nn+1 because stimuli(1) is name/description
        stimuli(nn+1).param.amplitude=amplitudes1(nn);
        stimuli(nn+1).param.itd=itds(nn);
        stimuli(nn+1).param.duration=durs(nn);
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    else
        stimuli(nn+1).type='itdtone';
        stimuli(nn+1).param.frequency=freqs(nn);
        stimuli(nn+1).param.amplitude=amplitudes1(nn);
        stimuli(nn+1).param.itd=itds(nn);
        stimuli(nn+1).param.duration=durs(nn);
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    end
end
global pref
Prefs
cd(pref.stimuli)
cd ('Bin Tuning Curve protocols')
save(filename, 'stimuli')


% keyboard