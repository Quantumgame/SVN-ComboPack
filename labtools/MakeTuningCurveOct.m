function [filename,path]=MakeTuningCurveOct(freqsperoctave, minfreq, maxfreq, numamplitudes, ...
    minamplitude, maxamplitude, durations, ramp, include_whitenoise, isi, nrepeats)





% Usage: MakeTuningCurveOct(freqsperoctave, minfreq, maxfreq, ...
% numamplitudes, minamplitude, maxamplitude, duration, ramp, ...
% include_whitenoise, isi, nrepeats)
%
% Very similar to MakeTuningCurve, except that you specify the number of
% frequencies per octave instead of the total number of frequencies
%
% Creates an exper2 stimulus protocol file for a tuning curve stimulus
% INPUTS:
% freqsperoctave: number of frequencies per octave (frequency resolution) 
%           note: use MakeTuningCurve for TCs with no tones (whitenoise only)
% minfreq: lowest frequency in Hz
% maxfreq: highest frequency in Hz
%           note: if minfreq-to-maxfreq cannot be divided evenly into
%           freqsperoctave, the nearest maxfreq will be used
%           (i.e. the requested freqsperoctave will be exactly enforced)
% numamplitudes: number of amplitude steps
% minamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
% maxamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
% durations: vector of different tone durations (in ms) (can be a single duration)
% ramp: on-off ramp duration in ms
% include_whitenoise: 0 or 1 to include white noise bursts at each amplitude
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% OUTPUTS:
%       - creates a suitably named stimulus protocol in exper2.2\protocols
%       - returns name & path to protocol (AKH 6/19/13)
% ------------------------------------------------------------------------
%
% example call: MakeTuningCurveOct(4, 1000, 32000, 3, 50, 80, 200, 10, 1, 500, 10)
%
% example call with multiple durations: 
% MakeTuningCurveOct(4, 1000, 32000, 3, 50, 80, [200 400],10,1, 500, 10) 
%
%

include_silentsound=0
if nargin==0; fprintf('\nno input');return;end

numoctaves=log2(maxfreq/minfreq);
% numfreqs=ceil((numoctaves)*freqsperoctave+1)
numdurations=length(durations);
logspacedfreqs=minfreq*2.^([0:(1/freqsperoctave):numoctaves]);
newmaxfreq=logspacedfreqs(end);
numfreqs=length(logspacedfreqs);
if maxfreq~=newmaxfreq
    fprintf('\nnote: could not divide %d-%d Hz evenly into exactly %d frequencies per octave', minfreq, maxfreq, freqsperoctave)
    fprintf('\nusing new maxfreq of %d to achieve exactly %d frequencies per octave\n', round(newmaxfreq), freqsperoctave)
    maxfreq=newmaxfreq;
end
linspacedamplitudes = linspace( minamplitude , maxamplitude , numamplitudes );
if numfreqs==0; logspacedfreqs=[]; end

if include_whitenoise==1
    logspacedfreqs=[logspacedfreqs -1]; %add whitenoise as extra freq=-1
    numfreqs=numfreqs+1;
end

[Amplitudes,Freqs, Durations]=meshgrid( linspacedamplitudes , logspacedfreqs, durations );
neworder=randperm( numfreqs * numamplitudes * numdurations);

amplitudes=zeros(size(neworder*nrepeats));
freqs=zeros(size(neworder*nrepeats));
durs=zeros(size(neworder*nrepeats));


tdur=numfreqs * numamplitudes*numdurations *(mean(durations)+isi)/1000;%approx. duration per repeat

for nn=1:nrepeats
    
        neworder=randperm( numfreqs * numamplitudes * numdurations);
        amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
        freqs( prod(size(Freqs))*(nn-1) + (1:prod(size(Freqs))) ) = Freqs( neworder );
        durs( prod(size(Durations))*(nn-1) + (1:prod(size(Durations))) ) = Durations( neworder );
    
end

durstring=sprintf('%d-', durations);durstring=durstring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
if include_whitenoise
    stimuli(1).param.name= sprintf('Tuning curve +WN, %dfpo(%d-%dHz)/%da(%d-%ddB)/%dd(%sms)/%dmsisi/%d repeats',...
        freqsperoctave,minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, numdurations, durstring,isi, nrepeats);
    stimuli(1).param.description=...
        sprintf('tuning curve, Tones +whitenoise, %d freqs/oct (%d-%dkHz), %d ampl. (%d-%d dB SPL), %d durations (%sms), %dms ramp, %d repeats, %dms isi, %ds duration per repeat',...
        freqsperoctave, minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, numdurations, durstring, ramp, nrepeats, isi, round(tdur));
    filename=sprintf('tuning-curve-tones+WN-%dfpo_%d-%dHz-%da_%d-%ddB-%dd_%sms-isi%dms-n%d repeats',...
        freqsperoctave,minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, numdurations, durstring, isi, nrepeats);
else
    stimuli(1).param.name= sprintf('Tuning curve, %dfpo(%d-%dHz)/%da(%d-%ddB)/%dd(%sms)/%dmsisi/%d reps', ...
        freqsperoctave,minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, numdurations, durstring,isi,nrepeats);
    stimuli(1).param.description=sprintf('tuning curve, Tones only, %d freqs/oct (%d-%dkHz), %d ampl. (%d-%d dB SPL), %d durations (%sms), %d repeats',...
        freqsperoctave, minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, numdurations, durstring,nrepeats);
    filename=sprintf('tuning-curve-tones-%dfpo_%d-%dHz-%da_%d-%ddB-%dd_%sms-isi%dms-n %d repeats',...
        freqsperoctave,minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, numdurations, durstring, isi, nrepeats);
end
for nn=1:length(amplitudes)
    if freqs(nn)==-1
        stimuli(nn+1).type='whitenoise'; %use nn+1 because stimuli(1) is name/description
        stimuli(nn+1).param.amplitude=amplitudes(nn);
        stimuli(nn+1).param.duration=durs(nn);
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    else
        stimuli(nn+1).type='tone';
        stimuli(nn+1).param.frequency=freqs(nn);
        stimuli(nn+1).param.amplitude=amplitudes(nn);
        stimuli(nn+1).param.duration=durs(nn);
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    end
end
global pref
Prefs
cd(pref.stimuli)
cd ('Tuning Curve protocols')
path=pwd;
save(filename, 'stimuli')
fprintf('\ncreated file %s \nin directory %s\n\n', filename, path)

% keyboard