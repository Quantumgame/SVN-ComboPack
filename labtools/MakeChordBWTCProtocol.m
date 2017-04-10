function MakeChordBWTCProtocol(bandwidths, tone_density, freqsperoctave, minfreq, maxfreq, numamplitudes, ...
    minamplitude, maxamplitude, duration, ramp, isi, nrepeats)
%usage: MakeNBNProtocol(bandwidths, tone_density, freqsperoctave, minfreq, maxfreq, numamplitudes, ...
%minamplitude, maxamplitude, duration, ramp, isi, nrepeats)
%
%this is a different approach to the same goal of MakeNBNProtocol. The goal
%is to have a "tuning curve" of chord stimuli of varying center frequency
%(Fc) and bandwidth (BW) and intensity. The chord stimuli are multiple 
%tones (frequency components) with a tone density (in tones/oct) and BW. 
%the main point of trying this approach (instead of using NBN) is that each
%tone can be perfectly calibrated, whereas our NBN stimuli are only
%calibrated to the Fc (so the NBN is not flat).
% automatically includes pure tone (BW 0) but not WN or any noise stimuli
%
% based on MakeNBNProtocol, which had the following help section:
% % makes a "tuning curve" with narrow-band noise bursts of varying center frequency (Fc) and
% % bandwidth (BW) and intensity, but only a single duration.
% % automatically includes pure tones (at the center frequencies) and white
% % noise (in other words additional bandwidths of 0 and infinity)
%
%based on MakeTuningCurveOct, in which you specify the number of
%frequencies per octave instead of the total number of frequencies
%
% creates an exper2 stimulus protocol file for a tuning curve stimulus
% inputs:
% bandwidths: vector of bandwidths (in octaves) e.g. [.25 .5 1]
% tone_density: scalar, in tones/oct: how denseley to fill the BW with tones
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
%example calls: 
% MakeChordBWTCProtocol([  .4 .8 1.6 3.2 6.4 12.8 ], 6, 1, 2000, 2000, 1, 80, 80, 200, 25, 500, 10)
% MakeChordBWTCProtocol([  .1 .2 .4 .8 1.6 3.2 6.4 12.8 ], 20, 1, 2000, 2000, 1, 80, 80, 200, 25, 500, 10)
% MakeChordBWTCProtocol([  .1 .2 .4 .8 1.6 3.2 6.4 12.8 ], 30, 1, 2000, 2000, 1, 80, 80, 200, 25, 500, 10)
% MakeChordBWTCProtocol([  .1 .2 .4 .8 1.6 3.2 6.4 12.8 ], 30, 1, 2000, 2000, 1, 80, 80, 200, 25, 500, 10)
% MakeChordBWTCProtocol([ logspace(-1, 1.25, 10) ], 30, 1, 8000, 8000, 1, 80, 80, 2000, 25, 500, 10)
% MakeChordBWTCProtocol([ .1 .3 .5 1 3 5 10 ], 20, 1, 1000, 8000, 1, 80, 80, 2000, 25, 500, 10)
% MakeChordBWTCProtocol([ .1 .3 .5 1 3 5 10 ], 20, 1, 2000, 2000, 4, 50, 80, 2000, 25, 500, 10)
%
%
%note: freqs is used for NBN center frequencies
if nargin==0 fprintf('\nno input');return;end

%sanity check
if min(bandwidths)<1/tone_density
    fprintf('\nProblem: requested tone density of %d/oct (%g oct) is too sparse to generate requested minimum bandwidth of %g oct', tone_density, 1/tone_density, min(bandwidths))
fprintf('\nDid not create stimuli')
return
end

numoctaves=log2(maxfreq/minfreq);
%always add pure tone (0)  to list of bandwidths but not white noise
bandwidths=[0 bandwidths];
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
    bws( prod(size(Bandwidths))*(nn-1) + (1:prod(size(Bandwidths))) ) = Bandwidths(neworder );
end

bwstring=sprintf('%g-', bandwidths(1:end));bwstring=bwstring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';
stimuli(1).param.name= sprintf('ChordBWTC Protocol,%s BW, %dtd, %dfpo(%d-%dHz)/%da(%d-%ddB)/%dmsdur/%dmsisi/%dreps',bwstring,...
    tone_density, freqsperoctave,minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, duration,isi, nrepeats);
stimuli(1).param.description=...
    sprintf('ChordBWTC Protocol, BW %s, td %d, %d freqs/oct (%d-%dkHz), %d ampl. (%d-%d dB SPL), %d ms duration, %dms ramp, %d repeats, %dms isi, %ds duration per repeat',...
    bwstring, tone_density, freqsperoctave, minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, duration, ramp, nrepeats, isi, round(tdur));
filename=sprintf('ChordBWTC-%sbw-%dtd-%dfpo_%d-%dHz-%da_%d-%ddB-d_%dms-isi%dms-n%d.mat',...
    bwstring, tone_density, freqsperoctave,minfreq, round(maxfreq), numamplitudes,minamplitude, maxamplitude, duration, isi, nrepeats);

for nn=1:length(amplitudes)
    if bws(nn)==0 %pure tone
        stimuli(nn+1).type='tone';
        stimuli(nn+1).param.frequency=freqs(nn);
        stimuli(nn+1).param.amplitude=amplitudes(nn);
        stimuli(nn+1).param.duration=duration;
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.next=isi;
    else %Chord
        stimuli(nn+1).type='chordtrain';
        stimuli(nn+1).param.nchords=1;
        stimuli(nn+1).param.isi=0; %not used since only 1 chord
        stimuli(nn+1).param.start=0;
        stimuli(nn+1).param.center_frequency=freqs(nn);
        stimuli(nn+1).param.bandwidthOct=bws(nn); %not used but stored for readability
        stimuli(nn+1).param.bandwidthHz=bws(nn); %not used but stored for readability
        lowerfreq=freqs(nn)*2^(-bws(nn)/2);
        upperfreq=freqs(nn)*2^(+bws(nn)/2);
        stimuli(nn+1).param.lower_frequency=lowerfreq;%not used but stored for readability
        stimuli(nn+1).param.upper_frequency=upperfreq;%not used but stored for readability
        chordfreqs=lowerfreq*2.^([0:(1/tone_density):bws(nn)]);
        if upperfreq-chordfreqs(end)>1
            fprintf('\nupper freq mismatch: %g Hz', upperfreq-chordfreqs(end));
        end
        stimuli(nn+1).param.frequency=chordfreqs;
        stimuli(nn+1).param.ramp=ramp;
        stimuli(nn+1).param.amplitude=amplitudes(nn);
        stimuli(nn+1).param.chordduration=duration;
        stimuli(nn+1).param.duration=duration;
        stimuli(nn+1).param.next=isi;
    end
end
global pref
Prefs
cd(pref.stimuli)
if exist('ChordBWTC Protocols')~=7
mkdir('ChordBWTC protocols')
end
cd ('ChordBWTC protocols')
save(filename, 'stimuli')
fprintf('\ncreated file %s \nin directory %s', filename, pwd)

% keyboard