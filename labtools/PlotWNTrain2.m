function PlotWNTrain2(expdate, session, filenum, varargin)
% usage: out=PlotWNTrain2(expdate, session, filenum, [xlimits])
% plots an averaged tuning curve for WNTrain2 stimuli
%(these are WN trains at various isis but with fixed train duration)
%saves processed data in outfile.

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
    error('PlotWNTrain2: wrong number of arguments');
end

outfilename=sprintf('out%s-%s-%s.mat',expdate,session, filenum);
godatadir(expdate, session, filenum)
if exist(outfilename, 'file')
    load(outfilename)
else
    ProcessWNTrain2(expdate, session, filenum, xlimits)
    load(outfilename)
end



Ms=out.M1stim;
mMs=out.mM1stim;
numisis=out.numisis;
nreps=out.nreps;
mMt=out.mM1;
Mt=out.M1;
samprate=out.samprate;
isis=out.isis;


%get "start" (first onset)
for i=1:length(out.event)
start(i)=out.event(i).Param.start;
end
if length(unique(start))>1 error ('more than one start time???');end
start=unique(start);


%plot stimuli to check for any glitches
offset_incr=2*max(max(max(max(abs(Ms)))));
p=0;
%subplot1(numisis, 1)
for isiindex=[1:numisis]
    p=p+1;
    %   subplot1( p)
    figure
    offset=0;
    for rep=1: nreps(isiindex)
        trace_stim=squeeze(Ms(isiindex,rep, :));
        trace_stim=trace_stim-median(trace_stim(1:100));
        trace_stim=trace_stim+offset;
        offset=offset+offset_incr;
        hold on
        plot(trace_stim, 'r');
    end
end
subplot1(1)
title(sprintf('%s-%s-%s', expdate,session, filenum))
%set(gcf, 'pos', [ 63          72        1588         887])

%find optimal axis limits
ylimits=[0 0];
for isiindex=[1:numisis]
    trace1=squeeze(mMt(isiindex, :));
    if length(trace1)>xlimits(2)*samprate/1000
        trace1=trace1(1:xlimits(2)*samprate/1000);
    end
    trace1=trace1-mean(trace1(1:100));
    if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
    if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
end

%plot the response for each trial
if (1) %set to 0 if you don't want these plots
    c='bmgryc';
    for isiindex=[1:numisis]
        figure
        hold on
        for rep=1: nreps(isiindex)
            trace1=squeeze(Mt(isiindex, rep,:));
            trace1=trace1-median(trace1(1:100));
            trace_stim=squeeze(mMs(isiindex, :));
            trace_stim=trace_stim-median(trace_stim(1:100));
            trace_stim=trace_stim/max(trace_stim); %normalize stim
            trace_stim=trace_stim*.1*diff(ylimits);
            trace_stim=trace_stim+ylimits(1);
            t=1:length(trace1);
            t=t/10;
                t=t+xlimits(1)-start;

            offset=.75*diff(ylimits);
            if rep==1
                plot(t, trace1+offset*(rep-1), 'b', t, trace_stim, 'r');
            else
                plot(t, trace1+offset*(rep-1), 'b');
            end
            xpos=xlimits(1)+.7*diff(xlimits);
            ypos=ylimits(1)+.2*diff(ylimits);
            text(xpos, ypos,sprintf('isi %gms, %d reps', isis(isiindex),nreps(isiindex)))
            orient tall
        end
    end
end



%plot the mean response
figure
p=0;
subplot1(numisis, 1)
for isiindex=[1:numisis]
    p=p+1;
    subplot1( p)
    trace1=squeeze(mMt(isiindex, :));
    trace1=trace1-median(trace1);
    trace_stim=squeeze(mMs(isiindex, :));
    trace_stim=trace_stim-median(trace_stim(1:100));
    trace_stim=trace_stim/max(trace_stim); %normalize stim
    trace_stim=trace_stim*.1*diff(ylimits);
    trace_stim=trace_stim+ylimits(1);
    t=1:length(trace1);
    t=t/10;
    t=t+xlimits(1)-start;
    plot(t, trace1, 'b', t, trace_stim, 'r');
    xpos=xlimits(1)+.7*diff(xlimits);
    ypos=ylimits(1)+.2*diff(ylimits);
    text(xpos, ypos,sprintf('isi %gms, %d reps', isis(isiindex),nreps(isiindex)))
    ylim(ylimits);
end

subplot1(1)
title(sprintf('%s-%s-%s', expdate,session, filenum))
set(gcf, 'pos', [784    87   520   900])
shg
refresh
orient tall


%get nclicks
for i=1:length(out.event)
isi=out.event(i).Param.isi;
isiindex=find(out.isis==isi);
nclicks(isiindex)=out.event(i).Param.nclicks;
end


%plot depolarization MTF
figure
nr=min(nreps);
for isiindex=[1:numisis]
    startpos= .001*samprate*(start-xlimits(1)); % first click onset in samples
    isi=out.isis(isiindex);
    onsets=isi*(0:nclicks(isiindex)-1);
    endpos=(isi+onsets(end))*samprate*.001; %a full isi after final click, in samples
    tracelength=size(mMt, 2);
    if tracelength<endpos
        endpos=tracelength;
    end
    trace=[];
    trace(:,:)=Mt(isiindex,1:nr,:); %reps x samples
    if nr>1
        mtrace=mean(trace,1);
        trace=trace-mean(mtrace(1:startpos)); %subtract baseline
        depol(:,isiindex)=mean(trace(:,startpos:endpos), 2);
    else %only 1 rep
        trace=trace-mean(trace(1:startpos)); %subtract baseline
        depol(:,isiindex)=mean(trace(startpos:endpos));
    end
end
plot(depol', 'k.');
hold on
p=plot(mean(depol,1), 'k.-');
set(p, 'markersize', 30)
ylabel('depolarization, mV')
set(gca, 'xtick', 1:numisis, 'xticklabel', out.isis)
xlim([.5 numisis+.5])
xlabel('ISI, ms')
x=repmat(1:numisis, nr, 1);
X=reshape(x,  prod(size(x)), 1);
X=[X ones(size(X))];
Y=reshape(depol,  prod(size(x)), 1);
[B,BINT,R,RINT,STATS] = regress(Y,X);
fprintf('\nb=%.2f, r2=%.2f, p=%.4f (p=1e%.1f)\n',B(1), STATS(1), STATS(3),log10(STATS(3)))
plot(X(:,1), X*B,'r') 
title(sprintf('%s-%s-%s p=%.4f (p=1e%.1f)', expdate,session, filenum, STATS(3),log10(STATS(3))))

%plot cycle averages (using 2 cycles for readibility, a la gilles)
figure
yl1=[0];
yl2=[0];
subplot1(numisis, 1)
for isiindex=[1:numisis]
    isi=out.isis(isiindex);
    onsets=isi*(0:nclicks(isiindex)-1); %in ms
    %     trace_stim=squeeze(mMs(isiindex, :));
    %     t=1:length(trace_stim);
    %     t=t/10;
    %     plot(t, trace_stim,'r', onsets, zeros(size(onsets)), '.')
    trace=mMt(isiindex,:);
    startpos= .001*samprate*(start-xlimits(1)); % first click onset in samples
    trace=trace-mean(trace(1:startpos)); %subtract baseline
    ctrace=zeros(length(onsets)-1,2*isi*.001*samprate+1);
    for o=1:length(onsets)-1
        startpos= round(.001*samprate*(onsets(o)+start-xlimits(1))); % first click onset in samples
        endpos=startpos+2*isi*.001*samprate; %a full isi after final click, in samples
        difo=endpos-startpos;
        if tracelength<endpos
            endpos=tracelength;
            startpos=endpos-difo;
        end
        if startpos<1
            %ctrace(o,:)=trace(:);
        else
            ctrace(o,:)=trace(startpos:endpos);
        end
    end
    subplot1(isiindex)
    t=1:2*isi*.001*samprate+1;
    t=t/max(t); t=t*2*pi;
    plot(t, mean(ctrace, 1))
    yl2=max(yl2, ylim);
    yl1=min(yl1, ylim);
    xlim([0 2*pi])
end
%for now I am leaving ylimits autoscaled,
% or else the high-isi plots are always flat lines
% for isiindex=[1:numisis]
%     subplot1(isiindex)
%     ylim([min(yl1) max(yl2)])
% end
xlabel('phase')
subplot1(1)
title(sprintf('cycle-averaged Vm  %s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
set(gcf, 'pos', [800    87   520   900])

%plot cycle averages, but as a function of time instead of phase
%top two isis are expanded
figure
subplot1(numisis, 1)
for isiindex=[1:numisis]
    isi=out.isis(isiindex);
    onsets=isi*(0:nclicks(isiindex)-1); %in ms
    trace=mMt(isiindex,:);
    trace=trace-mean(trace(1:startpos)); %subtract baseline
    ctrace=zeros(length(onsets),2*isi*.001*samprate+1);
    for o=1:length(onsets)
        startpos= round(.001*samprate*(onsets(o)+start-xlimits(1))); % first click onset in samples
        endpos=startpos+2*isi*.001*samprate; %a full isi after final click, in samples
        difo=endpos-startpos;
        if tracelength<endpos
            endpos=tracelength;
            startpos=endpos-difo;
        end
        if startpos<1
            %ctrace(o,:)=trace(:);
        else
            ctrace(o,:)=trace(startpos:endpos);
        end
    end
    subplot1(isiindex)
    t=1:2*isi*.001*samprate+1;
    t=t/10; %ms
    if isi<=10 t=10*t;text(200, mean(mean(ctrace)), '10x time');end
    plot(t, mean(ctrace, 1))
    yl2=max(yl2, ylim);
    yl1=min(yl1, ylim);
    xlim([-10 2*max(out.isis)])
end
%for now I am leaving ylimits autoscaled,
% or else the high-isi plots are always flat lines
% for isiindex=[1:numisis]
%     subplot1(isiindex)
%     ylim([min(yl1) max(yl2)])
% end
xlabel('time, ms')
subplot1(1)
title(sprintf('cycle-averaged Vm  %s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
set(gcf, 'pos', [820    87   520   900])



