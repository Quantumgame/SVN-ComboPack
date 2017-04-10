function MakePulseTrainProtocol2(numamplitudes, minamplitude, maxamplitude, ...
    trainduration, isis, clickduration, start, next,  nrepeats)
%usage:  MakePulseTrainProtocol2(numamplitudes, minamplitude, maxamplitude, ...
% trainduration, isis, clickduration, start, next,  nrepeats)
%
% similar to MakeWNTrainProtocol except it produces square pulses with
% MakePulseTrain instead of white noise bursts. This should make duration
% and sound level more interpretable for very short clicks (<~1ms) for
% which the white noise tokens can vary quite a bit due to finite sampling.
%
% Very similar to MakeWNTrainProtocol, except that instead of having a
% fixed number of clicks in each train, we have a fixed train duration
% (with variable number of clicks per train)
% creates an exper2 stimulus protocol file for a train of white noise bursts (click train)
%
% inputs:
%   numamplitudes: number of amplitude steps
%   minamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
%   maxamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
%   note that the amplitude should only be expected to loosely correspond to physical amplitude
%   trainduration   -   duration of train, in ms
%   isis            -   inter-stimulus interval, i.e. interval between the
%                       start of previous click and start of the next click
%                       (adding support for multiple ISIs, use a vector)
%   clickduration   -   duration of an individual click (ms)
%   start           -   start of the first click after the trigger (ms)
%   next            -   inter-click-train-interval, i.e. when the next
%                       click train should follow the previous one (ms)
%   nrepeats: number of repetitions (different pseudorandom orders for atten)
%
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
%note the arguments are the same as MakeWNTrainProtocol2 but there's no ramp

%example calls: 
%MakePulseTrainProtocol2(1, 80, 80, 10e3, 100, 25, 100, 500, 1)
%MakePulseTrainProtocol2(11, -20, 80, 200, 50, 1, 100, 100,  1) 
%MakePulseTrainProtocol2(1, 80, 80, 10e3, [16 32 64 128 256 512 1024], 10, 100,
%1000,  5) 
%MakePulseTrainProtocol2(1, 80, 80, 10e3, [ 32 64 128 256 512 1024], 10, 100, 3000, 10) 
numisis=length(isis);

linspacedamplitudes = linspace( minamplitude , maxamplitude , numamplitudes );
[Amplitudes,ISIs]=meshgrid( linspacedamplitudes , isis );

%[Amplitudes,Freqs]=meshgrid( linspacedamplitudes , logspacedfreqs );
neworder=randperm( numamplitudes*numisis );
amplitudes=zeros(size(neworder*nrepeats));
interclickintervals=zeros(size(neworder*nrepeats));

tdur=0;
total_trainduration=next+start+trainduration;
tdur=numisis*numamplitudes*(total_trainduration)/1000;%duration per repeat


for nn=1:nrepeats
    neworder=randperm( numamplitudes*numisis );
    amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    interclickintervals( prod(size(ISIs))*(nn-1) + (1:prod(size(ISIs))) ) = ISIs( neworder );
end

isistring=sprintf('%d-', isis);isistring=isistring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('PulseTrain, %da/%dms/%sms/d=%d', numamplitudes, clickduration, isistring, trainduration);
stimuli(1).param.description=sprintf('White noise train2, %d ampl. (%d-%d dB SPL), %dms clickduration, %d repeats, %d ms trainduration, %d ISIs (%sms), %ds duration per repeat', numamplitudes,minamplitude, maxamplitude, clickduration, nrepeats, trainduration, numisis, isistring, round(tdur));
filename=sprintf('PulseTrain-%da-%ddB-%ddB-%dms-%sms-d%d.mat',numamplitudes,minamplitude,maxamplitude,clickduration, isistring,trainduration);

for nn=2:(1+length(amplitudes))
    stimuli(nn).type='pulsetrain';
    stimuli(nn).param.amplitude=amplitudes(nn-1);
   
    nclicks=floor(trainduration/interclickintervals(nn-1));
    
    stimuli(nn).param.nclicks=nclicks;
    stimuli(nn).param.isi=interclickintervals(nn-1);
    stimuli(nn).param.clickduration=clickduration;
    stimuli(nn).param.start=start;
    stimuli(nn).param.next=next;
    stimuli(nn).param.duration=total_trainduration;
end


global pref
prefs
cd(pref.stimuli)
cd ('PulseTrain Protocols')

save(filename, 'stimuli')


% keyboard