function makeOddballProtocolBadly(common,oddball,probcommon,amp,duration,ITI,ramp,ntones,nlaser)
% Make an oddball stimulus protocol w/ laser interleaved in a way that's really crude and rushed
% because I don't have time to polish it -JLS042616
% Needs to counterbalance oddball presentations, be able to calc. tones
% from TC, etc.
%
% common = frequency of common tone (in Hz)
% oddball = frequency of oddball tone (in Hz)
% probcommon = probability of a common tone
% amp = amplitude (in dB)
% duration = duration of tone (in ms)
% ITI = intertrial interval (in ms)
% ramp = ramp to full amp (in ms)
% ntones = number of tone presentations (not doubled for laser
% interleaves!)
% nlaser = number of tones between laser on (eg. 5 means laser on every 5th
% tone)

stimuli = struct('type','exper2 stimulus protocol','param',[]);
stimuli(1).param.name = sprintf('Oddball, Common = %dHz, Oddball = %dHz, %ddB, %dms tone, %dms ISI, %dms ramp,%d tone presentations',common,oddball,amp,duration,ITI,ramp,nlaser);
stimuli(1).param.description = sprintf('Oddball, Common = %dHz, Oddball = %dHz, %ddB, %dms tone, %dms ISI, %dms ramp,%d tone presentations',common,oddball,amp,duration,ITI,ramp,nlaser);
z = 0;
lascount = 0;
for i = 2:(ntones+1)
    stimuli(i).type = 'tone';
    if rand<=probcommon
        stimuli(i).param.frequency = common;
        stimuli(i).param.numstandard = [];
        z = z+1;
    else
        stimuli(i).param.frequency = oddball;
        stimuli(i).param.numstandard = z;
        z = 0;
    end
    stimuli(i).param.amplitude = amp;
    stimuli(i).param.duration = duration;
    stimuli(i).param.ramp = ramp;
    stimuli(i).param.next = ITI;
    lascount = lascount+1;
    if lascount == nlaser
        stimuli(i).param.AOPulseOn = 1;
        lascount = 0;
    else
        stimuli(i).param.AOPulseOn = 0;
    end
end
uisave('stimuli')
