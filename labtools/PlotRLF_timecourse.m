function PlotRLF_timecourse(varargin)
%plots time course of responses for each tone frequency and level
%(useful for observing time course before/during/after drug application)
%usage:
%   PlotRLF_timecourse(expdate, session, filenum, [thresh], [xlimits], [stepsize])
%     thresh, xlimits, and stepsize are optional
%     thresh is in number of std (default: 3) or use [-1 thresh] to pass a fixed voltage threshold
%     default xlimits are 0:100 (xlimits forms the spike count window)
%     stepsize (in minutes) is the time interval to plot each point in the time course (default: 2 minute)
%
%example call: PlotRLF_timecourse('071509', '001', '001', [], [0 100], 2)
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=3;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[0 100]; %x limits for axis
    stepsize=2; %minutes
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    if isempty(nstd)
        nstd=3;
    end
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[0 100]; %x limits for axis
    stepsize=2; %minutes
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    if isempty(nstd)
        nstd=3;
    end
    xlimits=varargin{5};
    if isempty(nstd)
        nstd=3;
    end
    stepsize=2; %minutes
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    if isempty(nstd)
        nstd=3;
    end
    xlimits=varargin{5};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[0 100]; %x limits for axis
    end
    stepsize=varargin{6};
    if isempty (stepsize)
        stepsize=2;
    end
else
    error('wrong number of arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[D E S]=gogetdata(expdate,session,filenum);
%[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
% try
%     fprintf('\ntrying to load %s...', datafile)
%     godatadir(expdate, session, filenum)
%     D=load(datafile);
%     E=load(eventsfile);
%     %S=load(stimfile);
%     fprintf('done.');
% catch
%     try
%     fprintf('\ntrying to load %s...', datafile)
%     ProcessData_single(expdate, session, filenum)
%     godatadir(expdate, session, filenum)
%     D=load(datafile);
%     E=load(eventsfile);
%     %S=load(stimfile);
%     fprintf('done.');
%     catch      
%     fprintf('failed. Could not find data')
%     return
%     end
% end
monitor=0;

event=E.event;
%stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E S
tracelength=diff(xlimits); %in ms


high_pass_cutoff=300; %Hz
samprate=1e4;
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace=filtfilt(b,a,scaledtrace);
if length(nstd)==2
    if nstd(1)==-1
        thresh=nstd(2);
        fprintf('\nusing absolute spike detection threshold of %.4f mV (%.4f sd)', thresh, thresh/std(filteredtrace));
    end
else
    thresh=nstd*std(filteredtrace);
    fprintf('\nusing spike detection threshold of %.4f mV (%g sd)', thresh, nstd);
end
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );

spikes=find(abs(filteredtrace)>thresh);

dspikes=spikes(1+find(diff(spikes)>refract));
if ~isempty(spikes)
    dspikes=[spikes(1) dspikes'];
end
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
    %pause(.5)
    %close
end
if monitor
    figure
    ylim([min(filteredtrace) max(filteredtrace)]);
    for ds=dspikes(1:20)
        xlim([ds-100 ds+100])
        t=1:length(filteredtrace);
        region=[ds-100:ds+100];
        if min(region)<1
            region=[1:ds+100];
        end
        hold on
        plot(t(region), filteredtrace(region), 'b')
        plot(spikes, thresh*ones(size(spikes)), 'g*')
        plot(dspikes, thresh*ones(size(dspikes)), 'r*')
        line(xlim, thresh*[1 1])
        line(xlim, thresh*[-1 -1])
        pause(.05)
        hold off
    end
    pause(.5)
    close
end
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
            spikecount=length(find(dspikes>start & dspikes<stop)); %num spikes in region
            spikerate=1000*spikecount/tracelength; %in Hz
            M1(findex,aindex,dindex, nreps(findex, aindex, dindex))=spikecount;
            T1(findex,aindex,dindex, nreps(findex, aindex, dindex))=pos/samprate; %position in seconds

        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))
fprintf('\nnum spikes in response window: %d', sum(sum(sum(sum(M1))))                )
fprintf('\ntotal num spikes: %d', length(dspikes))

%compute mean and sd
dindex=1;
traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,:,:,traces_to_keep,:), 4);
    sM1=std(M1(:,:,:,traces_to_keep,:), [],4);
else
    mM1=mean(M1, 4);
    sM1=std(M1, [],4);
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

% plot
c=colormap;
cstep=round(64/(numamps));
for findex=1:numfreqs
    figure
    for aindex=1:numamps
        legstr{aindex}=sprintf('%d dB', amps(aindex));
        clear d t
        for rep=1:nreps(findex, aindex, dindex)
            d(rep)=M1(findex,aindex,dindex, rep);
            t(rep)=T1(findex,aindex,dindex, rep);
        end
        %average into chunks of length stepsize
        numsteps=floor(t(end)/(stepsize*60));
        for stp=1:numsteps
            trange=find(t>60*stepsize*(stp-1) & t<60*stepsize*stp);
            m(stp)=mean(d(trange)); %mean spikecount during step
%             s(stp)=std(d(trange));%sd of spikecount during step
            s(stp)=std(d(trange))/sqrt(length(d(trange)));%sem of spikecount during step
            mt(stp)=mean(t(trange))/60; %center time of step, in minutes
            rt(stp,:)=[min(t(trange)) max(t(trange))];
        end


        hold on
        e=errorbar(mt, m,s);
        set(e, 'marker', 'o', 'color', c(1+(aindex-1)*cstep,:))
    end
    legend(legstr)
    title(sprintf('RLF timecourse for %s-%s-%s', expdate, session, filenum))
    yl=ylim;
    ypos=yl(1)+.1*diff(yl);
    for tm=1:length(timemarks)
        line([timemarks(tm) timemarks(tm)],ylim,  'linestyle', '--', 'color', 'k')
        txt=text(timemarks(tm), ypos, notes(tm));
    end
    xlabel('time (minutes)')
%     ylabel('mean spike count +- s.d.')
    ylabel('mean spike count (+/- sem)')
end

godatadir('expdate', 'session', 'filename')
outfilename=sprintf('outRLFtimecourse%s-%s-%s',expdate,session, filenum);
out.M1=M1;
out.mM1=mM1;
out.sM1=sM1;
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
out.nstd=nstd;
out.xlimits=xlimits;
out.timemarks=timemarks;
out.notes=notes;
out.T1=T1;

save (outfilename, 'out')
fprintf('\n saved to %s', outfilename)

