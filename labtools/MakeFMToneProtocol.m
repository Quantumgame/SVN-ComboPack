function MakeFMToneProtocol(Fc, carrier_phase, Fm, modulation_phase,...
    modulation_index, amplitude, duration)
%usage: MakeFMToneProtocol(Fc, carrier_phase, Fm, modulation_phase, modulation_index, amplitude, duration)
%creates an exper2 stimulus protocol file for a FM Tones stimulus
% Fc            -   carrier frequencies (in Hz)
% carrier_phase -   carrier phase
% Fm            -   modulation frequency (in Hz)
% modulation_phase  -   modulation phase
% modulation_index  -   frequency deviation in Hz
% amplitude     -   amplitude (dB)
% duration      -   duration (in msec)
% ramp          - rising/falling edge (in ms)
%
% example call
% Fc=logspace(log10(1e3), log10(32e3), 21);
% MakeFMToneProtocol(Fc, 0, 4, 0, 100, 70, 2000)

% inputs:
% numfreqs: number of frequency steps, log spaced between minfreq and maxfreq
% minfreq: lowest frequency in Hz
% maxfreq: highest frequency in Hz
% numamplitudes: number of amplitude steps
% minamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
% maxamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
% durations: vector of different tone durations (in ms) (can be a single duration)
% ramp: on-off ramp duration in ms
% include_whitenoise: 0 or 1 to include white noise bursts at each amplitude
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
%
%example call: MakeTuningCurve(16, 1000, 32000, 3, 50, 80, 200, 10, 1, 500, 10)
%
%example call with multiple durations:
%MakeTuningCurve(16, 1000, 32000, 3, 50, 80, [200 400],10,1, 500, 10)
%
% numdurations=length(durations);
% logspacedfreqs = logspace( log10(minfreq) , log10(maxfreq) , numfreqs );
% linspacedamplitudes = linspace( minamplitude , maxamplitude , numamplitudes );
%
% if include_whitenoise==1
%     logspacedfreqs=[logspacedfreqs -1]; %add whitenoise as extra freq=-1
%     numfreqs=numfreqs+1;
% end
%
% [Amplitudes,Freqs, Durations]=meshgrid( linspacedamplitudes , logspacedfreqs, durations );
% neworder=randperm( numfreqs * numamplitudes * numdurations);
% amplitudes=zeros(size(neworder*nrepeats));
% freqs=zeros(size(neworder*nrepeats));
% durs=zeros(size(neworder*nrepeats));
%
% tdur=numfreqs * numamplitudes*numdurations *(mean(durations)+isi)/1000;%approx. duration per repeat
%
% for nn=1:nrepeats
%     neworder=randperm( numfreqs * numamplitudes * numdurations);
%     amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
%     freqs( prod(size(Freqs))*(nn-1) + (1:prod(size(Freqs))) ) = Freqs( neworder );
%     durs( prod(size(Durations))*(nn-1) + (1:prod(size(Durations))) ) = Durations( neworder );
% end
%
% durstring=sprintf('%d-', durations);durstring=durstring(1:end-1);
%put into stimuli structure
if modulation_index>Fc
    error(sprintf('modulation index (%d Hz) is greater than carrier frequency (%d Hz).\nThis would mean a negative tone frequency! ',modulation_index, Fc ))
end
stimuli(1).type='exper2 stimulus protocol';
if (0) %include_whitenoise
    stimuli(1).param.name= sprintf('Tuning curve +WN, %df(%d-%dHz)/%da(%d-%ddB)/%dd(%sms)/%dms/%dmsisi',...
        numfreqs,minfreq, maxfreq, numamplitudes,minamplitude, maxamplitude, numdurations, durstring,ramp,isi);
    stimuli(1).param.description=...
        sprintf('tuning curve, Tones +whitenoise, %d freq. (%d-%dkHz), %d ampl. (%d-%d dB SPL), %d durations (%sms), %dms ramp, %d repeats, %dms isi, %ds duration per repeat',...
        numfreqs, minfreq, maxfreq, numamplitudes,minamplitude, maxamplitude, numdurations, durstring, ramp, nrepeats, isi, round(tdur));
    filename=sprintf('tuning-curve-tones+WN-%df_%d-%dHz-%da_%d-%ddB-%dd_%sms-%dms-%dmsisi',...
        numfreqs,minfreq, maxfreq, numamplitudes,minamplitude, maxamplitude, numdurations, durstring,ramp, isi);
else
    filename=sprintf('FMTone_Fc%d_%d_%ddB_Fm%d', round(Fc(1)), round(Fc(end)), amplitude, round(Fm));
    stimuli(1).param.name= filename;
    stimuli(1).param.description=sprintf('FM Tone Fc%d-%d-%ddB', Fc(1), Fc(end), amplitude);

end


for nn=1:length(Fc);
ramp=10;
isi=500;

stimuli(nn+1).type='fmtone';
stimuli(nn+1).param.carrier_frequency=Fc(nn);
stimuli(nn+1).param.carrier_phase=carrier_phase;
stimuli(nn+1).param.modulation_frequency=Fm;
stimuli(nn+1).param.modulation_phase=modulation_phase;
stimuli(nn+1).param.modulation_index=modulation_index;

stimuli(nn+1).param.amplitude=amplitude;
stimuli(nn+1).param.duration=duration;
stimuli(nn+1).param.ramp=ramp;
stimuli(nn+1).param.next=isi;

end
global pref
cd(pref.stimuli)
cd('FMToneProtocols')
save(filename, 'stimuli')


% keyboard