function PlotWNTrain_psth(expdate, session, filenum, varargin)
% usage: out=PlotWNTrain(expdate, session, filenum, [xlimits], [ylimits], [binwidth])
% plots an averaged tuning curve (psth) for WNTrain stimuli
%(these are WN trains at various isis, with fixed number of pulses, various train durations)
%looks for outfile generated by ProcessWNTrain_xxx
%machine independent

xlimits=[];
ylimits=[];
defaultbinwidth=10;

if nargin==0
    fprintf('\nnoinput\n')
    return
elseif nargin==3
    binwidth=defaultbinwidth;
elseif nargin==4
    xlimits=varargin{1};
    binwidth=defaultbinwidth;
elseif nargin==5
    xlimits=varargin{1};
    ylimits=varargin{2};
    binwidth=defaultbinwidth;
elseif nargin==6
    xlimits=varargin{1};
    ylimits=varargin{2};
    binwidth=varargin{3};
else
    error('PlotWNTrain: wrong number of arguments');
end

outfilename=sprintf('out%s-%s-%s-psth',expdate,session, filenum);
fprintf('\ntrying to load %s...', outfilename)
try
    godatadir(expdate, session, filenum)
    load(outfilename)
catch
    fprintf('failed to load outfile')
    ProcessWNTrain_psth(expdate, session, filenum, xlimits);
    load(outfilename);
end

fprintf('done\n');

mMt=out.mMt;
mMs=out.mMs;
numisis=out.numisis;
if isempty(xlimits)
    xlimits=out.xlimits;
end
fprintf('\nusing xlimits [%d %d]', xlimits)

%get ylimits
if isempty(ylimits)
    ylimits=[0 0];
    for isiindex=[1:numisis]
        spiketimes=mMt(isiindex).spiketimes;
        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
        [N, x]=hist(spiketimes, X);
        N=N./out.nreps(isiindex); %normalize to spike rate (averaged across trials)
        N=1000*N./binwidth; %normalize to spike rate in Hz
        ylimits(2)=max(ylimits(2), max(N));
    end
end
stim_mag=.1*ylimits(2);
stim_offset=ylimits(1)-stim_mag;
ylimits(1)=ylimits(1)-stim_mag;

if range(ylimits)==0 %no spikes anyway
ylimits=[0 1];
end
%get start
for i=1:length(out.event)
    start(i)=out.event(i).Param.start;
end
start=unique(start);
if length(start)>1 error('cannot handle multiple starts');end

%plot psths of all P1s lumped together
figure
spiketimes=[];
for isiindex=[1:numisis]
    spiketimes=[spiketimes mMt(isiindex).spiketimes];
end
    trace_stim=mean(mMs,1);
    trace_stim=trace_stim-median(trace_stim(1:100));
    trace_stim=trace_stim/max(trace_stim); %normalize stim

X=xlimits(1):binwidth:xlimits(2); %specify bin centers
[N, x]=hist(spiketimes, X);
N=N./out.nreps(isiindex); %normalize to spike rate (averaged across trials)
N=1000*N./binwidth; %normalize to spike rate in Hz
bar(x, N,1);
%     line([0 0+out.durs(1)], [-.2 -.2], 'color', 'm', 'linewidth', 2)
line(xlimits, [0 0], 'color', 'k')
ylim(ylimits)
xlim(xlimits)
t=1:length(trace_stim);
t=t/10;
t=t-start;
hold on
plot( t, stim_mag*trace_stim+stim_offset, 'r');
title(sprintf('average across all isis'))



%plot the psths
if false
    figure
    p=0;
    subplot1(numisis, 1)
    for isiindex=[1:numisis]
        p=p+1;
        subplot1( p)
        spiketimes=mMt(isiindex).spiketimes;
        trace_stim=squeeze(mMs(isiindex, :));
        trace_stim=trace_stim-median(trace_stim(1:100));
        trace_stim=trace_stim/max(trace_stim); %normalize stim
        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
        [N, x]=hist(spiketimes, X);
        N=N./out.nreps(isiindex); %normalize to spike rate (averaged across trials)
        N=1000*N./binwidth; %normalize to spike rate in Hz
        bar(x, N,1);
        %     line([0 0+out.durs(1)], [-.2 -.2], 'color', 'm', 'linewidth', 2)
        line(xlimits, [0 0], 'color', 'k')
        ylim(ylimits)
        xlim(xlimits)
        t=1:length(trace_stim);
        t=t/10;
        t=t-start;
        hold on
        plot( t, stim_mag*trace_stim+stim_offset, 'r');
        title(sprintf('isi %dms, %d reps', out.isis(isiindex),out.nreps(isiindex)))
    end
    subplot1(1)
    title(sprintf('%s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
    set(gcf, 'pos', [618    72      520   900])
    shg
    refresh
    orient tall
end

%plot the psths with rasters
figure
p=0;
subplot1(numisis, 1)
for isiindex=[1:numisis]
    p=p+1;
    subplot1( p)
    spiketimes=mMt(isiindex).spiketimes;
    trace_stim=squeeze(mMs(isiindex, :));
    trace_stim=trace_stim-median(trace_stim(1:100));
    trace_stim=trace_stim/max(trace_stim); %normalize stim
    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
    [N, x]=hist(spiketimes, X);
    N=N./out.nreps(isiindex); %normalize to spike rate (averaged across trials)
    N=1000*N./binwidth; %normalize to spike rate in Hz
    bar(x, N,1);
    %     line([0 0+out.durs(1)], [-.2 -.2], 'color', 'm', 'linewidth', 2)
    line(xlimits, [0 0], 'color', 'k')
    ylim(ylimits)
    xlim(xlimits)
    t=1:length(trace_stim);
    t=t/10;
    t=t-start;
    hold on
    plot( t, stim_mag*trace_stim+stim_offset, 'r');
    title(sprintf('isi %dms, %d reps', out.isis(isiindex),out.nreps(isiindex)))
    
    inc=(ylimits(2))/max(out.nreps);
    for n=1:out.nreps(isiindex)
        spiketimes2=out.Mt(isiindex, n).spiketimes;
        h=plot(spiketimes2, ylimits(2)+ones(size(spiketimes2))+(n-1)*inc, '.');
        %                 set(h, 'markersize', 5)
        plot(xlimits, ylimits(2)+(1+(n-1)*inc.*[1 1]), 'color', [.85 .85 .85])
    end
    ylim([ylimits(1)  ylimits(2)+(1+(n-1)*inc)])
end


subplot1(1)

title(sprintf('%s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
set(gcf, 'pos', [618    72      520   900])
shg
refresh
orient tall

figure
hold on
if size(out.mP2P1, 1)==1 | size(out.mP2P1, 2)==1 
h=plot(out.mP2P1, '-ko')
plot(1, out.P2P1, 'ko')
else
h=plot(out.mP2P1, '-ko')
plot(1,out.P2P1, 'ko')
end
set(h, 'markerfacecolor', 'k')

xlim([0 out.numisis+1])
set(gca, 'xtick', 1:out.numisis, 'xticklabel', out.isis)
line(xlim, [1 1], 'linestyle', '--', 'color', 'k')

for i=1:numisis
    if isnan(out.facilitation_h(i)) | isnan(out.suppression_h(i))
        fprintf('\nisi %d: P2/P1 is undefined (probably no P1 spikes)', out.isis(i))
    else        
    if out.facilitation_h(i)
        fprintf('\nisi %d: significant facilitation (p=%.4f)', out.isis(i), out.facilitation_p(i))
        h=plot(i,1.2,'r^'); 
        set(h, 'markerfacecolor', 'r')
    elseif out.suppression_h(i)
        fprintf('\nisi %d: significant suppression (p=%.4f)', out.isis(i), out.suppression_p(i))
        h=plot(i,.8,'bv') ;
        set(h, 'markerfacecolor', 'b')
    else
        fprintf('\nisi %d: no difference (p=%.4f, %.4f)', out.isis(i), out.facilitation_p(i), out.suppression_p(i))
    end
end
end
