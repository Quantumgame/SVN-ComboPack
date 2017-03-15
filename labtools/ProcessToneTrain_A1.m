function ProcessToneTrain_A1(expdate, session, filenum)
%  processes tone train data, 
% to look at it, use PlotToneTrain

% this function has been replaced by ProcessToneTrain since you can now specify xlimits


area='A1';
loadit=1;
if nargin~=3 error('ProcessToneTrain_A1: wrong number of arguments');end

%lostat=2.4918e+006; %discard data after this position (in samples)

datafile=sprintf('%s-lab-%s-%s-AxopatchData1-trace.mat', expdate, session, filenum);
eventsfile=sprintf('%s-lab-%s-%s-AxopatchData1-events.mat', expdate, session, filenum);
stimfile=sprintf('%s-lab-%s-%s-stim.mat', expdate, session, filenum);

if loadit
    try
        fprintf('\ntrying to load %s...', datafile)
        godatadir(expdate, session, filenum)
        D=load(datafile);
        E=load(eventsfile);
        S=load(stimfile);
        fprintf('done.');
    catch
        fprintf('failed')
    end
end
fprintf('\ncomputing averaged response...');
event=E.event;

samprate=1e4;
scaledtrace=D.nativeScaling*double(D.trace);
stim=S.nativeScalingStim*double(S.stim);
clear D E S
% t=1:length(scaledtrace);
% t=1000*t/samprate;
tracelength=event(1).Param.duration; %in ms
baseline=25; %in ms


%first concatenate the sequence of trains into a matrix Mt 
j=0;
%preallocate Mt and Ms
Mt=zeros(length(event),tracelength*1e-3*samprate+1 );%trains
Ms=Mt;%stimulus record
for i=1:length(event)
    if strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'clicktrain')
        if isfield(event1(i), 'soundcardtriggerPos')
            pos=event1(i).soundcardtriggerPos;
        else
            pos=event1(i).Position_rising;
        end

         start=(pos-baseline*1e-3*samprate);
%        start=(pos);
        stop=(start+tracelength*1e-3*samprate);
        region=start:stop;
        if isempty(find(region<0)) & stop<length(scaledtrace) %(disallow negative start times and don't exceed end)
            %         tr=1:length(region);tr=1000*tr/samprate;
            %         plot(tr, scaledtrace(region))
            %         drawnow

%             manually align to stimulus            
%             s=stim(region);
%             s=s-mean(s(1:100));
%             s=s/max(s);
%             thresh=4*std(s(1:1000));
%             s1=find(abs(s)>thresh);
%             newpos=s1(1);
%             start=pos + newpos-samprate*1e-3*event(i).Param.start;
%             stop=(start+tracelength*1e-3*samprate);
%             region=start:stop;

            j=j+1;
            Mt(j,:)=scaledtrace(region);
            Ms(j,:)=stim(region);
        end
    end
end
numevents=j;




%extract tones from Tone Train into new matrix M
%note: samprate is in Hz (i.e. 10000)
%
p=0;

%get freqs/amps
j=0;
for i=1:numevents
    if strcmp(event(i).Type, 'tonetrain')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    end
end
freqs1=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs1);
numamps=length(amps);
numdurs=length(durs);

nreps=zeros(numfreqs, numamps);
switch event(1).Type
    case 'tonetrain'
        ntones=event(1).Param.ntones;
    case 'clicktrain'
        ntones=event(1).Param.nclicks;
end

% % preallocate Mc and MCs;
tracelength=300;%25; %ms
baseline=25; %in ms
Mc=zeros(numfreqs, numamps, ceil(numevents*ntones/(numfreqs*numamps)), tracelength*samprate/1000);
Mcs=Mc;

wb=waitbar(0, 'sorting into tone matrix');
for i=1:numevents
waitbar(i/numevents,wb);
switch event(i).Type
        case 'tonetrain'
            ntones=event(i).Param.ntones;
            toneduration=event(i).Param.toneduration;
            freq=event(i).Param.frequency;
        case 'clicktrain'
            ntones=event(i).Param.nclicks;
            toneduration=event(i).Param.clickduration;
            freq=-1;
    end
    isi=event(i).Param.isi;
    start=event(i).Param.start;
    amp=event(i).Param.amplitude;
    findex= find(freqs1==freq);
    aindex= find(amps==amp);


    for k=1:ntones
%        p=p+1;
%        onset=(start+(i-1)*(toneduration+isi))*samprate/1000;
        onset=(start+(k-1)*(isi))*samprate/1000;
        region=(onset+1-baseline*samprate/1000):onset+(tracelength-baseline)*samprate/1000;
        trace=squeeze(Mt(i,  region));
        trace_stim=squeeze(Ms(i,  region));
        nr=nreps(findex, aindex);
        Mc(findex, aindex, k+ntones*nr,:)=trace; %p= repetitions
        Mcs(findex, aindex, k+ntones*nr,:)=trace_stim; %stimulus matrix
    end
        nreps(findex, aindex)=nreps(findex, aindex)+1;
end
close(wb)
wb2=waitbar(.5, 'saving...');
mMc=mean(Mc, 3);
mMcs=mean(Mcs, 3);



outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
save(outfilename, 'Ms', 'Mcs' ,'Mc', 'Mt', 'baseline', 'expdate', 'session', 'filenum', 'isi', 'numevents', 'numfreqs', 'numamps', 'freqs1', 'amps')
close(wb2)

return

%examine trial-by-trial
figure;hold on
offset=max(max(max(max(Mc))));
%findex=numfreqs;
findex=1;
aindex=1;
t=1:samprate*(tracelength+baseline)/1000;t=t*1000/samprate;
for i=1:size(Mc,3)
    trace=squeeze(Mc(findex, aindex, i, :));
    plot(t, trace + offset*i)
end

figure;
hold on;
for i=1:size(Mt,1)
    plot(Mt(i,1:3800)+15*i);
    plot(Ms(i,1:3800)+15*i, 'r');
end

% keyboard

