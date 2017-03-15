function MakeBinTuningCurveProtocol(numfreqs, minfreq, maxfreq, amplitudes, ...
    durations, ramp, include_whitenoise, isi, nrepeats)
%usage: MakeBinTuningCurveProtocol(numfreqs, minfreq, maxfreq, ...
% amplitudes, durations, ramp, include_whitenoise, isi, nrepeats)
%creates an exper2 stimulus protocol file for a binaural tuning curve 
%pure tones with all possible combinations of specified amplitudes on Right
%and Left channels
% inputs:
% numfreqs: number of frequency steps, log spaced between minfreq and maxfreq
%           use 0 for no tones (whitenoise only)
% minfreq: lowest frequency in Hz
% maxfreq: highest frequency in Hz
% amplitudes: vector of amplitudes in dB SPL (to be used for both Right and
% Left) (use -1000 for silence
% durations: vector of different tone durations (in ms) (can be a single duration)
% ramp: on-off ramp duration in ms
% include_whitenoise: 0 or 1 to include white noise bursts at each amplitude
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
%
%example call: MakeBinTuningCurveProtocol(16, 1000, 32000, [50:10:80], 200, 10, 1, 500, 10)
%
%example call with multiple durations: 
%MakeBinTuningCurveProtocol(16, 1000, 32000, [50:10:80], [200 400],10,1, 500, 10) 
%
%this is good for a rate-level function (with 1 tone+WN):
%MakeBinTuningCurveProtocol(1, 7.3e3, 7.3e3, [30:10:80], [25], 5, 1, 500, 10)
%
%this is good for a rate-level function (with WN only):
%MakeBinTuningCurveProtocol(0, 0, 0, [0:10:80], 25, 3, 1, 500, 20)
%MakeBinTuningCurveProtocol(3, 1e3, 4e3, [60:10:80], 25, 3, 0, 500, 5)
% 
% for binaural experiments
% MakeBinTuningCurveProtocol(0, 0, 0, [-1000 10:10:50], 25, 3, 1, 500, 10)
% MakeBinTuningCurveProtocol(1, 8e3, 8e3, [-1000 10:10:50], 25, 3, 0, 500, 10)
% for TCHoldCmd: MakeBinTuningCurveProtocol(0, 0, 0, [-1000 10:10:50], 25, 3, 1, 500, 20)
% 

numdurations=length(durations);
logspacedfreqs = logspace( log10(minfreq) , log10(maxfreq) , numfreqs );

if numfreqs==0 logspacedfreqs=[]; end

if include_whitenoise==1
    logspacedfreqs=[logspacedfreqs -1]; %add whitenoise as extra freq=-1
    numfreqs=numfreqs+1;
end

numamplitudes=length(amplitudes);
[RAmplitudes,LAmplitudes,Freqs, Durations]=ndgrid( amplitudes,amplitudes , logspacedfreqs, durations );
neworder=randperm( numfreqs * numamplitudes * numamplitudes * numdurations);
Ramplitudes=zeros(size(neworder*nrepeats));
Lamplitudes=zeros(size(neworder*nrepeats));
freqs=zeros(size(neworder*nrepeats));
durs=zeros(size(neworder*nrepeats));

tdur=numfreqs * numamplitudes*numamplitudes*numdurations *(mean(durations)+isi)/1000;%approx. duration per repeat

for nn=1:nrepeats
    neworder=randperm( numfreqs * numamplitudes * numamplitudes * numdurations);
    Ramplitudes( prod(size(RAmplitudes))*(nn-1) + (1:prod(size(RAmplitudes))) ) = RAmplitudes( neworder );
    Lamplitudes( prod(size(LAmplitudes))*(nn-1) + (1:prod(size(LAmplitudes))) ) = LAmplitudes( neworder );
    freqs( prod(size(Freqs))*(nn-1) + (1:prod(size(Freqs))) ) = Freqs( neworder );
    durs( prod(size(Durations))*(nn-1) + (1:prod(size(Durations))) ) = Durations( neworder );
end

durstring=sprintf('%d-', durations);durstring=durstring(1:end-1);
ampstring=sprintf('%d-', amplitudes);ampstring=ampstring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
if include_whitenoise
    stimuli(1).param.name= sprintf('Bin Tuning curve +WN, %df(%d-%dHz)/%da(%sdB)/%dd(%sms)/%dmsisi',...
        numfreqs,round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring,isi);
    stimuli(1).param.description=...
        sprintf('binaural tuning curve, Tones +whitenoise, %d freq. (%d-%dkHz), %d ampl. (%s dB SPL), %d durations (%sms), %dms ramp, %d repeats, %dms isi, %ds duration per repeat',...
        numfreqs, round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring, ramp, nrepeats, isi, round(tdur));
    filename=sprintf('bin-tuning-curve-tones+WN-%df_%d-%dHz-%da_%sdB-%dd_%sms-isi%dms%dn.mat',...
        numfreqs,minfreq, round(maxfreq), numamplitudes,ampstring, numdurations, durstring, isi, nrepeats);
else
    stimuli(1).param.name= sprintf('Bin Tuning curve, %df(%d-%dHz)/%da(%sdB)/%dd(%sms)/%dmsisi/%dreps', ...
        numfreqs,round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring,isi, nrepeats);
    stimuli(1).param.description=sprintf('binaural tuning curve, Tones only, %d freq. (%d-%dkHz), %d ampl. (%s dB SPL), %d durations (%sms), %d isi, %d repeats',...
        numfreqs, round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring, isi, nrepeats);
    filename=sprintf('bin-tuning-curve-tones-%df_%d-%dHz-%da_%sdB-%dd_%sms-isi%dms%dn.mat',...
        numfreqs,round(minfreq), round(maxfreq), numamplitudes,ampstring, numdurations, durstring, isi, nrepeats);
end
for nn=1:length(Ramplitudes)
    if freqs(nn)==-1
        stimuli(nn+1).type='binwhitenoise'; %use nn+1 because stimuli(1) is name/description
        stimuli(nn+1).param.Ramplitude=Ramplitudes(nn);
        stimuli(nn+1).param.Lamplitude=Lamplitudes(nn);
        stimuli(nn+1).param.duration=durs(nn);
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    else
        stimuli(nn+1).type='bintone';
        stimuli(nn+1).param.frequency=freqs(nn);
        stimuli(nn+1).param.Ramplitude=Ramplitudes(nn);
        stimuli(nn+1).param.Lamplitude=Lamplitudes(nn);
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