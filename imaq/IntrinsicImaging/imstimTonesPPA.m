function imstimTonesPPA(freqsperoctave, minfreq, maxfreq, ascending, duration, amplitude, ramp, Fs, nreps, iti, varargin)
%usage: imstimTonesPPA(freqsperoctave, minfreq, maxfreq, ascending, duration, amplitude, ramp, Fs, nreps, iti)
% standalone function that plays sounds from a soundcard
% plays a series of tone pips ascending in freq
% synch clock (1-ms TTL pulses) on channel 2
% using PsychoPhysicsToolbox PortAudio (PTB) routines (goes up to 192
% kHz sampling rate no problem, so it can produce sounds up to ~90 kHz)
% note: this module requires that PsychToolbox is installed. Freely available from psychtoolbox.org
% (apparently separate ASIO driver installation is no longer required)
% use pref.soundcarddeviceID to specify output device (e.g. lynx soundcard)
% inputs:
% freqsperoctave: number of frequencies per octave (frequency resolution)
%           Typically 4
%           note: no whitenoise
% minfreq: lowest frequency in Hz
%           Note: 1 kHz is about the lowest that the rat can hear
% maxfreq: highest frequency in Hz
%           note: if minfreq-to-maxfreq cannot be divided evenly into
%           freqsperoctave, the nearest maxfreq will be used
%           (i.e. the requested freqsperoctave will be exactly enforced)
%           Note: the speaker craps out above 16 kHz, so this should be max
%           mk 22may2012
%  ascending: 1= ascending toneseries, 0=descending toneseries
%  duration: tone duration in ms
%  amplitude: tone amplitude in dB SPL
%           (this requires that the system has been calibrated)
%  ramp: duration of ramp at onset and termination
%  Fs: sound sampling rate
%  nreps: number of times to play the frequency series
%  iti: interval between sound onsets, including next in series
%
%note:
% use: imstim2(freqsperoctave, minfreq, maxfreq, ascending, duration, amplitude, ramp,
% Fs, nreps, iti, 'noplay') to spit out all the calculations but not
% actually play the sound
%
%note:
% use: imstim2(freqsperoctave, minfreq, maxfreq, ascending, duration, amplitude, ramp,
% Fs, nreps, iti, delay) to pause for 'delay' seconds before playing the
% sound (so you can turn out the lights and walk out the door)
%
%example calls:
% imstimTonesPPA(2, 1000,  8000, 1, 50, 60, 5, 192e3, 2, 250)
% imstimTonesPPA(4, 1000, 32000, 1, 50, 60, 5, 192e3, 5, 250)
% imstimTonesPPA(4, 1000, 32000, 0, 50, 60, 5, 192e3, 1, 250) %takes 6.3s per rep,
% 50 reps = 5 min

if nargin==0; fprintf('\nno input');return;end
global pref
if ~isfield(pref, 'soundcarddeviceID')
    Prefs
end

% if amplitude >1 | amplitude <0
%     error('amplitude out of bounds')
% end
if duration  <0
    error('duration out of bounds')
end
if nreps  <1
    error('nreps out of bounds')
end
fprintf('\nrequested amplitude %d dB SPL', amplitude)

numoctaves=log2(maxfreq/minfreq);
logspacedfreqs=minfreq*2.^([0:(1/freqsperoctave):numoctaves]);
newmaxfreq=logspacedfreqs(end);
numfreqs=length(logspacedfreqs);
if ascending<=0
    logspacedfreqs=fliplr(logspacedfreqs);
end

if maxfreq~=newmaxfreq
    fprintf('\nnote: could not divide %d-%d Hz evenly into exactly %d frequencies per octave', minfreq, maxfreq, freqsperoctave)
    fprintf('\nusing new maxfreq of %d to achieve exactly %d frequencies per octave\n', round(newmaxfreq), freqsperoctave)
    maxfreq=newmaxfreq;
end
fprintf('\n%d tones, ', length(logspacedfreqs))
if ascending>0 fprintf('ascending in frequency')
else fprintf('descending in frequency')
end
fprintf('\ntone duration %d ms, iti %d ms', duration, iti)

t=0:1/Fs:.001*duration;
toneseries=[];
for i=1:numfreqs
    frequency = logspacedfreqs(i);
    tone=sin(frequency*2*pi*t);
    tone=tone./(max(abs(tone))); % normalize
    calibrated_amplitude=calibrate(frequency, amplitude, logspacedfreqs);
   
   % fprintf('\nf %.1f a %.5f ',round(frequency)/1000, calibrated_amplitude)
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
fprintf('\ncalculated total duration %.2f s = %.1f min', nreps*numfreqs*length([tone silence])/Fs, nreps*numfreqs*length([tone silence])/(60*Fs))

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

save imstimparams ttl_int_samp ttl_interval FPS serieslength total_duration ...
    series_periodicity series_period_frames series_period_sec timestamp ttl_idx ...
    nreps total_duration_frames ascending
fprintf('\nsaved stim params')

delay=0;
if nargin==11
    if strcmp(varargin{1}, 'noplay')
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

%plot(toneseries, '-o')
%drawnow

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
%deviceid = pref.soundcarddeviceID; %32; %11;
deviceid = GetAsioLynxDevice;
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
fprintf('\ndone\n')
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

function  lineamp=calibrate(frequency, amplitude, logspacedfreqs)
%look-up table to correct for speaker frequency response
%the speaker frequency response has to be collected by hand with
%B&K and oscilloscope
%frequencies (Hz):
f=sort(logspacedfreqs); %sort so descending tones are ascending, since the cal values below are for ascending freq

% I recorded these freqs using the B&K from rig2 and placing the microphone
% ~11 cm from the speaker. Using the oscilloscope on Cyc RMS and averaging
% 64 traces I obtained the following values (mV).
% 85 dB command amplitude did pretty well
% mk 22may2012

%amp_in_mV=[1.490 1.100 .968 1.270 .984 .685 .904 .485 .301 .233 .373 .528 .573 .140 .125 .530 .533];
%above is for old speaker setup
amp_in_mV=[1.75 .90 1.22 1.92 1.84 2.37 3.14 6.8 9.7 11.2 6.7 5.1 10.8 6.70 5.16 4.50 11.3 12.4 2.69 2.12 1.41 .920 .880 .758 .350];
%amp_in_mV=[1.75 .90 1.22 1.92 1.84 2.37 3.14 6.8 9.7 11.2 6.7 5.1 10.8 6.70 5.16 4.50] %1.189-16Khz
%   recorded at 85dB command, with maxSPL=100 cto 06aug2012 - new
%   ultrasonic speaker
%amp_in_mV=[];
% converts amp_in_mV to dB
a=zeros(1,length(amp_in_mV));
for i=1:length(amp_in_mV)
    a(i)=dBSPL(amp_in_mV(i),1);
end
da=a-min(min(a));
% da=zeros(1,length(f)); %comment in and comment out the line above to calibrate,
% place recorded values (mV) into amp_in_mV above and note the command dB

maxSPL=100; % set by mk 23may2012. See lab notebook on page 7 for details. 
% This works in conjuction with amp_in_mV
% In short, maxSPL=110, with command amp of 85 produced ~65 dB
%           maxSPL=100, with command amp of 85 produced 76 dB
%           maxSPL= 91, with command amp of 85 produced 85 +/- 0.5 dB
%           maxSPL= 91, with command amp of 75 produced 74 +/- 1 dB
%           maxSPL= 91, with command amp of 65 produced 62 +/- 2 dB
% I used maxSPL=100 to obtain amp_in_mV above da set to zero. If I were to
% re-record these values by simply setting maxSPL to 91, the amp_in_mV
% values will change. Thus, maxSPL needs to be adjusted by 9 in the linamps 
% calculation.
maxSPL_adjusted=maxSPL-9;
%changed from -9 (old setup) 
amps=amplitude-da; %adjusted dB for each freq

%  lineamps = 1*(10.^((amps-maxSPL)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V
%   Use this one for recording the raw sounds with da set to zero
lineamps = 1*(10.^((amps-maxSPL_adjusted)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V
%   Use this one to ensure the command amplitude matches the actual speaker
%   output. You may need to adjust maxSPL_adjusted a little, currently -9
%   works pretty well

findex=find(f<=frequency, 1, 'last');

try
    lineamp=lineamps(findex);
catch
    warning('calibration error: tones not calibrated')
    lineamp=lineamps(end);
end

