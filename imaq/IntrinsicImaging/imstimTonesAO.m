function imstimTonesAO(freqsperoctave, minfreq, maxfreq, ascending, duration, amplitude, ramp, Fs, nreps, iti, varargin)
%usage: imstimTonesAO(freqsperoctave, minfreq, maxfreq, ascending, duration, amplitude, ramp, Fs, nreps, iti)
% standalone function that plays sounds from a soundcard
% plays a series of tone pips ascending in freq
% synch clock (1-ms TTL pulses) on channel 2
% uses analog output of data acquisition toolbox, so you can
% choose your output device (e.g. lynx soundcard) and have low-level device control
% use pref.soundcarddeviceID to specify output device
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
% imstim(2, 1000,  8000, 1, 50, 60, 5, 96000, 2, 250)
% imstim(4, 1000, 32000, 1, 50, 60, 5, 96000, 5, 250)
% imstim(4, 1000, 32000, 0, 50, 60, 5, 96000, 1, 250) %takes 6.3s per rep,
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

save imstimparams ttl_int_samp ttl_interval FPS serieslength total_duration series_periodicity series_period_frames series_period_sec timestamp ttl_idx nreps total_duration_frames ascending
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
f=logspacedfreqs;

% I recorded these freqs using the B&K from rig2 and placing the microphone
% ~11 cm from the speaker. Using the oscilloscope on Cyc RMS and averaging
% 64 traces I obtained the following values (mV).
% 85 dB command amplitude did pretty well
% mk 22may2012
amp_in_mV=[1.490 1.100 .968 1.270 .984 .685 .904 .485 .301 .233 .373 .528 .573 .140 .125 .530 .533];
%   recorded at 85dB command, with maxSPL=100 cto 25july2012

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

amps=amplitude-da; %adjusted dB for each freq

 %lineamps = 1*(10.^((amps-maxSPL)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V
%   Use this one for recording the raw sounds with da set to zero
lineamps = 1*(10.^((amps-maxSPL_adjusted)/20)); %in volts (-1<x<1), i.e. pref.maxSPL=+_1V
%   Use this one to ensure the command amplitude matches the actual speaker
%   output. You may need to adjust maxSPL_adjusted a little, currently -9
%   works pretty well

findex=find(f<=frequency, 1, 'last');

lineamp=lineamps(findex);



