
function  PlotAllNS_OE(expdate, session, filenum, channel, varargin )
%This is a plotting function for NS stimuli recorded with an Open
%Ephys system ALL NATURAL SOUNDS.
%usage: PlotNS_OE(expdate, session, filenum, channel number, [xlimits], [ylimits], [binwidth])
% (xlimits, ylimits, binwidth are optional)
%
% spiketimes are in ms, stimulus trace is extracted from exper with an
% assumption that sampling rate remains 10e3.
%
% ira 07.15.14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rasters=1;
sorter='MClust'; %can be either 'MClust' or 'simpleclust', this is also in ProcessNS_OE
%sorter='simpleclust';
% dbstop if error
if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-1000 dur+1000]; %x limits for axis
    binwidth=5;
    promt=('please enter tetrode number: ');
    channel=input(promt,'s');
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
elseif nargin==4
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-1000 dur+1000]; %x limits for axis
    binwidth=5;
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
elseif nargin==5
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-1000 dur+1000]; %x limits for axis
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    ylimits=-1;
    binwidth=15;
elseif nargin==6
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-1000 dur+1000]; %x limits for axis
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    ylimits=varargin{2};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=5;
elseif nargin==7
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-1000 dur+1000]; %x limits for axis
    end
    ylimits=varargin{2};
    if isempty(ylimits)
        ylimits=-1;
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    binwidth=varargin{3};
    if isempty(binwidth)
        binwidth=5;
    end
else
    error('Wrong number of arguments.');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gogetdata(expdate, session, filenum)
outfilename=sprintf('outNSOE%s_%s-%s-%s.mat', channel, expdate, session, filenum);
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
fprintf('\nload file: ')
godatadir(expdate,session,filenum);
try
    load(OEeventsfile);
catch
    OEgetEvents(expdate, session, filenum);
    load(OEeventsfile)
end

outfilename=sprintf('outNSOE%s_%s-%s-%s', channel, expdate, session, filenum);
try godatadir(expdate, session, filenum)
    load(outfilename);
catch
    ProcessAllNS_OE(expdate, session, filenum, channel, xlimits, ylimits, binwidth)
    godatadir(expdate, session, filenum)
    load(outfilename);
end
%extract variables from outfile
M1=out.M1; %matrix, trial-by-trial
mM1=out.mM1; %matrix of mean across trials
dur=out.dur;
isi=out.isi;
nreps=out.nreps;
numsounds=out.numsounds;
mM1stim=out.mM1stim;
M1stim=out.M1stim;
samprate=out.samprate;
soundfilenames=out.soundfilenames;
numsounds=out.numsounds;
dur=out.dur;
isi=out.isi;
if isempty(xlimits)
    xlimits=out.xlimits;
end
Nclusters=out.Nclusters;
datafile=out.datafile;
eventsfile=out.eventsfile;
stimfile=out.stimfile;
event=out.event; %event data file from open ephys
event1=out.event1; %event datafile from exper
try
    isrecording=out.isrecording;
end
try
    oepathname=out.oepathname;
end
xlimit1=out.xlimits;
if xlimits~=xlimit1
    ProcessAllNS_OE(expdate, session, filenum, channel, xlimits, ylimits, binwidth)
end

%find optimal axis limits
if ylimits==-1; ylimits=[0 .5]; end
for clust=1:Nclusters
    for sindex=1:numsounds
        spiketimes=mM1(clust,sindex, :).spiketimes;
        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
        [N,x]=hist(spiketimes,X);
        N=N./nreps(sindex); %normalize to spike rate averaged across trials
        N=1000*N./binwidth;
        ylimits1(2)=max(ylimits(2), max(N));
    end
    ylimits(clust,:,:)=ylimits1;
end

fs=12;
%plot the mean of all reps
for clust=1:Nclusters
    figure
    hold on
    p=0;
    subplot1(numsounds, 1)
    %add 10% ylim space for stimulus
    ylimits(clust,1)=ylimits(clust,1)-.1*diff(ylimits(clust,:,:));
    for sindex=1:numsounds
        p=p+1;
        subplot1( p)
        spiketimes1=mM1(clust,sindex).spiketimes; %in ms
        X=xlimits(1):binwidth:xlimits(2);
        [N, x]=hist(spiketimes1, X);
        N=N./nreps(sindex);
        N=1000*N./binwidth;
        bar(x, N,1);
        offset=0;
        yl=ylimits(clust,:);
        inc=(yl(2))/max(max(max(nreps)));
        if rasters==1
            for n=1:nreps(sindex)
                spiketimes2=M1(clust,sindex, n).spiketimes;
                offset=offset+inc;
                h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.k');
            end
        end
        
        stimtrace=squeeze(mM1stim(clust, sindex,  :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*.1*diff(ylimits(clust,:,:));
        stimtrace=stimtrace+ylimits(1)+.1*diff(ylimits(clust,:,:));
        
        
        if xlimits(1)<0
            t=xlimits(1)*10:length(stimtrace)-abs(xlimits(1)*10-1);
        else
            t=1:length(stimtrace);
        end
        t=1000*t/10e3; %sampling rate hard coded from exper
        plot(t, stimtrace, 'm');
        ylimits(clust,2)=ylimits(clust,2)+(inc)*(n+10);
        ylim(ylimits(clust,:,:))
        xlim(xlimits)
        set(gca, 'fontsize', fs)
        
    end
    set(gca, 'xticklabel', get(gca, 'xtick')/1000)
    xlabel('time, s')
    
    subplot1(1)
    if length(unique(nreps))==1
        nrepsstr=sprintf('Mean of %d reps', unique(nreps));
    else
        nrepsstr=sprintf('Mean of %d-%d  reps', min(nreps), max(nreps));
    end
        %get name of the file
     a= soundfilenames{1};
     a= a(45:47);
    h=title(sprintf('%s-%s-%s %s Cell # %d, file= %s', expdate,session, filenum, nrepsstr, clust,a));
    set(h, 'HorizontalAlignment', 'center')

    
    %label epochs
    p=0;
    for sindex=1:numsounds
        p=p+1;
        subplot1(p)
        text(xlimits(1)-.1*diff(xlimits), mean(ylimits(clust,:,:)), sprintf('FR (Hz)'))
    end
    subplot1(numsounds)
    axis on
    orient landscape
    hold off
end %clust



outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
save(outfilename,'out');
end

