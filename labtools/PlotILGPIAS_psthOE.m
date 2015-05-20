function PlotILGPIAS_psthOE(expdate, session, filenum, channel, varargin)
% PlotILGPIAS_psth(expdate, session, filenum, channel number, [xlimits], [ylimits], [binwidth], cell)
% (xlimits, ylimits, binwidth are optional)
%  defaults: binwidth=5ms, axes autoscaled
%  note there is no thresh because spikes were already cut in SimpleClust
%  plots mean spike rate (in Hz) averaged across trials

%mw 05.21.14 modified by merging PlotILGPIAS_psth and PlotTC_psthOE

% y = Binned spike counts / # trials.
% 6/3/13 AKH

% Last edits:
% 7.2.13 AKH -- saves psth to .txt file for Aldis
% mw 06.11.2014 - added MC
%
% note: on 06.09.2014 we changed MakeGPIASProtocol so that gapdelay now
% refers to time until gap offset (used to be time to gap onset). Also
% added soaflag which allows user to specify fixed soa or fixed isi.
% changing documentation below to reflect this change, i.e. spikes are now
% relative to gap offset, not gap onset

sorter='MClust'; %can be either 'MClust' or 'simpleclust'
%sorter='simpleclust';
fprintf('\nsorter: %s', sorter)

refract=15;
fs=12; %fontsize for figures
global pref
if isempty(pref); Prefs; end

if nargin==0
    fprintf('\nNo input'); return;
elseif nargin==3
    cell=[];
elseif nargin==4
    cell=[];
elseif nargin==5
    xlimits=varargin{1};
    cell=[];
elseif nargin==6
    xlimits=varargin{1};
    ylimits=varargin{2};
    cell=[];
elseif nargin==7
    xlimits=varargin{1};
    ylimits=varargin{2};
    binwidth=varargin{3};
    cell=[];
elseif nargin==8
    xlimits=varargin{1};
    ylimits=varargin{2};
    binwidth=varargin{3};
    cell=varargin{4};
else
    fprintf('\nWrong number of arguments'); return;
end
% varargin defaults
if ~exist('channel','var')
    channel=[];
end
if isempty(channel);
    prompt=('please enter channel number: ');
    channel=input(prompt,'s');
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
    if isempty(channel)
        fprintf('\nno channel entered. Goodbye.')
        return
    end
    %whoops, channel is a char
    %     if ~any(channel==[1:8])
    %     fprintf('\nchannel must be between 1-8. Goodbye.')
    %     return
    %     end
end
if ~strcmp('char',class(channel))
    channel=num2str(channel);
end

if ~exist('xlimits','var'); xlimits=[0 100]; end
if isempty(xlimits); xlimits=[0 100]; end
if ~exist('ylimits','var'); ylimits=-1; end
if isempty(ylimits); ylimits=-1; end
if ~exist('binwidth','var'); binwidth=5; end
if isempty(binwidth); binwidth=5; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
godatadir(expdate,session,filenum)
username=whoami;
screwup_filename=sprintf('%s-%s-%s-%sscrewups.mat', expdate, username, session, filenum);
try
    load(screwup_filename);
    fprintf('\nloaded screwup points from file %s', screwup_filename)
catch
    screwbackpoints=[];
    screwforwardpoints=[];
    fprintf('\ndid not find screwup file %s', screwup_filename)
end


fs=10; %fontsize
outfilename=sprintf('out%s-%s-%s-%s.mat', expdate,session,filenum, channel);
godatadir(expdate, session, filenum);
if 0%exist(outfilename,'file')
    fprintf('\nfound outfile, loading from %s', outfilename)
    load(outfilename)
    M1OFFtc= out.M1OFFtc;
    M1ONtc= out.M1ONtc;
    mM1OFFtc=out.mM1OFFtc;
    mM1ONtc=out.mM1ONtc;
    expdate=out.expdate;
    session=out.session;
    filenum=out.filenum;
    binwidth=out.binwidth;
    samprate=out.samprate;
    numpulseamps=out.numpulseamps;
    numgapdurs=out.numgapdurs;
    pulseamps=out.pulseamps;
    gapdurs=out.gapdurs;
    Nclusters=out.Nclusters;
    nrepsOFF=out.nrepsOFF;
    nrepsON=out.nrepsON;
    gapdelay=out.gapdelay;
else %process data and generate outfile
    [datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
    OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
    godatadir(expdate,session,filenum);
    try
        load(OEeventsfile);
    catch
        fprintf('\nProcessing OE Events...')
        OEgetEvents(expdate, session, filenum);
        load(OEeventsfile)
        fprintf('\ndone processing OE Events.')
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
        
        %samprate=OEget_samplerate(expdate, session, filenum);
        samprate=OEget_samplerate(oepathname);
    catch
        fprintf('\ncould not load sampling rate. Assuming samprate=30000');
        samprate=30000;
    end


%for now converting spiketimes to sec in call to read_MClust_output

if isempty(event); fprintf('\nno stimuli\n'); return; end

fprintf('\ncomputing tuning curve...');

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'GPIAS')
        j=j+1;
        allsoas(j)=event(i).Param.soa;
        allgapdurs(j)=event(i).Param.gapdur;
        allgapdelays(j)=event(i).Param.gapdelay;
        allnoisefreqs(j)=event(i).Param.center_frequency;
        allpulseamps(j)=event(i).Param.pulseamp;
        allpulsedurs(j)=event(i).Param.pulsedur;
        allnoiseamps(j)=event(i).Param.amplitude;
        allnoiselower_frequencies(j)=event(i).Param.lower_frequency;
        allnoiseupper_frequencies(j)=event(i).Param.upper_frequency;
    end
end

for i=1:length(event)
    if strcmp(event(i).Type, 'gapinnoise')
        j=j+1;
        allsoas(j)=event(i).Param.soa;
        allgapdurs(j)=event(i).Param.gapdur;
        allgapdelays(j)=event(i).Param.gapdelay;
        allnoisefreqs(j)=event(i).Param.center_frequency;
        allpulseamps(j)=event(i).Param.pulseamp;
        allpulsedurs(j)=event(i).Param.pulsedur;
        allnoiseamps(j)=event(i).Param.amplitude;
        allnoiselower_frequencies(j)=event(i).Param.lower_frequency;
        allnoiseupper_frequencies(j)=event(i).Param.upper_frequency;
    end
end

M1=[];
gapdurs=unique(allgapdurs);
pulsedurs=unique(allpulsedurs);
soas=unique(allsoas);
gapdelays=unique(allgapdelays);
pulseamps=unique(allpulseamps);
pulsedurs=unique(allpulsedurs);
noisefreqs=unique(allnoisefreqs);
noiseamps=unique(allnoiseamps);
noiselower_frequencies=unique(allnoiselower_frequencies);
noiseupper_frequencies=unique(allnoiseupper_frequencies);
numgapdurs=length(gapdurs);
numpulseamps=length(pulseamps);
nreps=zeros( numgapdurs, numpulseamps);

if length(noisefreqs)~=1
    error('not able to handle multiple noisefreqs')
end
if length(noiselower_frequencies)~=1
    error('not able to handle multiple noiselower_frequencies')
end
if length(noiseupper_frequencies)~=1
    error('not able to handle multiple noiseupper_frequencies')
end
if length(noiseamps)~=1
    error('not able to handle multiple noiseamps')
end
if length(gapdelays)~=1
    error('not able to handle multiple gapdelays')
end
if length(pulsedurs)~=1
    error('not able to handle multiple pulsedurs')
end
if length(soas)~=1
    error('not able to handle multiple soas')
end

noiseamp=noiseamps;
soa=soas;
pulsedur=pulsedurs;
gapdelay=gapdelays;
noisefreq=noisefreqs;
noiseupper_frequency=noiseupper_frequencies;
noiselower_frequency=noiselower_frequencies;
noiseBW=log2(noiseupper_frequency/noiselower_frequency);

M1ONtc=[];
M2ONtc=[];
M1ONtcstim=[];
M1OFFtc=[];
M2OFFtc=[];
M1OFFtcstim=[];

mM1ONtc=[];
mM2ONtc=[];
mM1ONtcstim=[];
mM1OFFtc=[];
mM2OFFtc=[];
mM1OFFtcstim=[];

medM1ONtc=[];
medM2ONtc=[];
medM1ONtcstim=[];
medM1OFFtc=[];
medM2OFFtc=[];
medM1OFFtcstim=[];

rsM1ONtc=[];
rsM2ONtc=[];
rsM1ONtcstim=[];
rsM1OFFtc=[];
rsM2OFFtc=[];
rsM1OFFtcstim=[];

nrepsON=zeros(numgapdurs, numpulseamps);
nrepsOFF=zeros(numgapdurs, numpulseamps);



%extract the traces into a big matrix M
lostat=inf;
numrestarts=0;
numscrewbacks=0;
numscrewforwards=0;

inRange=zeros(1, Nclusters);
for i=1:length(event)
    
%     if any(i==(restarts))
%         numrestarts=numrestarts+1;
%         fprintf('\ndiscarding event %d due to PPA restart', i)
%     end
%     waitbar( i/length(event), wb);
    
    %go back for any screwups mw 07012014
    if any(i==screwbackpoints)
        numscrewbacks=numscrewbacks+1;
    elseif any(i==screwforwardpoints)
        numscrewforwards=numscrewforwards+1;
    end
    
    if strcmp(event(i).Type, 'GPIAS')
        
        if isfield(event(i), 'soundcardtriggerPos')
                %go back numrestarts, skipping any aopulses
                numaopulsestoskip=0;
                for k=1:numrestarts
                    if strcmp(event(i-k).Type, 'aopulse')
                        numaopulsestoskip=numaopulsestoskip+1;
                    end
                end                
                pos=event(i-numrestarts-numaopulsestoskip-numscrewbacks+numscrewforwards).soundcardtriggerPos/samprate; %soundcardtriggerPos now in sec;
% 
%                 I=i-numrestarts-numscrewbacks+numscrewforwards;
%             pos=event(I).soundcardtriggerPos/samprate; %soundcardtriggerPos now in sec
            pr=event(i).Position;
%            Delta(i)=pos-pr;
        else
            pos=event(i).Position;
            fprintf('\nWARNING! Missing a soundcard trigger. Using hardware trigger instead.')
        end
        
        start=(pos+(xlimits(1)+gapdelay)*1e-3); %in seconds, relative to gap offset
        stop=(pos+(xlimits(2)+gapdelay)*1e-3); %in seconds
        if start>0 %(disallow negative start times)
            if stop>lostat
                fprintf('\ndiscarding event after lostat')
            else
                gapdur=event(i).Param.gapdur;
                gdindex= find(gapdur==gapdurs);
                pulseamp=event(i).Param.pulseamp;
                paindex= find(pulseamp==pulseamps);
                %                     if isfield(event(i).Param, 'AOPulseOn')
                aopulseon=event(i).Param.AOPulseOn;
                %                     else
                %                         aopulseon=0;
                %                     end
                if aopulseon
                    nrepsON(gdindex, paindex)=nrepsON(gdindex, paindex)+1;
                    for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                        st=spiketimes(clust).spiketimes;
                        spiketimes1=st(st>start & st<stop); % spiketimes in region
                        inRange(clust)=inRange(clust)+ length(spiketimes1);
                        spiketimes1=(spiketimes1-pos)*1000;%convert to ms relative to gap offset
                        %                             spiketimes1=(spiketimes1-pos-gapdelay/1000)*1000;%covert to ms after tone onset
                        M1ONtc(clust, gdindex, paindex, nrepsON(gdindex, paindex)).spiketimes=spiketimes1; % 
                    end
                    %                         M1ONtcstim(gdindex, paindex, nrepsON(gdindex, paindex),:)=stim(region);
                    %would be nice to load stim from continuous channel and put it in Mstim
                else
                    nrepsOFF(gdindex, paindex)=nrepsOFF(gdindex, paindex)+1;
                    for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                        st=spiketimes(clust).spiketimes;
                        spiketimes1=st(st>start & st<stop); % spiketimes in region
                        inRange(clust)=inRange(clust)+ length(spiketimes1);
                        spiketimes1=(spiketimes1-pos)*1000;%covert to ms relative to gap offset
                        %                             spiketimes1=(spiketimes1-pos-gapdelay/1000)*1000;%covert to ms after tone onset
                        M1OFFtc(clust, gdindex, paindex, nrepsOFF(gdindex, paindex)).spiketimes=spiketimes1;
                    end
                    % M1OFFtcstim(gdindex, paindex, nrepsOFF(gdindex, paindex),:)=stim(region);
                end
            end
        end
    end
end


fprintf('\nnum reps ON: min: %d, max: %d', min(nrepsON(:)), max(nrepsON(:)))
fprintf('\nnum reps OFF: min: %d, max: %d', min(nrepsOFF(:)), max(nrepsOFF(:)))
for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
    fprintf('\ncell %d:', clust)
    fprintf('\ntotal num spikes: %d', length(spiketimes(clust).spiketimes))
    fprintf('\nIn range: %d', inRange(clust))
end

%accumulate across trials ON
for paindex=1:numpulseamps
    for gdindex=1:numgapdurs
        for clust=1:Nclusters
            spiketimes1=[];
            for rep=1:nrepsON(gdindex,paindex)
                spiketimes1=[spiketimes1 M1ONtc(clust, gdindex,paindex, rep).spiketimes];
            end
            mM1ONtc(clust, gdindex,paindex).spiketimes=spiketimes1;
        end
    end
end

%accumulate across trials OFF
for paindex=1:numpulseamps
    for gdindex=1:numgapdurs
        for clust=1:Nclusters
            spiketimes1=[];
            for rep=1:nrepsOFF(gdindex,paindex)
                spiketimes1=[spiketimes1 M1OFFtc(clust, gdindex,paindex, rep).spiketimes];
            end
            mM1OFFtc(clust, gdindex,paindex).spiketimes=spiketimes1;
        end
    end
end

for paindex=1:numpulseamps;
    for gdindex=1:numgapdurs;
        %        mM1ONtcstim(gdindex, paindex,:)=mean(M1ONtcstim(gdindex, paindex, 1:nrepsON(gdindex, paindex),:), 3);
        %        mM1OFFtcstim(gdindex, paindex,:)=mean(M1OFFtcstim(gdindex, paindex, 1:nrepsOFF(gdindex, paindex),:), 3);
        %when we load the stim we should uncomment these
    end
end

out.M1OFFtc = M1OFFtc;
out.M1ONtc = M1ONtc;
out.mM1OFFtc = mM1OFFtc;
out.mM1ONtc = mM1ONtc;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.binwidth=binwidth;
out.samprate=samprate;
out.numpulseamps = numpulseamps;
out.numgapdurs = numgapdurs;
out.pulseamps = pulseamps;
out.gapdurs = gapdurs;
out.gapdelay = gapdelay;
out.Nclusters = Nclusters;
out.nrepsOFF=nrepsOFF;
out.nrepsON=nrepsON;
out.channel=channel; %which tetrode
godatadir(expdate, session, filenum)
save(outfilename, 'out')
fprintf('\nsaved to %s\n', outfilename);

end %if ~outfile exists


if ylimits==-1
    for paindex=1:numpulseamps;
        for gdindex=1:numgapdurs;
            for clust=1:Nclusters
                ylimits=[-.3 0];
                spiketimes1=mM1OFFtc(clust, gdindex,paindex).spiketimes; %in ms relative to gap offset
                X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                [N, x]=hist(spiketimes1, X);
                N=N./nrepsOFF(gdindex,paindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                ylimits(2)= max(ylimits(2),max(N));
                
                spiketimes1=mM1ONtc(clust, gdindex,paindex).spiketimes; %in ms relative to gap offset
                X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                [N, x]=hist(spiketimes1, X);
                N=N./nrepsON(gdindex,paindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                ylimits(2)= max(ylimits(2),max(N));
                
                ylimits(2)=1.05*ylimits(2);
                ylimits1(clust,:)=[ylimits];
            end
        end
    end
else
    for clust=1:Nclusters
        ylimits1(clust, :)=[ylimits];
    end
end

% Plotpsth ON
if ~isempty(cell)
    clust=cell;
    figure
    for paindex=1:numpulseamps
        p=0;
        subplot1(numgapdurs,1)
        
        for gdindex=1:numgapdurs
            p=p+1;
            subplot1(p)
            hold on
            
            if p==1
                title(sprintf('%s-%s-%s, tetrode %s, cell %d, Green=Laser ON; Black=Laser OFF',expdate,session,filenum, channel, clust))
            end
            
            if ~isempty (M1ONtc) & ~isempty (M1OFFtc)
                %only makes sense to do the t-test if you have both ON and OFF
                ONcounts=[M1ONtc(clust, gdindex,paindex).spiketimes];
                OFFcounts=[M1OFFtc(clust, gdindex,paindex).spiketimes];
                [h,pvalues]=ttest2(ONcounts,OFFcounts);
                if pvalues<0.05
                    if mean(ONcounts)>mean(OFFcounts)
                        fprintf('\n%.1f ms gap: p = %f; ON > OFF',gapdurs(gdindex),pvalues)
                    else
                        fprintf('\n%.1f ms gap: p = %f; OFF > ON',gapdurs(gdindex),pvalues)
                    end
                else
                    fprintf('\n%.1f ms gap: p = %f',gapdurs(gdindex),pvalues)
                end
            end
            
            % plot off psth
            if ~isempty (mM1OFFtc)
                
                spiketimes1=mM1OFFtc(clust, gdindex,paindex).spiketimes;
                %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                [N, x]=hist(spiketimes1, X);
                N=N./nrepsOFF(gdindex,paindex); % averaged across trials
                N=1000*N./binwidth; %normalize to spike rate in Hz
                bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
            end
            
            BinCenters=X-gapdelay; %for writing bin centers to aldis file
            
            % plot on psth
            if ~isempty (mM1ONtc)
                spiketimes1=mM1ONtc(clust, gdindex,paindex).spiketimes;
                %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                [N, x]=hist(spiketimes1, X);
                N=N./nrepsON(gdindex,paindex); % averaged across trials
                N=1000*N./binwidth; %normalize to spike rate in Hz
                bar(x-gapdelay, N,1,'facecolor','none','edgecolor',[0 .8 0]);
            end
            
            %plot stim
            if(0)
                %when we load the stim we should plot it here
                stim=squeeze(mM1ONtcstim(gdindex, paindex,:));
                stim=stim-median(stim(1:(length(stim))));
                stim=stim./max(abs(stim));
                
                t=1:length(stim);
                t=t/10;
                t=t+xlimits(1)+gapdelay;
                hold on; plot(t, (stim*(ylimmax/2)), 'm');
            end
            
            
            
            
            xlim([(xlimits(1)) xlimits(2)])
            %            xlim([(xlimits(1)+gapdelay) xlimits(2)+gapdelay])
            ylim(ylimits1(clust, :))
            ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
            
            if gapdurs(gdindex)>0
                line([0 0],[ylim],'color','m')
                line(-[(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
            end
        end
    end
    
    xlabel('ms')
else
for clust=1:Nclusters
    figure
    for paindex=1:numpulseamps
        p=0;
        subplot1(numgapdurs,1)
        
        for gdindex=1:numgapdurs
            p=p+1;
            subplot1(p)
            hold on
            
            if p==1
                title(sprintf('%s-%s-%s, tetrode %s, cell %d, Green=Laser ON; Black=Laser OFF',expdate,session,filenum, channel, clust))
            end
            
            if ~isempty (M1ONtc) & ~isempty (M1OFFtc)
                %only makes sense to do the t-test if you have both ON and OFF
                ONcounts=[M1ONtc(clust, gdindex,paindex).spiketimes];
                OFFcounts=[M1OFFtc(clust, gdindex,paindex).spiketimes];
                [h,pvalues]=ttest2(ONcounts,OFFcounts);
                if pvalues<0.05
                    if mean(ONcounts)>mean(OFFcounts)
                        fprintf('\n%.1f ms gap: p = %f; ON > OFF',gapdurs(gdindex),pvalues)
                    else
                        fprintf('\n%.1f ms gap: p = %f; OFF > ON',gapdurs(gdindex),pvalues)
                    end
                else
                    fprintf('\n%.1f ms gap: p = %f',gapdurs(gdindex),pvalues)
                end
            end
            
            % plot off psth
            if ~isempty (mM1OFFtc)
                
                spiketimes1=mM1OFFtc(clust, gdindex,paindex).spiketimes;
                %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                [N, x]=hist(spiketimes1, X);
                N=N./nrepsOFF(gdindex,paindex); % averaged across trials
                N=1000*N./binwidth; %normalize to spike rate in Hz
                bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
            end
            
            BinCenters=X-gapdelay; %for writing bin centers to aldis file
            
            % plot on psth
            if ~isempty (mM1ONtc)
                spiketimes1=mM1ONtc(clust, gdindex,paindex).spiketimes;
                %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                [N, x]=hist(spiketimes1, X);
                N=N./nrepsON(gdindex,paindex); % averaged across trials
                N=1000*N./binwidth; %normalize to spike rate in Hz
                bar(x-gapdelay, N,1,'facecolor','none','edgecolor',[0 .8 0]);
            end
            
            %plot stim
            if(0)
                %when we load the stim we should plot it here
                stim=squeeze(mM1ONtcstim(gdindex, paindex,:));
                stim=stim-median(stim(1:(length(stim))));
                stim=stim./max(abs(stim));
                
                t=1:length(stim);
                t=t/10;
                t=t+xlimits(1)+gapdelay;
                hold on; plot(t, (stim*(ylimmax/2)), 'm');
            end
            
            
            
            
            xlim([(xlimits(1)) xlimits(2)])
            %            xlim([(xlimits(1)+gapdelay) xlimits(2)+gapdelay])
            ylim(ylimits1(clust, :))
            ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
            
            if gapdurs(gdindex)>0
                line([0 0],[ylim],'color','m')
                line(-[(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
            end
        end
    end
    
    xlabel('ms')
end %for clust
end

% Plotpsth ON/OFF again, this time with rasters
if 1
    if ~isempty(cell)
        clust=cell;
                figure
        for paindex=1:numpulseamps
            p=0;
            subplot1(numgapdurs,1)
            
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                
                if p==1
                    title(sprintf('%s-%s-%s, tetrode %s, cell %d, Green=Laser ON; Black=Laser OFF',expdate,session,filenum, channel, clust))
                end
               
                % plot off psth
                offset=0;
                yl=ylimits1(clust,:);
                inc=(yl(2))/max(max(max(nrepsOFF)));
                if ~isempty (mM1OFFtc)
                    
                    spiketimes1=mM1OFFtc(clust, gdindex,paindex).spiketimes;
                    %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                    X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                    [N, x]=hist(spiketimes1, X);
                    N=N./nrepsOFF(gdindex,paindex); % averaged across trials
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
                end
                
                for n=1:nrepsOFF(gdindex,paindex)
                    spiketimes2=M1OFFtc(clust, gdindex,paindex, n).spiketimes;
                    offset=offset+inc;
                    h=plot(spiketimes2-gapdelay, yl(2)+ones(size(spiketimes2))+offset, '.k');
                end
                
                
                % plot on psth
                if ~isempty (mM1ONtc)
                    spiketimes1=mM1ONtc(clust, gdindex,paindex).spiketimes;
                    %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                    X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                    [N, x]=hist(spiketimes1, X);
                    N=N./nrepsON(gdindex,paindex); % averaged across trials
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    bar(x-gapdelay, N,1,'facecolor','none','edgecolor',[0 .8 0]);
                end
                
                
                for n=1:nrepsON(gdindex,paindex)
                    spiketimes2=M1ONtc(clust, gdindex,paindex, n).spiketimes;
                    offset=offset+inc;
                    h=plot(spiketimes2-gapdelay, ylimits(2)+ones(size(spiketimes2))+offset, '.g');
                end
                
                %plot stim
                if(0)
                    %when we load the stim we should plot it here
                    stim=squeeze(mM1ONtcstim(gdindex, paindex,:));
                    stim=stim-median(stim(1:(length(stim))));
                    stim=stim./max(abs(stim));
                    
                    t=1:length(stim);
                    t=t/10;
                    t=t+xlimits(1)+gapdelay;
                    hold on; plot(t, (stim*(ylimmax/2)), 'm');
                end
                
                    if gapdurs(gdindex)>0
                line([0 0],[ylim],'color','m')
                line(-[(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
            end
                
                
                xlim([(xlimits(1)) xlimits(2)])
                %            xlim([(xlimits(1)+gapdelay) xlimits(2)+gapdelay])
                %ylim(ylimits1(clust, :))
                ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
                %
                %             if gapdurs(gdindex)>0
                %                 line([0 0],[ylim],'color','m')
                %                 line([(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
                %             end
            end
        end
        
        xlabel('ms')
    else
    for clust=1:Nclusters
        figure
        for paindex=1:numpulseamps
            p=0;
            subplot1(numgapdurs,1)
            
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                
                if p==1
                    title(sprintf('%s-%s-%s, tetrode %s, cell %d, Green=Laser ON; Black=Laser OFF',expdate,session,filenum, channel, clust))
                end
                
                
                
                % plot off psth
                offset=0;
                yl=ylimits1(clust,:);
                inc=(yl(2))/max(max(max(nrepsOFF)));
                if ~isempty (mM1OFFtc)
                    
                    spiketimes1=mM1OFFtc(clust, gdindex,paindex).spiketimes;
                    %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                    X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                    [N, x]=hist(spiketimes1, X);
                    N=N./nrepsOFF(gdindex,paindex); % averaged across trials
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
                end
                
                for n=1:nrepsOFF(gdindex,paindex)
                    spiketimes2=M1OFFtc(clust, gdindex,paindex, n).spiketimes;
                    offset=offset+inc;
                    h=plot(spiketimes2-gapdelay, yl(2)+ones(size(spiketimes2))+offset, '.k');
                end
                
                
                % plot on psth
                if ~isempty (mM1ONtc)
                    spiketimes1=mM1ONtc(clust, gdindex,paindex).spiketimes;
                    %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                    X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                    [N, x]=hist(spiketimes1, X);
                    N=N./nrepsON(gdindex,paindex); % averaged across trials
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    bar(x-gapdelay, N,1,'facecolor','none','edgecolor',[0 .8 0]);
                end
                
                
                for n=1:nrepsON(gdindex,paindex)
                    spiketimes2=M1ONtc(clust, gdindex,paindex, n).spiketimes;
                    offset=offset+inc;
                    h=plot(spiketimes2-gapdelay, ylimits(2)+ones(size(spiketimes2))+offset, '.g');
                end
                
                %plot stim
                if(0)
                    %when we load the stim we should plot it here
                    stim=squeeze(mM1ONtcstim(gdindex, paindex,:));
                    stim=stim-median(stim(1:(length(stim))));
                    stim=stim./max(abs(stim));
                    
                    t=1:length(stim);
                    t=t/10;
                    t=t+xlimits(1)+gapdelay;
                    hold on; plot(t, (stim*(ylimmax/2)), 'm');
                end
                
                    if gapdurs(gdindex)>0
                line([0 0],[ylim],'color','m')
                line(-[(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
            end
                
                
                xlim([(xlimits(1)) xlimits(2)])
                %            xlim([(xlimits(1)+gapdelay) xlimits(2)+gapdelay])
                %ylim(ylimits1(clust, :))
                ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
                %
                %             if gapdurs(gdindex)>0
                %                 line([0 0],[ylim],'color','m')
                %                 line([(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
                %             end
            end
        end
        
        xlabel('ms')
    end %for clust
end %if plot rasters
end

% Plot OFF trials
if ~isempty(cell)
        clust=cell;
                figure
        for paindex=1:numpulseamps
            p=0;
            subplot1(numgapdurs,1)
            
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                
                if p==1
                    title(sprintf('%s-%s-%s, tetrode %s, cell %d, Green=Laser ON; Black=Laser OFF',expdate,session,filenum, channel, clust))
                end
                
                
                
                % plot off psth
                offset=0;
                yl=ylimits1(clust,:);
                inc=(yl(2))/max(max(max(nrepsOFF)));
                if ~isempty (mM1OFFtc)
                    
                    spiketimes1=mM1OFFtc(clust, gdindex,paindex).spiketimes;
                    %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                    X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                    [N, x]=hist(spiketimes1, X);
                    N=N./nrepsOFF(gdindex,paindex); % averaged across trials
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
                end
                
                for n=1:nrepsOFF(gdindex,paindex)
                    spiketimes2=M1OFFtc(clust, gdindex,paindex, n).spiketimes;
                    offset=offset+inc;
                    h=plot(spiketimes2-gapdelay, yl(2)+ones(size(spiketimes2))+offset, '.k');
                end
                
                
                %plot stim
                if(0)
                    %when we load the stim we should plot it here
                    stim=squeeze(mM1ONtcstim(gdindex, paindex,:));
                    stim=stim-median(stim(1:(length(stim))));
                    stim=stim./max(abs(stim));
                    
                    t=1:length(stim);
                    t=t/10;
                    t=t+xlimits(1)+gapdelay;
                    hold on; plot(t, (stim*(ylimmax/2)), 'm');
                end
                
                    if gapdurs(gdindex)>0
                line([0 0],[ylim],'color','m')
                line(-[(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
            end
                
                
                xlim([(xlimits(1)) xlimits(2)])
                %            xlim([(xlimits(1)+gapdelay) xlimits(2)+gapdelay])
                %ylim(ylimits1(clust, :))
                ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
                %
                %             if gapdurs(gdindex)>0
                %                 line([0 0],[ylim],'color','m')
                %                 line([(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
                %             end
            end
        end
        
        xlabel('ms')
    else
    for clust=1:Nclusters
        figure
        for paindex=1:numpulseamps
            p=0;
            subplot1(numgapdurs,1)
            
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                
                if p==1
                    title(sprintf('%s-%s-%s, tetrode %s, cell %d, Green=Laser ON; Black=Laser OFF',expdate,session,filenum, channel, clust))
                end
                
                
                
                % plot off psth
                offset=0;
                yl=ylimits1(clust,:);
                inc=(yl(2))/max(max(max(nrepsOFF)));
                if ~isempty (mM1OFFtc)
                    
                    spiketimes1=mM1OFFtc(clust, gdindex,paindex).spiketimes;
                    %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                    X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                    [N, x]=hist(spiketimes1, X);
                    N=N./nrepsOFF(gdindex,paindex); % averaged across trials
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
                end
                
                for n=1:nrepsOFF(gdindex,paindex)
                    spiketimes2=M1OFFtc(clust, gdindex,paindex, n).spiketimes;
                    offset=offset+inc;
                    h=plot(spiketimes2-gapdelay, yl(2)+ones(size(spiketimes2))+offset, '.k');
                end
                
                                
                %plot stim
                if(0)
                    %when we load the stim we should plot it here
                    stim=squeeze(mM1ONtcstim(gdindex, paindex,:));
                    stim=stim-median(stim(1:(length(stim))));
                    stim=stim./max(abs(stim));
                    
                    t=1:length(stim);
                    t=t/10;
                    t=t+xlimits(1)+gapdelay;
                    hold on; plot(t, (stim*(ylimmax/2)), 'm');
                end
                
                    if gapdurs(gdindex)>0
                line([0 0],[ylim],'color','m')
                line(-[(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
            end
                
                
                xlim([(xlimits(1)) xlimits(2)])
                %            xlim([(xlimits(1)+gapdelay) xlimits(2)+gapdelay])
                %ylim(ylimits1(clust, :))
                ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
                %
                %             if gapdurs(gdindex)>0
                %                 line([0 0],[ylim],'color','m')
                %                 line([(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
                %             end
            end
        end
        
        xlabel('ms')
    end %for clust
end %if plot rasters
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open .txt file for aldis

txtfilename=sprintf('ForAldis_ILGPIAS_psthOE-%s-%s-%s-%s.txt', expdate, session, filenum, channel);
godatadir(expdate, session, filenum);
fid=fopen(txtfilename, 'w'); %'a'=open or create file for writing; append data to end of file
fprintf(fid, '\n%s-%s-%s channel %s\n****************************',expdate,session,filenum, channel);
fprintf(fid, '\nBin Centers\n');
fprintf(fid, '\t%d',X-gapdelay);

for clust=1:Nclusters
    fprintf(fid, '\ncell %d of %d:\n\n', clust, Nclusters);
    
    if isempty (M1OFFtc)
        fprintf(fid, '\nOFF psth is empty\n');
    else
        for paindex=1:numpulseamps
            for gdindex=1:numgapdurs
                
                fprintf(fid, '\n\n%.0f ms Gap: Mean OFF Trials (%.0f)\n',gapdurs(gdindex),nrepsOFF(gdindex,paindex));
                
                for rep=1:nrepsOFF(gdindex,paindex)
                    fprintf(fid,'\n');
                    spiketimes1=M1OFFtc(clust, gdindex,paindex, rep).spiketimes;
                    [N, x]=hist(spiketimes1, X);
                    fprintf(fid,'\t%.0f', N);
                end
            end
        end
    end
    
    % ON
    if isempty (M1ONtc)
        fprintf(fid, '\nON psth is empty\n');
    else
        for paindex=1:numpulseamps
            for gdindex=1:numgapdurs
                
                fprintf(fid, '\n\n%.0f ms Gap: Mean ON Trials (%.0f)\n',gapdurs(gdindex),nrepsOFF(gdindex,paindex));
                
                for rep=1:nrepsON(gdindex,paindex)
                    fprintf(fid,'\n');
                    spiketimes1=M1ONtc(clust, gdindex,paindex, rep).spiketimes;
                    [N, x]=hist(spiketimes1, X);
                    fprintf(fid,'\t%.0f', N);
                end
            end
        end
    end
    %         % Mean ON
    %         for paindex=1:numpulseamps
    %             for gdindex=1:numgapdurs
    %
    %                 fprintf(fid, '\n%.0f ms Gap: Mean ON Trials (%.0f)\n',gapdurs(gdindex),nrepsON(gdindex,paindex));
    %
    %                 for rep=1:nrepsON(gdindex,paindex)
    %                     fprintf(fid,'\n');
    %                     spiketimes1=M1ONtc(gdindex,paindex, rep).spiketimes;
    %                     X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
    %                     [N, x]=hist(spiketimes1, X);
    %                     fprintf(fid,'\t%.0f', N);
    %                 end
    %
    %             end
    %         end
    
    
    fprintf(fid, '\n');
end
fprintf(fid, '\n');
fclose(fid);
fprintf('\nwrote psth bin values to text file %s', txtfilename);
fprintf('\n\n');


