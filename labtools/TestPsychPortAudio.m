%test PsychPortAudio for sanity check
%mw 09-03-2015

if exist('PPAhandle')
PsychPortAudio('Stop', PPAhandle);
PsychPortAudio('Close', PPAhandle);
end

InitializePsychSound(0); %  InitializePsychSound([reallyneedlowlatency=0])
PsychPortAudio('Verbosity', 5); %nm 09.09.08 turn off all text feedback from PPA
deviceid=GetAsioLynxDevice
numchan=1
reqlatencyclass=2
SoundFs = 44100
buffPos=0
buffSize = 1024
nreps=1
PPAhandle = PsychPortAudio('Open', deviceid, [], reqlatencyclass, SoundFs, numchan, buffSize)
runMode = 1 %leaves soundcard on (hot), uses more resources but may solve dropouts? mw 08.25.09: so far so good.
PsychPortAudio('RunMode', PPAhandle, runMode)
samples=.005*randn(1, SoundFs);
samples=reshape(samples, 1, length(samples)); %ensure samples are a row vector

status = PsychPortAudio('GetStatus', PPAhandle)

PsychPortAudio('FillBuffer', PPAhandle, samples) % fill buffer now, start in PlaySound
when=0 %use this to start immediately
waitForStart=0

PsychPortAudio('Start', PPAhandle,nreps,when,waitForStart);




