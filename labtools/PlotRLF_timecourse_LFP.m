function PlotRLF_timecourse_LFP(varargin)
%plots time course of responses for each tone frequency and level
%(useful for observing time course before/during/after drug application)
%usage:
%   PlotRLF_timecourse_LFP(expdate, session, filenum, [xlimits], [ylimits] [stepsize])
%     xlimits, and stepsize are optional
%     default xlimits are 0:300
%     stepsize (in minutes) is the time interval to plot each point in the time course (default: 2 minute)
%
%example call: PlotRLF_timecourse_LFP('071509', '001', '001', [0 100], [], 2)
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[0 300]; %x limits for axis
    ylimits=[];
    stepsize=2; %minutes
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=[];
    stepsize=2; %minutes
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[0 300]; %x limits for axis
    end
    ylimits=varargin{5};
    stepsize=2;
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[0 300]; %x limits for axis
    end
    ylimits=varargin{5};
    stepsize=varargin{6};
    if isempty (stepsize)
        stepsize=2;
    end
else
    error('wrong number of arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
try
    fprintf('\ntrying to load %s...', datafile)
    godatadir(expdate, session, filenum)
    D=load(datafile);
    E=load(eventsfile);
    %S=load(stimfile);
    fprintf('done.');
catch
    try
        fprintf('\ntrying to load %s...', datafile)
        ProcessData_single(expdate, session, filenum)
        godatadir(expdate, session, filenum)
        D=load(datafile);
        E=load(eventsfile);
        %S=load(stimfile);
        fprintf('done.');
    catch
        fprintf('failed. Could not find data')
        return
    end
end

event=E.event;
%stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E S
tracelength=diff(xlimits); %in ms

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'tonetrain')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.toneduration;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'grating')
        j=j+1;
        allfreqs(j)=event(i).Param.angle*1000;
        allamps(j)=event(i).Param.spatialfrequency;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.clickduration; %        alldurs(j)=event(i).Param.duration; gives trial duration not tone duration
    end
end
freqs1=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs1);
numamps=length(amps);
numdurs=length(durs);
M1=[];
nreps=zeros(numfreqs, numamps, numdurs);
samprate=1e4;
%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') |strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos)
                pos=event(i).Position_rising;
            end
        else
            pos=event(i).Position_rising;
        end

        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop<=length(scaledtrace)
                if strcmp(event(i).Type, 'tone')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.duration;
                elseif  strcmp(event(i).Type, 'tonetrain')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.toneduration;
                elseif  strcmp(event(i).Type, 'grating')
                    freq=event(i).Param.angle*1000;
                    dur=event(i).Param.duration;
                elseif strcmp(event(i).Type, 'whitenoise')
                    dur=event(i).Param.duration;
                    freq=-1;
                elseif strcmp(event(i).Type, 'clicktrain')
                    dur=event(i).Param.clickduration;
                    freq=-1;
                end
                amp=event(i).Param.amplitude;
                findex= find(freqs1==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                M1(findex,aindex,dindex, nreps(findex, aindex, dindex),:)=scaledtrace(region);
                T1(findex,aindex,dindex, nreps(findex, aindex, dindex))=pos/samprate; %position in seconds
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))

traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,:,:,traces_to_keep,:), 4);
else
    for aindex=1:numamps
        for findex=1:numfreqs
            for dindex=1:numdurs
                mM1(findex, aindex, dindex,:)=mean(M1(findex, aindex, dindex, 1:nreps(findex, aindex, dindex),:), 4);
%                 mM1stim(findex, aindex, dindex,:)=mean(M1stim(findex, aindex, dindex, 1:nreps(findex, aindex, dindex),:), 4);
            end
        end
    end
end

% try to load exper structure
user=whoami;
expfilename=sprintf('%s-%s-%s-%s.mat', expdate, user, session, filenum);
expstructurename=sprintf('exper_%s', filenum);
if exist(expfilename)==2 %try current directory
    load(expfilename)
    exp=eval(expstructurename);
    timemarks=exp.timemark.param.timemarks.value;
    notes=exp.timemark.param.notes.value;
else %try data directory
    cd ../../..
    try
        cd(sprintf('Data-%s-backup',user))
        cd(sprintf('%s-%s',expdate,user))
        cd(sprintf('%s-%s-%s',expdate,user, session))
    end
    if exist(expfilename)==2
        load(expfilename)
        exp=eval(expstructurename);
        if isfield(exp, 'timemark')
            timemarks=exp.timemark.param.timemarks.value;
            notes=exp.timemark.param.notes.value;
        else
            timemarks=[];
            notes=[];
            fprintf('\nno timemarks in exper structure.')
        end
    else
        timemarks=[];
        notes=[];
        fprintf('\ncould not find exper structure. Cannot plot timemarks.')
    end
end
timemarks=timemarks/60;

%find optimal axis limits
if isempty(ylimits)
    ylimits=[0 0];
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            trace1=squeeze(mM1(findex, aindex, dindex, :));
            trace1=trace1-mean(trace1(1:100));
            if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
            if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot

%get numsteps
tend=max(max(max(T1)));
numsteps=floor(tend/(stepsize*60));

for findex=1:numfreqs
    figure
    subplot1(numamps, numsteps)
    p=0;
    for aindex=numamps:-1:1
        clear d t
        for rep=1:nreps(findex, aindex, dindex)
            d(rep,:)=M1(findex,aindex,dindex, rep,:); % traces
            t(rep)=T1(findex,aindex,dindex, rep);     %times
        end
        %average into chunks of length stepsize
%         numsteps=floor(t(end)/(stepsize*60));
        for stp=1:numsteps
            trange=find(t>60*stepsize*(stp-1) & t<60*stepsize*stp);
            m(stp,:)=mean(d(trange,:)); %mean trace during step
            %             s(stp)=std(d(trange));%sd of spikecount during step
            mt(stp)=mean(t(trange))/60; %center time of step, in minutes
            rt(stp,:)=[min(t(trange)) max(t(trange))];

            p=p+1;
            subplot1(p)
            trace1=m(stp,:);
            trace1=trace1-mean(trace1(1:100));
            %         stimtrace=squeeze(mM1stim(findex, aindex, dindex,  :));
            %         stimtrace=stimtrace-mean(stimtrace(1:100));
            %         stimtrace=stimtrace./max(abs(stimtrace));
            %         stimtrace=stimtrace*.1*diff(ylimits);
            %         stimtrace=stimtrace+ylimits(1);

            tt=1:length(trace1);
            tt=tt/10;
            plot(tt, trace1, 'b');
            ylim(ylimits)
            xlim(xlimits)
            axis off
            
            if stp==1 %label amps
                text(xlimits(1)-.5*diff(xlimits), mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
            text(mean(xlimits), ylimits(1)-.5*diff(ylimits), sprintf('%.1f',mt(stp)))
            end
        end
    end
    subplot1(2)
    title(sprintf('RLF LFP timecourse for %s-%s-%s', expdate, session, filenum))

    for tm=1:length(timemarks)
        stepnum=find(abs(mt-timemarks(tm))==min(abs(mt-timemarks(tm))));
        subplot1([numamps stepnum])
        ypos=ylimits(1)-1*diff(ylimits);
        %       line([timemarks(tm) timemarks(tm)],ylim,  'linestyle', '--', 'color', 'k')
        txt=text(timemarks(tm), ypos, notes(tm));
    end
    subplot1([numamps 1])
    text(xlimits(1),ylimits(1)-1*diff(ylimits), 'time (minutes)')
end


outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
out.M1=M1;
out.mM1=mM1;
out.xlimits=xlimits;
out.numfreqs=numfreqs;
out.numamps=numamps;
out.nreps=nreps;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.freqs=freqs1;
out.amps=amps;
out.durs=durs;
out.xlimits=xlimits;
out.timemarks=timemarks;
out.notes=notes;
out.T1=T1;

save (outfilename, 'out')
fprintf('\n saved to %s', outfilename)

