function MakeToneTrainProtocol(numfreqs, minfreq, maxfreq, include_whitenoise, numamplitudes, minamplitude, maxamplitude, ...
    ntones, isi, toneduration, start, next, ramp, nrepeats)
%usage:  MakeToneTrainProtocol(numfreqs, minfreq, maxfreq, include_whitenoise, numamplitudes, minamplitude, maxamplitude, ...
%    ntones, isi, toneduration, start, next, ramp, nrepeats)
%creates an exper2 stimulus protocol file for a train of tones (tone train)
%each train is n tones of a fixed freq/amp
%
% inputs:
% numfreqs: number of tone frequencies (in Hz)
% minfreq: minimum tone frequency (in Hz)
% maxfreq: maximum tone frequency (in Hz)
% include whitenoise (0 or 1)
%   numamplitudes: number of amplitude steps
%   minamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
%   maxamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
%   ntones         -   number of tones
%   isi             -   inter-stimulus interval, i.e. interval between the
%                       start of previous tone and start of the next tone
%   toneduration   -   duration of an individual tone (ms)
%   start           -   start of the first tone after the trigger (ms)
%   next            -   inter-tone-train-interval, i.e. when the next
%                       tone train should follow the previous one (ms)
%   ramp            -   rising/falling edge of individual tones
%   nrepeats: number of repetitions (different pseudorandom orders for atten)
%
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
%
%example call: MakeToneTrainProtocol(4, 1e3, 8e3, 1, 1, 60, 60, 10, 100, 25, 100, 500, 3, 1)
%MakeToneTrainProtocol(6, 1e3, 32e3, 0, 6, 10, 60, 500, 100, 25, 100, 500, 3, 1)
%MakeToneTrainProtocol(1, 8e3, 8e3, 0, 1, 60, 60, 1, 1000, 25, 100, 5000, 3, 1)

logspacedfreqs = logspace( log10(minfreq) , log10(maxfreq) , numfreqs );
linspacedamplitudes = linspace( minamplitude , maxamplitude , numamplitudes );

if include_whitenoise==1
    logspacedfreqs=[logspacedfreqs -1]; %add whitenoise as extra freq=-1
    numfreqs=numfreqs+1;
end

[Amplitudes,Freqs]=meshgrid( linspacedamplitudes , logspacedfreqs );
neworder=randperm( numfreqs * numamplitudes );
amplitudes=zeros(size(neworder*nrepeats));
freqs=zeros(size(neworder*nrepeats));

tdur= numfreqs*numamplitudes*(next+start+toneduration+(ntones-1)*isi)/1000;%duration per repeat
trainduration=(next+start+toneduration+(ntones-1)*isi);

for nn=1:nrepeats
    neworder=randperm( numfreqs * numamplitudes );
    amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    freqs( prod(size(Freqs))*(nn-1) + (1:prod(size(Freqs))) ) = Freqs( neworder );
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
if include_whitenoise
    stimuli(1).param.name= sprintf('ToneTrain+WN, %df(%d-%d)Hz/%da(%d-%d)/%dms/%dms/n=%d', numfreqs,minfreq, maxfreq, numamplitudes,minamplitude, maxamplitude, toneduration, isi, ntones);
    stimuli(1).param.description=sprintf('Tone+WN train, %d ampl. (%d-%d dB SPL), %dms toneduration, %dms ramp, %d repeats, %d bursts per train, %dms isi, %ds duration per repeat', numamplitudes,minamplitude, maxamplitude, toneduration, ramp, nrepeats, ntones, isi, round(tdur));
    filename=sprintf('ToneTrain+WN-%df_%d-%dHz-%da_%d-%ddB-%dms-%dms-n%d',numfreqs,minfreq, maxfreq, numamplitudes,minamplitude, maxamplitude, toneduration, isi, ntones);
else
    stimuli(1).param.name= sprintf('ToneTrain, %df(%d-%d)Hz/%da(%d-%d)/%dms/%dms/n=%d', numfreqs,minfreq, maxfreq, numamplitudes,minamplitude, maxamplitude, toneduration, isi, ntones);
    stimuli(1).param.description=sprintf('Tone train, %d ampl. (%d-%d dB SPL), %dms toneduration, %dms ramp, %d repeats, %d bursts per train, %dms isi, %ds duration per repeat', numamplitudes,minamplitude, maxamplitude, toneduration, ramp, nrepeats, ntones, isi, round(tdur));
    filename=sprintf('ToneTrain-%df_%d-%dHz-%da_%d-%ddB-%dms-%dms-n%d',numfreqs,minfreq, maxfreq, numamplitudes,minamplitude, maxamplitude, toneduration, isi, ntones);
end

for nn=2:(1+length(amplitudes))
    if freqs(nn-1)==-1
        stimuli(nn).type='clicktrain';
        stimuli(nn).param.amplitude=amplitudes(nn-1);
        stimuli(nn).param.nclicks=ntones;
        stimuli(nn).param.isi=isi;
        stimuli(nn).param.frequency=-1;
        stimuli(nn).param.clickduration=toneduration;
        stimuli(nn).param.start=start;
        stimuli(nn).param.next=next;
        stimuli(nn).param.ramp=ramp;
        stimuli(nn).param.duration=trainduration;
    else
        stimuli(nn).type='tonetrain';
        stimuli(nn).param.amplitude=amplitudes(nn-1);
        stimuli(nn).param.ntones=ntones;
        stimuli(nn).param.isi=isi;
        stimuli(nn).param.frequency=freqs(nn-1);
        stimuli(nn).param.toneduration=toneduration;
        stimuli(nn).param.start=start;
        stimuli(nn).param.next=next;
        stimuli(nn).param.ramp=ramp;
        stimuli(nn).param.duration=trainduration;
    end
end



global pref
Prefs
cd(pref.stimuli)
cd ('Train Protocols')
save(filename, 'stimuli')
fprintf('\nwrote file %s in directory %s', filename, pwd)

% keyboard