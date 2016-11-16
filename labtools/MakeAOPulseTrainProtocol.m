function MakeAOPulseTrainProtocol2(numamplitudes, minamplitude, maxamplitude, ...
    trainduration, isis, pulseduration, start, next,  nrepeats, shuffle)
%usage:  MakeAOPulseTrainProtocol2(numamplitudes, minamplitude, maxamplitude, ...
% trainduration, isis, pulseduration, start, next,  nrepeats, shuffle)
%
% similar to MakePulseTrainProtocol except the pulse train outputs are sent
% to AO instead of the soundcard. SO they are for electroporating or
% something, not for making clicktrain sounds.
%
% here is the original help from MakePulseTrainProtocol2
% similar to MakeWNTrainProtocol2 except it produces square pulses with
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
%   minamplitude: minimum amplitude in volts 
%   maxamplitude: maximum amplitude in volts
%   trainduration   -   duration of train, in ms
%   isis            -   inter-stimulus interval, i.e. interval between the
%                       start of previous pulse and start of the next pulse
%                       (adding support for multiple ISIs, use a vector)
%   pulseduration   -   duration of an individual pulse (ms)
%   start           -   start of the first pulse after the trigger (ms)
%   next            -   inter-pulse-train-interval, i.e. when the next
%                       pulse train should follow the previous one (ms)
%   nrepeats: number of repetitions (different pseudorandom orders for atten)
%   shuffle: 1 to randomly interleave stimuli, 0 to increment amplitudes
%   and/or isis linearly (for example, if you want to gradually increase
%   amplitude until some criteria is met)
%
%
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
%note the arguments are the same as MakeWNTrainProtocol2 but there's no ramp
%
%example calls: 
% 200 hz train of 1 ms 2 V pulses
% MakeAOPulseTrainProtocol(1, 2, 2, 1e3, 5, 1, 10, 1000, 1, 0)
%
% 200 hz train of 1 ms pulses, voltage gradually increasing from 1 volt to
% 3 volts in 20 steps
% MakeAOPulseTrainProtocol(20, 1, 3, 1e3, 5, 1, 10, 1000, 1, 0)
%
%MakeAOPulseTrainProtocol(1, 5, 5, 10e3, [16 32 64 128 256 512 1024], 10, 100, 1000,  5) 
global pref
numisis=length(isis);

linspacedamplitudes = linspace( minamplitude , maxamplitude , numamplitudes );
[Amplitudes,ISIs]=meshgrid( linspacedamplitudes , isis );

%[Amplitudes,Freqs]=meshgrid( linspacedamplitudes , logspacedfreqs );
neworder=randperm( numamplitudes*numisis );
amplitudes=zeros(size(neworder*nrepeats));
interpulseintervals=zeros(size(neworder*nrepeats));

tdur=0;
total_trainduration=next+start+trainduration;
tdur=numisis*numamplitudes*(total_trainduration)/1000;%duration per repeat


for nn=1:nrepeats
    if shuffle
        neworder=randperm( numamplitudes*numisis );
    else
        neworder=sort(randperm( numamplitudes*numisis ));
    end
    amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    interpulseintervals( prod(size(ISIs))*(nn-1) + (1:prod(size(ISIs))) ) = ISIs( neworder );
end

channel=1;
for c=1:length(pref.ao_channels)
    if strcmp(pref.ao_channels(c).name, 'ledchannel')
        channel=c;
    end
end

isistring=sprintf('%d-', isis);isistring=isistring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('AOPulseTrain, %da/%gV-%gV/%dms/%sms/d=%d', numamplitudes, minamplitude,maxamplitude,pulseduration, isistring, trainduration);
stimuli(1).param.description=sprintf('AO pulse train, %d ampl. (%g-%g V), %dms pulseduration, %d repeats, %d ms trainduration, %d ISIs (%sms), %ds duration per repeat', numamplitudes,minamplitude, maxamplitude, pulseduration, nrepeats, trainduration, numisis, isistring, round(tdur));
filename=sprintf('AOPulseTrain-%da-%gV-%gV-%dms-%sms-d%d.mat',numamplitudes,minamplitude,maxamplitude,pulseduration, isistring,trainduration);

for nn=2:(1+length(amplitudes))
    stimuli(nn).type='AOpulsetrain';
    stimuli(nn).param.amplitude=amplitudes(nn-1);
   
    npulses=floor(trainduration/interpulseintervals(nn-1));
    
    stimuli(nn).param.npulses=npulses;
    stimuli(nn).param.isi=interpulseintervals(nn-1);
    stimuli(nn).param.pulseduration=pulseduration;
    stimuli(nn).param.start=start;
    stimuli(nn).param.next=next;
    stimuli(nn).param.channel=channel;
    stimuli(nn).param.duration=total_trainduration;
end


global pref
prefs
cd(pref.stimuli)
cd ('PulseTrain Protocols')

save(filename, 'stimuli')


% keyboard