function ProcessWNTrain2_psth(expdate, session, filenum, varargin)
% usage: out=ProcessWNTrain2_psth(expdate, session, filenum, [xlimits], [nstd])
% processes data for WNTrain2 stimuli
%(these are WN trains at various isis but with fixed train duration)
%returns processed data in out.
%machine independent

monitor=1; %0=off; 1=on

nstd=7;
if nargin==0
    fprintf('\nnoinput\n')
    return
elseif nargin==3
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
elseif nargin==4
    xlimits=varargin{1};
    if isempty(xlimits) | length(xlimits)~=2
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
elseif nargin==5
    xlimits=varargin{1};
    if isempty(xlimits) | length(xlimits)~=2
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    nstd=varargin{2};
    if isempty(nstd) nstd=7;end
else
    error('ProcessWNTrain2: wrong number of arguments');
end

fprintf('\nusing xlimits [%d %d]', xlimits)
 use_soundcard_triggers=1; %this flag is normally set to 1. Set it to 0 if
% you want to use hardware trigger (Position_rising), which is less
% accurate, but a useful backup in case there is a glitch in a soundcard
% trigger. You can check for a glitch with this code snippet: for i=1:length(event);sc(i)=event(i).soundcardtriggerPos;pr(i)=event(i).Position_rising;end;figure;plot(sc-pr)
if use_soundcard_triggers fprintf('\nusing soundcard triggers.')
else fprintf('\nusing hardware triggers.')
end

outfilename=sprintf('out%s-%s-%s-psth',expdate,session, filenum);

[D E S]=gogetdata(expdate,session,filenum);




samprate=1e4;
scaledtrace=D.nativeScaling*double(D.trace);
stim=S.nativeScalingStim*double(S.stim);
event=E.event;
numevents=length(event);
clear D E S

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

high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace=filtfilt(b,a,scaledtrace);
thresh=nstd*std(filteredtrace);
fprintf('\nusing spike detection threshold of %.1f mV (%d sd)', thresh, nstd);
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
if isempty(spikes)
    fprintf('\n\ndspikes is empty; either the cell never spiked or the nstd is set too high\n');
else
    dspikes=[spikes(1) dspikes'];
end

if (monitor)
    figure
    subplot(211)
    plot(filteredtrace, 'b')
    hold on
    plot(thresh+zeros(size(filteredtrace)), 'm--')
    plot(spikes, thresh*ones(size(spikes)), 'g*')
    plot(dspikes, thresh*ones(size(dspikes)), 'r*')
    L1=line(xlim, thresh*[1 1]);
    L2=line(xlim, thresh*[-1 -1]);
    set([L1 L2], 'color', 'g');
    subplot(212)
    plot(filteredtrace(1:10e4), 'b')
    hold on
    plot(thresh+zeros(size(filteredtrace(1:10e4))), 'm--')
    plot(spikes, thresh*ones(size(spikes)), 'g*')
    plot(dspikes, thresh*ones(size(dspikes)), 'r*')
    xlim([0 10e4])
    L1=line(xlim, thresh*[1 1]);
    L2=line(xlim, thresh*[-1 -1]);
    set([L1 L2], 'color', 'g');
end

% Mt: matrix with each complete train
% Ms: stimulus matrix in same format as Mt

%first concatenate the sequence of trains into a matrix Mt
%preallocate Mt and Ms
% Mt=zeros(numisis, 1,round(tracelength*1e-3*samprate+1) );%trains
% Ms=Mt;%stimulus record
nreps=0*isis;
for i=1:length(event)
    if strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'pulsetrain')
        if isfield(event(i), 'soundcardtriggerPos') & use_soundcard_triggers
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end

        start=round(pos+(event(i).Param.start+xlimits(1))*1e-3*samprate);
        stop=round(pos+(event(i).Param.start+xlimits(2))*1e-3*samprate);

        region=start:stop;
        if pos>lostat
            fprintf('discarding trace')
        elseif isempty(find(region<0)) & stop<length(scaledtrace) %(disallow negative start times and don't exceed end)
            isi=event(i).Param.isi;
            isiindex=find(isi==isis);
            nreps(isiindex)=nreps(isiindex)+1;
            spiketimes=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
            spiketimes=(spiketimes-pos)*1000/samprate - event(i).Param.start;%covert to ms after tone onset
            Mt(isiindex,nreps(isiindex)).spiketimes=spiketimes;
            Ms(isiindex,nreps(isiindex),:)=stim(region);
        end
    end
end

fprintf('\nminimum of %d repetitions', min(nreps))

%accumulate across trials
for isiindex=[1:numisis]
    spiketimes=[];
    for rep=1:nreps(isiindex)
        spiketimes=[spiketimes Mt(isiindex, rep).spiketimes];
    end
    mMt(isiindex).spiketimes=spiketimes;
end
for isiindex=[1:numisis]
    mMs(isiindex,:)=mean(Ms(isiindex, 1:nreps(isiindex),:), 2);
end


tracelength=50;%25; %ms
fprintf('\nusing response window of 0-%d ms after tone onset', tracelength);

% Mc=zeros(numisis, max(nclicks), tracelength*samprate/1000);
% Mcs=Mc;

% figure

fprintf( '\nsorting into tone matrix...');
for isiindex=1:numisis
    for k=1:nclicks(isiindex)
        for rep=1:nreps(isiindex)
            isi=isis(isiindex);
            start=(0+(k-1)*(isi));
%             start=(baseline+(k-1)*(isi));
            if start<1 start=1;end
            stop=start+tracelength ;
%             start=(baseline+(k-1)*(isi))*samprate/1000;
%             stop=start+tracelength*samprate/1000 -1;
            region=round(start):round(stop);
            spiketimes=Mt(isiindex, rep).spiketimes;
            st=spiketimes(spiketimes>start & spiketimes<stop); % spiketimes in region

            trace_stim=squeeze(Ms(isiindex, rep, region));

            Mc(isiindex,  k, rep).spiketimes=st;
            Mcs(isiindex,  k,rep, :)=trace_stim;
        end
    end
end
for isiindex=1:numisis
    for k=1:nclicks(isiindex)
%         spiketimes=[];
%         spiketimes=[spiketimes Mc(isiindex, k, 1:nreps(isiindex)).spiketimes];
        mMc(isiindex, k).spiketimes=[Mc(isiindex, k, 1:nreps(isiindex)).spiketimes];
        mMcs(isiindex, k,:)=mean(Mcs(isiindex, k, 1:nreps(isiindex), :), 3);
    end
end
fprintf('done')

for isiindex=1:numisis
    for k=1:nclicks(isiindex)
            for rep=1:nreps(isiindex)
            Mspikecount(isiindex, k, rep)=length([Mc(isiindex, k, rep).spiketimes]);        
            end
    end
end

% % compute RRTF as ratio of last5/first click response -- rep-by-rep
for isiindex=[1:numisis]
    for rep=1:nreps(isiindex)
        spiketimes1=(Mc(isiindex, 1, rep).spiketimes);
        spiketimesn=[];
        
            for click=nclicks(isiindex)-4:nclicks(isiindex)
                spiketimesn=[spiketimesn (Mc(isiindex, click, rep).spiketimes)];
            end
            
            for click=nclicks(isiindex)-4:nclicks(isiindex)
                spiketimesn=[spiketimesn (Mc(isiindex, click, rep).spiketimes)];
            end
            
            RRTF(isiindex, rep)=(length(spiketimesn)/5)/(length(spiketimes1));
            if isinf(RRTF(isiindex, rep)), RRTF(isiindex, rep)=nan;end
            
            
    end
end

% % %compute RRTF as ratio of last5/first click response
% % % mean across reps
for isiindex=[1:numisis]
    spiketimes1=cat(2,Mc(isiindex, 1, 1:nreps(isiindex)).spiketimes);
    spiketimesn=[];
    

    for click=nclicks(isiindex)-4:nclicks(isiindex)
        spiketimesn=[spiketimesn (Mc(isiindex, click, 1:nreps(isiindex)).spiketimes)];
    end
    %         mRRTF(isiindex)=(length(spiketimesn)/5)/(nreps(isiindex)*length(s
    %         piketimes1));    why do I have the divide by nreps(isiindex) in
    %         there ???
    mRRTF(isiindex)=(length(spiketimesn)/5)/(length(spiketimes1));
    
    
    
    for click=nclicks(isiindex)-4:nclicks(isiindex)
        spiketimesn=[spiketimesn (Mc(isiindex, click, 1:nreps(isiindex)).spiketimes)];
    end
    %         mRRTF(isiindex)=(length(spiketimesn)/5)/(nreps(isiindex)*length(s
    %         piketimes1));    why do I have the divide by nreps(isiindex) in
    %         there ???
    mRRTF(isiindex)=(length(spiketimesn)/5)/(length(spiketimes1));
end

%compute P2P1 as ratio of second/first click response -- rep-by-rep
for isiindex=[1:numisis]
    for rep=1:nreps(isiindex)
        spiketimes1=(Mc(isiindex, 1, rep).spiketimes);
        spiketimes2=(Mc(isiindex, 2, rep).spiketimes);
        P2P1(isiindex,rep)=length(spiketimes2)/(length(spiketimes1));
        if isinf(P2P1(isiindex, rep)), P2P1(isiindex, rep)=nan;end
    end
end

%compute P2P1 as ratio of second/first click response 
% % mean across reps
for isiindex=[1:numisis]
        spiketimes1=cat(2, Mc(isiindex, 1, 1:nreps(isiindex)).spiketimes);
        spiketimes2=cat(2, Mc(isiindex, 2, 1:nreps(isiindex)).spiketimes);     
        mP2P1(isiindex)=length(spiketimes2)/(length(spiketimes1));    
end

%assign outputs
out.P2P1=P2P1;
out.mP2P1=mP2P1;
out.RRTF=RRTF;
out.mRRTF=mRRTF;
% out.scaledtrace=scaledtrace;
out.Mt=Mt;
out.Ms=Ms;
out.Mc=Mc;
out.Mspikecount=Mspikecount;
out.mMc=mMc;
out.Mcs=Mcs;
out.mMs=mMs;
out.mMt=mMt;
out.expdate=expdate;
out.filenum=filenum;
out.session=session;
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
 out.xlimits=xlimits;
out.samprate=samprate;

fprintf('\nsaving %s...', outfilename)
godatadir(expdate, session, filenum)
save(outfilename, 'out')
fprintf('done')