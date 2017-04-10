function  PlotILPhoneme_OE(expdate, session, filenum, channel, varargin )
%This is a plotting function for natural sound stimuli (e.g. phonemes)
% recorded with an Open Ephys system.
%usage: PlotNS_OE(expdate, session, filenum, channel number, [xlimits], [ylimits], [binwidth])
% (xlimits, ylimits, binwidth are optional)
%
% spiketimes are in ms, stimulus trace is extracted from exper with an
% assumption that sampling rate remains 10e3.
%
% ira 07.15.14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dbstop if error

sorter='MClust'; %can be either 'MClust' or 'simpleclust'
%sorter='simpleclust';
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
    channel=input(promt,'s')
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
    binwidth=5;
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
% gogetdata(expdate, session, filenum)
%load events file
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
godatadir(expdate,session,filenum);
try
    load(OEeventsfile);
catch
    OEgetEvents(expdate, session, filenum);
    load(OEeventsfile)
end
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
godatadir(expdate,session,filenum);
try
    load(OEeventsfile);
catch
    OEgetEvents(expdate, session, filenum);
    load(OEeventsfile)
end

%check for laser in events
for i=1:length(event)
    if isfield(event(i).Param, 'AOPulseOn')
        aopulseon(i)=event(i).Param.AOPulseOn;
    else
        aopulseon(i)=0;
        event(i).Param.AOPulseOn=0;
    end
end
fprintf('\n%d laser pulses in this events file', sum(aopulseon))

%find correct open ephys file
try
    oepathname=getOEdatapath(expdate, session, filenum);
    cd(oepathname);
catch
    cd('C:\Program Files\Open Ephys')
    switch sorter
        case 'MClust'
            [OEdatafile, oepathname] = uigetfile('*.t', 'pick an MClust output file (*.t)');
            if isequal(OEdatafile,0) || isequal(oepathname,0)
                return;
            else
                cd(oepathname)
            end
        case 'simpleclust'
            [OEdatafile, oepathname] = uigetfile('*simpleclust.mat', 'pick a simpleclust.mat file');
    end
end

first_sample_timestamp=OEget_first_sample_timestamp(oepathname); %in s
%load spiketimes from clustered data
switch sorter
    case 'simpleclust'
        OEdatafile=sprintf('ch%s_simpleclust.mat', channel);
        load(OEdatafile);
        Nclusters=features.Nclusters;
        for n=1:Nclusters
            spikeidx(n).spikeidx=find(features.clusters==n);%list of indexes for spikes in each cluster
            nspikes(n)=length(spikeidx(n).spikeidx);
            spiketimes(n).spiketimes=features.ts(spikeidx(n).spikeidx); %list of spiketimes in sec
            spiketimes(n).spiketimes=spiketimes(n).spiketimes-first_sample_timestamp;
        end
    case 'MClust'
        %MClust spiketime files are of the form simpleclustfname_1.t
        %there is one for each cluster
        basefn=sprintf('ch%s_simpleclust_*.t', channel);
        OEdatafile=basefn; %not used except to write to outfile
        d=dir(basefn);
        numclusters=size(d, 1);
        if numclusters==0 error('PlotMClustTC: no cluster files found');end
        for clustnum=1:numclusters
            if clustnum<10
                fn=sprintf('ch%s_simpleclust_0%d.t', channel, clustnum);
            else
                fn=sprintf('ch%s_simpleclust_%d.t', channel, clustnum);
            end
            fprintf('\nreading MClust output file %s cluster %d', fn, clustnum)
            spiketimes(clustnum).spiketimes=read_MClust_output(fn)'/10000;
            %correct for OE start time, so that time starts at 0
            spiketimes(clustnum).spiketimes=spiketimes(clustnum).spiketimes-first_sample_timestamp;
            
            totalnumspikes(clustnum)=length(spiketimes(clustnum).spiketimes);
        end
        fprintf('\nsuccessfully loaded MClust spike data')
        Nclusters=numclusters;
end

try
    samprate=OEget_samplerate(oepathname);
catch
    fprintf('\ncould not load sampling rate. Assuming samprate=30000');
    samprate=30000;
end

outfilename=sprintf('outPhOE%s_%s-%s-%s', channel, expdate, session, filenum);
try godatadir(expdate, session, filenum)
    load(outfilename);
catch
    ProcessILPhoneme_OE(expdate, session, filenum, channel, xlimits, ylimits, binwidth)
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
soundsfilenames=out.soundsfilenames;
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

for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
    fprintf('\ncell %d:', clust)
    fprintf('\ttotal num spikes: %d', length(spiketimes(clust).spiketimes))
end

%find optimal axis limits
if ylimits==-1; ylimits=[0 .5]; end
for clust=1:Nclusters
    for soundind=1:numsounds
        spiketimes=mM1(clust,soundind, :).spiketimes;
        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
        [N,x]=hist(spiketimes,X);
        N=N./nreps(soundind); %normalize to spike rate averaged across trials
        N=1000*N./binwidth;
        ylimits(2)=max(ylimits(2), max(N));
    end
end

fs=12;

%plot spike mean of all reps in a histogram
for clust=1:Nclusters
    figure
    hold on
    p=0;
    subplot1(numsounds, 1)
    %add 10% ylim space for stimulus
    ylimits(1)=ylimits(1)-.1*diff(ylimits);
    for soundind=1:numsounds
        p=p+1;
        subplot1( p)
        spiketimes1=mM1(clust,soundind).spiketimes; %in ms
%         if xlimits(1)<0 %to align spikes with stimulus trace when xlimits(1)~=0 ira 06.04.14
%             start=abs(xlimits(1));
%             spiketimes1=spiketimes1+start;
%         end
%         if xlimits(1)>0
%             start=xlimits(1);
%             spiketimes1=spiketimes1-start;
%         end
%spiketimes1=spiketimes1+out.xlimits(1);
        X=xlimits(1):binwidth:xlimits(2);
        [N, x]=hist(spiketimes1, X);
        N=N./nreps(soundind);
        N=1000*N./binwidth;
        bar(x, N,1);
        
        stimtrace=squeeze(mM1stim(clust, soundind,  :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*.1*diff(ylimits);
        stimtrace=stimtrace+ylimits(1)+.1*diff(ylimits);
        
        
        t=1:length(stimtrace);
        t=1000*t/10e3; %sampling rate hard coded from exper
        t=t+out.xlimits(1);
        
        plot(t, stimtrace, 'm');
        ylim(ylimits)
        xlim(xlimits)
        set(gca, 'fontsize', fs)
        axis off
    end
%    set(gca, 'xticklabel', get(gca, 'xtick')/1000)
%    xlabel('time, s')
    
    subplot1(1)
    if length(unique(nreps))==1
        nrepsstr=sprintf('Mean of %d reps', unique(nreps));
    else
        nrepsstr=sprintf('Mean of %d-%d  reps', min(nreps), max(nreps));
    end
    h=title(sprintf('%s-%s-%s %s Cell # %d', expdate,session, filenum, nrepsstr, clust));
    set(h, 'HorizontalAlignment', 'center')
    
    
    %label epochs
    p=0;
    for soundind=1:numsounds
        p=p+1;
        subplot1(p)
        text(xlimits(1)-.1*diff(xlimits), mean(ylimits), sprintf('epoch%d', soundind))
    end
    subplot1(numsounds)
    axis on
    orient landscape
    hold off
end %clust

%plot all reps with rasters
for clust=1:Nclusters
    figure
    hold on
    p=0;
    subplot1(numsounds, 1)
    %add 10% ylim space for stimulus
    ylimits(1)=ylimits(1)-.1*diff(ylimits);
    for soundind=1:numsounds
        p=p+1;
        subplot1( p)
        X=xlimits(1):binwidth:xlimits(2);
        spiketimes1=mM1(clust,soundind,:).spiketimes; %in ms
        [N, x]=hist(spiketimes1, X);
        N=N./nreps(soundind);
        N=1000*N./binwidth;
        bar(x, N,1);
        
        
        stimtrace=squeeze(M1stim(clust, soundind, 1,  :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*.1*diff(ylimits);
        stimtrace=stimtrace+ylimits(1)+.1*diff(ylimits);
        t=1:length(stimtrace);
        t=1000*t/10e3; %sampling rate hard coded from exper
        t=t+out.xlimits(1);
        plot(t, stimtrace, 'm');
        for rep=1:max(nreps)
            spiketimes1=M1(clust,soundind, rep,:).spiketimes; %in ms
%             if xlimits(1)<0 %to align spikes with stimulus trace when xlimits(1)~=0 ira 06.04.14
%                 start=abs(xlimits(1));
%                 spiketimes1=spiketimes1+start;
%             end
%             if xlimits(1)>0
%                 start=xlimits(1);
%                 spiketimes1=spiketimes1-start;
%             end
            
            
            ylimits1=ylimits(2)/4;
            try
                h= plot(spiketimes1, ylimits1+rep,'k.');
            catch
                fprintf('\nno spikes on sound %d, rep %d', soundind, rep);
            end
        end
        ylim(ylimits)
        xlim(xlimits)
        set(gca, 'fontsize', fs)
        axis off
        
    end
%     set(gca, 'xticklabel', get(gca, 'xtick')/1000)
%     xlabel('time, s')
    
    subplot1(1)
    if length(unique(nreps))==1
        nrepsstr=sprintf('Plot of %d reps', unique(nreps));
    else
        nrepsstr=sprintf('Plot of %d-%d  reps', min(nreps), max(nreps));
    end
    h=title(sprintf('%s-%s-%s %s Cell # %d', expdate,session, filenum, nrepsstr, clust));
    set(h, 'HorizontalAlignment', 'left')
    
    
    %label epochs
    p=0;
    for soundind=1:numsounds
        p=p+1;
        subplot1(p)
        text(xlimits(1)-.1*diff(xlimits), mean(ylimits), sprintf('sound %d', soundind))
    end
    subplot1(numsounds)
    axis on
    orient landscape
    hold off
end %clust



end


