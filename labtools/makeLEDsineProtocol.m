function makeLEDsineProtocol(frequency, amplitude, duration) 

global pref
%usage: makeLEDsineProtocol(frequency, amplitude, duration) 
% inputs:
% frequency: temporal frequency of the sine wave in Hz
% amplitude: peak-to-peak amplitude of the sine wave, in %
% duration: duration of sine wave in ms
%
%creates an exper2 stimulus protocol file of a  sine wave
%intensity time series for an LED. The sine wave varies from zero to
%amplitude (in %) where 100%=max AD range=max brightness
%phase is fixed at -pi/2
%
% outputs:
% creates a suitably named stimulus protocol in D:\wehr\exper2.2\protocols
%
%
%example call: makeLEDsineProtocol(2, 100, 2000)

samplingrate=10e3; %
t=1:duration*samplingrate/1000;
t=t/samplingrate;
s=(-amplitude/20)*sin(2*pi*frequency*t-pi/2)-amplitude/20;

s(end)=0; %leave last value at ground
sample.param.description=sprintf('sine wave LED stimulus, %dHz, %d%%, %dms', frequency, amplitude, duration);
sample.sample=s;

%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('LEDsin_%d_%d_%d', frequency, amplitude, duration);
stimuli(1).param.description= sprintf('sine wave LED stimulus, %dHz, %d%%, %dms', frequency, amplitude, duration);

filename=sprintf('LEDsin_protocol_%d_%d_%d', frequency, amplitude, duration);
sourcefilename=sprintf('LEDsin_sourcefile_%d_%d_%d', frequency, amplitude, duration);

stimuli(2).type='led';
stimuli(2).param.file=sourcefilename;
stimuli(2).param.duration=duration; %in ms, =2700s=45minutes
stimuli(2).param.channel=1; %try chan 2????

%???note: isi not used!!!

Prefs
cd (pref.stimuli)
save(filename, 'stimuli');
save(sourcefilename, 'sample');


