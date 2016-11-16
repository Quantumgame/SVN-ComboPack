function MakeGapInNoiseProtocol(amps, gapdurs, pregap, duration, ramp, isi, nrepeats)
% usage MakeGapInNoiseProtocol(amp, gapdurs, pregap, duration, ramp, isi, nrepeats)
%
% creates an exper2 stimulus protocol file for Gap In Noise. Can use
% multiple gap durations, gap is silent. This is hard-coded for white noise
% but the MakeGapInNoise function can do narrow-band or other types of
% noise. Use MakeGapInTone to use tone as background.
%
% a control stimulus is also included, which is a WN the same duration as
% pregap (to compare gap response to off response) see recanzone 2011 for
% details.
%
% inputs:
% amps: amplitudes of the background noise, in dB SPL (can be a vector of
%   amplitudes)
% gapdurs: durations of the gap, in ms, in a vector, e.g. 50, or [0 50]
% pregap: delay from start of continuous noise to gap onset, in ms
% duration: total duration of noise burst
% ramp: ramp duration in ms for both noise onset/termination AND gap
% onset/termination.
%   note that the MakeGapInNoise function can handle separate ramps for gap
%   and noise, but I haven't bothered to separate them here
%
%   also note that I'm not dealing with how to handle very short gaps and
%   still avoid using very short ramps, since here a very short ramp is
%   fine (since it's white noise anyway; no clicks)
%
% isi: inter stimulus interval (onset-to-onset) in ms
% nrepeats: number of repetitions (different pseudorandom orders)
%
% outputs:
% creates a suitably named stimulus protocol in
% D:\lab\exper2.2\protocols\GapProtocols
%
%
%example calls:
%MakeGapInNoiseProtocol(70, [0 64], 128, 256, .1, 1000, 10)
%MakeGapInNoiseProtocol(70, [0 1 2 4 6 8 12 16 24 32 48 64 96 128 192 256], 256, 768, .1, 1000, 10)
%
%from recanzone 2011: 0 (no-gap), 1, 2, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192 and 256 msec

gapdurs=[gapdurs -1];
%add gapdur of -1 as a placeholder for control stimulus

numgapdurs=length(gapdurs);
numamps=length(amps);
gapdursstring='';
for i=1:numgapdurs
    gapdursstring=[gapdursstring, sprintf('%d-', gapdurs(i))];
end
gapdursstring=gapdursstring(1:end-1); %remove trailing -
ampstring='';
for i=1:numamps
    ampstring=[ampstring, sprintf('%d-', amps(i))];
end
ampstring=ampstring(1:end-1); %remove trailing -

if ramp>=1
    rampstring=sprintf('%d', ramp);
else
    rampstring=sprintf('%.1f', ramp);
end

[Amplitudes,Gapdurs]=meshgrid( amps , gapdurs );

neworder=randperm( numamps*numgapdurs );
amplitudes=zeros(size(neworder*nrepeats));
gapdurations=zeros(size(neworder*nrepeats));

% tdur=0;
% for isi=isis
%     tdur=tdur+ numamplitudes*(next+start+clickduration+(nclicks-1)*isi)/1000;%duration per repeat
% end
% trainduration=(next+start+clickduration+(nclicks-1)*isi);

for nn=1:nrepeats
    neworder=randperm( numamps*numgapdurs );
    amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    gapdurations( prod(size(Gapdurs))*(nn-1) + (1:prod(size(Gapdurs))) ) = Gapdurs( neworder );
end

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('GapWN-%sdB-gd%sms-d%dms-r%s-isi%d-%dreps',...
    ampstring, gapdursstring, duration, rampstring, isi, nrepeats);
stimuli(1).param.description=sprintf('Gap In White Noise stimulus protocol, noise amplitude:%sdB, gap duration: %sms, pre-gap: %dms, noised duration" %d ms, ramp:%sms isi:%dms %drepeats',...
    ampstring, gapdursstring, pregap, duration, rampstring, isi, nrepeats);
filename=sprintf('%s.mat', stimuli(1).param.name);

for nn=2:(1+length(amplitudes))
    stimuli(nn).type='gapinnoise';
    stimuli(nn).param.amplitude=amplitudes(nn-1);
    stimuli(nn).param.start=0;
    stimuli(nn).param.next=isi;
    stimuli(nn).param.ramp=ramp;
    stimuli(nn).param.duration=duration;
    stimuli(nn).param.filter_operation='wideband';
    stimuli(nn).param.gapdur=gapdurations(nn-1);
    stimuli(nn).param.pregap=pregap;
    stimuli(nn).param.gapramp=ramp;

    %using gapdur=-1 as a placeholder for control stimulus
    %control stimulus which is a WN the same duration as pregap
    if gapdurations(nn-1)==-1
        stimuli(nn).param.duration=pregap;
        stimuli(nn).param.gapdur=0;
    end
    
end


global pref
prefs
cd(pref.stimuli)
mkdir ('Gap In Noise Protocols')
cd ('Gap In Noise Protocols')
save(filename, 'stimuli')
fprintf('\n wrote file %s to directory %s', filename, pwd)


% keyboard