function PlotBinTC_ILD_laser(expdate,session,filenum,varargin)

% extracts spikes from Vm/ECspikes and plots psth
%
% defaults:
% thresh=7 std; To use absolute threshold (in mV) pass [-1 mV] as the thresh argument,
%               where mV is the desired threshold
% xlimits=[0 100] ms
% ylimits autoscaled
% binwidth=5 ms
% monitor=1 (spike threshold plot is turned on, 0=off)
%
% usage: PlotBinTC_ILD_laser('expdate','session','filenum',[thresh],[xlimits],[ylimits],binwidth,monitor)

% created using PlotBinTC_ILD and PlotILArch
% mak 13Aug2012
% latest updates:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
global pref
if isempty(pref); Prefs; end
username=pref.username;
samprate=1e4;

trials=[];
trials_specified=0;

fs=10; %fontsize for figures
refract=15;

if nargin==0
    fprintf('\nno input'); return;
elseif nargin==3
elseif nargin==4
    nstd=varargin{1};
elseif nargin==5
    nstd=varargin{1};
    xlimits=varargin{2};
elseif nargin==6
    nstd=varargin{1};
    xlimits=varargin{2};
    ylimits=varargin{3};
elseif nargin==7
    nstd=varargin{1};
    xlimits=varargin{2};
    ylimits=varargin{3};
    binwidth=varargin{4};
elseif nargin==8
    nstd=varargin{1};
    xlimits=varargin{2};
    ylimits=varargin{3};
    binwidth=varargin{4};
    monitor=varargin{5};
else
    fprintf('\nwrong number of arguments'); return;
end
if ~exist('nstd','var'); nstd=7; end
if isempty(nstd); nstd=7; end
if ~exist('xlimits','var'); xlimits=[0 100]; end
if isempty(xlimits); xlimits=[0 100]; end
if ~exist('ylimits','var'); ylimits=-1; end
if isempty(ylimits); ylimits=-1; end
if ~exist('binwidth','var'); binwidth=5; end
if isempty(binwidth); binwidth=5; end
if ~exist('monitor','var'); monitor=1; end
if isempty(monitor); monitor=1; end

fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));

[D E S D2]=gogetdata(expdate,session,filenum);
event=E.event;
if isempty(event); fprintf('\nno tones\n'); return; end
stim1=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace)+D.nativeOffset;
scaledtrace2=[];
try scaledtrace2=D2.nativeScaling*double(D2.trace) +D2.nativeOffset; end %#ok
clear D E S D2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lostat1=-1; %discard data after this position (in samples), -1 to skip
if     strcmp(username,'mak') && strcmp(expdate,'081712') && strcmp(session,'002') && strcmp(filenum,'001') %noted in cell_list
    lostat1=3350000;
    % elseif strcmp(username,'username') && strcmp(expdate,'expdate') && strcmp(session,'session') && strcmp(filenum,'filenum') %noted?
    %     lostat1=e6;
end
lostin1=-1; %discard data before this position (in samples), -1 to skip
%find this value the same way you would for lostat1 mak 19Jan2012

if lostat1==-1; lostat1=length(scaledtrace); end
if lostin1==-1; lostin1=0; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first plot the AO pulses, same as PlotAOPulse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wb=waitbar(0,'computing tuning curve (aopulses)...');

%get laser durs
j=0;
alldurs=nan(1,length(event));
for i=1:length(event)
    if strcmp(event(i).Type, 'aopulse')
        j=j+1;
        alldurs(j)=event(i).Param.width;
    end
end
durs=unique(alldurs(~isnan(alldurs))); %laser dur
numdurs=length(durs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first plot the AO pulses, same as PlotAOPulse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%extract the traces into a big matrix M
M1=[];
nreps=zeros(numdurs);
laserstart=[];

%get laser durs
j=0;
cont=1;
for i=1:length(event)
% for i=1:length(event)-1 %temp mk 20aug2012
    waitbar(i/length(event), wb);
    if cont
        if strcmp(event(i).Type, 'aopulse')
            
            pos=event(i).Position_rising;
            start=(pos+xlimits(1)*1e-3*samprate);
            stop=(pos+xlimits(2)*1e-3*samprate)-1;
            region=start:stop;
            if isempty(find(region<0)) % disallow negative start times
                if stop>lostat1
                    fprintf('\ndiscarding trace')
                else
                    j=j+1;
                    alldurs(j)=event(i).Param.width;
                    %laserstart=[laserstart (event(i+1).soundcardtriggerPos - event(i).Position)/10];
                    %now that we use the module ppalaser, this is
                    %unnecessary
                    dur=event(i).Param.width;
                    dindex= find(durs==dur);
                    nreps(dindex)=nreps(dindex)+1;
                    M1(dindex, nreps(dindex),:)=scaledtrace(region);
                    if ~isempty(scaledtrace2)
                        M2(dindex, nreps(dindex),:)=scaledtrace2(region);
                    end
                    M1stim(dindex, nreps(dindex),:)=stim1(region);
                end
                if ~isempty(trials)
                    if max(nreps)>max(trials)
                        cont=0; % stop extracting
                        fprintf('\nstopped computing after %d trials', max(nreps))
                    end
                end
            end
            
        end
    end
end
% laserbegin=round(mean(laserstart));
close(wb)

if ~isempty(trials)
    fprintf('\n using only traces %d-%d, discarding others', trials(1), trials(end));
    mM1=mean(M1(:,trials,:), 2);
    if ~isempty(scaledtrace2)
        mM2=mean(M2(:,trials,:), 2);
    end
    mM1stim=mean(M1stim(:,trials,:), 2);
else
    for dindex=1:numdurs
        mM1(dindex,:)=mean(M1(dindex, 1:nreps(dindex),:), 2);
        if ~isempty(scaledtrace2)
            mM2(dindex,:)=mean(M2(dindex, 1:nreps(dindex),:), 2);
        end
        mM1stim(dindex,:)=mean(M1stim(dindex, 1:nreps(dindex),:), 2);
    end
end

if ~isempty(trials)
    trialstring=sprintf('%d-%d', trials(1), trials(end));
else
    trials=1:min(min(min(min(nreps))));
    trialstring=sprintf(' all trials (%d-%d)', trials(1), trials(end));
end

labtools
cell_list_exists=0; % loads in this cell's data from cell_list_Binaural.m
if exist('cell_list_Binaural_Arch.m','file')==2
    try
        celldata=cell_list_Binaural_Reader(expdate,session,filenum);
        earpiececheck_notes=celldata.earpiececheck_notes;
        age=celldata.age;
        mass=celldata.mass;
        a1=celldata.a1;
        depth=celldata.depth;
        CF=celldata.CF;
        notes=celldata.notes;
        keep=celldata.keep;
        bintype=celldata.bintype;
        if isfield(celldata,'inorm')
            inorm=celldata.inorm;
        end
        cell_list_exists=1;
    end
end

% I'd like to bypass the filtering step here if the outfile exists
% But, I'll need to ensure that command line inputs are used as well as any new lostat1
% maybe later...
outfilename=sprintf('out%s-%s-%s.mat', expdate,session,filenum);
% if ~exist(outfilename,'file')
high_pass_cutoff=300; %Hz
% fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace=filtfilt(b,a,scaledtrace);
if length(nstd)==2
    if nstd(1)==-1
        thresh=nstd(2);
        fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh, thresh/std(filteredtrace));
    end
else
    thresh=nstd*std(filteredtrace);
    fprintf('\nusing spike detection threshold of %.1f mV (%g sd)', thresh, nstd);
end

% fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
try dspikes=[spikes(1) dspikes'];
catch %#ok
    dspikes=0;
end
% else
%     load(outfilename)
% end

% Plots entire file with nstd (green) and shows where spikes were counted (red)
if monitor
    figure
    plot(filteredtrace, 'b')
    hold on
    plot(thresh+zeros(size(filteredtrace)), 'm--')
    plot(spikes, thresh*ones(size(spikes)), 'g*')
    plot(dspikes, thresh*ones(size(dspikes)), 'r*')
    L1=line(xlim, thresh*[1 1]);
    L2=line(xlim, thresh*[-1 -1]);
    set([L1 L2], 'color', 'g');
    if lostat1~=length(scaledtrace)
        line([lostat1 lostat1],ylim,'linewidth',2,'linestyle',':','color','k')
    end
    if lostin1~=length(scaledtrace)
        line([lostin1 lostin1],ylim,'linewidth',2,'linestyle',':','color','k')
    end
    title(sprintf('%s-%s-%s-%s',expdate,username,session,filenum));
    %pause(.5)
    %close
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the tuning curve, same as PlotBinTC_ILD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wb=waitbar(0,'computing tuning curve (sounds)...');

% t=1:length(scaledtrace);
% t=1000*t/samprate;

%get freqs/Ramps/Lamps/durs
allRamps=zeros(1,length(event)); %these 4 pre-alls save 2.2ms
allLamps=zeros(1,length(event));
alldurs=zeros(1,length(event));
allfreqs=zeros(1,length(event));
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'bintone') || strcmp(event(i).Type, 'binwhitenoise')
        j=j+1;
        allRamps(j)=event(i).Param.Ramplitude;
        allLamps(j)=event(i).Param.Lamplitude;
        alldurs(j)=event(i).Param.duration;
        if strcmp(event(i).Type, 'bintone')
            allfreqs(j)=event(i).Param.frequency;
        elseif strcmp(event(i).Type, 'binwhitenoise')
            allfreqs(j)=-1;
        end
        
    end
end

freqs=unique(allfreqs(1:j)); %trim pre-allocated variables to actual sizes
Ramps=unique(allRamps(1:j));
Lamps=unique(allLamps(1:j));
try plotcriteria=mean(Lamps==Ramps);
    if plotcriteria~=1
        error('There must be at least 1 rep for all stimuli in order to plot these data')
    end
catch
    error('There must be at least 1 rep for all stimuli in order to plot these data')
end

durs=unique(alldurs(1:j));
numfreqs=length(freqs);
numamps=length(Ramps);
numdurs=length(durs);
M1ONtc=[];
M2ONtc=[];
M1ONtcstim=[];
mM1ONtc=[];
mM2ONtc=[];
mM1ONtcstim=[];
M1OFFtc=[];
M2OFFtc=[];
M1OFFtcstim=[];
mM1OFFtc=[];
mM2OFFtc=[];
mM1OFFtcstim=[];
nrepsON=zeros(numfreqs, numamps, numamps, numdurs);
nrepsOFF=zeros(numfreqs, numamps, numamps, numdurs);
M1OFFpre=[];
M1ONpre=[];
% M1=[];
% nreps=zeros(numfreqs, numamps, numamps, numdurs);
%extract the traces into a big matrix M
for i=1:length(event)
    waitbar( i/length(event), wb);
    if strcmp(event(i).Type,'bintone') || strcmp(event(i).Type,'binwhitenoise')
        if isfield(event(i),'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos) && ~isempty(event(i).Position_rising)
                pos=event(i).Position_rising;
            end
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        % Inserted the three lines below to count spikes in the same sized window before
        % stim onset. start must be == 0 to work & stop should be <= half of the isi.
        % This code could be brittle. mak 16june2011
        if xlimits(1) == 0 && xlimits(2) <= 0.5*(event(i).Param.next)
            start1=(pos+(-xlimits(2))*1e-3*samprate);
            stop1=(pos+xlimits(1)*1e-3*samprate)-1;
            % region1=start1:stop1; % this could be unnecessary
        else
            % warning('spikes in the pre-xlim window aren''t counted, because xlimit(1)~=0');
        end
        if isempty(find(region<0,1)) %(disallow negative start times)
            if stop>lostat1
                fprintf('\ndiscarding trace')
            elseif start<lostin1
                fprintf('\ndiscarding trace')
            else
                if strcmp(event(i).Type, 'bintone')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.duration;
                elseif strcmp(event(i).Type, 'binwhitenoise')
                    dur=event(i).Param.duration;
                    freq=-1;
                end
                aopulseon=event(i).Param.AOPulseOn;
                Ramp=event(i).Param.Ramplitude;
                Lamp=event(i).Param.Lamplitude;
                findex= find(freqs==freq);
                Raindex= find(Ramps==Ramp);
                Laindex= find(Lamps==Lamp);
                dindex= find(durs==dur);
                
                spiketimes1=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
                spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
                
                if aopulseon
                    nrepsON(findex, Raindex, Laindex, dindex) = nrepsON(findex, Raindex, Laindex, dindex)+1;
                    M1ONtc(findex, Raindex, Laindex, dindex, nrepsON(findex, Raindex, Laindex, dindex)).spiketimes=spiketimes1;
                    M1ONtcstim(findex ,Raindex, Laindex, dindex, nrepsON(findex, Raindex, Laindex, dindex),:)=stim1(region);
                else
                    nrepsOFF(findex, Raindex, Laindex, dindex) = nrepsOFF(findex, Raindex, Laindex, dindex)+1;
                    M1OFFtc(findex, Raindex, Laindex, dindex, nrepsOFF(findex, Raindex, Laindex, dindex)).spiketimes=spiketimes1;
                    M1OFFtcstim(findex, Raindex, Laindex, dindex, nrepsOFF(findex, Raindex, Laindex, dindex),:)=stim1(region);
                end
                
                % The 3 lines below find all the spikes in the prespike window (mak 16june2011)
                if xlimits(1) == 0 && xlimits(2) <= 0.5*(event(i).Param.next)
                    pre_xlim_flag=1;
                    spiketimes1pre=dspikes(dspikes>start1 & dspikes<stop1); % spiketimes in same sized region window, before stim onset
                    spiketimes1pre=(spiketimes1pre-pos)*1000/samprate; %covert to ms after tone onset
                    if aopulseon
                        M1ONpre(findex, Raindex, Laindex,dindex, nrepsON(findex, Raindex, Laindex, dindex)).pre_spiketimes=spiketimes1pre;
                    else
                        M1OFFpre(findex, Raindex, Laindex,dindex, nrepsOFF(findex, Raindex, Laindex, dindex)).pre_spiketimes=spiketimes1pre;
                    end
                else
%                     warning('xlimits(1) < 0 ')
                    pre_xlim_flag=0;
                end
            end
        end
    end
end
close(wb)

ntrialsON=sum(sum(squeeze(nrepsON)));
nrepsmaxON=max(unique(nrepsON));
nrepsminON=min(unique(nrepsON));
ntrialsOFF=sum(sum(squeeze(nrepsOFF)));
nrepsmaxOFF=max(unique(nrepsOFF));
nrepsminOFF=min(unique(nrepsOFF));

monoflag=0;
if max(unique(nreps(:,2:end,2:end,:)))==0 %determine whether this is a mono BinTC
    monoflag=1;
end
if length(unique(nrepsON))~=2 || length(unique(nrepsOFF))~=2
    fprintf('\n');
    warning('There are more than 2 unique nreps')
    disp(unique(nrepsON));
    disp(unique(nrepsOFF));
    % If all stimuli were played there should be 0 and the nreps specified by
    % MakeBinTC_ILD_Protocol (typically 10)
end
% nreps0=nreps(1, 1, 1, 1);
% totreps=sum(sum(nreps))-nreps0;
fprintf('\nnrepsON -- min: %d; max: %d',nrepsminON,nrepsmaxON)
fprintf('\nnrepsOFF -- min: %d; max: %d',nrepsminOFF,nrepsmaxOFF)
if dspikes==0
    ds=dspikes;
else
    ds=length(dspikes);
end

%accumulate spike times across trials
spiketimesipsiON=[];
pre_spiketimesipsiON=[];
spiketimescontraON=[];
pre_spiketimescontraON=[];
spiketimesipsiOFF=[];
pre_spiketimesipsiOFF=[];
spiketimescontraOFF=[];
pre_spiketimescontraOFF=[];
spiketimesbinON=[];
pre_spiketimesbinON=[];
spiketimesbinOFF=[];
pre_spiketimesbinOFF=[];

counterON=0;
counter_preON=0;
spiketimes2ON=[];
pre_spiketimes2ON=[];
counterOFF=0;
counter_preOFF=0;
spiketimes2OFF=[];
pre_spiketimes2OFF=[];
for dindex=1:numdurs
    for Raindex=1:numamps
        for Laindex=1:numamps
            for findex=1:numfreqs
                spiketimes1ON=[];
                pre_spiketimes1ON=[];
                for rep=1:nrepsON(findex, Raindex, Laindex, dindex)
                    spiketimes1ON=[spiketimes1ON M1ONtc(findex, Raindex, Laindex, dindex, rep).spiketimes];
                    try pre_spiketimes1ON=[pre_spiketimes1ON M1ONpre(findex, Raindex, Laindex, dindex, rep).pre_spiketimes]; end
                end
                spiketimes1OFF=[];
                pre_spiketimes1OFF=[];
                for rep=1:nrepsOFF(findex, Raindex, Laindex, dindex)
                    spiketimes1OFF=[spiketimes1OFF M1OFFtc(findex, Raindex, Laindex, dindex, rep).spiketimes];
                    try pre_spiketimes1OFF=[pre_spiketimes1OFF M1OFFpre(findex, Raindex, Laindex, dindex, rep).pre_spiketimes]; end
                end
                
                if Laindex~=1 && Raindex==1
                    spiketimesipsiON=[spiketimesipsiON spiketimes1ON];
                    try pre_spiketimesipsiON=[pre_spiketimesipsiON pre_spiketimes1ON]; end
                    spiketimesipsiOFF=[spiketimesipsiOFF spiketimes1OFF];
                    try pre_spiketimesipsiOFF=[pre_spiketimesipsiOFF pre_spiketimes1OFF]; end
                end
                if Laindex==1 && Raindex~=1
                    spiketimescontraON=[spiketimescontraON spiketimes1ON];
                    try pre_spiketimescontraON=[pre_spiketimescontraON pre_spiketimes1ON]; end
                    spiketimescontraOFF=[spiketimescontraOFF spiketimes1OFF];
                    try pre_spiketimescontraOFF=[pre_spiketimescontraOFF pre_spiketimes1OFF]; end
                end
                if ~(Laindex==1 || Raindex==1)
                    spiketimesbinON=[spiketimesbinON spiketimes1ON];
                    try pre_spiketimesbinON=[pre_spiketimesbinON pre_spiketimes1ON]; end
                    spiketimesbinOFF=[spiketimesbinOFF spiketimes1OFF];
                    try pre_spiketimesbinOFF=[pre_spiketimesbinOFF pre_spiketimes1OFF]; end
                end
                
                if ~(Raindex==1 && Laindex==1)
                    counterON=counterON+length(spiketimes1ON);
                    spiketimes2ON=[spiketimes2ON spiketimes1ON];
                    counter_preON=counter_preON+length(pre_spiketimes1ON);
                    pre_spiketimes2ON=[pre_spiketimes2ON pre_spiketimes1ON];
                    mM1ONtc(findex, Raindex, Laindex, dindex).spiketimes=spiketimes1ON;
                    mM1ONtc(findex, Raindex, Laindex, dindex).pre_spiketimes=pre_spiketimes1ON;
                    
                    counterOFF=counterOFF+length(spiketimes1OFF);
                    spiketimes2OFF=[spiketimes2OFF spiketimes1OFF];
                    counter_preOFF=counter_preOFF+length(pre_spiketimes1OFF);
                    pre_spiketimes2OFF=[pre_spiketimes2OFF pre_spiketimes1OFF];
                    mM1OFFtc(findex, Raindex, Laindex, dindex).spiketimes=spiketimes1OFF;
                    mM1OFFtc(findex, Raindex, Laindex, dindex).pre_spiketimes=pre_spiketimes1OFF;
                end
            end
        end
    end
end

% numbins=diff(xlimits)/binwidth;
% dindex=1;

%find optimal y-axis limits if unspecified
if ylimits==-1
    ylimits=[-1 0];
    for Raindex=numamps:-1:1
        for Laindex=numamps:-1:1
            for findex=1:numfreqs
                spiketimes=mM1ONtc(findex, Raindex, Laindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(spiketimes, X);
                ylimits(2)=max(ylimits(2), max(N));
                
                spiketimes=mM1OFFtc(findex, Raindex, Laindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(spiketimes, X);
                ylimits(2)=max(ylimits(2), max(N));
            end
        end
    end
end
ylimits(2)=ylimits(2)-rem(ylimits(2),5)+5;

ipsispikesxlimON=length(spiketimesipsiON);
pre_ipsispikesxlimON=length(pre_spiketimesipsiON);
contraspikesxlimON=length(spiketimescontraON);
pre_contraspikesxlimON=length(pre_spiketimescontraON);
binspikesxlimON=length(spiketimesbinON);
pre_binspikesxlimON=length(pre_spiketimesbinON);
dspikesxlimON=length(spiketimes2ON);
pre_dspikesxlimON=length(pre_spiketimes2ON);

ipsispikesxlimOFF=length(spiketimesipsiOFF);
pre_ipsispikesxlimOFF=length(pre_spiketimesipsiOFF);
contraspikesxlimOFF=length(spiketimescontraOFF);
pre_contraspikesxlimOFF=length(pre_spiketimescontraOFF);
binspikesxlimOFF=length(spiketimesbinOFF);
pre_binspikesxlimOFF=length(pre_spiketimesbinOFF);
dspikesxlimOFF=length(spiketimes2OFF);
pre_dspikesxlimOFF=length(pre_spiketimes2OFF);


filelength=length(scaledtrace);
spikerateFF=(ds/filelength)*samprate; %spikerate for the full file

spikerateRWON=(dspikesxlimON*1000)/(diff(xlimits)*ntrialsON); %spikerate for the response window only
spikerateRW_preON=(pre_dspikesxlimON*1000)/(diff(xlimits)*ntrialsON); %spikerate for the response window only
spikerateNonRWON=((ds-dspikesxlimON)*1000)/((filelength*0.1)-(ntrialsON*diff(xlimits))); %spikerate for the full file minus the response window

spikerateRWOFF=(dspikesxlimOFF*1000)/(diff(xlimits)*ntrialsOFF); %spikerate for the response window only
spikerateRW_preOFF=(pre_dspikesxlimOFF*1000)/(diff(xlimits)*ntrialsOFF); %spikerate for the response window only
spikerateNonRWOFF=((ds-dspikesxlimOFF)*1000)/((filelength*0.1)-(ntrialsOFF*diff(xlimits))); %spikerate for the full file minus the response window

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\nProcessing and loading data = %.1f seconds\n',toc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot laser ON
if ~monoflag % binaural and mono stim 
    ILDs=-40:10:40;
    ABLs=fliplr(max(Ramps)-20:-5:15);
    MonoAmps=Ramps(find(nrepsON(1,:,1)~=0)); %same for either L or R
    rows=length(MonoAmps)*2;
    columns=length(ILDs)+2+2; % +2 mono, +2 spaces on either side of bin
    
    for dindex=1:numdurs
        for findex=1:numfreqs
            figure
            subplot1(rows,columns)
            h=get(gcf, 'children');
            axis(h, 'off')
            
            %note: don't use aindex=1 (-1000 dB) since ABL/ILD undefined for monaural sounds
            for Raindex=numamps:-1:2
                for Laindex=2:numamps
                    ABL=mean([Ramps(Raindex) Lamps(Laindex)]);
                    ILD=(Ramps(Raindex) - Lamps(Laindex));
                    if sum(ABLs==ABL)==1 && sum(ILDs==ILD)
                        ILDindex=ILD==ILDs;
                        
                        ABLindex=ABL==ABLs;
                        ILDpos=0:length(ILDs)-1;
                        ABLpos=fliplr(3:columns*2:columns*2*length(ABLs));
                        toppos=(ABLpos(ABLindex)+ILDpos(ILDindex))+columns*2;
                        totalpos=[toppos toppos+columns];
                        subplot(rows,columns,totalpos);
                        spiketimes7=mM1ONtc(findex, Raindex, Laindex, dindex).spiketimes;
                        
                        %use this code to plot histograms
                        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                        hist(spiketimes7, X);
                        ylim(ylimits)
                        xlim(xlimits)
                        line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                        line(xlimits, [0 0], 'color', 'k')
                        
                        % set up axis labels
                        file_name=sprintf('%s-%s-%s-%s',expdate,username,session,filenum);
                        if freq(findex)==-1
                            tone='WN';
                        else
                            tone=num2str(freq(findex));
                        end
                        if ABLindex(end) && ILDindex(ceil(length(ILDs)/2))
                            title(sprintf('%s, %s (%d ms)\nLaser ON\nInteraural Level Difference (dB)\n\n%d',file_name,tone,durs(dindex),ILD))
                        elseif ABLindex(end)
                            title(sprintf('%d',ILD))
                        end
                        if ILDindex(1) && ABLindex(ceil(length(ABLindex)/2))
                            text(xlimits(1)-50,mean(ylimits),sprintf('Average Binaural Level (dB)\n%d',ABL),'rotation',90,'horizontalalignment','center')
                        elseif ILDindex(1)
                            text(xlimits(1)-50,mean(ylimits),sprintf('\n%d',ABL),'rotation',90)
                        end
                        set(gca, 'fontsize', fs)
                        axis off
                    end
                end
            end
            
            % Now add in the Ipsi ear
            ipsiindex=(rows-2)*columns+1:-columns*2:1;
            for Raindex=1
                for Laindex=numamps:-2:2
                    Lmono=floor(Laindex/2); %only actually use every other Lamp
                    subplot(rows,columns,[ipsiindex(Lmono) ipsiindex(Lmono)+columns]);
                    spiketimes8=mM1ONtc(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes8, X);
                    ylim(ylimits)
                    xlim(xlimits)
                    line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    
                    set(gca, 'fontsize', fs)
                    ylabel(sprintf('%d',Lamps(Laindex)))
                    if Lmono==round(numamps/4)
                        text(xlimits(1)-50,mean(ylimits),sprintf('Mono Amplitudes (dB SPL)\n%d',Lamps(Laindex)),'rotation',90,'horizontalalignment','center')
                    else
                        text(xlimits(1)-50,mean(ylimits),sprintf('\n%d',Lamps(Laindex)),'rotation',90)
                    end
                    if Lmono==floor(numamps/2)
                        title(sprintf('Ipsi (L mono)'))
                    end
                    axis off
                end
            end
            
            % Now add in the Contra ear
            conindex=columns*(rows-1):-columns*2:columns;
            for Raindex=numamps:-2:2
                for Laindex=1
                    Rmono=floor(Raindex/2); %only actually use every other Ramp
                    subplot(rows,columns,[ipsiindex(Lmono) ipsiindex(Lmono)+columns]);
                    subplot(rows,columns,[conindex(Rmono) conindex(Rmono)+columns]);
                    spiketimes9=mM1ONtc(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes9, X);
                    ylim(ylimits)
                    xlim(xlimits)
                    line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    
                    set(gca, 'fontsize', fs)
                    if Rmono==floor(numamps/2)
                        title(sprintf('Contra (R mono)'))
                    end
                    axis off
                    if Rmono==1
                        axis on
                        ylabel('FR (Hz)')
                        xlabel('Time (ms)')
                        set(gca,'xtick',xlimits,'xticklabel',xlimits);
                    end
                end
            end
            set(gcf,'pos',[200   550   1000   400])
        end
    end
end

if monoflag % mono stim only 
    columns=length(Ramps);
    rows=3;
    
    for dindex=1:numdurs
        for findex=1:numfreqs
            figure
            subplot1(rows,columns)
            h=get(gcf, 'children');
            axis(h, 'off')
            
            % Ipsi ear
            for Raindex=1
                for Laindex=2:numamps
                    subplot1(Laindex+columns);
                    spiketimes8=mM1ONtc(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes8, X);
                    line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits)
                    xlim(xlimits)
                    if Laindex==2
                        ylabel(sprintf('Ispi (L ear)\nFR (Hz)'))
                        axis on
                        ytickmarks=[mean(ylimits) ylimits(2)];
                        set(gca,'ytick',ytickmarks,'yticklabel',ytickmarks)
                    end       
                    file_name=sprintf('%s-%s-%s-%s',expdate,username,session,filenum);
                    if freq(findex)==-1
                        tone='WN';
                    else
                        tone=num2str(freq(findex));
                    end
                    if Laindex==round(numamps/2+1)
                        title(sprintf('%s, %s (%d ms)\n\nMono Intensity (dB SPL)\n\n%d',file_name,tone,durs(dindex),Lamps(Laindex)),'horizontalalignment','center')
                    else
                        title(sprintf('%d',Lamps(Laindex)))
                    end
                    set(gca, 'fontsize', fs)
                end
            end
            
            % Contra ear
            for Raindex=2:numamps
                for Laindex=1
                    subplot1(Raindex+(columns*2));
                    spiketimes8=mM1ONtc(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes8, X);
                    line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits)
                    xlim(xlimits)
                    if Raindex==2
                        ylabel(sprintf('Contra (R ear)\nFR (Hz)'))
                        axis on
                        ytickmarks=[mean(ylimits) ylimits(2)];
                        xtickmarks=xlimits;
                        set(gca,'ytick',ytickmarks,'yticklabel',ytickmarks)
                        set(gca,'xtick',xtickmarks,'xticklabel',xtickmarks)
                        xlabel('time (ms)')
                    end                    
                    set(gca, 'fontsize', fs)
                end
            end
            set(gcf,'pos',[200   550   1000   400])
        end
    end
end

% plot laser OFF
if ~monoflag % binaural and mono stim 
    ILDs=-40:10:40;
    ABLs=fliplr(max(Ramps)-20:-5:15);
    MonoAmps=Ramps(find(nrepsOFF(1,:,1)~=0)); %same for either L or R
    rows=length(MonoAmps)*2;
    columns=length(ILDs)+2+2; % +2 mono, +2 spaces on either side of bin
    
    for dindex=1:numdurs
        for findex=1:numfreqs
            figure
            subplot1(rows,columns)
            h=get(gcf, 'children');
            axis(h, 'off')
            
            %note: don't use aindex=1 (-1000 dB) since ABL/ILD undefined for monaural sounds
            for Raindex=numamps:-1:2
                for Laindex=2:numamps
                    ABL=mean([Ramps(Raindex) Lamps(Laindex)]);
                    ILD=(Ramps(Raindex) - Lamps(Laindex));
                    if sum(ABLs==ABL)==1 && sum(ILDs==ILD)
                        ILDindex=ILD==ILDs;
                        
                        ABLindex=ABL==ABLs;
                        ILDpos=0:length(ILDs)-1;
                        ABLpos=fliplr(3:columns*2:columns*2*length(ABLs));
                        toppos=(ABLpos(ABLindex)+ILDpos(ILDindex))+columns*2;
                        totalpos=[toppos toppos+columns];
                        subplot(rows,columns,totalpos);
                        spiketimes7=mM1OFFtc(findex, Raindex, Laindex, dindex).spiketimes;
                        
                        %use this code to plot histograms
                        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                        hist(spiketimes7, X);
                        ylim(ylimits)
                        xlim(xlimits)
                        line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                        line(xlimits, [0 0], 'color', 'k')
                        
                        % set up axis labels
                        file_name=sprintf('%s-%s-%s-%s',expdate,username,session,filenum);
                        if freq(findex)==-1
                            tone='WN';
                        else
                            tone=num2str(freq(findex));
                        end
                        if ABLindex(end) && ILDindex(ceil(length(ILDs)/2))
                            title(sprintf('%s, %s (%d ms)\nLaser OFF\nInteraural Level Difference (dB)\n\n%d',file_name,tone,durs(dindex),ILD))
                        elseif ABLindex(end)
                            title(sprintf('%d',ILD))
                        end
                        if ILDindex(1) && ABLindex(ceil(length(ABLindex)/2))
                            text(xlimits(1)-50,mean(ylimits),sprintf('Average Binaural Level (dB)\n%d',ABL),'rotation',90,'horizontalalignment','center')
                        elseif ILDindex(1)
                            text(xlimits(1)-50,mean(ylimits),sprintf('\n%d',ABL),'rotation',90)
                        end
                        set(gca, 'fontsize', fs)
                        axis off
                    end
                end
            end
            
            % Now add in the Ipsi ear
            ipsiindex=(rows-2)*columns+1:-columns*2:1;
            for Raindex=1
                for Laindex=numamps:-2:2
                    Lmono=floor(Laindex/2); %only actually use every other Lamp
                    subplot(rows,columns,[ipsiindex(Lmono) ipsiindex(Lmono)+columns]);
                    spiketimes8=mM1OFFtc(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes8, X);
                    ylim(ylimits)
                    xlim(xlimits)
                    line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    
                    set(gca, 'fontsize', fs)
                    ylabel(sprintf('%d',Lamps(Laindex)))
                    if Lmono==round(numamps/4)
                        text(xlimits(1)-50,mean(ylimits),sprintf('Mono Amplitudes (dB SPL)\n%d',Lamps(Laindex)),'rotation',90,'horizontalalignment','center')
                    else
                        text(xlimits(1)-50,mean(ylimits),sprintf('\n%d',Lamps(Laindex)),'rotation',90)
                    end
                    if Lmono==floor(numamps/2)
                        title(sprintf('Ipsi (L mono)'))
                    end
                    axis off
                end
            end
            
            % Now add in the Contra ear
            conindex=columns*(rows-1):-columns*2:columns;
            for Raindex=numamps:-2:2
                for Laindex=1
                    Rmono=floor(Raindex/2); %only actually use every other Ramp
                    subplot(rows,columns,[ipsiindex(Lmono) ipsiindex(Lmono)+columns]);
                    subplot(rows,columns,[conindex(Rmono) conindex(Rmono)+columns]);
                    spiketimes9=mM1OFFtc(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes9, X);
                    ylim(ylimits)
                    xlim(xlimits)
                    line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    
                    set(gca, 'fontsize', fs)
                    if Rmono==floor(numamps/2)
                        title(sprintf('Contra (R mono)'))
                    end
                    axis off
                    if Rmono==1
                        axis on
                        ylabel('FR (Hz)')
                        xlabel('Time (ms)')
                        set(gca,'xtick',xlimits,'xticklabel',xlimits);
                    end
                end
            end
            set(gcf,'pos',[200    50   1000   400])
        end
    end
end

if monoflag % mono stim only 
    columns=length(Ramps);
    rows=3;
    
    for dindex=1:numdurs
        for findex=1:numfreqs
            figure
            subplot1(rows,columns)
            h=get(gcf, 'children');
            axis(h, 'off')
            
            % Ipsi ear
            for Raindex=1
                for Laindex=2:numamps
                    subplot1(Laindex+columns);
                    spiketimes8=mM1OFFtc(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes8, X);
                    line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits)
                    xlim(xlimits)
                    if Laindex==2
                        ylabel(sprintf('Ispi (L ear)\nFR (Hz)'))
                        axis on
                        ytickmarks=[mean(ylimits) ylimits(2)];
                        set(gca,'ytick',ytickmarks,'yticklabel',ytickmarks)
                    end       
                    file_name=sprintf('%s-%s-%s-%s',expdate,username,session,filenum);
                    if freq(findex)==-1
                        tone='WN';
                    else
                        tone=num2str(freq(findex));
                    end
                    if Laindex==round(numamps/2+1)
                        title(sprintf('%s, %s (%d ms)\nLaser OFF\nMono Intensity (dB SPL)\n\n%d',file_name,tone,durs(dindex),Lamps(Laindex)),'horizontalalignment','center')
                    else
                        title(sprintf('%d',Lamps(Laindex)))
                    end
                    set(gca, 'fontsize', fs)
                end
            end
            
            % Contra ear
            for Raindex=2:numamps
                for Laindex=1
                    subplot1(Raindex+(columns*2));
                    spiketimes8=mM1OFFtc(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes8, X);
                    line([0 0+durs(dindex)], [-0.5 -0.5], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits)
                    xlim(xlimits)
                    if Raindex==2
                        ylabel(sprintf('Contra (R ear)\nFR (Hz)'))
                        axis on
                        ytickmarks=[mean(ylimits) ylimits(2)];
                        xtickmarks=xlimits;
                        set(gca,'ytick',ytickmarks,'yticklabel',ytickmarks)
                        set(gca,'xtick',xtickmarks,'xticklabel',xtickmarks)
                        xlabel('time (ms)')
                    end                    
                    set(gca, 'fontsize', fs)
                end
            end
            set(gcf,'pos',[200    50   1000   400])
        end
    end
end

% Here I will compress all ABL into ILD and convert from spikecount into firing rate
% FR will be calculated by 5 ms bins
if false
    ABLs=[];ILDs=[];
    for Raindex=numamps:-1:2
        for Laindex=2:numamps
            ABLs=[ABLs mean([Ramps(Raindex) Lamps(Laindex)])];
            ILDs=[ILDs (Ramps(Raindex)- Lamps(Laindex))];
        end
    end
    ILDs=unique(ILDs);
    ABLs=unique(ABLs);
    for ILDspikes=1:length(ILDs)
        ILD2(ILDspikes).spikes=[];
        ILD2(ILDspikes).nreps=[];
    end
    for dindex=1:numdurs
        for findex=1:numfreqs
            for Raindex=numamps:-1:2
                for Laindex=2:numamps
                    ILD=(Ramps(Raindex)- Lamps(Laindex));
                    ILDindex=find(ILD==ILDs);
                    ILD2(ILDindex).spikes=[ILD2(ILDindex).spikes mM1(findex, Raindex, Laindex, dindex).spiketimes];
                    ILD2(ILDindex).nreps=[ILD2(ILDindex).nreps nreps(findex, Raindex, Laindex, dindex)];
                end
            end
        end
    end
    
    figure
    subplot1(1,length(ILDs));
    max_ylim=0;
    min_ylim=0;
    for p=1:length(ILDs)
        subplot1(p);
        %use this code to plot histograms
        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
        spiketimes3=ILD2(p).spikes;
        h4=hist(spiketimes3, X);
        h5=h4/sum(ILD2(p).nreps);
        plot(h5)
        axis off
        if max(h5)>max_ylim; max_ylim=max(h5);end
        if min(h5)>min_ylim; min_ylim=min(h5);end
    end
    
    for p=1:length(ILDs)
        subplot1(p);
        ylim([min_ylim max_ylim])
        xlim(xlimits)
        line([0 0+durs(dindex)], [0 0], 'color', 'm', 'linewidth', 5)
        line(xlimits, [0 0], 'color', 'k')
        text(mean(xlimits)/2, -max_ylim/15, int2str(ILDs(p)))
    end
    subplot1(1)
    axis on
    ylabel('Firing rate by trial');
    subplot1(5)
    if freqs(findex)/1000 < 1 %title script
        h=title(sprintf('%s-%s-%s, WN (%d ms), Max %d, Min %d trials ', expdate,session,filenum,durs(dindex),nrepsmax,nrepsmin));
        set(h, 'HorizontalAlignment', 'center')
    else
        h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), Max %d, Min %d trials ', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmax,nrepsmin));
        set(h, 'HorizontalAlignment', 'center')
    end
    text(mean(xlimits), -max_ylim/10, 'ILD dB SPL (Neg:Ipsi, Pos:Contra)','HorizontalAlignment', 'center');
    set(gca, 'fontsize', fs)
end

% FR will be calculated by total spikes in response window across all trials

% Process ABL into ILD and convert from spikecount into firing rate
if false
    if xlimits(1)~=0
        error('this code requires xlimits(1)==0')
    end
    %multiplier=0.5;
    ABLs=[];ILDs=[];
    for Raindex=numamps:-1:2
        for Laindex=2:numamps
            ABLs=[ABLs mean([Ramps(Raindex) Lamps(Laindex)])];
            ILDs=[ILDs (Ramps(Raindex)- Lamps(Laindex))];
        end
    end
    ILDs=unique(ILDs);
    ABLs=unique(ABLs);
    ILD2(length(ILDs),length(ABLs)).spikes1=[];
    ILD2(length(ILDs),length(ABLs)).nreps1=[];
    
    for dindex=1:numdurs
        for findex=1:numfreqs
            for Raindex=numamps:-1:2
                for Laindex=2:numamps
                    ABL=mean([Ramps(Raindex) Lamps(Laindex)]);
                    ABLindex=find(ABL==ABLs);
                    ILD=(Ramps(Raindex)- Lamps(Laindex));
                    ILDindex=find(ILD==ILDs);
                    ILD2(ILDindex,ABLindex).spikes1=[ILD2(ILDindex,ABLindex).spikes1 mM1(findex, Raindex, Laindex, dindex).spiketimes];
                    ILD2(ILDindex,ABLindex).nreps1=[ILD2(ILDindex,ABLindex).nreps1 nreps(findex, Raindex, Laindex, dindex)];
                end
            end
        end
    end
    for Lspikes=2:numamps
        Lmono(Lspikes).spikes1=[];
        Lmono(Lspikes).nreps1=[];
    end
    for dindex=1:numdurs
        for findex=1:numfreqs
            for Raindex=1
                for Laindex=2:numamps
                    Lmono(Laindex).spikes1=[Lmono(Laindex).spikes1 mM1(findex, Raindex, Laindex, dindex).spiketimes];
                    Lmono(Laindex).nreps1=[Lmono(Laindex).nreps1 nreps(findex, Raindex, Laindex, dindex)];
                end
            end
        end
    end
    for Rspikes=numamps:-1:2
        Rmono(Rspikes).spikes1=[];
        Rmono(Rspikes).nreps1=[];
    end
    for dindex=1:numdurs
        for findex=1:numfreqs
            for Raindex=numamps:-1:2
                for Laindex=1
                    Rmono(Raindex).spikes1=[Rmono(Raindex).spikes1 mM1(findex, Raindex, Laindex, dindex).spiketimes];
                    Rmono(Raindex).nreps1=[Rmono(Raindex).nreps1 nreps(findex, Raindex, Laindex, dindex)];
                end
            end
        end
    end
    FRbyILD.meanFR=[];
    FRbyILD.semFR=[];
    FRbyILD.ABL_FR=[];
    FRbyILD.ABL_nreps=[];
    for p=1:length(ILDs)+2
        if p==1
            for q=2:numamps
                LMspikes=length(Lmono(q).spikes1);
                LMnreps(q-1)=Lmono(q).nreps1;
                LmonoFR(q-1)=(LMspikes*1e3)/(LMnreps(q-1)*xlimits(2));
            end
            FRbyILD(p).meanFR=mean(LmonoFR);
            FRbyILD(p).semFR=std(LmonoFR)/sqrt(length(LmonoFR));
            FRbyILD(p).ABL_FR=LmonoFR;
            FRbyILD(p).ABL_nreps=LMnreps;
        elseif p==length(ILDs)+2
            for q=numamps:-1:2
                RMspikes=length(Rmono(q).spikes1);
                RMnreps(q-1)=Rmono(q).nreps1;
                RmonoFR(q-1)=(RMspikes*1e3)/(RMnreps(q-1)*xlimits(2));
            end
            FRbyILD(p).meanFR=mean(RmonoFR);
            FRbyILD(p).semFR=std(RmonoFR)/sqrt(length(RmonoFR));
            FRbyILD(p).ABL_FR=RmonoFR;
            FRbyILD(p).ABL_nreps=RMnreps;
        else
            if p==10
                stophere=0;
            end
            ABLcounter=0;
            for q=1:length(ABLs)
                if size(ILD2(p-1,q).nreps1,1)~=0
                    ABLcounter=ABLcounter+1;
                    ILD2spikes=length(ILD2(p-1,q).spikes1);
                    ILD2nreps(ABLcounter)=ILD2(p-1,q).nreps1;
                    ILD2FR(ABLcounter)=(ILD2spikes*1e3)/(ILD2nreps(ABLcounter)*xlimits(2));
                    breakstop='now';
                end
                
                
            end
            FRbyILD(p).ABL_FR=ILD2FR;
            FRbyILD(p).ABL_nreps=ILD2nreps;
            FRbyILD(p).meanFR=mean(ILD2FR);
            FRbyILD(p).semFR=std(ILD2FR)/sqrt(length(ILD2FR));
            clear ILD2spikes ILD2nreps ILD2FR
        end
    end
    %     FRbyILD(find(isnan(FRbyILD)))=0;
    %     FRbyILDnreps(find(isnan(FRbyILDnreps)))=0;
    
    if false
        figure
        hold on
        errorbar([FRbyILD.meanFR],[FRbyILD.semFR],'bo-','linewidth',4)
        ILDlabel=cell(1,length(FRbyILD));
        for p=1:length(FRbyILD)
            if p==1
                ILDlabel{p}='Ipsi';
            elseif p==length(FRbyILD)
                ILDlabel{p}='Contra';
            else
                ILDlabel{p}=sprintf('%d',ILDs(p-1));
            end
        end
        set(gca,'xtick',1:length(FRbyILD),'xticklabel',ILDlabel);
        set(gca,'xlim',[1-0.5 length(FRbyILD)+0.5]);
        h2=get(gca,'ylim');
        if max([FRbyILD.meanFR])~=0
            set(gca,'ylim',[0 h2(2)]);
        end
        xlabel('ILD dB SPL');
        ylabel('Mean firing rate (Spikes/s; sem)');
        h4=get(gca,'ylim');
        h5=get(gca,'xlim');
        %         h6=multiplier*(max(FRbyILD(2:end-1).meanFR)-min(FRbyILD(2:end-1).meanFR))+min(FRbyILD(2:end-1).meanFR);
        [cellclass maxpos monoCutoff]=BinCellClass(FRbyILD);
        line([1.5 1.5],h4,'linewidth',4,'linestyle',':','color','k')
        line([length([FRbyILD.meanFR])-0.5 length([FRbyILD.meanFR])-0.5],h4,'linewidth',4,'linestyle',':','color','k')
        line(h5,[monoCutoff monoCutoff],'linewidth',4,'linestyle',':','color','g');
        maxpos2=round((maxpos-5)*10);
        maxpos=maxpos+1;
        line([maxpos maxpos],h4,'linewidth',4,'linestyle',':','color','r')
        if freqs(findex)/1000 < 1
            h=title(sprintf('%s-%s-%s, WN (%d ms), %d/%d trials , weightFRI: %d, class: %s', expdate,session,filenum,durs(dindex),nrepsmin,nrepsmax,maxpos2,cellclass));
        else
            h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), %d/%d trials , weightFRI: %d, class: %s', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmin,nrepsmax,maxpos2,cellclass));
        end
        set(h, 'HorizontalAlignment', 'center')
    end
end

% plot all the spikes for each duration & frequency, collapsing Lamp & Ramp
% into one response window  mak 14feb2011
% This ignores the silence-silence stimulus combination mk 1Dec2011. The best control is
% the 100 ms prior to stimulus onset for each stimulus combo.
if false
    
    figure
    for dindex=1:numdurs
        for findex=1:numfreqs
            if numdurs ~= 1 && numfreqs ~= 1
                warning('numfreqs and numdurs are greater than 1, figure 3 won''t work and dspikesxlim/pre will be wrong');
            end
            
            % Plots all Ipsi spikes in one histogram with balanced pre_xlim spikes
            subplot(4,3,2)
            X=-xlimits(2):binwidth:xlimits(2); %specify bin centers
            hist([pre_spiketimesipsi spiketimesipsi], X);
            line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
            line(xlimits, [0 0], 'color', 'k')
            adjustylim=get(gca,'ylim');
            %         if no ylimits are passed they are set based on the highest
            %         spike count per R/L ear amp (line 261). They will likely be
            %         higher when these are collapsed. I like a little bit of space
            %         between the highest spike count and the top of the plot thus I
            %         will round up the ylimits by 5. mak 20feb2011
            ylimits2=[-1 floor(adjustylim(2)/5)*5+5];
            ylim(ylimits2)
            xlim([-xlimits(2) xlimits(2)])
            set(gca, 'fontsize', fs)
            if freqs(findex)/1000 < 1
                if length(nstd)==1
                    h=title(sprintf('%s-%s-%s-%s, WN (%d ms), nstd=%g, %d ms bins\nIpsi %d:%d spikes',expdate,username,session,filenum,durs(dindex),nstd,binwidth,pre_ipsispikesxlim,ipsispikesxlim));
                else
                    h=title(sprintf('%s-%s-%s-%s, WN (%d ms), nstd=%.1f mV, %d ms bins\nIpsi %d:%d spikes',expdate,username,session,filenum,durs(dindex),nstd(2),binwidth,pre_ipsispikesxlim,ipsispikesxlim));
                end
            else
                if length(nstd)==1
                    h=title(sprintf('%s-%s-%s-%s, %.1f kHz (%d ms), nstd=%g, %d ms bins\nIpsi %d:%d spikes',expdate,username,session,filenum,freqs(findex)/1000,durs(dindex),nstd,binwidth,pre_ipsispikesxlim,ipsispikesxlim));
                else
                    h=title(sprintf('%s-%s-%s-%s, %.1f kHz (%d ms), nstd=%.1f mV, %d ms bins\nIpsi %d:%d spikes',expdate,username,session,filenum,freqs(findex)/1000,durs(dindex),nstd(2),binwidth,pre_ipsispikesxlim,ipsispikesxlim));
                end
            end
            set(h,'HorizontalAlignment', 'center')
            
            % Plots all Contra spikes in one histogram with balanced pre_xlim spikes
            subplot(4,3,5)
            X=-xlimits(2):binwidth:xlimits(2); %specify bin centers
            hist([pre_spiketimescontra spiketimescontra], X);
            line([0 0+durs(dindex)], [-1 -1], 'color','m', 'linewidth', 2)
            line(xlimits, [0 0], 'color', 'k')
            adjustylim=get(gca,'ylim');
            %         if no ylimits are passed they are set based on the highest
            %         spike count per R/L ear amp (line 261). They will likely be
            %         higher when these are collapsed. I like a little bit of space
            %         between the highest spike count and the top of the plot thus I
            %         will round up the ylimits by 5. mak 20feb2011
            ylimits2=[-2 floor(adjustylim(2)/5)*5+5];
            ylim(ylimits2)
            xlim([-xlimits(2) xlimits(2)])
            set(gca, 'fontsize', fs)
            h=title(sprintf('Contra %d:%d spikes',pre_contraspikesxlim,contraspikesxlim));
            set(h,'HorizontalAlignment', 'center')
            
            % Plots all Bin combo spikes in one histogram with balanced pre_xlim spikes
            subplot(4,3,8)
            X=-xlimits(2):binwidth:xlimits(2); %specify bin centers
            hist([pre_spiketimesbin spiketimesbin], X);
            line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
            line(xlimits, [0 0], 'color', 'k')
            adjustylim=get(gca,'ylim');
            %         if no ylimits are passed they are set based on the highest
            %         spike count per R/L ear amp (line 261). They will likely be
            %         higher when these are collapsed. I like a little bit of space
            %         between the highest spike count and the top of the plot thus I
            %         will round up the ylimits by 5. mak 20feb2011
            ylimits2=[-2 floor(adjustylim(2)/5)*5+5];
            ylim(ylimits2)
            xlim([-xlimits(2) xlimits(2)])
            set(gca, 'fontsize', fs)
            
            h=title(sprintf('Bin %d:%d spikes',pre_binspikesxlim,binspikesxlim));
            set(h,'HorizontalAlignment', 'center')
            
            % All Bin, Ipsi, and Contra combinations with balanced pre_xlim spiking
            subplot(4,3,11)
            X=-xlimits(2):binwidth:xlimits(2); %specify bin centers
            hist([pre_spiketimes2 spiketimes2], X);
            line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
            line(xlimits, [0 0], 'color', 'k')
            adjustylim=get(gca,'ylim');
            %         if no ylimits are passed they are set based on the highest
            %         spike count per R/L ear amp (line 261). They will likely be
            %         higher when these are collapsed. I like a little bit of space
            %         between the highest spike count and the top of the plot thus I
            %         will round up the ylimits by 5. mak 20feb2011
            ylimits2=[-2 floor(adjustylim(2)/5)*5+5];
            ylim(ylimits2)
            xlim([-xlimits(2) xlimits(2)])
            set(gca, 'fontsize', fs)
            h=title(sprintf('All %d:%d (%d) spikes, %d total trials',pre_dspikesxlim,dspikesxlim,ds,ntrials));
            set(h,'HorizontalAlignment', 'center')
        end
    end
end

% aa=squeeze(mM1);
% a=zeros(6,6);
% for i=1:6
%     for j=1:6
%         if ~isempty(aa(i,j).spiketimes)
%             a(i,j)=length(aa(i,j).spiketimes);
%         end
%     end
% end

% stimtypes=stimtype(expdate, session, filenum);
% if sum(strcmp(stimtypes,'binwhitenoise'))==1
%     outfilename2=sprintf('out%s-%swn%d.mat',expdate,session,durs);
% end

% if exist(outfilename2,'file')==2
%     load(outfilename2)
% end
% out.expdate=expdate;
% out.session=session;
% out.psthfilenum=filenum;
% out.spikes=a(6:-1:1,:);
% out.psthnreps=squeeze(nreps);
% save(outfilename2,'out')
% clear out
if false
out.M1=M1;
out.mM1=mM1;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.freqs=freqs;
out.Ramps=Ramps;
out.Lamps=Lamps;
out.durs=durs;
out.ylimits=ylimits;
out.nstd=nstd;
out.thresh=thresh;
out.binwidth=binwidth;

out.samprate=samprate;
out.nreps=nreps;
out.ntrials=sum(sum(squeeze(nreps)));
out.xlimits=xlimits;

out.dspikes=dspikes;
out.ds=ds;
out.dspikesxlim=dspikesxlim;
out.pre_dspikesxlim=pre_dspikesxlim;
out.filelength=length(scaledtrace);
out.spikerateFF=spikerateFF;
out.spikerateRW=spikerateRW;
out.spikerateRW_pre=spikerateRW_pre;
out.spikerateNonRW=spikerateNonRW;

if cell_list_exists
    out.earpiececheck_notes=earpiececheck_notes;
    out.age=age;
    out.mass=mass;
    out.a1=a1;
    out.depth=depth;
    out.CF=CF;
    out.notes=notes;
    out.keep=keep;
    out.bintype=bintype;
    out.FRbyILD=FRbyILD;
    if exist('inorm','var')
        out.inorm=inorm;
    end
end

fprintf('\nspikes in response window %d; total spikes: %d',dspikesxlim,ds);
fprintf('\nFiring rate (spikes/second) for:');
fprintf('\n   Only xlim: %.2f',spikerateRW);
if pre_xlim_flag==1
    fprintf('\n    pre-xlim: %.2f',spikerateRW_pre);
else
    fprintf('\n    pre-xlim not done b/c xlimit(1) < 0 or xlimit(2) > (isi)/2');
end
fprintf('\n    non-xlim: %.2f',spikerateNonRW);
fprintf('\n   Full file: %.2f',spikerateFF);

godatadir(expdate, session, filenum)
save(outfilename, 'out')
fprintf('\n saved to %s\n\n', outfilename);
end

fprintf('\nTotal run time = %.1f seconds\n',toc);
    
    
    


