function MakeNBNProtocol(bandwidths, freqsperoctave, minfreq, maxfreq, numamplitudes, ...
    minamplitude, maxamplitude, duration, ramp, isi, nrepeats)
%usage: MakeNBNProtocol(bandwidths, freqsperoctave, minfreq, maxfreq, numamplitudes, ...
%minamplitude, maxamplitude, duration, ramp, isi, nrepeats)
%
%makes a "tuning curve" with narrow-band noise bursts of varying center frequency (Fc) and
% bandwidth (BW) and intensity, but only a single duration.
%automatically includes pure tones (at the center frequencies) and white
%noise (in other words additional bandwidths of 0 and infinity)
%
%based on MakeTuningCurveOct, in which you specify the number of
%frequencies per octave instead of the total number of frequencies
%
% creates an exper2 stimulus protocol file for a tuning curve stimulus
% inputs:
% bandwidths: vector of bandwidths (in octaves) e.g. [.25 .5 1]
% freqsperoctave: number of center frequencies per octave (frequency resolution)
% minfreq: lowest center frequency in Hz
% maxfreq: highest center frequency in Hz
%           note: if minfreq-to-maxfreq cannot be divided evenly into
%           freqsperoctave, the nearest maxfreq will be used
%           (i.e. the requested freqsperoctave will be exactly enforced)
% numamplitudes: number of amplitude steps
% minamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
% maxamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
% duration:  tone duration (in ms)
% ramp: on-off ramp duration in ms
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
%
%example call: MakeNBNProtocol([1], 1, 1000, 8000, 1, 80, 80, 200, 10, 500, 10)
%
%
%
%note: freqs is used for NBN center frequencies
if nargin==0 fprintf('\nno input');return;end

numoctaves=log2(maxfreq/minfreq);
%always add pure tone (0) and white noise (-1) to list of bandwidths
bandwidths=[-1 0 bandwidths];
numbandwidths=length(bandwidths);

logspacedfreqs=minfreq*2.^([0:(1/freqsperoctave):numoctaves]);
newmaxfreq=logspacedfreqs(end);
numfreqs=length(logspacedfreqs);
if maxfreq~=newmaxfreq
    fprintf('\nnote: could not divide %d-%d Hz evenly into exactly %d center frequencies per octave', minfreq, maxfreq, freqsperoctave)
    fprintf('\nusing new maxfreq of %d to achieve exactly %d frequencies per octave\n', round(newmaxfreq), freqsperoctave)
    maxfreq=newmaxfreq;
end
linspacedamplitudes = linspace( minamplitude , maxamplitude , numamplitudes );
if numfreqs==0 logspacedfreqs=[]; end

[Amplitudes,Freqs, Bandwidths]=meshgrid( linspacedamplitudes , logspacedfreqs, bandwidths );
neworder=randperm( numfreqs * numamplitudes * numbandwidths);
amplitudes=zeros(size(neworder*nrepeats));
freqs=zeros(size(neworder*nrepeats));
bws=zeros(size(neworder*nrepeats));

tdur=numfreqs * numamplitudes*numbandwidths *(duration+isi)/1000;%approx. duration per repeat

for nn=1:nrepeats
    neworder=randperm( numfreqs * numamplitudes * numbandwidths);
    amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    freqs( prod(size(Freqs))*(nn-1) + (1:prod(size(Freqs))) ) = Freqs( neworder );
    bws( prod(size(Bandwidths))*(nn-1) + (1:prod(size(Bandwidths))) ) = Bandwidths( neworder );
end

bwstring=sprintf('%g-', bandwidths(3:end));bwstring=bwstring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('NBN Protocol,%s BW, %dfpo(%d-%dHz)/%da(%d-%ddB)/%dmsdur/%dmsisi/%dreps',bwstring,...
    freqsperoctave,minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, duration,isi, nrepeats);
stimuli(1).param.description=...
    sprintf('NBN Protocol, BW %s, %d freqs/oct (%d-%dkHz), %d ampl. (%d-%d dB SPL), %d ms duration, %dms ramp, %d repeats, %dms isi, %ds duration per repeat',...
    bwstring, freqsperoctave, minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, duration, ramp, nrepeats, isi, round(tdur));
filename=sprintf('NBN-%sbw-%dfpo_%d-%dHz-%da_%d-%ddB-d_%dms-isi%dms-n%d.mat',...
    bwstring, freqsperoctave,minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, duration, isi, nrepeats);

for nn=1:length(amplitudes)
    if bws(nn)==-1 %white noise
        stimuli(nn+1).type='whitenoise'; %use nn+1 because stimuli(1) is name/description
        stimuli(nn+1).param.amplitude=amplitudes(nn);
        stimuli(nn+1).param.duration=duration;
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    elseif bws(nn)==0 %pure tone
        stimuli(nn+1).type='tone';
        stimuli(nn+1).param.frequency=freqs(nn);
        stimuli(nn+1).param.amplitude=amplitudes(nn);
        stimuli(nn+1).param.duration=duration;
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    else %NBN
        stimuli(nn+1).type='noise';
        stimuli(nn+1).param.filter_operation='bandpass';
        stimuli(nn+1).param.center_frequency=freqs(nn);
        stimuli(nn+1).param.bandwidthOct=bws(nn); %not used but stored for readability
        stimuli(nn+1).param.bandwidthHz=bws(nn); %not used but stored for readability
        stimuli(nn+1).param.lower_frequency=freqs(nn)*2^(-bws(nn)/2);
        stimuli(nn+1).param.upper_frequency=freqs(nn)*2^(+bws(nn)/2);
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.amplitude=amplitudes(nn);
        stimuli(nn+1).param.duration=duration;
        stimuli(nn+1).param.next=isi;
    end
end
global pref
Prefs
cd(pref.stimuli)
cd ('NBN protocols')
save(filename, 'stimuli')
fprintf('\ncreated file %s \nin directory %s', filename, pwd)

% keyboard