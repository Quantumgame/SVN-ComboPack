function MakeWNTrainProtocol(numamplitudes, minamplitude, maxamplitude, ...
    nclicks, isis, clickduration, start, next, ramp, nrepeats)
%usage:  MakeWNTrainProtocol(numamplitudes, minamplitude, maxamplitude, ...
% nclicks, isis, clickduration, start, next, ramp, nrepeats)
% 
%
% creates an exper2 stimulus protocol file for a train of white noise bursts (click train)
% each train has a fixed number of clicks (and therefore different durations, 
% if you use multiple inter-click-intervals) 
% 
% note: to use a fixed train duration, use MakeWNTrainProtocol2 
%
% inputs:
%   numamplitudes: number of amplitude steps
%   minamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
%   maxamplitude: maximum amplitude in dB SPL (requires system to be calibrated)
%   nclicks         -   number of clicks
%   isis             -   inter-stimulus interval, i.e. interval between the
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
% creates a suitably named stimulus protocol in D:\lab\exper2.2\protocols
%
%
%example calls: 
%MakeWNTrainProtocol(1, 80, 80, 10, 100, 25, 100, 500, 3, 1)
%MakeWNTrainProtocol(11, -20, 80, 200, 50, 1, 100, 100, .1, 1) 
%MakeWNTrainProtocol(1, 80, 80, 10, [32 64 128 256 512 1024], 10, 100, 1000, .1, 5) 
numisis=length(isis);

linspacedamplitudes = linspace( minamplitude , maxamplitude , numamplitudes );
[Amplitudes,ISIs]=meshgrid( linspacedamplitudes , isis );

%[Amplitudes,Freqs]=meshgrid( linspacedamplitudes , logspacedfreqs );
neworder=randperm( numamplitudes*numisis );
amplitudes=zeros(size(neworder*nrepeats));
interclickintervals=zeros(size(neworder*nrepeats));

tdur=0;
for isi=isis
    tdur=tdur+ numamplitudes*(next+start+clickduration+(nclicks-1)*isi)/1000;%duration per repeat
end
trainduration=(next+start+clickduration+(nclicks-1)*isi);

for nn=1:nrepeats
    neworder=randperm( numamplitudes*numisis );
    amplitudes( prod(size(Amplitudes))*(nn-1) + (1:prod(size(Amplitudes))) ) = Amplitudes( neworder );
    interclickintervals( prod(size(ISIs))*(nn-1) + (1:prod(size(ISIs))) ) = ISIs( neworder );
end

isistring=sprintf('%d-', isis);isistring=isistring(1:end-1);
%put into stimuli structure
stimuli(1).type='exper2 stimulus protocol';

stimuli(1).param.name= sprintf('WNTrain, %da/%dms/%sms/n=%d', numamplitudes, clickduration, isistring, nclicks);
stimuli(1).param.description=sprintf('White noise train, %d ampl. (%d-%d dB SPL), %dms clickduration, %.1fms ramp, %d repeats, %d bursts per train, %d ISIs (%sms), %ds duration per repeat', numamplitudes,minamplitude, maxamplitude, clickduration, ramp, nrepeats, nclicks, numisis, isistring, round(tdur));
filename=sprintf('WNTrain%da-%ddB-%ddB-%dms-%sms-n%d',numamplitudes,minamplitude,maxamplitude,clickduration, isistring,nclicks);

for nn=2:(1+length(amplitudes))
    stimuli(nn).type='clicktrain';
    stimuli(nn).param.amplitude=amplitudes(nn-1);
    stimuli(nn).param.nclicks=nclicks;
    stimuli(nn).param.isi=interclickintervals(nn-1);
    stimuli(nn).param.clickduration=clickduration;
    stimuli(nn).param.start=start;
    stimuli(nn).param.next=next;
    stimuli(nn).param.ramp=ramp;
    trainduration=(next+start+clickduration+(nclicks-1)*stimuli(nn).param.isi);
    stimuli(nn).param.duration=trainduration;
end


global pref
prefs
cd(pref.stimuli)
cd ('Train Protocols')
save(filename, 'stimuli')
fprintf('\n wrote file %s to directory %s', filename, pwd)


% keyboard