function PlotILWNTrain2_psthOE(expdate, session, filenum, channel, varargin)
% usage: out=PlotILWNTrain2_psthOE(expdate, session, filenum, tetrode (channel), [xlimits], [ylimits], [binwidth], cell)
% plots an averaged tuning curve (psth) for WNTrain2 stimuli for data
% collected with OpenEphys
%(these are WN trains at various isis but with fixed train duration)
% ira 01.20.15
%___________________________________________________________________________
dbstop if error
sorter='MClust'; %can be either 'MClust' or 'simpleclust'
% sorter='simpleclust';
save_outfile=1;

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
    error('PlotILWNTrain2_psthOE: wrong number of arguments');
end
save_outfile=1;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%Get PPA lazer params

ProcessData_single(expdate,session,filenum);
[on, PPAstart, width, numpulses, PPAisi]=getPPALaserParams(expdate,session,filenum);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

lostat=-1; % Discard data after this position (in samples), -1 to skip
fs=10; %fontsize

%load events file
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
try
    fprintf('\nLooking on this machine for OE events file:\n   %s ...',OEeventsfile);
    godatadir(expdate,session,filenum);
catch
    fprintf('... not found. \nWill now call ProcessData_single.');
    ProcessData_single(expdate, session, filenum)
    godatadir(expdate,session,filenum);
end
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outfilename=sprintf('out_ILWNTrain%s-%s-%s-psth',expdate,session, filenum);
fprintf('\ntrying to load %s...', outfilename)
try
    godatadir(expdate, session, filenum)
    load(outfilename)
catch
    fprintf('\nCould not find an outfile, processing data');
    %     fprintf('failed to load outfile')
    %     ProcessILWNTrain2_psthOE(expdate, session, filenum, xlimits);
    %     load(outfilename);
end

%% Find OE data directory
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


if isempty(event); fprintf('\nno stimuli\n'); return; end


fprintf('\ncomputing tuning curve...');
%

if lostat==-1
    lostat=inf;
end
fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));

%get freqs/amps
j=0;
allfreqs=0;
for i=1:length(event)
    allisis(i)=event(i).Param.isi;
    alldurs(i)=event(i).Param.duration;
    if isfield(event(i).Param, 'frequency')
        allfreqs(i)=event(i).Param.frequency;
    else
        allfreqs(i)=1;
    end
    if isfield(event(i).Param, 'ntones')
        allnclicks(i)=event(i).Param.ntones;
    elseif isfield(event(i).Param, 'nclicks')
        allnclicks(i)=event(i).Param.nclicks;
    end
    allamps(i)=event(i).Param.amplitude;
    allnexts(i)=event(i).Param.next;
    allclickdurs(i)=event(i).Param.clickduration; %should be only one duration;
end
clickdurs=unique(allclickdurs);
isis=unique(allisis);
nclicks=unique(allnclicks);
nclicks=sort(nclicks, 'descend');
durs=unique(alldurs);
freqs1=unique(allfreqs);
amps=unique(allamps);
numisis=length(isis);
numnclicks=length(nclicks);
numamps=length(amps);
numdurs=length(durs);
numfreqs=length(freqs1);
numclickdurs=length(clickdurs);


% Mt: matrix with each complete train
% Ms: stimulus matrix in same format as Mt

%first concatenate the sequence of trains into a matrix Mt
%preallocate Mt and Ms
% Mt=zeros(numisis, 1,round(tracelength*1e-3*samprate+1) );%trains
% Ms=Mt;%stimulus record

nrepsON=zeros(numfreqs, numamps, numclickdurs, numisis);
nrepsOFF=zeros(numfreqs, numamps, numclickdurs, numisis);
inRange=zeros(1, Nclusters)
nreps=0*isis;
for i=1:length(event)
    if strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'pulsetrain')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos/samprate;
            if isempty(pos) & ~isempty(event(i).Position)
                pos=event(i).Position;
                fprintf('\nWARNING! Missing a soundcard trigger. Using hardware trigger instead.')
                
            end
        else
            pos=event(i).Position; %in sec
            fprintf('noSCT %d ',event(i).Param.AOPulseOn )
        end
        
        start=pos+event(i).Param.start*1e-3+xlimits(1)*1e-3; %in sec
        stop=pos+event(i).Param.start*1e-3+xlimits(2)*1e-3; %in sec
        if strcmp(event(i).Type, 'clicktrain')
            
            isi=event(i).Param.isi;
            nclick=event(i).Param.nclicks;
            AOPulseOn=event(i).Param.AOPulseOn;
            amp=event(i).Param.amplitude;
            clickdur=event(i).Param.clickduration;
            try
                freq= event(i).Param.frequency;
            catch
                freq=1;
                %fprintf('\n found only one type of sound, WN');
            end
            
            iindex= find(isis==isi);
            aindex= find(amps==amp);
            dindex= find(clickdurs== clickdur);
            findex= find(freqs1==freq);
            
            region=start:stop;
            for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                nreps(iindex)=nreps(iindex)+1;
                st=spiketimes(clust).spiketimes;
                spiketimes1=st(st>start & st<stop); % spiketimes in region
                spikecount=length(spiketimes1); % No. of spikes fired in response to this rep of this stim.
                inRange(clust)=inRange(clust)+ spikecount; %accumulate total spikecount in region
                spiketimes1=(spiketimes1-pos)*1000;%covert to ms after tone onset
                spont_spikecount=length(find(st<start & st>(start-(stop-start))));
                Mt(iindex,nreps(iindex)).spiketimes=spiketimes;
                %               Ms(iindex,nreps(iindex),:)=stim(region);
                if AOPulseOn
                    if clust==1
                        nrepsON(findex, aindex, dindex, iindex)=nrepsON(findex, aindex, dindex, iindex)+1;
                    end
                    M1ONp(clust, findex, aindex, dindex, iindex, nrepsON(findex, aindex, dindex, iindex)).spiketimes=spiketimes1;
                    M1ONspikecounts(clust, findex, aindex, dindex, iindex, nrepsON(findex, aindex, dindex, iindex))=spikecount;
                    M1spontON(clust, findex, aindex, dindex, iindex, nrepsON(findex, aindex, dindex, iindex))=spont_spikecount;
                else
                    if clust==1
                        nrepsOFF(findex, aindex, dindex, iindex)=nrepsOFF(findex, aindex, dindex, iindex)+1;
                    end
                    M1OFFp(clust, findex, aindex, dindex, iindex, nrepsOFF(findex, aindex, dindex, iindex)).spiketimes=spiketimes1;
                    M1OFFspikecounts(clust, findex, aindex, dindex, iindex, nrepsOFF(findex, aindex, dindex, iindex))=spikecount;
                    M1spontOFF(clust, findex, aindex, dindex, iindex, nrepsOFF(findex, aindex, dindex, iindex))=spont_spikecount;
                end
            end
        end
    end
end

%
%     fprintf('\nmin num ON reps: %d\nmax num ON reps: %d', min(min(min(min(nrepsON)))), max(max(max(max(nrepsON)))))
%     fprintf('\nmin num OFF reps: %d\nmax num OFF reps: %d', min(min(min(min(nrepsOFF)))), max(max(max(max(nrepsOFF)))))
for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
    fprintf('\ncell %d:', clust)
    fprintf('\ntotal num spikes: %d', length(spiketimes(clust).spiketimes))
    fprintf('\nIn range: %d', inRange(clust))
end


% Accumulate spiketimes across trials, for psth...
for dindex=1:length(durs); % Hardcoded.
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            for iindex=1:numisis
                for clust=1:Nclusters
                    
                    % on
                    spiketimesON=[];
                    spikecountsON=[];
                    for rep=1:nrepsON(findex, aindex, dindex, iindex)
                        spiketimesON=[spiketimesON M1ONp(clust, findex, aindex, dindex, iindex, rep).spiketimes];
                        % Accumulate spike times for all presentations of each
                        % laser/f/a combo.
                    end
                    
                    % All spiketimes for a given f/a/d combo, for psth:
                    mM1ONp(clust, findex, aindex, dindex, iindex).spiketimes=spiketimesON;
                    
                    % off
                    spiketimesOFF=[];
                    for rep=1:nrepsOFF(findex, aindex, dindex)
                        spiketimesOFF=[spiketimesOFF M1OFFp(clust, findex, aindex, dindex, iindex, rep).spiketimes];
                    end
                    mM1OFFp(clust, findex, aindex, dindex, iindex).spiketimes=spiketimesOFF;
                end
            end
        end
    end
end

%find axis limits

if ylimits==-1
    for clust=1:Nclusters
        ymax=0;
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                for iindex=1:numisis
                    st=mM1ONp(clust, findex, aindex, dindex, iindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    [N, x]=hist(st, X);
                    N=N./nrepsON(findex, aindex, dindex, iindex); %normalize to spike rate (averaged across trials)
                    %                 N=1000*N./binwidth; %normalize to spike rate in Hz
                    ymax1= max(ymax,max(N));
                    
                    st=mM1OFFp(clust, findex, aindex, dindex, iindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    [N, x]=hist(st, X);
                    N=N./nrepsOFF(findex, aindex, dindex, iindex); %normalize to spike rate (averaged across trials)
                    %                 N=1000*N./binwidth; %normalize to spike rate in Hz
                    ymax2= max(ymax,max(N));
                end
            end
        end
        ylimits1(clust,:)=[-.3 max(ymax1, ymax2)];
    end
else
    for clust=1:Nclusters
        ylimits1(clust, :)=[ylimits];
    end
end


%%%%%%%%%%%%% DONE PROCESSING %%%%%%%%%% PLOTTING NOW %%%%%%%%%%%%%%%%%%%

%plot the ON/OFF
if ~isempty(cell)
    clust=cell;
    figure;
    p=0;
    subplot1(numisis, 1)
    for iindex=[1:numisis]
        for dindex=1:numdurs
            for findex=1:numfreqs
                for aindex=numamps
                    p=p+1;
                    subplot1( p)
                    hold on
                    
                    spiketimesON=mM1ONp(clust, findex, aindex, dindex, iindex).spiketimes;
                    spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex, iindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    [NON, xON]=hist(spiketimesON, X);
                    [NOFF, xOFF]=hist(spiketimesOFF, X);
                    
                    NON=NON./nrepsON(findex, aindex, dindex,iindex); %
                    %NON=1000*NON./binwidth; %normalize to spike rate in Hz
                    NOFF=NOFF./nrepsOFF(findex, aindex, dindex,iindex);
                    %NOFF=1000*NOFF./binwidth;
                    bON=bar(xON, NON,1);
                    hold on
                    bOFF=bar(xOFF,NOFF,1);
                    set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                    set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                    
                    line([PPAstart width+PPAstart], [-.1 -.1], 'color', 'c', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits1(clust,:))
                    xlim(xlimits)
                    
                    hold on
                    
                    stim=[1:clickdurs];
                    line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                    for i=1:nclicks(iindex)-1
                        from_this_point=max(max(stim)+isis(iindex)-clickdurs);
                        add_this=max(max(stim)+isis(iindex));
                        stim=[stim from_this_point:add_this];
                        line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                    end
                    title(sprintf('isi %dms', isis(iindex)));
                end
            end
        end
        all_stims(iindex).stim=stim;
    end
    
    subplot1(1)
    title(sprintf('%s-%s-%s laser ON and OFF, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
    set(gcf, 'pos', [618    72      520   900])
    shg
    refresh
    orient tall
else
    for clust=1:Nclusters
        figure;
        p=0;
        subplot1(numisis, 1)
        for iindex=[1:numisis]
            for dindex=1:numdurs
                for findex=1:numfreqs
                    for aindex=numamps
                        p=p+1;
                        subplot1( p)
                        hold on
                        
                        spiketimesON=mM1ONp(clust, findex, aindex, dindex, iindex).spiketimes;
                        spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex, iindex).spiketimes;
                        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                        [NON, xON]=hist(spiketimesON, X);
                        [NOFF, xOFF]=hist(spiketimesOFF, X);
                        
                        NON=NON./nrepsON(findex, aindex, dindex,iindex); %
                        %NON=1000*NON./binwidth; %normalize to spike rate in Hz
                        NOFF=NOFF./nrepsOFF(findex, aindex, dindex,iindex);
                        %NOFF=1000*NOFF./binwidth;
                        bON=bar(xON, NON,1);
                        hold on
                        bOFF=bar(xOFF,NOFF,1);
                        set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                        set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                        
                        %line([PPAstart width+PPAstart], [-.1 -.1], 'color', 'c', 'linewidth', 2)
                        line(xlimits, [0 0], 'color', 'k')
                        ylim(ylimits1(clust,:))
                        xlim(xlimits)
                        
                        hold on
                        
                        stim=[1:clickdurs];
                        line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                        for i=1:nclicks(iindex)-1
                            from_this_point=max(max(stim)+isis(iindex)-clickdurs);
                            add_this=max(max(stim)+isis(iindex));
                            stim=[stim from_this_point:add_this];
                            line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                        end
                        title(sprintf('isi %dms', isis(iindex)));
                    end
                end
            end
            all_stims(iindex).stim=stim;
        end
        
        subplot1(1)
        title(sprintf('%s-%s-%s laser ON and OFF, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
        set(gcf, 'pos', [618    72      520   900])
        shg
        refresh
        orient tall
    end
end
%plot the OFF
if ~isempty(cell)
    clust=cell;
    figure;
    p=0;
    subplot1(numisis, 1)
    for iindex=[1:numisis]
        for dindex=1:numdurs
            for findex=1:numfreqs
                for aindex=numamps
                    p=p+1;
                    subplot1( p)
                    hold on
                    spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex, iindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    [NOFF, xOFF]=hist(spiketimesOFF, X);
                    NOFF=NOFF./nrepsOFF(findex, aindex, dindex,iindex);
                    bOFF=bar(xOFF,NOFF,1);
                    set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits1(clust,:))
                    xlim(xlimits)
                    stim=[1:clickdurs];
                    line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                    for i=1:nclicks(iindex)-1
                        from_this_point=max(max(stim)+isis(iindex)-clickdurs);
                        add_this=max(max(stim)+isis(iindex));
                        stim=[stim from_this_point:add_this];
                        line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                    end
                    title(sprintf('isi %dms', isis(iindex)));
                end
            end
        end
        all_stims(iindex).stim=stim;
    end
    
    subplot1(1)
    title(sprintf('%s-%s-%s laser OFF, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
    set(gcf, 'pos', [618    72      520   900])
    shg
    refresh
    orient tall
else
    
    for clust=1:Nclusters
        figure;
        p=0;
        subplot1(numisis, 1)
        for iindex=[1:numisis]
            for dindex=1:numdurs
                for findex=1:numfreqs
                    for aindex=numamps
                        p=p+1;
                        subplot1( p)
                        hold on
                        spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex, iindex).spiketimes;
                        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                        [NOFF, xOFF]=hist(spiketimesOFF, X);
                        NOFF=NOFF./nrepsOFF(findex, aindex, dindex,iindex);
                        bOFF=bar(xOFF,NOFF,1);
                        set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                        line(xlimits, [0 0], 'color', 'k')
                        ylim(ylimits1(clust,:))
                        xlim(xlimits)
                        stim=[1:clickdurs];
                        line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                        for i=1:nclicks(iindex)-1
                            from_this_point=max(max(stim)+isis(iindex)-clickdurs);
                            add_this=max(max(stim)+isis(iindex));
                            stim=[stim from_this_point:add_this];
                            line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                        end
                        title(sprintf('isi %dms', isis(iindex)));
                    end
                end
            end
            all_stims(iindex).stim=stim;
        end
        
        subplot1(1)
        title(sprintf('%s-%s-%s laser OFF, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
        set(gcf, 'pos', [618    72      520   900])
        shg
        refresh
        orient tall
    end
    
end
%plot the ON
if ~isempty(cell)
    clust=cell;
    figure;
    p=0;
    subplot1(numisis, 1)
    for iindex=[1:numisis]
        for dindex=1:numdurs
            for findex=1:numfreqs
                for aindex=numamps
                    p=p+1;
                    subplot1( p)
                    spiketimesON=mM1ONp(clust, findex, aindex, dindex, iindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    [NON, xON]=hist(spiketimesON, X);
                    NON=NON./nrepsON(findex, aindex, dindex,iindex);
                    bON=bar(xON, NON,1);
                    set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                    line([PPAstart width+PPAstart], [-.1 -.1], 'color', 'c', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits1(clust,:))
                    xlim(xlimits)
                    
                    hold on
                    
                    stim=[1:clickdurs];
                    line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                    for i=1:nclicks(iindex)-1
                        from_this_point=max(max(stim)+isis(iindex)-clickdurs);
                        add_this=max(max(stim)+isis(iindex));
                        stim=[stim from_this_point:add_this];
                        line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                    end
                    title(sprintf('isi %dms', isis(iindex)));
                end
            end
        end
        all_stims(iindex).stim=stim;
    end
    
    subplot1(1)
    title(sprintf('%s-%s-%s laser ON, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
    set(gcf, 'pos', [618    72      520   900])
    shg
    refresh
    orient tall
else
    for clust=1:Nclusters
        figure;
        p=0;
        subplot1(numisis, 1)
        for iindex=[1:numisis]
            for dindex=1:numdurs
                for findex=1:numfreqs
                    for aindex=numamps
                        p=p+1;
                        subplot1( p)
                        spiketimesON=mM1ONp(clust, findex, aindex, dindex, iindex).spiketimes;
                        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                        [NON, xON]=hist(spiketimesON, X);
                        NON=NON./nrepsON(findex, aindex, dindex,iindex);
                        bON=bar(xON, NON,1);
                        set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                        %line([PPAstart width+PPAstart], [-.1 -.1], 'color', 'c', 'linewidth', 2)
                        line(xlimits, [0 0], 'color', 'k')
                        ylim(ylimits1(clust,:))
                        xlim(xlimits)
                        
                        hold on
                        
                        stim=[1:clickdurs];
                        line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                        for i=1:nclicks(iindex)-1
                            from_this_point=max(max(stim)+isis(iindex)-clickdurs);
                            add_this=max(max(stim)+isis(iindex));
                            stim=[stim from_this_point:add_this];
                            line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                        end
                        title(sprintf('isi %dms', isis(iindex)));
                    end
                end
            end
            all_stims(iindex).stim=stim;
        end
        
        subplot1(1)
        title(sprintf('%s-%s-%s laser ON, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
        set(gcf, 'pos', [618    72      520   900])
        shg
        refresh
        orient tall
    end
end
godatadir(expdate,session,filenum);

%assign outputs

out.mM1ONp=mM1ONp;
out.mM1OFFp=mM1OFFp;
out.M1ONp=M1ONp;
out.M1OFFp=M1OFFp;
out.stim=all_stims;
out.nrepsON=nrepsON;
out.nrepsOFF=nrepsOFF;
out.username=whoami;
out.expdate=expdate;
out.filenum=filenum;
out.session=session;
out.oepathname=oepathname;
out.OEdatafile=OEdatafile;
out.freqs=freqs1;
out.amps=amps;
out.durs=durs;
out.isis=isis;
out.next=unique(allnexts);
out.numfreqs=numfreqs;
out.numamps=numamps;
out.numdurs=numdurs;
out.clickdurs=clickdurs;
out.event=event;
out.xlimits=xlimits;
out.ylimits=ylimits;
out.samprate=samprate;
out.PPAstart=PPAstart;
out.width=width;
out.cluster=cell;


outfilename=sprintf('out_T%s_ILWNTrain%s-%s-%s-psth',channel,expdate,session, filenum);
save (outfilename, 'out')
fprintf('\n Saved to %s.\n', outfilename)


if save_outfile==1
cd('D:\lab\Somatostatin_project_shared_folder\Clicks\')
outfilename=sprintf('out_T%s_ILWNTrain%s-%s-%s-%d',channel,expdate,session, filenum, cell);
save(outfilename, 'out');
fprintf('saved the outfile in Clicks folder'); %ira 7.29.15
end


