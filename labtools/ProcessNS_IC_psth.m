function ProcessNS_IC_psth(varargin)
%Process membrane potential responses to natural sound stimuli (speech, etc.)
%u
%ProcessNS_IC(expdate, session, filename, thresh, xlimits, ylimits, binwidth)
%saves output to outfile
dbstop if error

username=whoami;
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=7;
    xlimits=[]; %x limits for axis
    ylimits=[];
    binwidth=[];
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    xlimits=[];
    ylimits=[];
    binwidth=[];
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    xlimits=varargin{5};
    ylimits=[];
    binwidth=[];
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    xlimits=varargin{5};
    ylimits=varargin{6};
    binwidth=[];
elseif nargin==7
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    xlimits=varargin{5};
    ylimits=varargin{6};
    binwidth=varargin{7};    
else
    error('wrong number of arguments'); % If you get any other number of arguments...
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(binwidth)
    binwidth=5;
end

monitor=1; %0=off; 1=on

fprintf('\nload file: ')
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
[D E S]=gogetdata(expdate,session,filenum);
event=E.event;
if isempty(event); fprintf('\nno tones\n'); return; end
stim1=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E S

lostatfilename=sprintf('lostat-%s-%s-%s.mat',expdate,session,filenum);
if exist(lostatfilename,'file')
    load(lostatfilename)
    fprintf('\nfound lostat file. using lostat %d %d',lostat );
    if length(lostat)==1
        lostat=[1 lostat];
        save(lostatfilename,'lostat')
    end
else
    lostat=[1 length(scaledtrace)];
end
fprintf('\ncomputing tuning curve...');
samprate=1e4;

%filter
high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace=filtfilt(b,a,scaledtrace);
hiCutOff = nan;

%threshold
if nstd(1)==-1
    if length(nstd)==2
        thresh=nstd(2);
        nstd=thresh/std(filteredtrace);
        fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh, nstd);
    end
elseif length(nstd)==3
    % If there's a hard mV thresh AND a high cut off...
    % AKH 5/22/12
    if nstd(1)==-1
        thresh=nstd(2);
        hiCutOff=nstd(3);
        nstd=thresh/std(filteredtrace);
        fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh, nstd);
        fprintf('\nIgnoring spikes >%.1f mV',hiCutOff)
    end
else
    thresh=nstd*std(filteredtrace);
    if thresh>1
        fprintf('\nusing spike detection threshold of %.1f mV (%g sd)', thresh, nstd);
    elseif thresh<=1
        fprintf('\nusing spike detection threshold of %.4f mV (%g sd)', thresh, nstd);
    end
end

%looking for spikes above threshold
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
try
dspikes=[spikes(1) dspikes'];
catch
    fprintf('\n\ndspikes is empty; either the cell never spiked or the nstd is set too high\n');
    return
end

%plotting filteredtrace
if (monitor)
    figure
    plot(filteredtrace, 'b')
    hold on
    plot(thresh+zeros(size(filteredtrace)), 'm--')
    plot(spikes, thresh*ones(size(spikes)), 'g*')
    plot(dspikes, thresh*ones(size(dspikes)), 'r*')
    L1=line(xlim, thresh*[1 1]);
    L2=line(xlim, thresh*[-1 -1]);
    set([L1 L2], 'color', 'g');
end

%%Looking for stimuli
%note: we assume only one dur, and multiple epochs
%get number of epochs
j=0;
for i=1:length(event) %
    if strcmp(event(i).Type, 'naturalsound')
        j=j+1;
        alldurs(j)=event(i).Param.duration;
        allisis(j)=event(i).Param.next;
        allfilenames{j}=event(i).Param.file;
        allfreqs(j)=0;
        allamps(j)=event(i).Param.amplitude;
    end
end
numepochs=length(unique(allfilenames));
%note: we correct numepochs below to actual number of epochs in data set, for truncated recordings -mw 07.18.2013

epochfilenames=(unique(allfilenames));
dur=unique(alldurs);
isi=unique(allisis);
freqs=unique(allfreqs);
amps=unique(allamps);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(dur);

if length(dur)~=1 error('cannot handle multiple durs');end
if length(isi)~=1 error('cannot handle multiple isis');end
if isempty(xlimits)
    xlimits=[0 dur+1000];
end

M1=[];
nreps=zeros(1, numepochs);
lostin_counter=[];
lostat_counter=[];
%extract the traces into a big matrix M
for i=1:length(event)
    if strcmp(event(i).Type, 'naturalsound')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat(2)
                lostat_counter=[lostat_counter i];
            elseif start<lostat(1)
                lostin_counter=[lostin_counter i];
            else
                switch event(i).Type
                    case 'naturalsound'
                        epochfile=event(i).Param.file;
                end
                
                dur=event(i).Param.duration;
                epochnum=find(strcmp(epochfilenames, epochfile));
                nreps(epochnum)=nreps(epochnum)+1;
                spiketimes1=dspikes(dspikes>start &dspikes<stop);
                spiketimes1=(spiketimes1-pos)*1000/samprate;
                M1(epochnum, nreps(epochnum),:).spiketimes=spiketimes1;
                spont_spikecount=length(find(dspikes<start & dspikes>(start-(stop-start))));
                spont_spikerate=1000*spont_spikecount/diff(xlimits); %in Hz
                M1spont(epochnum, nreps(epochnum))=spont_spikerate;
                M1stim(epochnum, nreps(epochnum),:)=stim1(region);
                sequences(epochnum,nreps(epochnum),:)=event(i).Param.sequence;
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))
fprintf('\ntotal num spikes: %d', length(dspikes))

if ~isempty(lostat_counter) || ~isempty(lostin_counter)
  skipped_events=[lostat_counter lostin_counter];
  fprintf('\n%d/%d events skipped due to lostat or incomplete file\n',length(skipped_events),i)
end

traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,traces_to_keep,:), 2);
else
    for eindex=1:size(M1,1)
        spiketimes1=[];
        for rep=1:nreps(eindex)
            spikecounts(rep)=length(M1(eindex,rep).spiketimes);
            spikerates(rep)=1000*spikecounts(rep)/diff(xlimits); %in Hz
            spiketimes1=[spiketimes1 M1(eindex, rep).spiketimes];
        end
        mM1(eindex,:).spiketimes=spiketimes1;
        sM1(eindex,:)=std(spikerates);
        semM1(eindex,:)=std(spikerates)./sqrt(nreps(epochnum));
%         M11(rep,:)=M1(eindex, rep).spiketimes;
%         mM1(eindex,:)=mean(M11(reps,:), 1);
        mM1stim(eindex,:)=mean(M1stim(eindex, 1:nreps(eindex),:), 2);
        mM1stim(eindex,:)=mM1stim(eindex,:);

    end
end


numepochs=size(M1, 1); %actual numepochs in dataset
sequences(find(sequences==0))=nan; %convert missing seq entries to nans

%assign outputs
out.scaledtrace=scaledtrace;
out.M1=M1;
out.mM1=mM1;
out.sM1=sM1;
out.M1stim=M1stim;
out.mM1stim=mM1stim;
out.mM1=mM1;
out.expdate=expdate;
out.filenum=filenum;
out.session=session;
out.datafile=datafile;
out.eventsfile=eventsfile;
out.stimfile=stimfile;
out.nreps=nreps;
out.traces_to_keep=traces_to_keep;
out.event=event;
out.xlimits=xlimits;
out.samprate=samprate;
out.epochfilenames=epochfilenames;
out.numepochs=numepochs;
out.sequences=sequences;
out.dur=dur;
out.isi=isi;
out.lostat=lostat;
out.thresh=thresh;
out.nreps=nreps;
out.ntrials=sum(sum(squeeze(nreps)))
out.binwidth=binwidth;
out.semM1=semM1;
out.nstd=nstd;
out.dspikes=dspikes;
out.filteredtrace=filteredtrace;

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
godatadir(expdate, session, filenum)
save (outfilename, 'out')
fprintf('\n saved to %s\n', outfilename)

