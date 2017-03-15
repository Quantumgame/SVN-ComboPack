function ProcessWNTrain2(expdate, session, filenum, varargin)
% usage: out=ProcessWNTrain2(expdate, session, filenum, [xlimits])
% processes data for WNTrain2 stimuli
%(these are WN trains at various isis but with fixed train duration)
%saves processed data in outfile.
%
global pref
if isempty(pref) Prefs; end
username=pref.username;

if nargin==0
    fprintf('\nnoinput\n')
    return
elseif nargin==3
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
        xlimits=[-100 dur+100]; %in ms
elseif nargin==4
    xlimits=varargin{1};
    if isempty(xlimits) | length(xlimits)~=2
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-100 dur+100]; %in ms
    end
else
    error('ProcessWNTrain2: wrong number of arguments');
end

 use_soundcard_triggers=1; %this flag is normally set to 1. Set it to 0 if
% you want to use hardware trigger (Position_rising), which is less
% accurate, but a useful backup in case there is a glitch in a soundcard
% trigger. You can check for a glitch with this code snippet: for i=1:length(event);sc(i)=event(i).soundcardtriggerPos;pr(i)=event(i).Position_rising;end;figure;plot(sc-pr)

[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
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
j=0;
for i=1:numevents
    if strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'pulsetrain')
        j=j+1;
        allisis(j)=event(i).Param.isi;
        alldurs(j)=event(i).Param.duration;
        if isfield(event(i).Param, 'frequency')
            allfreqs(j)=event(i).Param.frequency;
        end
        allamps(j)=event(i).Param.amplitude;
    end
end
isis=unique(allisis);
durs=unique(alldurs);
freqs1=unique(allfreqs);
amps=unique(allamps);
numisis=length(isis);
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
Mt=zeros(numisis, 1,diff(xlimits)*1e-3*samprate );%trains
Ms=Mt;%stimulus record
nreps=0*isis;
for i=1:length(event)
    if strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'pulsetrain')
        if isfield(event(i), 'soundcardtriggerPos') & use_soundcard_triggers
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end

        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if pos>lostat
            fprintf('discarding trace')
        elseif isempty(find(region<0)) & stop<length(scaledtrace) %(disallow negative start times and don't exceed end)
            isi=event(i).Param.isi;
            isiindex=find(isi==isis);
            nreps(isiindex)=nreps(isiindex)+1;
            Mt(isiindex,nreps(isiindex),:)=scaledtrace(region);
            Ms(isiindex,nreps(isiindex),:)=stim(region);
        end
    end
end

nreps

for isiindex=[1:numisis]
    mMt(isiindex,:)=mean(Mt(isiindex, 1:nreps(isiindex),:), 2);
    mMs(isiindex,:)=mean(Ms(isiindex, 1:nreps(isiindex),:), 2);
end


%assign outputs
out.scaledtrace=scaledtrace;
out.M1=Mt;
out.M1stim=Ms;
out.mM1stim=mMs;
out.mM1=mMt;
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
out.nreps=nreps;
out.numfreqs=numfreqs;
out.numamps=numamps;
out.numdurs=numdurs;
out.numisis=numisis;
out.event=event;
 out.xlimits=xlimits;
% out.ylimits=ylimits;
out.samprate=samprate;
out.outfilegeneratedby='ProcessWNTrain2';

godatadir(expdate, session, filenum)
fprintf('\nsaved in %s...', outfilename)
save(outfilename, 'out');