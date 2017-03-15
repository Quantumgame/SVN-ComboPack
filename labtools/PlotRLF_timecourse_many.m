function PlotRLF_timecourse_many(varargin)
%plots time course of responses for each tone frequency and level
%(useful for observing time course before/during/after drug application)
%use this function to concatenate several consecutive files together and
%plot them as a single timecourse
%you must run PlotRLF_timecourse on each file first (preferably with the
%same fixed voltage threshold). Specify thresh and xlimits (which is used for spike count
%window) at the time you run PlotRLF_timecourse.
%
%usage:
%   PlotRLF_timecourse_many(expdate1, session1, filenum1, expdate2, session2, filenum2, ... , [stepsize])
%   use as many expdate-session-filenum triples as you want.
%   stepsize is optional
%   stepsize (in minutes) is the time interval to plot each point in the time course (default: 2 minutes)
%
%example call: PlotRLF_timecourse_many('080409','001','001','080409','001','002','080409','001','003')
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin<3
    fprintf('\nnot enough inputs\n')
    return
elseif mod(nargin,3)==0 %multiple of 3
    nfiles=nargin/3;
    for filen=1:nfiles
        expdate(filen,:)=varargin{(filen-1)*3+1};
        session(filen,:)=varargin{(filen-1)*3+2};
        filenum(filen,:)=varargin{(filen-1)*3+3};
        stepsize=2; %minutes
    end
elseif mod(nargin,3)==1 %multiple of 3 + stepsize
    nfiles=(nargin-1)/3;
    for filen=1:nfiles
        expdate(filen,:)=varargin{(filen-1)*3+1};
        session(filen,:)=varargin{(filen-1)*3+2};
        filenum(filen,:)=varargin{(filen-1)*3+3};
        stepsize=varargin{end};
        if isempty (stepsize) stepsize=5;end
    end
else
    error('wrong number of arguments');
end


for filen=1:nfiles
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [datafile, eventsfile, stimfile]=getfilenames(expdate(filen,:), session(filen,:), filenum(filen,:));
    outfilename=sprintf('outRLFtimecourse%s-%s-%s.mat',expdate(filen,:),session(filen,:), filenum(filen,:));
    user=whoami;
    godatadir(user,expdate(filen,:), session(filen,:), '001');
    if exist(outfilename)==2;
        load(outfilename);
    else
        PlotRLF_timecourse(expdate(filen,:),session(filen,:), filenum(filen,:), [], [0 100], 5)
        load(outfilename);
    end

    % plot each file in own window as we accumulate
    c=colormap;
    cstep=round(64/(out.numamps));
    dindex=1;
    for findex=1:out.numfreqs
        figure
        for aindex=1:out.numamps
            legstr{aindex}=sprintf('%d dB', out.amps(aindex));
            clear d t trange m sem mt rt
            for rep=1:out.nreps(findex, aindex, dindex)
                d(rep)=out.M1(findex,aindex,dindex, rep); %d=data, t=time
                t(rep)=out.T1(findex,aindex,dindex, rep);
            end
            %average into chunks of length stepsize
            numsteps=floor(t(end)/(stepsize*60));
            for stp=1:numsteps
                trange=find(t>60*stepsize*(stp-1) & t<60*stepsize*stp);
                m(stp)=mean(d(trange)); %mean spikecount during step
                %                 s(stp)=std(d(trange));%sd of spikecount during step
                sem(stp)=std(d(trange))/sqrt(length(d(trange)));%sem of spikecount during step
                mt(stp)=mean(t(trange))/60; %center time of step, in minutes
                rt(stp,:)=[min(t(trange)) max(t(trange))];%range step, in minutes
            end


            hold on
            e=errorbar(mt, m,sem);
            set(e, 'marker', 'o', 'color', c(1+(aindex-1)*cstep,:))
            %mtlength=length(MT);
            Mt(aindex,filen).mt= mt; %center times of steps, in minutes
            M(aindex,filen).m= m;    %mean spikecounts during steps
            %             S(aindex,filen).s= s;    %sd of spikecounts during steps
            S(aindex,filen).s= sem;    %sem of spikecounts during steps
        end
        legend(legstr)
        title(sprintf('RLF timecourse for %s-%s-%s', expdate(filen,:), session(filen,:), filenum(filen,:)))
        yl=ylim;
        ypos=yl(1)+.1*diff(yl);
        for tm=1:length(out.timemarks)
            line([out.timemarks(tm) out.timemarks(tm)],ylim,  'linestyle', '--', 'color', 'k')
            txt=text(out.timemarks(tm), ypos, out.notes(tm));
        end
        Thresh(filen,:)=out.nstd;
        timemarks(filen).t=out.timemarks;
        notes(filen).n=out.notes;
        xlabel('time (minutes)')
        ylabel('mean spike count (+/- sem)')
    end

end %for filen

if size(Thresh,2)==2
    Thresh=Thresh(:,2);
    fixedV=1;
end
if ~isequal(eq(Thresh(1),Thresh), ones(size(Thresh)))
    fprintf('\nthresh=')
    fprintf('%g  ', Thresh)
    error ('these files have different thresholds')
end

%assuming only one frequency for now

Timemarks=[];
for aindex=1:out.numamps
    MTtemp=[];
    Mtemp=[];
    Stemp=[];

    k=0;
    for filen=1:nfiles
        if filen==1
            mt=Mt(aindex,filen).mt;
            xpos(filen)=mean(mt);
        else
            mt=Mt(aindex,filen).mt +max(MTtemp);
            xpos(filen)=mean(Mt(aindex,filen).mt) +max(MTtemp);
        end
        if aindex==1
            tm=timemarks(filen).t;
            if filen>1
                tm=tm+max(MTtemp);
            end
            Timemarks=[Timemarks tm];
            if ~isempty( tm)
                k=k+1;
                Notes{k}=notes(filen).n;
            end
        end
        m=M(aindex,filen).m;
        s=S(aindex,filen).s;
        MTtemp=[MTtemp mt];
        Mtemp=[Mtemp m];
        Stemp=[Stemp s];

    end
    if aindex>1
        if length(MTtemp)>size(MT, 2); %mw101409 hack to get around a dimension mismatch which I think was coming from unmatched nreps
            MTtemp=MTtemp(1:size(MT, 2));
            Mtemp=Mtemp(1:size(MT, 2));
            Stemp=Stemp(1:size(MT, 2));
        end
    end
    MT(aindex,:)=MTtemp;
    MM(aindex,:)=Mtemp;
    SS(aindex,:)=Stemp;
end

% Plot each amp in a seperate figure
% close all
counter=1;
newnotes=[];
if ~exist('Notes','var');
    Notes=[];
    temp=[];
end

% flatten Notes
kn=0;
for in=1:length(Notes)
    for jn=1:length(Notes{in})
        kn=kn+1;temp{kn}=Notes{in}{jn};
    end
end
Notes=temp;

% plot each amp in a separate window
for aindex=1:out.numamps
    figure
    e=errorbar(MT(aindex,:), MM(aindex,:), SS(aindex,:));
    set(e, 'marker', 'o', 'color', c(1+(aindex-1)*cstep,:))
    yl=ylim;
    ypos=yl(1)+.1*diff(yl);
    for tm=1:length(Timemarks)
        line([Timemarks(tm) Timemarks(tm)],ylim,  'linestyle', '--', 'color', 'k')
        txt=text(Timemarks(tm), ypos, Notes{tm});
    end
    xlabel('time (minutes)')
    ylabel('mean spike count (+/- sem)')
    title(sprintf('RLF timecourse for %s-%s-%s (%d files), thresh=%g, %d dB', expdate(1,:), session(1,:), filenum(1,:), nfiles, Thresh(1),out.amps(aindex)))
    for filen=1:nfiles
        yl=ylim;
        text(xpos(filen), yl(1)+.9*diff(yl), (filenum(filen,:)))
    end
end

%plot all together in one window
figure
hold on
for aindex=1:out.numamps
    e=errorbar(MT(aindex,:), MM(aindex,:), SS(aindex,:));
    set(e,'linewidth',2, 'marker', 'o', 'color', c(1+(aindex-1)*cstep,:))
end
yl=ylim;
ypos=yl(1)+.1*diff(yl);

for tm=1:length(Timemarks)
    line([Timemarks(tm) Timemarks(tm)],ylim,  'linestyle', '--', 'color', 'k')
    txt=text(Timemarks(tm), ypos, Notes{tm});
end
xlabel('time (minutes)','fontsize',14)

ylabel('mean spike count (+/- sem)','fontsize',14)

title(sprintf('RLF timecourse for %s-%s-%s (%d files), thresh=%g', expdate(1,:), session(1,:), filenum(1,:), nfiles, Thresh(1)),'fontsize',14)
for filen=1:nfiles
    yl=ylim;
    text(xpos(filen), yl(1)+.9*diff(yl), (filenum(filen,:)),'fontsize',14)
end


