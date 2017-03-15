function PlotILNBN_psthOE(expdate, session, filenum, channel, varargin)
% plots psth tuning curve for spike data from Open Ephys/SimpleClust
% interleaved laser ON and OFF trials, PPA_laser signal expected on 100_CH36
% usage: PlotILNBN_psthOE(expdate, session, filenum, channel number, [xlimits], [ylimits], [binwidth])
% (xlimits, ylimits, binwidth are optional)
%
%  defaults: binwidth=5ms, axes autoscaled
%  note there is no thresh because spikes were already cut in SimpleClust
%  plots mean spike rate (in Hz) averaged across trials

% mw 032614
%edited by ira 04-01-14
% mw 06.11.2014 - added MClust capability
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sorter='MClust'; %can be either 'MClust' or 'simpleclust'
%sorter='simpleclust';
% recordings = cell_list_ira_som_OE;
% for i=1:length(recordings)
%     if strcmp(recordings(i).expdate, expdate) && strcmp(recordings(i).session, session) && strcmp(recordings(i).filenum, filenum)
%         sorter=recordings(i).sorter;
%     end
% end

save_outfile=0; %saves outfile into a folder which is synced with
combine_ONOFF=1;
dbstop if error
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

lostat=-1; % Discard data after this position (in samples), -1 to skip
fs=10; %fontsize

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
        OEdatafile=sprintf('ch%s_simpleclust.mat', channel);
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
    samprate=OEget_samplerate(expdate, session, filenum);
catch
    fprintf('\ncould not load sampling rate. Assuming samprate=30000');
    samprate=30000;
end

% try
%     gorawdatadir(expdate, session, filenum)
%     expfilename=sprintf('%s-%s-%s-%s.mat', expdate, whoami, session, filenum);
%     expstructurename=sprintf('exper_%s', filenum);
%     if exist(expfilename)==2 %try current directory
%         load(expfilename)
%         exp=eval(expstructurename);
%         isrecording=exp.openephyslinker.param.isrecording.value;
%         oepathname=exp.openephyslinker.param.oepathname.value;
%         cd(oepathname)
%         OEdatafile=sprintf('ch%s_simpleclust.mat', channel);
%         fprintf('\ntrying to load %s... ',OEdatafile)
%         load(OEdatafile)
%         fprintf('success\n')
%     else %try data directory
%         cd ../../..
%         try
%             cd(sprintf('Data-%s-backup',user))
%             cd(sprintf('%s-%s',expdate,user))
%             cd(sprintf('%s-%s-%s',expdate,user, session))
%         end
%         if exist(expfilename)==2
%             load(expfilename)
%             exp=eval(expstructurename);
%             isrecording=exp.openephyslinker.param.isrecording.value;
%             oepathname=exp.openephyslinker.param.oepathname.value;
%             cd(oepathname);
%             OEdatafile=spintf('ch%s_simpleclust.mat', channel);
%             load(OEdatafile);
%             fprintf('success\n')
%         else
%             fprintf('failed\ncould not find exper structure. Cannot get OE file info.')
%         end
%     end
% catch
%     cd('C:\Program Files\Open Ephys')
%     [OEdatafile, oepathname] = uigetfile('*simpleclust.mat', 'pick a simpleclust.mat file');
%     if isequal(OEdatafile,0) || isequal(oepathname,0)
%         return;
%     else
%         cd(oepathname)
%     end
%     load(OEdatafile)
%     fprintf('success')
%
% end
%
% %try to get samprate
% try
%     [~, ~, info] = load_open_ephys_data('all_channels.events');
%     samprate=info.header.sampleRate;
% catch
%     fprintf('\ncould not load sampling rate. Assuming samprate=30000');
%     samprate=30000;
% end
%
% Nclusters=features.Nclusters;
% for n=1:Nclusters
%     spikeidx(n).spikeidx=find(features.clusters==n);%list of indexes for spikes in each cluster
%     nspikes(n)=length(spikeidx(n).spikeidx);
%     spiketimes(n).spiketimes=features.ts(spikeidx(n).spikeidx); %list of spiketimes in sec
% end



if isempty(event); fprintf('\nno tones\n'); return; end


fprintf('\ncomputing tuning curve...');
%

if lostat==-1
    lostat=inf;
end
fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));


%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allbws(j)=0;
    elseif strcmp(event(i).Type, 'fmtone')
        j=j+1;
        allfreqs(j)=event(i).Param.carrier_frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allbws(j)=0;
    elseif strcmp(event(i).Type, 'tonetrain')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.toneduration;
        allbws(j)=0;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allbws(j)=inf;
    elseif strcmp(event(i).Type, 'grating')
        j=j+1;
        allfreqs(j)=event(i).Param.angle*1000;
        allamps(j)=event(i).Param.spatialfrequency;
        alldurs(j)=event(i).Param.duration;
        allbws(j)=0;
    elseif strcmp(event(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.clickduration; %        alldurs(j)=event(i).Param.duration; gives trial duration not tone duration
        allbws(j)=0;
    elseif strcmp(event(i).Type, 'noise')
        j=j+1;
        allfreqs(j)=event(i).Param.center_frequency;
        allbws(j)=event(i).Param.bandwidthOct;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    end
    
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
bws=unique(allbws);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);
try
    numbws=length(bws);
catch
    numbws=1;
end
try
    [on, PPAstart, width, numpulses, isi]=getPPALaserParams(expdate,session,filenum);
catch
    ProcessData_single(expdate,session,filenum);
    [on, PPAstart, width, numpulses, isi]=getPPALaserParams(expdate,session,filenum);
end
%delete
% expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
% M1=[];
% nreps=zeros(numfreqs, numamps, numdurs);

M1ONp=[]; %all spiketimes by trial
mM1ONp=[]; %all spiketimes collapsed across trials
nrepsON=zeros(numfreqs, numamps, numdurs);
M1spontON=[]; %spont spiketimes by trial
mM1spontON=[]; %spont spiketimes collapsed across trials
sM1spontON=[];%std dev of spont
semM1spontON=[];%s.e.m. of spont

M1OFFp=[];
mM1OFFp=[];
nrepsOFF=zeros(numfreqs, numamps, numdurs);
M1spontOFF=[];
mM1spontOFF=[];
sM1spontOFF=[];
semM1spontOFF=[];

inRange=zeros(1, Nclusters);
%extract the traces into a big matrix M
j=0;

for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'grating') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'noise')
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
        start=(pos+xlimits(1)*1e-3); %in sec
        stop=(pos+xlimits(2)*1e-3); %in sec
        if start>0 %(disallow negative start times)
            if stop>lostat
                fprintf('\ndiscarding trace')
            else
                aopulseon=event(i).Param.AOPulseOn;
                
                if strcmp(event(i).Type, 'tone')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.duration;
                    bw=0;
                elseif strcmp(event(i).Type, 'fmtone')
                    freq=event(i).Param.carrier_frequency;
                    dur=event1(i).Param.duration;
                    bw=0;
                elseif  strcmp(event(i).Type, 'tonetrain')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.toneduration;
                    bw=0;
                elseif  strcmp(event(i).Type, 'grating')
                    freq=event(i).Param.angle*1000;
                    dur=event(i).Param.duration;
                    bw=0;
                elseif strcmp(event(i).Type, 'whitenoise')
                    dur=event(i).Param.duration;
                    freq=-1;
                    bw=inf;
                elseif strcmp(event(i).Type, 'clicktrain')
                    dur=event(i).Param.clickduration;
                    freq=-1;
                    bw=0;
                elseif strcmp(event(i).Type, 'noise')
                    dur=event(i).Param.duration;
                    bw=event(i).Param.bandwidthOct;
                    freq=event(i).Param.center_frequency;
                end
                try
                    amp=event(i).Param.amplitude;
                catch
                    amp=event(i).Param.spatialfrequency;
                end
                %                 dur=event(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                bwindex= find(bws==bw);
                if i==1
                    nrepsOFF=zeros(numfreqs, numamps, numbws, numdurs);
                    nrepsON=zeros(numfreqs, numamps, numbws, numdurs);
                end
                %analyzing a NBN TC; ira 04-01-14
                
                for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                    st=spiketimes(clust).spiketimes;
                    spiketimes1=st(st>start & st<stop); % spiketimes in region
                    spikecount=length(spiketimes1); % No. of spikes fired in response to this rep of this stim.
                    inRange(clust)=inRange(clust)+ spikecount; %accumulate total spikecount in region
                    spiketimes1=(spiketimes1-pos)*1000;%covert to ms after tone onset
                    spont_spikecount=length(find(st<start & st>(start-(stop-start))));
                    % No. spikes in a region of same length preceding response window
                    if aopulseon
                        if clust==1
                            nrepsON(findex, aindex, bwindex, dindex)=nrepsON(findex, aindex, bwindex, dindex)+1;
                        end
                        M1ONp(clust, findex,aindex,bwindex, dindex, nrepsON(findex, aindex, bwindex, dindex)).spiketimes=spiketimes1; % Spike times
                        M1ONspikecounts(clust, findex,aindex,bwindex, dindex,nrepsON(findex, aindex, bwindex, dindex))=spikecount; % No. of spikes
                        M1spontON(clust, findex,aindex,bwindex, dindex, nrepsON(findex, aindex,bwindex,  dindex))=spont_spikecount; % No. of spikes in spont window, for each presentation.
                        % Could save actual spont spiketimes here, in addition
                        % to count...
                    else
                        if clust==1
                            nrepsOFF(findex, aindex,bwindex, dindex)=nrepsOFF(findex, aindex, bwindex, dindex)+1;
                        end
                        M1OFFp(clust, findex,aindex,bwindex, dindex, nrepsOFF(findex, aindex, bwindex, dindex)).spiketimes=spiketimes1;
                        M1OFFspikecounts(clust, findex,aindex,bwindex, dindex,nrepsOFF(findex, aindex,bwindex,  dindex))=spikecount;
                        M1spontOFF(clust, findex,aindex,bwindex, dindex, nrepsOFF(findex, aindex,bwindex,  dindex))=spont_spikecount;
                    end
                end
            end
        end
    end
end



fprintf('\nmin num ON reps: %d\nmax num ON reps: %d', min(min(min(min(nrepsON)))), max(max(max(max(nrepsON)))))
fprintf('\nmin num OFF reps: %d\nmax num OFF reps: %d', min(min(min(min(nrepsOFF)))), max(max(max(max(nrepsOFF)))))
for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
    fprintf('\ncell %d:', clust)
    fprintf('\ntotal num spikes: %d', length(spiketimes(clust).spiketimes))
    fprintf('\nIn range: %d', inRange(clust))
end

% ON, evoked
if isempty(mM1ONp) %no laser pulses in this file
    mM1ONspikecount=[];
    sM1ONspikecount=[];
    semM1ONspikecount=[];
    M1ONspikecounts=[];
else
    mM1ONspikecount=mean(M1ONspikecounts,5); % Mean spike count
    sM1ONspikecount=std(M1ONspikecounts,[],5); % Std of the above
    for clust=1:Nclusters
        semM1ONspikecount(clust, :,:)=squeeze(sM1ONspikecount(clust, :,:))./sqrt(nrepsON(:,:,1)); % Sem of the above
    end
    % Spont
    mM1spontON=mean(M1spontON,5);
    sM1spontON=std(M1spontON,[],5);
    for clust=1:Nclusters
        semM1spontON(clust, :,:)=squeeze(sM1spontON(clust, :,:))./sqrt(nrepsON(:,:,1));
    end
end

% % OFF, evoked
mM1OFFspikecount=mean(M1OFFspikecounts,5);
sM1OFFspikecount=std(M1OFFspikecounts,[],5);
% for clust=1:Nclusters
%     semM1OFFspikecount(clust, :,:,:,:)=squeeze(sM1OFFspikecount(clust, :,:,:,:))./sqrt(nrepsOFF(:,:,:,2));
% end
% Spont
mM1spontOFF=mean(M1spontOFF,5);
sM1spontOFF=std(M1spontOFF,[],5);
% for clust=1:Nclusters
%     semM1spontOFF(clust, :,:,:)=squeeze(sM1spontOFF(clust, :,:,:))./sqrt(nrepsOFF(:,:,:,1));
% end


%% Accumulate spiketimes across trials, for psth...
for dindex=1:numdurs; % Hardcoded.
    for bwindex=1:length(bws)
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                for clust=1:Nclusters
                    
                    % on
                    spiketimesON=[];
                    spikecountsON=[];
                    for rep=1:nrepsON(findex, aindex, bwindex, dindex)
                        spiketimesON=[spiketimesON M1ONp(clust, findex, aindex,bwindex,dindex, rep).spiketimes];
                        % Accumulate spike times for all presentations of each
                        % laser/f/a combo.
                    end
                    
                    % All spiketimes for a given f/a/d combo, for psth:
                    mM1ONp(clust, findex, aindex, bwindex, dindex).spiketimes=spiketimesON;
                    
                    % off
                    spiketimesOFF=[];
                    for rep=1:nrepsOFF(findex, aindex, bwindex, dindex)
                        spiketimesOFF=[spiketimesOFF M1OFFp(clust, findex, aindex, bwindex, dindex, rep).spiketimes];
                    end
                    mM1OFFp(clust, findex, aindex, bwindex, dindex).spiketimes=spiketimesOFF;
                end
            end
        end
    end
end

%find axis limits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i=1:length(recordings)
%     if strcmp(recordings(i).expdate, expdate) && strcmp(recordings(i).session, session) && strcmp(recordings(i).filenum, filenum)
%     for j=1:size(recordings(i).tetrode)
%         for k=1:size(recordings(i).tetrode(j,:).cluster)
%         clust1(k,:)=recordings(i).tetrode(j,:).cluster(k,:).number;
%         end
%     end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ylimits==-1
    for clust=1:Nclusters
        ymax=0;
        for dindex=1:numdurs
            for bwindex=1:numbws
                for aindex=[numamps:-1:1]
                    for findex=1:numfreqs
                        st=mM1ONp(clust, findex, aindex, bwindex, dindex).spiketimes;
                        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                        [N, x]=hist(st, X);
                        N=N./nrepsON(findex, aindex, bwindex, dindex); %normalize to spike rate (averaged across trials)
                        N=1000*N./binwidth; %normalize to spike rate in Hz
                        ymax= max(ymax,max(N));
                        
                        st=mM1OFFp(clust, findex, aindex, bwindex, dindex).spiketimes;
                        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                        [N, x]=hist(st, X);
                        N=N./nrepsON(findex, aindex, bwindex, dindex); %normalize to spike rate (averaged across trials)
                        N=1000*N./binwidth; %normalize to spike rate in Hz
                        ymax= max(ymax,max(N));
                    end
                end
            end
        end
        ylimits1(clust,:)=[-.3 ymax];
    end
else
    for clust=1:Nclusters
        ylimits1(clust, :)=[ylimits];
    end
end

% %find axis limits
%
% if ylimits==-1
%     for dindex=1:numdurs
%         for bwindex=1:numbws
%             for aindex=[numamps:-1:1]
%                 for findex=1:numfreqs
%                     for clust=1:Nclusters
%                         ylimits=[-.3 0];
%                         spiketimes=mM1ONp(clust, findex, aindex, bwindex, dindex).spiketimes;
%                         X=xlimits(1):binwidth:xlimits(2); %specify bin centers
%                         [N, x]=hist(spiketimes, X);
%                         N=N./nrepsON(findex, aindex, bwindex, dindex); %normalize to spike rate (averaged across trials)
%                         N=1000*N./binwidth; %normalize to spike rate in Hz
%                         ylimits(2)= max(ylimits(2),max(N));
%                         ylimits1(clust,:)=[clust ylimits];
%                     end
%                 end
%             end
%         end
%     end
% end

% ttest
if isempty(mM1ONspikecount) %no laser pulses in this file
    pvalues=nan(size(nrepsON));alpha=[];
else
    [h,pvalues]=ttest2(M1ONspikecounts,M1OFFspikecounts,[],[],[],4);
    alpha=0.05/(numamps*numfreqs);
end

% Plot psth, ON/OFF overlay
if ~isempty(cell)
    clust=cell;
    for dindex=1:numdurs;

        figure
        p=0;
        if numdurs~=1 %dealing with multiple durations when a silent stimulus is added
            if dindex~=1
                subplot1(numbws,numfreqs-1)
            end
            if dindex==1
                subplot1(numamps-1,numfreqs-1)
            end
        else
            subplot1(numbws,numfreqs-1)
        end

        for bwindex=1:numbws
            for findex=1:numfreqs

                for aindex=[1:numamps]

                    %                 if bwindex==numbws
                    %                     findex=1;
                    %                 end
                    if nrepsON(findex, aindex, bwindex, dindex)==0
                        fprintf('\n no reps')
                    else
                        p=p+1;
                        subplot1(p)
                        hold on

                        spiketimesON=mM1ONp(clust, findex, aindex, bwindex, dindex).spiketimes;
                        spiketimesOFF=mM1OFFp(clust, findex, aindex, bwindex, dindex).spiketimes;
                        X=xlimits(1):binwidth:xlimits(2); % specify bin centers

                        [NON, xON]=hist(spiketimesON, X);
                        [NOFF, xOFF]=hist(spiketimesOFF, X);

                        NON=NON./nrepsON(findex, aindex, bwindex, dindex); %
                        NON=1000*NON./binwidth; %normalize to spike rate in Hz
                        NOFF=NOFF./nrepsOFF(findex, aindex, bwindex, dindex);
                        NOFF=1000*NOFF./binwidth;

                        bON=bar(xON, NON,1);
                        hold on
                        bOFF=bar(xOFF,NOFF,1);

                        set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                        set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                        line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                        line(xlimits, [0 0], 'color', 'k')

                        xlim(xlimits)
                        ylim(ylimits1(clust,:))

                        % Add stars for ttest.
                        if pvalues(findex,aindex, bwindex)<alpha
                            text((xlimits(2)*.1),(ylimits(2)*.6),'*','fontsize',30,'color','r')
                        end

                    end
                end
                if bwindex==numbws
                    if numfreqs>2
                        vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/4;
                        frequencies=num2str(freqs/1000, .1);
                        text(xlimits(2), vpos, sprintf('%s kHz', frequencies))
                    else
                        vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/4;
                        text(mean(xlimits), vpos, sprintf('%0.1f kHz', freqs(findex)/1000))
                    end
                else
                end

                set(gca, 'yticklabel', '')
            end
        end
        % Label amps and freqs.
        p=0;
        if dindex==1
            xlabel('Quiet white noise, 25 ms')
            title(sprintf('%s-%s-%s: -1000 dB (Max reps ON=%.0f, OFF=%.0f cell # %.0f)',expdate,session, filenum, max(max(max(max(nrepsON)))),max(max(max(max(nrepsOFF)))), clust))
        else

            for bwindex=[1:numbws]
                for findex=2:numfreqs
                    p=p+1;
                    subplot1(p)
                    if findex==2
                        T=text(xlimits(1)-diff(xlimits)/16, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                        set(T, 'HorizontalAlignment', 'right')

                        if bwindex==1
                            T=text(xlimits(1)-diff(xlimits)/16, ylimits1(clust,2), sprintf('BW\nOct'));
                            set(T, 'HorizontalAlignment', 'right')
                        end
                    else
                        set(gca, 'xticklabel', '')
                    end
                    set(gca, 'xtickmode', 'auto')
                    grid on

                end

                subplot1(ceil(numfreqs/3))

                title(sprintf('%s-%s-%s: %.0f dB (Max reps ON=%.0f, OFF=%.0f cell number %.0f, )',expdate,session, filenum, amps(aindex), max(max(max(max(nrepsON)))),max(max(max(max(nrepsOFF)))), clust))

                %                 pos=get(gcf, 'pos');
                %                 pos(2)=pos(2)-600;
                %                 pos(4)=pos(4)+600;
                %                 set(gcf, 'pos', pos);
                %                 text
            end
        end %dindex
        %nclust
    end
    % Plot ON trials

else
    for clust=1:Nclusters
        for dindex=1:numdurs;

            figure
            p=0;
            if numdurs~=1 %dealing with multiple durations when a silent stimulus is added
                if dindex~=1
                    subplot1(numbws,numfreqs-1)
                end
                if dindex==1
                    subplot1(numamps-1,numfreqs-1)
                end
            else
                subplot1(numbws,numfreqs-1)
            end

            for bwindex=1:numbws
                for findex=2:numfreqs

                    for aindex=[1:numamps]
                        if nrepsON(findex, aindex, bwindex, dindex)==0
                            fprintf('\n no reps')
                        end
                            p=p+1;
                            subplot1(p)
                            hold on

                            spiketimesON=mM1ONp(clust, findex, aindex, bwindex, dindex).spiketimes;
                            spiketimesOFF=mM1OFFp(clust, findex, aindex, bwindex, dindex).spiketimes;
                            X=xlimits(1):binwidth:xlimits(2); % specify bin centers

                            [NON, xON]=hist(spiketimesON, X);
                            [NOFF, xOFF]=hist(spiketimesOFF, X);

                            NON=NON./nrepsON(findex, aindex, bwindex, dindex); %
                            NON=1000*NON./binwidth; %normalize to spike rate in Hz
                            NOFF=NOFF./nrepsOFF(findex, aindex, bwindex, dindex);
                            NOFF=1000*NOFF./binwidth;

                            bON=bar(xON, NON,1);
                            hold on
                            bOFF=bar(xOFF,NOFF,1);

                            set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                            set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                            line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                            line(xlimits, [0 0], 'color', 'k')

                            xlim(xlimits)
                            ylim(ylimits1(clust,:))

                            % Add stars for ttest.
                            if pvalues(findex,aindex, bwindex)<alpha
                                text((xlimits(2)*.1),(ylimits(2)*.6),'*','fontsize',30,'color','r')
                            end

                    end
                    if bwindex==numbws
                        if numfreqs>2
                            vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/4;
                            frequencies=num2str(freqs/1000, .1);
                            text(xlimits(2), vpos, sprintf('%s kHz', frequencies))
                        else
                            vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/4;
                            text(mean(xlimits), vpos, sprintf('%0.1f kHz', freqs(findex)/1000))
                        end
                    else
                    end

                    set(gca, 'yticklabel', '')
                end
            end
            % Label amps and freqs.
            p=0;
            if dindex==1
                xlabel('Quiet white noise, 25 ms')
                title(sprintf('%s-%s-%s: -1000 dB (Max reps ON=%.0f, OFF=%.0f cell # %.0f)',expdate,session, filenum, max(max(max(max(nrepsON)))),max(max(max(max(nrepsOFF)))), clust))
            end

                for bwindex=[1:numbws]
                    for findex=2:numfreqs
                        p=p+1;
                        subplot1(p)
                        if findex==2
                            T=text(xlimits(1)-diff(xlimits)/16, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                            set(T, 'HorizontalAlignment', 'right')

                            if bwindex==1
                                T=text(xlimits(1)-diff(xlimits)/16, ylimits1(clust,2), sprintf('BW\nOct'));
                                set(T, 'HorizontalAlignment', 'right')
                            end
                        else
                            set(gca, 'xticklabel', '')
                        end
                        set(gca, 'xtickmode', 'auto')
                        grid on

                    end

                    subplot1(ceil(numfreqs/3))

                    title(sprintf('%s-%s-%s: %.0f dB (Max reps ON=%.0f, OFF=%.0f cell number %.0f, )',expdate,session, filenum, amps(aindex), max(max(max(max(nrepsON)))),max(max(max(max(nrepsOFF)))), clust))

                end
            end %dindex
            %nclust
        
    end
end

%Plot OFF trials only
if ~isempty(cell)
    clust=cell;
    for dindex=1:numdurs;
        
        figure
        p=0;
        if numdurs~=1 %dealing with multiple durations when a silent stimulus is added
            if dindex~=1
                subplot1(numbws,numfreqs-1)
            end
            if dindex==1
                subplot1(numamps-1,numfreqs-1)
            end
        else
            subplot1(numbws,numfreqs-1)
        end
        
        for bwindex=1:numbws
            for findex=1:numfreqs
                
                for aindex=[1:numamps]
                    
                    %                 if bwindex==numbws
                    %                     findex=1;
                    %                 end
                    p=p+1;
                    subplot1(p)
                    hold on
                    
                    spiketimesOFF=mM1OFFp(clust, findex, aindex, bwindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); % specify bin centers
                    [NOFF, xOFF]=hist(spiketimesOFF, X);
                    
                    NOFF=NOFF./nrepsOFF(findex, aindex, bwindex, dindex);
                    NOFF=1000*NOFF./binwidth;
                    
                    bOFF=bar(xOFF,NOFF,1);
                    
                    set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                    line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    
                    xlim(xlimits)
                    %ylim(ylimits1(clust,:))
                    
                    % Add stars for ttest.
                    if pvalues(findex,aindex, bwindex)<alpha
                        text((xlimits(2)*.1),(ylimits(2)*.6),'*','fontsize',30,'color','r')
                    end
                    
                end
            end
            if bwindex==numbws
                if numfreqs>2
                    vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/8;
                    frequencies=num2str(freqs/1000, .1);
                    text(xlimits(2), vpos, sprintf('%s kHz', frequencies))
                elseif numfreqs==2
                    vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/8;
                    text(mean(xlimits), vpos, sprintf('%0.1f kHz', freqs(2)/1000))
                else
                    vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/8;
                    text(mean(xlimits), vpos, sprintf('%0.1f kHz', freqs(findex)/1000))
                end
            else
            end
            
            set(gca, 'yticklabel', '')
        end
    end
    
    
else
    for clust=1:Nclusters
        for dindex=1:numdurs;
            
            figure
            p=0;
            if numdurs~=1 %dealing with multiple durations when a silent stimulus is added
                if dindex~=1
                    subplot1(numbws,numfreqs-1)
                end
                if dindex==1
                    subplot1(numamps-1,numfreqs-1)
                end
            else
                subplot1(numbws,numfreqs-1)
            end
            
            for bwindex=1:numbws
                 findex=2
                    for aindex=[1:numamps]
                        
                        p=p+1;
                        subplot1(p)
                        hold on
                        
                        spiketimesOFF=mM1OFFp(clust, findex, aindex, bwindex, dindex).spiketimes;
                        X=xlimits(1):binwidth:xlimits(2); % specify bin centers
                        [NOFF, xOFF]=hist(spiketimesOFF, X);
                        
                        NOFF=NOFF./nrepsOFF(findex, aindex, bwindex, dindex);
                        NOFF=1000*NOFF./binwidth;
                        
                        bOFF=bar(xOFF,NOFF,1);
                        
                        set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                        line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                        line(xlimits, [0 0], 'color', 'k')
                        
                        xlim(xlimits)
                        if pvalues(findex,aindex, bwindex)<alpha
                            text((xlimits(2)*.1),(ylimits(2)*.6),'*','fontsize',30,'color','r')
                        end
                        
                    end
                
                if bwindex==numbws
                    if numfreqs>2
                        vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/8;
                        frequencies=num2str(freqs/1000, .1);
                        text(xlimits(2), vpos, sprintf('%s kHz', frequencies))
                    elseif numfreqs==2
                        vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/8;
                        text(mean(xlimits), vpos, sprintf('%0.1f kHz', freqs(2)/1000))
                    else
                        vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/8;
                        text(mean(xlimits), vpos, sprintf('%0.1f kHz', freqs(findex)/1000))
                    end
                else
                    
                    
                    set(gca, 'yticklabel', '')
                end
            end
            % Label amps and freqs.
            p=0;
            
                        for bwindex=[1:numbws]
                            for findex=2:numfreqs
                                p=p+1;
                                subplot1(p)
                                if findex==2
                                    T=text(xlimits(1)-diff(xlimits)/16, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                                    set(T, 'HorizontalAlignment', 'right')
            
                                    if bwindex==1
                                        T=text(xlimits(1)-diff(xlimits)/16, ylimits1(clust,2), sprintf('BW\nOct'));
                                        set(T, 'HorizontalAlignment', 'right')
                                    end
                                else
                                    set(gca, 'xticklabel', '')
                                end
                                set(gca, 'xtickmode', 'auto')
                                grid on
            
                            end
            
                            subplot1(ceil(numfreqs/3))
            
                            title(sprintf('%s-%s-%s: %.0f dB (cell number %.0f, tetrode %s KMA)',expdate,session, filenum, amps(aindex), clust, channel))
            
                        end
            end %dindex
        end
    end


if combine_ONOFF==1
    for clust=1:Nclusters
        for dindex=1:numdurs;

            figure
            p=0;
            if numdurs~=1 %dealing with multiple durations when a silent stimulus is added
                if dindex~=1
                    subplot1(numbws,numfreqs-1)
                end
                if dindex==1
                    subplot1(numamps-1,numfreqs-1)
                end
            else
                subplot1(numbws,numfreqs-1)
            end

            for bwindex=1:numbws
                for findex=2:numfreqs

                    for aindex=[1:numamps]
                        if nrepsON(findex, aindex, bwindex, dindex)==0
                            fprintf('\n no reps')
                        end
                            p=p+1;
                            subplot1(p)
                            hold on

                            spiketimesON=mM1ONp(clust, findex, aindex, bwindex, dindex).spiketimes;
                            spiketimesOFF=mM1OFFp(clust, findex, aindex, bwindex, dindex).spiketimes;
                            spiketimes=[spiketimesON spiketimesOFF];
                            X=xlimits(1):binwidth:xlimits(2); % specify bin centers

                            [N, x]=hist(spiketimes, X);
                            nreps=nrepsON+nrepsOFF;

                            N=N./nreps(findex, aindex, bwindex, dindex); %
                            N=1000*N./binwidth; %normalize to spike rate in Hz

                            b=bar(x, N,1);

                            set(b, 'facecolor', 'none','edgecolor', [0 0 0]);
                            line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                            line(xlimits, [0 0], 'color', 'k')

                            xlim(xlimits)
                            ylim(ylimits1(clust,:))

                            % Add stars for ttest.
                            if pvalues(findex,aindex, bwindex)<alpha
                                text((xlimits(2)*.1),(ylimits(2)*.6),'*','fontsize',30,'color','r')
                            end

                    end
                    if bwindex==numbws
                        if numfreqs>2
                            vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/4;
                            frequencies=num2str(freqs/1000, .1);
                            text(xlimits(2), vpos, sprintf('%s kHz', frequencies))
                        else
                            vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/4;
                            text(mean(xlimits), vpos, sprintf('%0.1f kHz', freqs(findex)/1000))
                        end
                    else
                    end
                end
            end
            % Label amps and freqs.
            p=0;

                for bwindex=[1:numbws]
                    for findex=2:numfreqs
                        p=p+1;
                        subplot1(p)
                        if p==1
                             title(sprintf('%s-%s-%s: %.0f dB (Max reps ON=%.0f, OFF=%.0f cell number %.0f, )',expdate,session, filenum, amps(aindex), max(max(max(max(nrepsON)))),max(max(max(max(nrepsOFF)))), clust))
                        end
                        if findex==2
                            T=text(xlimits(1)-diff(xlimits)/16, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                            set(T, 'HorizontalAlignment', 'right')

                            if bwindex==1
                                T=text(xlimits(1)-diff(xlimits)/16, ylimits1(clust,2), sprintf('BW\nOct'));
                                set(T, 'HorizontalAlignment', 'right')
                            end
                        else
                            set(gca, 'xticklabel', '')
                        end
                        set(gca, 'xtickmode', 'auto')
                        grid on

                    end

                   

                    %                 pos=get(gcf, 'pos');
                    %                 pos(2)=pos(2)-600;
                    %                 pos(4)=pos(4)+600;
                    %                 set(gcf, 'pos', pos);
                    %                 text
                end
            end 
           
        end%dindex
    end %nclust




%% Save it to an outfile!

% Evoked spikes.
out.M1OFFp=M1OFFp; % All spiketimes, trial-by-trial.
out.M1ONp=M1ONp;
out.mM1OFFp=mM1OFFp; % Accumulated spike times for *all* presentations of each laser/f/a combo.
out.mM1ONp=mM1ONp;

out.mM1ONspikecount=mM1ONspikecount; % Mean spikecount for each laser/f/a combo.
out.sM1ONspikecount=sM1ONspikecount;
out.semM1ONspikecount=semM1ONspikecount;
out.mM1OFFspikecount=mM1OFFspikecount;
out.sM1OFFspikecount=sM1OFFspikecount;
%out.semM1OFFspikecount=semM1OFFspikecount;

% Spont spikes.
out.mM1spontON=mM1spontON;
out.sM1spontON=sM1spontON;
out.semM1spontON=semM1spontON;
out.mM1spontOFF=mM1spontOFF;
out.sM1spontOFF=sM1spontOFF;
out.semM1spontOFF=semM1spontOFF;

out.amps=amps;
out.durs=durs;
out.bws=bws;
out.freqs=freqs;
out.nrepsON=nrepsON;
out.nrepsOFF=nrepsOFF;
out.xlimits=xlimits;
%out.mVthresh=thresh;

out.oepathname=oepathname;
out.OEdatafile=OEdatafile;
out.PPAstart=PPAstart;
out.width=width;
out.cluster=cell;

godatadir(expdate,session,filenum);
outfilename=sprintf('out%sArchNBN%s-%s-%s',channel,expdate,session, filenum);
save (outfilename, 'out')
fprintf('\n Saved to %s.\n', outfilename)

if save_outfile==1
    cd('D:\lab\Somatostatin_project_shared_folder\NBN\');
    outfilename=sprintf('out%sArchNBN%s-%s-%s-%d',channel,expdate,session, filenum, cell);
    save(outfilename, 'out');
    fprintf('saved the outfile in NBN folder'); %ira 7.29.15
    
end

fprintf('\n\n')
end
