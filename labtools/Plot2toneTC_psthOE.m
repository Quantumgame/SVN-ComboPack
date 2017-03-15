function Plot2toneTC_psthOE(expdate, session, filenum,channel, varargin)
% plots spikes from OE recording of WN 2 tone stimuli
% usage: PlotTC_psthOE(expdate, session, filenum, channel number, [xlimits], [ylimits], [binwidth], cell)
% ira 11.02.15
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sorter='MClust'; %can be either 'MClust' or 'simpleclust'
rasters=1;
location='D:\lab\Data4Yashar\OnOn';
  save_outfile=0;
     location='D:\lab\Data4Yashar\OffOn';

global pref
if isempty(pref) Prefs; end
username=pref.username;
if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=5;
    promt=('please enter channel number: ');
    channel=input(promt,'s')
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    cell=[];
elseif nargin==4
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=5;
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    cell=[];
elseif nargin==5
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    ylimits=-1;
    binwidth=5;
    cell=[];
elseif nargin==6
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    ylimits=varargin{2};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=5;
    cell=[];
elseif nargin==7
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
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
    cell=[];
elseif nargin==8
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
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
    cell=varargin{4};
else
    error('Wrong number of arguments.');
end

fs=10; %fontsize

gogetdata(expdate, session, filenum);
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
godatadir(expdate,session,filenum);
try
    load(OEeventsfile);
catch
    OEgetEvents(expdate, session, filenum);
    load(OEeventsfile)
end

%find OE data directory
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
        basefn=sprintf(sprintf('ch%s_simpleclust_*.t', channel));
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
if isempty(event); fprintf('\nno tones\n'); return; end


fprintf('\ncomputing tuning curve...');
%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'fmtone')
        j=j+1;
        allfreqs(j)=event(i).Param.carrier_frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'amtone')
        j=j+1;
        allfreqs(j)=event(i).Param.carrier_frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allSOAs(j)=event(i).Param.SOA;
    end
end
%SOAs=500; fprintf('SOA was not saved, using 100');
freqs=unique(allfreqs);


SOAs=unique(allSOAs);
% twotonefreqs=unique(all2tonefreqs);
% probefreqs=unique(allprobefreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

M1=[];
nreps1=zeros(numfreqs, numamps, numdurs);
nreps2=zeros(numfreqs, numamps, numdurs);
%nreps=zeros(length(twotonefreqs), numamps, numdurs);

inRange=zeros(1, Nclusters);
%extract the traces into a big matrix M1 (tone alone)
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')  || strcmp(event(i).Type, 'whitenoise') || strcmp(event(i).Type, '2tone');
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos/samprate;
        else
            pos=event(i).Position;
        end
        
        start=(pos+xlimits(1)*1e-3); %in sec
        stop=(pos+xlimits(2)*1e-3); %in sec
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if strcmp(event(i).Type, 'whitenoise') || strcmp(event(i).Type, 'tone')
                freq=event(i).Param.frequency;
                dur=event(i).Param.duration;
            amp=event(i).Param.amplitude;
            findex= find(freqs==freq);
            aindex= find(amps==amp);
            dindex= find(durs==dur);
            nreps1(findex, aindex, dindex)=nreps1(findex, aindex, dindex)+1;
            for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                st=spiketimes(clust).spiketimes;
                spiketimes1=st(st>start & st<stop); % spiketimes in region
                inRange(clust)=inRange(clust)+ length(spiketimes1);
                spiketimes1=(spiketimes1-pos)*1000;%covert to ms after tone onset
                M1(clust, findex,aindex,dindex, nreps1(findex, aindex, dindex)).spiketimes=spiketimes1;
            end
            
            
            elseif strcmp(event(i).Type, '2tone')
                freq=event(i).Param.frequency;
                dur=event(i).Param.duration;
            amp=event(i).Param.amplitude;
            findex= find(freqs==freq);
            aindex= find(amps==amp);
            dindex= find(durs==dur);
            nreps2(findex, aindex, dindex)=nreps2(findex, aindex, dindex)+1;
            for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                st=spiketimes(clust).spiketimes;
                spiketimes2=st(st>start & st<stop); % spiketimes in region
                inRange(clust)=inRange(clust)+ length(spiketimes2);
                spiketimes2=(spiketimes2-pos)*1000;%covert to ms after tone onset
                M2(clust,findex,aindex,dindex, nreps2(findex, aindex, dindex)).spiketimes=spiketimes2;
            end
            end
            
        end
    end
end


fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps2))), max(max(max(nreps2))))
for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
    fprintf('\ncell %d:', clust)
    fprintf('\ntotal num spikes: %d', length(spiketimes(clust).spiketimes))
    fprintf('\nIn range: %d', inRange(clust))
end

mM1=[];
%accumulate across trials
for dindex=[1:numdurs]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            for clust=1:Nclusters
                spiketimes1=[];
                spiketimes2=[];
                for rep=1:nreps1(findex, aindex, dindex)
                    spiketimes1=[spiketimes1 M1(clust, findex, aindex, dindex, rep).spiketimes];
                end
                for rep=1:nreps2(findex, aindex, dindex)
                    spiketimes2=[spiketimes2 M2(clust, findex, aindex, dindex, rep).spiketimes];
                end
                mM1(clust, findex, aindex, dindex).spiketimes=spiketimes1;
                mM2(clust, findex, aindex, dindex).spiketimes=spiketimes2;
            end
        end
    end
end

% %accumulate across trials(M2)
% for dindex=[1:numdurs]
%     for aindex=[numamps:-1:1]
%         for findex=1:length(twotonefreqs)
%             spiketimes1=[];
%             for rep=1:nreps(findex, aindex, dindex)
%                 spiketimes1=[spiketimes1 M2(findex, aindex, dindex, rep).spiketimes];
%             end
%             mM2(findex, aindex, dindex).spiketimes=spiketimes1;
%         end
%     end
% end

numbins=200;

dindex=1;

%find axis limits
if ylimits==-1
    for clust=1:Nclusters
        ymax=0;
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                st=mM1(clust, findex, aindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(st, X);
                N=N./nreps1(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                ymax= max(ymax,max(N));
            end
        end
        ylimits1(clust,:)=[-.3 ymax];
    end
else
    for clust=1:Nclusters
        ylimits1(clust, :)=[ylimits];
    end
end

%%%%%
%plot (M1)
dbstop if error
plot_one=1; % if the cell is specified, it will plot only one cell and plot_one will become 2, the rest wont be plotted. ira 11.02.15
for clust=1:Nclusters
    if ~isempty(cell) && plot_one==1
        clust=str2num(cell);
    end
    if plot_one==1;
        if ~isempty(cell)
            plot_one=plot_one+1;
        end
        for dindex=[1:numdurs]
            figure;
            p=0;
            subplot1( numamps,numfreqs)
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                    p=p+1;
                    subplot1( p)
                    spiketimes1=mM1(clust,findex, aindex, dindex).spiketimes;
                    total_sp=length(spiketimes1);
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    [N, x]=hist(spiketimes1, X);
                    N=N./nreps1(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    offset=0;
                    yl=ylimits1(clust,:);
                    inc=(yl(2))/max(max(max(nreps1)));
                    if rasters==1
                        for n=1:nreps1(findex, aindex, dindex)
                            spiketimes1=M1(clust, findex, aindex, dindex, n).spiketimes;
                            offset=offset+inc;
                            h=plot(spiketimes1, yl(2)+ones(size(spiketimes1))+offset, '.k');
                            
                        end
                    end
                    bar(x, N,1);
                    line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
                   
                    line(xlimits, [0 0], 'color', 'k')
                    ylimits2(2)=ylimits1(clust,2)*3;
                    ylimits2(1)=-2;
                    ylim(ylimits2)
                    
                    
                    xlim(xlimits)
                    set(gca, 'fontsize', fs)
                    
                end
            end
            
            %label amps and freqs
            p=0;
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                    p=p+1;
                    subplot1(p)
                    if findex==1
                        text(xlimits(1)-100, mean(ylimits), int2str(amps(aindex)))
                    else
                        set(gca, 'xtickmode', 'auto')
                        grid on
                    end
                    if aindex==1
                        vpos=ylimits2(1)-diff(ylimits2)/10;
                        %            end
                        text(0, vpos, sprintf('%.1f', freqs(findex)/1000))
                    end
                    ylabel('FR (Hz)');
                    xlabel('time (ms)');
                end
            end
            subplot1(ceil(numfreqs/3))
            title(sprintf('%s-%s-%s, dur=%d, %d total spikes, tetrode %s, cell %d',expdate,session,filenum, durs(dindex),total_sp, channel, clust))
        end
    end %for dindex
end %for NClusters

%plot (M2)
dbstop if error
plot_one=1; % if the cell is specified, it will plot only one cell and plot_one will become 2, the rest wont be plotted. ira 11.02.15
for clust=1:Nclusters
    if ~isempty(cell) && plot_one==1
        clust=str2num(cell);
    end
    if plot_one==1;
        if ~isempty(cell)
            plot_one=plot_one+1;
        end
        for dindex=[1:numdurs]
            figure;
            p=0;
            subplot1( numamps,numfreqs)
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                    p=p+1;
                    subplot1( p)
                    spiketimes2=mM2(clust,findex, aindex, dindex).spiketimes;
                    total_sp=spiketimes2;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    [N, x]=hist(spiketimes2, X);
                    N=N./nreps2(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    offset=0;
                    yl=ylimits1(clust,:);
                    inc=(yl(2))/max(max(max(nreps2)));
                    if rasters==1
                        for n=1:nreps2(findex, aindex, dindex)
                            spiketimes2=M2(clust, findex, aindex, dindex, n).spiketimes;
                            offset=offset+inc;
                            h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.k');
                            
                        end
                    end
                    bar(x, N,1);
                    line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
                    line([SOAs SOAs+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    ylimits2(2)=ylimits1(clust,2)*3;
                    ylimits2(1)=-2;
                    ylim(ylimits2)
                    
                    
                    xlim(xlimits)
                    set(gca, 'fontsize', fs)
                    
                end
            end
            
            %label amps and freqs
            p=0;
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                    p=p+1;
                    subplot1(p)
                    if findex==1
                        text(xlimits(1)-100, mean(ylimits), int2str(amps(aindex)))
                    else
                        set(gca, 'xtickmode', 'auto')
                        grid on
                    end
                    if aindex==1
                        vpos=ylimits2(1)-diff(ylimits2)/10;
                        %            end
                        text(0, vpos, sprintf('%.1f', freqs(findex)/1000))
                    end
                    ylabel('FR (Hz)');
                    xlabel('time (ms)');
                end
            end
            subplot1(ceil(numfreqs/3))
            title(sprintf('%s-%s-%s, dur=%d, %d total spikes, tetrode %s, cell %d',expdate,session,filenum, durs(dindex),length(spiketimes2), channel, clust))
        end
    end %for dindex
end %for NClusters
if save_outfile==1
        
    out.expdate=expdate;
    out.session=session;
    out.filenum=filenum;
    out.username=whoami;
    out.M1=squeeze(M1(clust,:,:,:,:));
    out.mM1=squeeze(mM1(clust,:));
    out.M2=squeeze(M2(clust,:,:,:,:));
    out.mM2=squeeze(mM2(clust,:));
    out.datafile=datafile;
    out.eventsfile=eventsfile;
    out.stimfile=stimfile;
    out.freqs=freqs;
    out.amps=amps;
    out.durs=durs;
    out.SOA=SOAs;
    out.nreps1=nreps1;
    out.nreps2=nreps2;
    out.numfreqs=numfreqs;
    out.numamps=numamps;
    out.numdurs=numdurs;
    out.event=event;
    out.xlimits=xlimits;
    out.ylimits=ylimits;
    out.samprate=samprate;
    out.channel=channel;
    out.Nclusters=Nclusters;
    out.cell=cell;
    out.quality=3;
    try
        out.isrecording=isrecording;
    end
    try
        out.oepathname=oepathname;
    end
    cd(location);
    outfilename=sprintf('outTCOE%s_%s-%s-%s_%s',channel, expdate, session, filenum, cell);
    save(outfilename, 'out');
end


fprintf('\n\n')

