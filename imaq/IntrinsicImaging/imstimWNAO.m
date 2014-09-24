function imstimWNAO(numtones, minamp, maxamp, duration, ramp, Fs, nreps, iti, varargin)
%usage: imstimWNAO(numtones, minamp, maxamp, duration, ramp, Fs, nreps, iti)
% standalone function that plays sounds from a soundcard
% modified from imstim2 to play white noise bursts that rise and fall sinusoidally in
% amplitude, to uniformly activate auditory cortex 
% synch clock (1-ms TTL pulses) on channel 2
% uses analog output of data acquisition toolbox, so you can
% choose your output device (e.g. lynx soundcard) and have low-level device control
% use pref.soundcarddeviceID to specify output device
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
% imstim3(25, 10, 90, 25,  .1, 44100,  5, 250) %immediately plays
% imstim3(25, 10, 90, 25,  .1, 44100,  5, 250, 'noplay') %doesn't play
% imstim3(25, 10, 90, 25,  .1, 44100,  5, 250, 10) %plays after 10 s delay
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

%intialize AOsound object
deviceid =pref.soundcarddeviceID;
deviceid =0;
%for some strange reason, this ID sometimes does not work. Try setting ID
%to 0 if 6 does not work
global AOhandle
AOhandle = analogoutput('winsound', deviceid);
addchannel(AOhandle, [1:2]);
set(AOhandle, 'StandardSampleRates','Off')
set(AOhandle, 'SampleRate', Fs);
set(AOhandle, 'BitsPerSample', 16)
if isempty(AOhandle)
    message(me,'Can''t create winsound object...');
    return;
end
for j=1:nreps
    putdata(AOhandle, tone2);
end
%set(AOhandle, 'repeatoutput', nreps-1)
set(AOhandle,  'StopFcn',  {@go_away})
start(AOhandle)
fprintf('\nplaying...')
%clean up when done
% delete(AOhandle)
% clear AOhandle

% playtimer=timer('TimerFcn', {@start, AOhandle}, 'Period',iti*.001,...
%     'ExecutionMode','FixedRate', 'TasksToExecute', nreps, 'StopFcn',  {@go_away});
% start(playtimer)

% function pl_sound(obj, event, tone, Fs)
% %sound(tone, Fs)
%

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
















