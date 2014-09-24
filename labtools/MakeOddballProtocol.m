function MakeOddballProtocol(numfreqs, minfreq, maxfreq, oddball_freq, include_whitenoise, numamplitudes, minamplitude, maxamplitude, ...
    ntones, isi, toneduration, start, next, ramp, nrepeats)
%usage:  MakeOddballProtocol(numfreqs, minfreq, maxfreq, include_whitenoise, numamplitudes, minamplitude, maxamplitude, ...
%    ntones, isi, toneduration, start, next, ramp, nrepeats)
%creates an exper2 stimulus protocol file for an oddball type stimulus
%train of tones (tone train) with one extra tone at end
%each train is n tones of a fixed freq/amp (oddball is the n+1)
%
% inputs:
% numfreqs: number of tone frequencies (in Hz)
% minfreq: minimum tone frequency (in Hz)
% maxfreq: maximum tone frequency (in Hz)
% oddball_freq: oddball tone frequency (in Hz)
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
% creates a suitably named stimulus protocol in D:\wehr\exper2.2\protocols
%
%
%example calls: 
% MakeOddballProtocol(1, 10e3, 10e3, 8e3, 0, 1, 60, 60, 10, 1000, 25, 100, 1000, 3, 1)
% MakeOddballProtocol(1, 8e3, 8e3, 10e3, 0, 1, 60, 60, 10, 1000, 25, 100, 1000, 3, 1)

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
    stimuli(1).param.name= sprintf('Oddball+WN, %df(%d-%d)-%dHz/%da(%d-%d)/%dms/%dms/n=%d', numfreqs,minfreq, maxfreq, oddball_freq, numamplitudes,minamplitude, maxamplitude, toneduration, isi, ntones);
    stimuli(1).param.description=sprintf('Oddball+WN train, %d ampl. (%d-%d dB SPL), %dms toneduration, %dms ramp, %d repeats, %d bursts per train, %dms isi, %ds duration per repeat', numamplitudes,minamplitude, maxamplitude, toneduration, ramp, nrepeats, ntones, isi, round(tdur));
    filename=sprintf('Oddball+WN-%df_%d-%d-%dHz-%da_%d-%ddB-%dms-%dms-n%d',numfreqs,minfreq, maxfreq, oddball_freq, numamplitudes,minamplitude, maxamplitude, toneduration, isi, ntones);
else
    stimuli(1).param.name= sprintf('Oddball, %df(%d-%d)-%dHz/%da(%d-%d)/%dms/%dms/n=%d', numfreqs,minfreq, maxfreq, oddball_freq, numamplitudes,minamplitude, maxamplitude, toneduration, isi, ntones);
    stimuli(1).param.description=sprintf('Oddball, %d ampl. (%d-%d dB SPL), %dms toneduration, %dms ramp, %d repeats, %d bursts per train, %dms isi, %ds duration per repeat', numamplitudes,minamplitude, maxamplitude, toneduration, ramp, nrepeats, ntones, isi, round(tdur));
    filename=sprintf('Oddball-%df_%d-%d-%dHz-%da_%d-%ddB-%dms-%dms-n%d',numfreqs,minfreq, maxfreq, oddball_freq, numamplitudes,minamplitude, maxamplitude, toneduration, isi, ntones);
end

for nn=2:(1+length(amplitudes))
    if freqs(nn-1)==-1
        stimuli(nn).type='oddball';
        stimuli(nn).param.amplitude=amplitudes(nn-1);
        stimuli(nn).param.nclicks=ntones;
        stimuli(nn).param.isi=isi;
        stimuli(nn).param.frequency=-1;
        stimuli(nn).param.oddball_frequency=oddball_freq;
        stimuli(nn).param.clickduration=toneduration;
        stimuli(nn).param.start=start;
        stimuli(nn).param.next=next;
        stimuli(nn).param.ramp=ramp;
        stimuli(nn).param.duration=trainduration;
    else
        stimuli(nn).type='oddball';
        stimuli(nn).param.amplitude=amplitudes(nn-1);
        stimuli(nn).param.ntones=ntones;
        stimuli(nn).param.isi=isi;
        stimuli(nn).param.frequency=freqs(nn-1);
        stimuli(nn).param.oddball_frequency=oddball_freq;
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
cd ('Oddball Protocols')
 %instead I should use global pref.stimuli
save(filename, 'stimuli')


% keyboard