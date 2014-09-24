function ProcessNS_IC(varargin)
%Process membrane potential responses to natural sound stimuli (speech, etc.)
%usage: ProcessNS_IC(expdate, session, filename)
%ProcessNS_IC(expdate, session, filename, xlimits)
%saves output to outfile

if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=[]; %x limits for axis
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
else
    error('wrong number of arguments'); % If you get any other number of arguments...
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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

%note: we assume only one dur, and multiple epochs
%get number of epochs
j=0;
for i=1:length(event) %
    
    if strcmp(event(i).Type, 'naturalsound')
        
        
        j=j+1;
        alldurs(j)=event(i).Param.duration;
        allisis(j)=event(i).Param.next;
        allfilenames{j}=event(i).Param.file;
    end
end
numepochs=length(unique(allfilenames));
%note: we correct numepochs below to actual number of epochs in data set, for truncated recordings -mw 07.18.2013

epochfilenames=(unique(allfilenames));
dur=unique(alldurs);
isi=unique(allisis);
if length(dur)~=1 error('cannot handle multiple durs');end
if length(isi)~=1 error('cannot handle multiple isis');end
if isempty(xlimits)
    xlimits=[-1000 dur+1000];
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
                M1(epochnum, nreps(epochnum),:)=scaledtrace(region);
                M1stim(epochnum, nreps(epochnum),:)=stim1(region);
                sequences(epochnum,nreps(epochnum),:)=event(i).Param.sequence;
            end
        end
    end
end

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
        mM1(eindex,:)=mean(M1(eindex, 1:nreps(eindex),:), 2);
        mM1stim(eindex,:)=mean(M1stim(eindex, 1:nreps(eindex),:), 2);
    end
end

numepochs=size(M1, 1); %actual numepochs in dataset
sequences(find(sequences==0))=nan; %convert missing seq entries to nans

%assign outputs
out.scaledtrace=scaledtrace;
out.M1=M1;
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

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
godatadir(expdate, session, filenum)
save (outfilename, 'out')
fprintf('\n saved to %s\n', outfilename)

