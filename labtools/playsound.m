function playsound(frequency, duration, amplitude, ramp, Fs, nreps, iti)
% standalone function that plays sounds from the built-in soundcard
% TTL pulse with same duration on channel 2
%
% inputs:
%  frequency: tone frequency in Hz, use -1 for white noise
%  duration: tone duration in ms
%  amplitude: tone amplitude, range 0-1 (arbitrary units) 
%           (if you get clicky sounds with 1, try .9)
%  ramp: duration of ramp at onset and termination
%  Fs: sound sampling rate
%  nreps: number of times to play the sound
%  iti: interval between sound onsets, in ms (but is subject to OS
%  interference)
%
%example calls:
% playsound(1000, 100,  1, 5, 44100,  5, 1000)
% playsound(  -1,  25, .5, 1, 44100, 10, 1000)
% playsound(8000,  25,  1, 3, 44100, 15, 500)


t=0:1/Fs:.001*duration;
if amplitude >1 | amplitude <0
    error('amplitude out of bounds')
end
if duration  <0
    error('duration out of bounds')
end
if frequency>0
    tone=sin(frequency*2*pi*t);
elseif frequency==-1
    tone=randn(1,length(t));
else
    error('frequency out of bounds')
end
tone=tone./(max(abs(tone))); % normalize
tone=amplitude*tone;

if ramp>0
    [edge,ledge]=MakeEdge(ramp,Fs);     % prepare the edges
    tone(1:ledge)=tone(1:ledge).*fliplr(edge);
    tone((end-ledge+1):end)=tone((end-ledge+1):end).*edge;
end
 
 ttl_pulse=ones(size(tone));
 ttl_pulse(end)=0;
 tone2(:,1)=tone;
 tone2(:,2)=ttl_pulse;

playtimer=timer('TimerFcn', {@pl_sound, tone2, Fs}, 'Period',iti*.001,...
    'ExecutionMode','FixedRate', 'TasksToExecute', nreps, 'StopFcn',  {
@go_away});
start(playtimer)

function pl_sound(obj, event, tone, Fs)
sound(tone, Fs)

function go_away(obj, event)
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

