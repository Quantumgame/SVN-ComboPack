function imstimWNPPA(numtones, minamp, maxamp, duration, ramp, Fs, nreps, iti, varargin)
%usage: imstimWNPPA(numtones, minamp, maxamp, duration, ramp, Fs, nreps, iti)
% standalone function that plays sounds from a soundcard
% modified from imstim2 to play white noise bursts that rise and fall sinusoidally in
% amplitude, to uniformly activate auditory cortex 
% synch clock (1-ms TTL pulses) on channel 2
% using PsychoPhysicsToolbox PortAudio (PTB) routines (goes up to 192
% kHz sampling rate no problem, so it can produce sounds up to ~90 kHz)
% note: this module requires that PsychToolbox is installed. Freely available from psychtoolbox.org
% (apparently separate ASIO driver installation is no longer required)
% use pref.soundcarddeviceID to specify output device (e.g. lynx soundcard)
% inputs:
% numtones: number of WN bursts in series
% minamp: lowest amplitude in dB
% maxamp: highest amp 
%           (this requires that the system has been calibrated)
%  duration: tone duration in ms
%  ramp: duration of ramp at onset and termination
%  Fs: sound sampling rate
%  nreps: number of times to play the  series
%  iti: interval between sound onsets, including next in series
%
%note:
% use: imstim3(numtones, minamp, maxamp, duration, ramp, Fs, nreps, iti, 'noplay') to spit out all the calculations but not
% actually play the sound
%
%note:
% use: imstim3(numtones, minamp, maxamp, duration, ramp, Fs, nreps, iti, delay) to pause for 'delay' seconds before playing the
% sound (so you can turn out the lights and walk out the door)
%
%example calls:
% imstimWNPPA(25, 10, 90, 25,  .1, 192e3,  5, 250) %immediately plays
% imstimWNPPA(25, 10, 90, 25,  .1, 192e3,  5, 250, 'noplay') %doesn't play
% imstimWNPPA(25, 10, 90, 25,  .1, 192e3,  5, 250, 10) %plays after 10 s delay
% 50 reps = 5 min
fprintf('\nNote: WN not calibrated yet');

if nargin==0 fprintf('\nno input');return;end
global pref
if ~isfield(pref, 'soundcarddeviceID')
    Prefs
end

 if minamp>= maxamp
     error('minamp must be less than maxamp')
 end
if duration  <0
    error('duration out of bounds')
end
if nreps  <1
    error('nreps out of bounds')
end

 x=2*pi*[1/numtones:1/numtones:1]; %0 to 2pi
 y=(sin(x-pi/2)+1)/2; %0 to 1
 amps=minamp+(maxamp-minamp)*y;
fprintf('\namplitudes (dB): ')
str=textwrap({sprintf('%.1f, ', amps)}, 60);
fprintf('\n%s',str{:})

fprintf('\ntone duration %d ms, iti %d ms', duration, iti)

t=0:1/Fs:.001*duration;
toneseries=[];
for i=1:numtones
    tone=randn(size(t));
    tone=tone./(max(abs(tone))); % normalize
    amp=amps(i);
    calibrated_amplitude=calibrate(-1, amp);
    tone=calibrated_amplitude*tone;
    
    if ramp>0
        [edge,ledge]=MakeEdge(ramp,Fs);     % prepare the edges
        tone(1:ledge)=tone(1:ledge).*fliplr(edge);
        tone((end-ledge+1):end)=tone((end-ledge+1):end).*edge;
    end
    silence=zeros(1, round(Fs*.001*(iti-duration)));
    toneseries=[toneseries tone silence];
end
serieslength=length(toneseries);



total_duration=nreps*length(toneseries)/Fs;
fprintf('\ncalculated total duration %.2f s = %.1f min', nreps*numtones*length([tone silence])/Fs, nreps*numtones*length([tone silence])/(60*Fs))

series_periodicity = Fs/serieslength;

fprintf('\nactual total duration %.4f s', total_duration)
fprintf('\nseries periodicity %.4f hz', Fs/serieslength)
fprintf('\nseries period %.4f s', serieslength/Fs)
%fprintf('\ncalculated series periodicity %.4f hz', 1000/(numfreqs*(iti)))
%note: calculated matches actual
%see AOSound 222

% %this code puts  synch clock (1-ms TTL pulses) on channel 2 (to trig each frame grab)
triglength=round(Fs/1000); %1 ms trigger
ttl_interval=134; %in ms %ttl_interval=1000/FPS; %in ms %125ms=8Hz
FPS=1000/ttl_interval; %FPS=10; %frames per second
ttl_int_samp=round(ttl_interval*Fs/1000); %ttl_interval in samples
series_period_frames=serieslength/ttl_int_samp;
newserieslength=ttl_int_samp*round(series_period_frames);
fprintf('\nreadjusting toneseries by %d samples (%.2f ms)', newserieslength-serieslength, 1000*(newserieslength-serieslength)/Fs)
if newserieslength<serieslength
    toneseries=toneseries(1:newserieslength);
elseif serieslength<newserieslength
    spoo=zeros(1,newserieslength);
    spoo(1:serieslength)=toneseries;
    toneseries=spoo;
end
ttl_pulses=zeros(size(toneseries));
serieslength=length(toneseries);
fprintf('\nseries period %.4f s', serieslength/Fs)

fprintf('\nvideo frame interval: %d samples = %.4f ms = %.4f fps', ttl_int_samp, 1000*ttl_int_samp/Fs,Fs/ttl_int_samp)
fprintf('\nseries period %.4f frames', serieslength/ttl_int_samp)
series_period_sec=serieslength/Fs;
%write stimulus params to file
cd('c:\lab\imaq')
timestamp=datestr(now);

ttl_idx=1:ttl_int_samp:(length(toneseries)-triglength);
total_duration_frames=nreps*length(ttl_idx);
fprintf('\ntotal duration %d frames', total_duration_frames)
for i=ttl_idx
    ttl_pulses(i:i+triglength-1)=.8*ones(size(1:triglength));
end
tone2=zeros(length(toneseries),2); %iti is implemented as silence after tone
tone2(:,1)=toneseries;
tone2(:,2)=ttl_pulses;

ascending=0; %not used here but might be by imanal?

save imstimparams ttl_int_samp ttl_interval FPS serieslength total_duration series_periodicity series_period_frames series_period_sec timestamp ttl_idx nreps total_duration_frames ascending
fprintf('\nsaved stim params')

delay=0;
if nargin==9
    if strcmp(varargin{1}, 'noplay')
        fprintf('\nuser requested "noplay"')
        return
    elseif isnumeric(varargin{1})
        delay=varargin{1};
        fprintf('\nWill pause %g seconds before playback after you press return', delay)
    end
end
fprintf('\n\n')
spoo=input('Press return to start playback');
fprintf('\npausing %g seconds...', delay)
pause(delay)


%intialize PPA sound
InitializePsychSound(1);
%note: this module requires that PsychToolbox is installed. Freely
%available from psychtoolbox.org
%You might need to reinstall PsychToolbox after a fresh matlab
%install/upgrade
%also, after a fresh PsychToolbox install, you need to download the
%ASIO-enabled PPA driver
%(http://psychtoolbox.org/wikka.php?wakka=PsychPortAudio) and copy the
%enclosed portaudio_x86.dll into C:\toolbox\Psychtoolbox
PsychPortAudio('Verbosity', 1); %nm 09.09.08 turn off all text feedback from PPA
%because it is machine dependent, we now set deviceid in Prefs.m
%use printdevices.m to figure out which device id to use for your soundcard
deviceid = pref.soundcarddeviceID; %32; %11;
numChan = pref.num_soundcard_outputchannels; %set in Prefs.m
reqlatencyclass = pref.reqlatencyclass;
%because it is machine dependent, we now set reqlatencyclass in Prefs.m
%on rig1 use 4; %on rig2, set to 1 (the default) to avoid dropouts mw 051809
%on rig1, 1 seems to cause dropouts but 2/3/4 seem better
% class 2 empirically the best, 3 & 4 == 2
% 'reqlatencyclass' Allows to select how aggressive PsychPortAudio should be about
% minimizing sound latency and getting good deterministic timing, i.e. how to
% trade off latency vs. system load and playing nicely with other sound
% applications on the system. Level 0 means: Don't care about latency, this mode
% works always and with all settings, plays nicely with other sound applications.
% Level 1 (the default) means: Try to get the lowest latency that is possible
% under the constraint of reliable playback, freedom of choice for all parameters
% and interoperability with other applications. Level 2 means: Take full control
% over the audio device, even if this causes other sound applications to fail or
% shutdown. Level 3 means: As level 2, but request the most aggressive settings
% for the given device. Level 4: Same as 3, but fail if device can't meet the
% strictest requirements.
buffSize = 32;           % Low latency: 32, 64 or 128. High latency: 512>=
% nm 05.07.09 changed to 32, should fix dropouts.  If not, open LynxMixer.exe
% (in C:\lynx) and Settings->Buffer Size->32
% If Lynx seems not to change buffer size then type "CloseAllSoundDevices" into Matlab.
% You can monitor for dropouts using the LynxMixer as well.
buffPos = 0;

% Open audio device for low-latency output:
try PPAhandle = PsychPortAudio('Open', deviceid, [], reqlatencyclass, Fs, numChan, buffSize);
catch
    error(sprintf('Call PrintDevices and confirm that the ASIO Lynx DeviceIndex matches pref.soundcarddeviceID (in Prefs)\nIt was 24 and is now 22, mak11feb2011\n'));
end
%runMode = 0; %default, turns off soundcard after playback
runMode = 1; %leaves soundcard on (hot), uses more resources but may solve dropouts? mw 08.25.09: so far so good.
PsychPortAudio('RunMode', PPAhandle, runMode);
if isempty(PPAhandle)
    message(me,'Can''t create PsychPortAudio object...');
    return;
end

  %load samples into PPA object
  PsychPortAudio('FillBuffer', PPAhandle, tone2'); % fill buffer now, start in PlaySound
  
  %play sound

  %when=GetSecs+.1; %this extra latency prevents dropouts somehow
  when=0; %use this to start immediately
  waitForStart=0;
  PsychPortAudio('Start', PPAhandle,nreps,when,waitForStart);
  fprintf('\nplaying...')

      %when done, clean up and close
      waitforendofplayback=1;
      PsychPortAudio('Stop', PPAhandle, waitforendofplayback);
      
% not necessary to check status and wait for completion, the stop command blocks and waits       
% status = PsychPortAudio('GetStatus', PPAhandle);
% while status.Active
%    fprintf('waiting...')
%    pause(1)
% status = PsychPortAudio('GetStatus', PPAhandle);
% end
   fprintf('\nplayback completed\n')
   PsychPortAudio('Close', PPAhandle);


function go_away(obj, event)
fprintf('\ndone')
delete(obj)

function [edge, ledge]=MakeEdge(ramp, samplerate);
% generates rising/falling cosine-squared edge for the stimuli.
% Input:
% ramp          -   length of the edge (ms)
% samplerate    -   sampling rate to use for the new edge(Hz)
% Output:
% edge          -   the brand new edge itself
% ledge         -   length of the new edge
%
% Returns empty edge and ledge=0 if unsuccessful
edge=[];
ledge=0;
if nargin<2
    return;
end
omega=(1e3/ramp)*(acos(sqrt(0.1))-acos(sqrt(0.9)));
t=0:1/samplerate:pi/2/omega;
t=t(1:(end-1));
edge=(cos(omega*t)).^2;
ledge=length(edge);

function  lineamp=calibrate(frequency, amplitude)
%look-up table to correct for speaker frequency response
%the speaker frequency response has to be collected by hand with
%B&K and oscilloscope
%
%note: currently not implemented yet!
%

maxSPL=93; %need to measure this
%frequencies (Hz):
f=[-1 1 1.19 1.14 1.68 2 2.38 2.83 3.36 4 4.75 5.65 6.73 8 9.5 11.33 13.46 16 19]*1e3;

%corresponding amplitudes (dB):
a=[93 94.6 92.8 91 87 86.8 86 84.6 87.6 87.2 85.6 76.9 83.5 83.5 82.2 82.6 88.3 86 83.5];
da=a-min(min(a)); 
amps=amplitude-da; %adjusted dB for each freq
lineamps= 1*(10.^((amps-maxSPL)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V

findex=find(f<=frequency, 1, 'last');

lineamp=lineamps(findex);
















