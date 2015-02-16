function PlotGapInNoiseIL_psthOE(expdate,session,filenum,varargin)
% PlotGapInNoise_psth(expdate,session,filenum,tetrode,[xlimits],[ylimits],[binwidth], cell)
% originally written by AKH 7/29/13, modified to open ephys data by ira
% 10/22/14
dbstop if error
fs=12; % Fontsize for figures
global pref
if isempty(pref); Prefs; end

if nargin==0
    fprintf('\nNo input'); return;
elseif nargin==3
    prompt=('Please enter tetrode number: ');
    channel=input(prompt,'s') ;
    cell=[];
elseif nargin==4
    channel=varargin{1};
    cell=[];
elseif nargin==5
    channel=varargin{1};
    xlimits=varargin{2};
    cell=[];
elseif nargin==6
    channel=varargin{1};
    xlimits=varargin{2};
    ylimits=varargin{3};
    cell=[];
elseif nargin==7
    channel=varargin{1};
    xlimits=varargin{2};
    ylimits=varargin{3};
    binwidth=varargin{4};
    cell=[];
elseif nargin==8
    channel=varargin{1};
    xlimits=varargin{2};
    ylimits=varargin{3};
    binwidth=varargin{4};
    cell=varargin{5};
else
    fprintf('\nWrong number of arguments'); return;
end
% Defaults
if channel==[]; fprintf('No tetrode selected'); end
if ~exist('ylimits','var'); ylimits=-1; end
if isempty(ylimits); ylimits=-1; end
if ~exist('binwidth','var'); binwidth=5; end
if isempty(binwidth); binwidth=5; end
    if ~strcmp('char',class(channel))
        channel=num2str(channel);
    end
lostat=-1; % Discard data after this position (in samples), -1 to skip
fs=10; %fontsize

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    load(OEeventsfile); %Not smart enough to check for different
    %parameters. Reprocessing every time. AKH 7/14/14
    %not sure what the problem is - switching back. mw 7-24-20145
catch
    OEgetEvents(expdate, session, filenum);
    load(OEeventsfile)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
sorter='MClust';
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfilename=sprintf('out%sArch_Gap%s-%s-%s',channel, expdate, session, filenum);
if exist(outfilename,'file')
    outfile_exists=1;
else
    outfile_exists=0;
end

if ~outfile_exists
    j=0;
    
    for i=1:length(event)
        if strcmp(event(i).Type, 'gapinnoise')
            j=j+1;
            allsoas(j)=event(i).Param.duration-event(i).Param.pregap-event(i).Param.amplitude;
            allgapdurs(j)=event(i).Param.gapdur;
            allgapdelays(j)=event(i).Param.pregap;
            allnoiseamps(j)=event(i).Param.amplitude;
            duration(j)=event(i).Param.duration;
        end
    end
    gapdurs=unique(allgapdurs);
    soa=unique(allsoas);
    gapdelay=unique(allgapdelays);
    noiseamp=unique(allnoiseamps);
    pulseamp=unique(allnoiseamps);
    numpulseamps=length(pulseamp);
    numgapdurs=length(gapdurs);
    nreps=zeros(numgapdurs);
    
    duration=unique(duration);
else
    gapdurs=out.gapdurs;
    soa=out.soa;
    gapdelay=out.gapdelay;
    noiseamp=out.noiseamp;
    pulseamp=out.pulseamp;
    numpulseamps=out.numpulseamps;
    numgapdurs=out.numgapdurs;
    nreps=out.nreps;
    duration=out.duration;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('xlimits','var')
    fprintf('xlimits are specified');
    if isempty(xlimits); xlimits=[-50 max(duration)]; end
else
    xlimits=[-50 max(duration)];
end

M1ONp=[]; %all spiketimes by trial
mM1ONp=[]; %all spiketimes collapsed across trials
nrepsON=zeros(numgapdurs, numpulseamps);
M1spontON=[]; %spont spiketimes by trial
mM1spontON=[]; %spont spiketimes collapsed across trials
sM1spontON=[];%std dev of spont
semM1spontON=[];%s.e.m. of spont
M1OFFp=[];
mM1OFFp=[];
nrepsOFF=zeros(numgapdurs, numpulseamps);
M1spontOFF=[];
mM1spontOFF=[];
sM1spontOFF=[];
semM1spontOFF=[];
inRange=zeros(1, Nclusters);

% Extract into big matrix M
%if ~outfile_exists
for i=1:length(event)
    if isfield(event(i), 'soundcardtriggerPos')
        pos=event(i).soundcardtriggerPos/samprate;
    elseif isempty(pos) & ~isempty(event(i).Position)
        pos=event(i).Position;
        fprintf('\nWARNING! Missing a soundcard trigger. Using hardware trigger instead.')
        
    end
    
    start=(pos+xlimits(1)*1e-3); %in sec
    stop=(pos+xlimits(2)*1e-3); %in sec
    if start>0 %(disallow negative start times)
        %         if stop>lostat
        %             fprintf('\ndiscarding spikes')
        %         else
        aopulseon=event(i).Param.AOPulseOn;
        if strcmp(event(i).Type, 'gapinnoise')
            
            region=start:0.001:stop;
            for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                if isempty(find(region<0)) % Disallow negative start times
                    gapdur=event(i).Param.gapdur;
                    gdindex= find(gapdur==gapdurs);
                    pulseamp=event(i).Param.amplitude;
                    paindex= find(pulseamp==pulseamp);
                    st=spiketimes(clust).spiketimes;
                    spiketimes1=st(st>start & st<stop); % spiketimes in region
                    spikecount=length(spiketimes1); % No. of spikes fired in response to this rep of this stim.
                    inRange(clust)=inRange(clust)+ spikecount; %accumulate total spikecount in region
                    spiketimes1=(spiketimes1-pos)*1000;%covert to ms after tone onset
                    spont_spikecount=length(find(st<start & st>(start-(stop-start))));
                    % No. spikes in a region of same length preceding response window
                    nreps(gdindex, paindex)=nreps(gdindex, paindex)+1;
                    if aopulseon
                        if clust==1
                            nrepsON(gdindex, paindex)=nrepsON(gdindex, paindex)+1;
                        end
                        M1ONp(clust, gdindex, paindex, nrepsON(gdindex, paindex)).spiketimes=spiketimes1;
                        M1ONspikecounts(clust,gdindex, paindex, nrepsON(gdindex, paindex))=spikecount; % No. of spikes
                        M1spontON(clust,gdindex, paindex, nrepsON(gdindex, paindex))=spont_spikecount; % No. of spikes in spont window, for each presentation.
                        %M1stim(gdindex, paindex, nreps(gdindex, paindex),:)=stim(start:stop);
                    else
                        if clust==1
                            nrepsOFF(gdindex, paindex)=nrepsOFF(gdindex, paindex)+1;
                        end
                        M1OFFp(clust, gdindex, paindex, nrepsOFF(gdindex, paindex)).spiketimes=spiketimes1;
                        M1OFFspikecounts(clust,gdindex, paindex, nrepsOFF(gdindex, paindex))=spikecount; % No. of spikes
                        M1spontOFF(clust,gdindex, paindex, nrepsOFF(gdindex, paindex))=spont_spikecount; % No. of spikes in spont window, for each presentation.
                        %M1stim(gdindex, paindex, nreps(gdindex, paindex),:)=stim(start:stop);
                        
                    end
                end
            end
        end
        %         end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nmin num ON reps: %d\nmax num ON reps: %d', min(min(nrepsON)), max(max(nrepsON)))
fprintf('\nmin num OFF reps: %d\nmax num OFF reps: %d', min(min(nrepsOFF)), max(max(nrepsOFF)))

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Accumulate across trials
for paindex=1:numpulseamps
    for gdindex=1:numgapdurs
        for clust=1:Nclusters
            % on
            spiketimesON=[];
            spikecountsON=[];
            for rep=1:nrepsON(gdindex,paindex)
                spiketimesON=[spiketimesON M1ONp(clust,gdindex,paindex, rep).spiketimes];
            end
            mM1ONp(clust,gdindex,paindex).spiketimes=spiketimesON;
            
            %off
            spiketimesOFF=[];
            for rep=1:nrepsOFF(gdindex,paindex)
                spiketimesOFF=[spiketimesOFF M1OFFp(clust,gdindex,paindex, rep).spiketimes];
            end
            mM1OFFp(clust,gdindex,paindex).spiketimes=spiketimesOFF;
            
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylimmaxON=ylimits;
ylimmaxOFF=ylimits;
%find axis limits

if ylimits==-1
    for clust=1:Nclusters
        ylimmax=0.0001;
        for paindex=1:numpulseamps
            for gdindex=1:numgapdurs
                st1=mM1ONp(clust,gdindex,paindex).spiketimes;
                st2=mM1OFFp(clust,gdindex,paindex).spiketimes;
                X=(xlimits(1)+0):binwidth:(xlimits(2)+0); %specify bin centers
                [N1, x1]=hist(st1, X);
                [N2, x2]=hist(st2, X);
                N1=N1./nrepsON(gdindex,paindex); % averaged across trials
                N2=N2./nrepsON(gdindex,paindex); % averaged across trials
                ylimmaxON=max(ylimmaxON, max(N1));
                ylimmaxOFF=max(ylimmaxOFF,max(N2));
            end
            ylimmax=max(ylimmaxON, ylimmaxOFF);
            
            
        end
        ylimits1(clust,:)=[-.2 ylimmax];
    end
    
else
    for clust=1:Nclusters
        ylimits1(clust, :)=ylimits;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot ON only

if ~isempty(cell)
    clust=cell;
    sp1=[];
    figure;
    for paindex=1:numpulseamps
        p=0;
        subplot1(numgapdurs,1)
        for gdindex=1:numgapdurs
            p=p+1;
            subplot1(p)
            hold on
            if p==1
                title(sprintf('ON trials %s-%s-%s tetrode %s cell %d',expdate,session,filenum, channel, clust))
            end
            spiketimesON=mM1ONp(clust,gdindex,paindex).spiketimes;
            X=(xlimits(1)+0):binwidth:(xlimits(2)+0); %specify bin centers
            [NON, xON]=hist(spiketimesON, X);
            NON=NON./nrepsON(gdindex,paindex); % averaged across trials
            bON=bar(xON, NON,1);
            set(bON, 'facecolor',([51 204 0]/255), 'edgecolor', ([51 204 0]/255));
            line([0 gapdelay],[-.01 -.01],'color','m','linewidth',1.5)
            if gapdurs(gdindex)>0
                line([gapdelay+gapdurs(gdindex) max(duration)],[-.01 -.01],'color','m','linewidth',1.5) % Assuming a single duration.
            end
            yl=ylim;
            offset=yl(2);
            %plot rasters
            inc=ylimmax/50;
            sp=[];
            for n=1:nrepsON(gdindex,paindex)
                spiketimes2=M1ONp(clust,gdindex,paindex, n).spiketimes;
                h=plot(spiketimes2, offset+zeros(size(spiketimes2)), '.');
                offset=offset+inc;
                %                 set(h, 'markersize', 5)
                set(h,'Color','k');
                sp=[sp spiketimes2];
            end
            sp1=[sp1 sp];
            xlim([(xlimits(1)) xlimits(2)])
            %        ylim([-.2 (2*ylimmax)])
            yl=ylimits1(clust,:,:);
            yl(1)=yl(1)/10;
            yl(2)=yl(2)*2;
            ylim(yl);
            xlim(xlimits);
            ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
            
        end
    end
else
    for clust=1:Nclusters
        sp1=[];
        figure;
        for paindex=1:numpulseamps
            p=0;
            subplot1(numgapdurs,1)
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                if p==1
                    title(sprintf('ON trials %s-%s-%s tetrode %s cell %d',expdate,session,filenum, channel, clust))
                end
                spiketimesON=mM1ONp(clust,gdindex,paindex).spiketimes;
                X=(xlimits(1)+0):binwidth:(xlimits(2)+0); %specify bin centers
                [NON, xON]=hist(spiketimesON, X);
                NON=NON./nrepsON(gdindex,paindex); % averaged across trials
                bON=bar(xON, NON,1);
                set(bON, 'facecolor',([51 204 0]/255), 'edgecolor', ([51 204 0]/255));
                line([0 gapdelay],[-.01 -.01],'color','m','linewidth',1.5)
                if gapdurs(gdindex)>0
                    line([gapdelay+gapdurs(gdindex) max(duration)],[-.01 -.01],'color','m','linewidth',1.5) % Assuming a single duration.
                end
                
                yl=ylim;
                offset=yl(2);
                %plot rasters
                inc=ylimmax/50;
                sp=[];
                for n=1:nrepsON(gdindex,paindex)
                    spiketimes2=M1ONp(clust,gdindex,paindex, n).spiketimes;
                    h=plot(spiketimes2, offset+zeros(size(spiketimes2)), '.');
                    offset=offset+inc;
                    %                 set(h, 'markersize', 5)
                    set(h,'Color','k');
                    sp=[sp spiketimes2];
                end
                sp1=[sp1 sp];
                xlim([(xlimits(1)) xlimits(2)])
                %        ylim([-.2 (2*ylimmax)])
                yl=ylimits1(clust,:,:);
                yl(1)=yl(1)/10;
                yl(2)=yl(2)*2;
                ylim(yl);
                xlim(xlimits);
                ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
                
            end
        end
        
    end
    xlabel('ms')
end
set(gcf, 'pos', [618    72      520   900]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot OFF only

if ~isempty(cell)
    clust=cell;
    sp1=[];
    figure;
    for paindex=1:numpulseamps
        p=0;
        subplot1(numgapdurs,1)
        for gdindex=1:numgapdurs
            p=p+1;
            subplot1(p)
            hold on
            if p==1
                title(sprintf('OFF trials %s-%s-%s tetrode %s cell %d',expdate,session,filenum, channel,clust))
            end
            spiketimesOFF=mM1OFFp(clust,gdindex,paindex).spiketimes;
            X=(xlimits(1)+0):binwidth:(xlimits(2)+0); %specify bin centers
            [NOFF, xOFF]=hist(spiketimesOFF, X);
            NOFF=NOFF./nrepsOFF(gdindex,paindex); % averaged across trials
            bOFF=bar(xOFF, NOFF,1);
            set(bOFF, 'facecolor','none', 'edgecolor', [0 0 0]);
            line([0 gapdelay],[-.01 -.01],'color','m','linewidth',1.5)
            if gapdurs(gdindex)>0
                line([gapdelay+gapdurs(gdindex) max(duration)],[-.01 -.01],'color','m','linewidth',1.5) % Assuming a single duration.
            end
            yl=ylim;
            offset=yl(2);
            %plot rasters
            inc=ylimmax/10;
            sp=[];
            for n=1:nrepsOFF(gdindex,paindex)
                spiketimes2=M1OFFp(clust,gdindex,paindex, n).spiketimes;
                h=plot(spiketimes2, offset+zeros(size(spiketimes2)), '.');
                offset=offset+inc;
                sp=[sp spiketimes2];
                %                 set(h, 'markersize', 5)
                set(h,'Color','k');
            end
            sp1=[sp1 sp];
            xlim([(xlimits(1)) xlimits(2)])
            %        ylim([-.2 (2*ylimmax)])
            yl=ylimits1(clust,:,:);
            yl(1)=yl(1)/10;
            yl(2)=yl(2)*2;
            ylim(yl);
            xlim(xlimits);
            ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
            
        end
    end
else
    for clust=1:Nclusters
        sp1=[];
        figure;
        for paindex=1:numpulseamps
            p=0;
            subplot1(numgapdurs,1)
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                if p==1
                    title(sprintf('OFF trials %s-%s-%s tetrode %s cell %d',expdate,session,filenum, channel,clust))
                end
                spiketimesOFF=mM1OFFp(clust,gdindex,paindex).spiketimes;
                X=(xlimits(1)+0):binwidth:(xlimits(2)+0); %specify bin centers
                [NOFF, xOFF]=hist(spiketimesOFF, X);
                NOFF=NOFF./nrepsOFF(gdindex,paindex); % averaged across trials
                bOFF=bar(xOFF, NOFF,1);
                set(bOFF, 'facecolor','none', 'edgecolor', [0 0 0]);
                line([0 gapdelay],[-.01 -.01],'color','m','linewidth',1.5)
                if gapdurs(gdindex)>0
                    line([gapdelay+gapdurs(gdindex) max(duration)],[-.01 -.01],'color','m','linewidth',1.5) % Assuming a single duration.
                end
                yl=ylim;
                offset=yl(2);
                %plot rasters
                inc=ylimmax/50;
                sp=[];
                for n=1:nrepsOFF(gdindex,paindex)
                    spiketimes2=M1OFFp(clust,gdindex,paindex, n).spiketimes;
                    h=plot(spiketimes2, offset+zeros(size(spiketimes2)), '.');
                    offset=offset+inc;
                    sp=[sp spiketimes2];
                    %                 set(h, 'markersize', 5)
                    set(h,'Color','k');
                end
                sp1=[sp1 sp];
                xlim([(xlimits(1)) xlimits(2)])
                yl=ylimits1(clust,:,:);
                yl(1)=yl(1)/10;
                yl(2)=yl(2)*2;
                ylim(yl);
                xlim(xlimits);
                ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
                
            end
        end
        
    end
end
set(gcf, 'pos', [618    72      520   900]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %plot stimulus as a sanity check
% if(0)
%     figure
%     for paindex=1:numpulseamps
%         p=0;
%         subplot1(numgapdurs,1)
%         for gdindex=1:numgapdurs
%             p=p+1;
%             subplot1(p)
%             hold on
%             if p==1
%                 title(sprintf('%s-%s-%s',expdate,session,filenum))
%             end
%             spiketimes1=mM1(gdindex,paindex).spiketimes;
%             X=(xlimits(1)+0):binwidth:(xlimits(2)+0); %specify bin centers
%             [N, x]=hist(spiketimes1, X);
%             N=N./nreps(gdindex,paindex); % averaged across trials
%             bar(x, N,1,'facecolor',[0 0 0]);
%             line([ 0 gapdelay ],[-.1 -.1],'color','g','linewidth',1.5)
%             if gapdurs(gdindex)>0
%                 line([gapdelay+gapdurs(gdindex) max(duration)],[-.1 -.1],'color','m','linewidth',1.5) % Assuming a single duration.
%             end
%             xlim([(xlimits(1)) xlimits(2)])
%             ylim([-.2 (1.1*ylimmax)])
%             ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
%             stimtrace=squeeze(M1stim(gdindex, paindex, nreps(gdindex, paindex),:));
%             stimtrace=.1*diff(ylim)*stimtrace./max(abs(stimtrace));
%             t=1:length(stimtrace);
%             t=t/10;t=t+xlimits(1);
%             plot(t, stimtrace, 'r')
%         end
%     end
%
%     xlabel('ms')
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SAVE AN OUTFILE
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.M1OFFp=M1OFFp; % All spiketimes, trial-by-trial.
out.M1ONp=M1ONp;
out.mM1OFFp=mM1OFFp; % Accumulated spike times for *all* presentations of each laser/f/a combo.
out.mM1ONp=mM1ONp;
out.gapdurs=gapdurs;
out.soa=soa;
out.gapdelay=gapdelay;
out.noiseamp=noiseamp;
out.pulseamp=pulseamp;
out.numpulseamps=numpulseamps;
out.numgapdurs=numgapdurs;
out.nreps=nreps;
out.duration=duration;
out.oepathname=oepathname;
out.OEdatafile=OEdatafile;
out.xlimits=xlimits;
out.NClusters=Nclusters;

godatadir(expdate,session,filenum);
save (outfilename, 'out')
fprintf('\n Saved to %s.\n', outfilename)
fprintf('\n\n')


end