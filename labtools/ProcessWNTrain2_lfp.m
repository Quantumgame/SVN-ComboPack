function ProcessWNTrain2_lfp(expdate, session, filenum)
% usage: ProcessWNTrain2_lfp(expdate, session, filenum)
% processes data for WNTrain2 stimuli
%(these are WN trains at various isis but with fixed train duration)
%saves processed data in out file.

if nargin==0
    fprintf('\nnoinput\n')
    return
elseif nargin~=3 error('ProcessWNTrain2: wrong number of arguments');
end

 use_soundcard_triggers=1; %this flag is normally set to 1. Set it to 0 if
% you want to use hardware trigger (Position_rising), which is less
% accurate, but a useful backup in case there is a glitch in a soundcard
% trigger. You can check for a glitch with this code snippet: for i=1:length(event);sc(i)=event(i).soundcardtriggerPos;pr(i)=event(i).Position_rising;end;figure;plot(sc-pr)
if ~use_soundcard_triggers 
    fprintf('\n\nWarning: using hardware triggers instead of soundcard triggers... this is less accurate! \n')
end

datafile=sprintf('%s-lab-%s-%s-AxopatchData1-trace.mat', expdate, session, filenum);
eventsfile=sprintf('%s-lab-%s-%s-AxopatchData1-events.mat', expdate, session, filenum);
stimfile=sprintf('%s-lab-%s-%s-stim.mat', expdate, session, filenum);
outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
try
    fprintf('\ntrying to load %s...', datafile)
    godatadir(expdate, session, filenum)
    D=load(datafile);
    E=load(eventsfile);
    S=load(stimfile);
    fprintf('done.');
catch
    fprintf('\ncould not find data...\n')
    ProcessData_single(expdate, session, filenum)  
    D=load(datafile);
    E=load(eventsfile);
    S=load(stimfile);
end



samprate=1e4;
scaledtrace=D.nativeScaling*double(D.trace);
stim=S.nativeScalingStim*double(S.stim);
event=E.event;
numevents=length(event);
clear D E S
tracelength=event(1).Param.duration+100; %in ms
baseline=25; %in ms

lostat=length(scaledtrace);
% lostat=   2.8399e+05;
%discard data after this position (in samples)

allfreqs=0;
for i=1:numevents
    allisis(i)=event(i).Param.isi;
    alldurs(i)=event(i).Param.duration;
    if isfield(event(i).Param, 'frequency')
        allfreqs(i)=event(i).Param.frequency;
    end
    if isfield(event(i).Param, 'ntones')
        allnclicks(i)=event(i).Param.ntones;
    elseif isfield(event(i).Param, 'nclicks')
        allnclicks(i)=event(i).Param.nclicks;
    end
    allamps(i)=event(i).Param.amplitude;
end
isis=unique(allisis);
nclicks=unique(allnclicks);
nclicks=sort(nclicks, 'descend');
durs=unique(alldurs);
freqs1=unique(allfreqs);
amps=unique(allamps);
numisis=length(isis);
numnclicks=length(nclicks);
numamps=length(amps);
numdurs=length(durs);
numfreqs=length(freqs1);
if length(durs)>1 error('can''t handle multiple durations'), end
if length(freqs1)>1 error('can''t handle multiple frequencies'), end
if length(amps)>1 error('can''t handle multiple amplitudes'), end

for i=1:length(event)
    if  strcmp(event(i).Type, 'tonetrain')
        for j=1:length(event)
            if  strcmp(event(j).Type, 'clicktrain')
                error('can''t handle both tonetrain and clicktrain in same file yet')
            end
        end
    end
end

% Mt: matrix with each complete train
% Ms: stimulus matrix in same format as Mt

%first concatenate the sequence of trains into a matrix Mt
%preallocate Mt and Ms
Mt=zeros(numisis, 1,round(tracelength*1e-3*samprate+1) );%trains
Ms=Mt;%stimulus record
nreps=0*isis;
for i=1:length(event)
    if strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'clicktrain')
        if isfield(event(i), 'soundcardtriggerPos') & use_soundcard_triggers
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end

        start=(pos+(event(i).Param.start-baseline)*1e-3*samprate);
        stop=round(start+tracelength*1e-3*samprate);
        region=start:stop;
        if pos>lostat
            fprintf('discarding trace')
        elseif isempty(find(region<0)) & stop<length(scaledtrace) %(disallow negative start times and don't exceed end)
            isi=event(i).Param.isi;
            isiindex=find(isi==isis);
            nreps(isiindex)=nreps(isiindex)+1;
            Mt(isiindex,nreps(isiindex),:)=scaledtrace(region);
            Ms(isiindex,nreps(isiindex),:)=stim(region);
%             figure(1)
%             plot((1:length(region))/10, stim(region))
%             title(int2str(isi))
%             pause
        end
    end
end

nreps

for isiindex=[1:numisis]
    mMt(isiindex,:)=mean(Mt(isiindex, 1:nreps(isiindex),:), 2);
    mMs(isiindex,:)=mean(Ms(isiindex, 1:nreps(isiindex),:), 2);
end

%need ntones/nclicks

tracelength=100%60 %25; %ms
Mc=zeros(numisis, max(nclicks), max(nreps), tracelength*samprate/1000);
Mcs=Mc;

% figure

fprintf( '\nsorting into tone matrix...');
for isiindex=1:numisis
    for k=1:nclicks(isiindex)
        for rep=1:nreps(isiindex)
            isi=isis(isiindex);
            start=(baseline+(k-1)*(isi))*samprate/1000;
%            start=(baseline+(k-1)*(isi))*samprate/1000+200; use this if soundcardtriggers are turned off, to adjust for soundcard latency
            stop=start+tracelength*samprate/1000 -1;
            region=start:stop;
            trace=squeeze(Mt(isiindex, rep, region));
            trace_stim=squeeze(Ms(isiindex, rep, region));
            Mc(isiindex, k, rep,:)=trace;
            Mcs(isiindex,  k,rep,:)=trace_stim;
        end
    end
end

for isiindex=1:numisis
    for k=1:nclicks(isiindex)
        mMc(isiindex, k,:)=mean(Mc(isiindex, k, 1:nreps(isiindex), :), 3);
        mMcs(isiindex, k,:)=mean(Mcs(isiindex, k, 1:nreps(isiindex), :), 3);
    end
end
fprintf('done')


%compute RRTF as ratio of last/first click response
%using mean of last 5 clicks for "last"
for isiindex=[1:numisis]
    for rep=1:nreps(isiindex)
        trace1=squeeze(Mc(isiindex, 1,rep, :));
        trace1=trace1-median(trace1);

        tracen=squeeze(Mc(isiindex, nclicks(isiindex)-4:nclicks(isiindex),rep, :));
        tracen=mean(tracen);
        tracen=tracen-median(tracen);

        RRTF(isiindex,rep)=max(abs(tracen))/max(abs(trace1));
        PN(isiindex,rep)=max(abs(tracen));
    end
end

%compute P2P1 as ratio of second/first click response
for isiindex=[1:numisis]
    for rep=1:nreps(isiindex)
        trace1=squeeze(Mc(isiindex, 1,rep, :));
        trace1=trace1-median(trace1);

        trace2=squeeze(Mc(isiindex, 2,rep, :));
        trace2=trace2-median(trace2);

        P2P1(isiindex,rep)=max(abs(trace2))/max(abs(trace1));
        P1(isiindex,rep)=max(abs(trace1));
        P2(isiindex,rep)=max(abs(trace2));        
    end
end

%assign outputs
out.P2P1=P2P1;
out.P1=P1;
out.P2=P2;
out.PN=PN;
out.RRTF=RRTF;
out.scaledtrace=scaledtrace;
out.Mt=Mt;
out.Ms=Ms;
out.Mc=Mc;
out.Mcs=Mcs;
out.Mc=mMc;
out.Mcs=mMcs;
out.mMs=mMs;
out.mMt=mMt;
out.expdate=expdate;
out.filenum=filenum;
out.session=session;
out.datafile=datafile;
out.eventsfile=eventsfile;
out.stimfile=stimfile;
out.lostat=lostat;
out.freqs=freqs1;
out.amps=amps;
out.durs=durs;
out.isis=isis;
out.nclicks=nclicks;
out.nreps=nreps;
out.numfreqs=numfreqs;
out.numamps=numamps;
out.numdurs=numdurs;
out.numisis=numisis;
out.numnclicks=numnclicks;
out.event=event;
% out.xlimits=xlimits;
% out.ylimits=ylimits;
out.baseline=baseline;
out.tracelength=tracelength;
out.samprate=samprate;

fprintf('\nsaving %s...', outfilename)
save(outfilename, 'out')
fprintf('done')