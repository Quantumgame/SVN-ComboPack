function MakeWNTrainProtocol2(numamplitudes, minamplitude, maxamplitude, ...
    trainduration, isis, clickduration, start, next, ramp, nrepeats)
%usage:  MakeWNTrainProtocol2(numamplitudes, minamplitude, maxamplitude, ...
% trainduration, isis, clickduration, start, next, ramp, nrepeats)
%
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
%   trainduration   -   duration of train, in ms
%   isis            -   inter-stimulus interval, i.e. interval between the
%                       start of previous click and start of the next click
%                       (adding support for multiple ISIs, use a vector)
%   clickduration   -   duration of an individual click (ms)
%   start           -   start of the first click after the trigger (ms)
%   next            -   inter-click-train-interval, i.e. when the next
%                       click train should follow the previous one (ms)
%   ramp            -   rising/falling edge of individual clicks
%   nrepeats: number of repetitions (different pseudorandom orders for atten)
%
% outputs:
% creates a suitably named stimulus protocol in exper2.2\protocols
%
%
%example calls: 
%MakeWNTrainProtocol2(1, 80, 80, 10e3, 100, 25, 100, 500, 3, 1)
%MakeWNTrainProtocol2(11, -20, 80, 200, 50, 1, 100, 100, .1, 1) 
%MakeWNTrainProtocol2(1, 80, 80, 10e3, [16 32 64 128 256 512 1024], 10, 100,
%1000, .1, 5) 
%MakeWNTrainProtocol2(1, 80, 80, 10e3, [ 32 64 128 256 512 1024], 10, 100, 3000, .1, 10) 
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

stimuli(1).param.name= sprintf('WNTrain2, %da/min%d,max%ddB%dms/%sms/d=%d', numamplitudes,minamplitude,maxamplitude ,clickduration, isistring, trainduration);
stimuli(1).param.description=sprintf('White noise train2, %d ampl. (%d-%d dB SPL), %dms clickduration, %.1fms ramp, %d repeats, %d ms trainduration, %d ISIs (%sms), %ds duration per repeat', numamplitudes,minamplitude, maxamplitude, clickduration, ramp, nrepeats, trainduration, numisis, isistring, round(tdur));
filename=sprintf('WNTrain2-%da-%ddB-%ddB-%dms-%sms-d%d.mat',numamplitudes,minamplitude,maxamplitude,clickduration, isistring,trainduration);

for nn=2:(1+length(amplitudes))
    stimuli(nn).type='clicktrain';
    stimuli(nn).param.amplitude=amplitudes(nn-1);
   
    nclicks=floor(trainduration/interclickintervals(nn-1));
    
    stimuli(nn).param.nclicks=nclicks;
    stimuli(nn).param.isi=interclickintervals(nn-1);
    stimuli(nn).param.clickduration=clickduration;
    stimuli(nn).param.start=start;
    stimuli(nn).param.next=next;
    stimuli(nn).param.ramp=ramp;
    stimuli(nn).param.duration=total_trainduration;
end


global pref
Prefs
cd(pref.stimuli)
cd ('WNTrain2 Protocols')

save(filename, 'stimuli')


% keyboard