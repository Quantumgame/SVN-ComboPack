function PlotILTC_psthOE(expdate, session, filenum, channel, varargin)
% plots psth tuning curve for spike data from Open Ephys/SimpleClust
% interleaved laser ON and OFF trials, PPA_laser signal expected on 100_CH36
% usage: PlotILTC_psthOE(expdate, session, filenum, channel number, [xlimits], [ylimits], [binwidth],cell)
% (xlimits, ylimits, binwidth are optional)
%
%  defaults: binwidth=5ms, axes autoscaled
%  note there is no thresh because spikes were already cut in SimpleClust
%  plots mean spike rate (in Hz) averaged across trials
%  cell is an option for plotting only one specific cluster (cell),

%Use PlotILNBN_psthOE to process narrow band noise
% D drive version
% mw 032614
% mw 06.11.2014 - added MClust capability
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sorter='MClust'; %can be either 'MClust' or 'simpleclust'
rasters=1;
save_the_outfile=0; % saves an outfile in a specific locationt that is synced with ira's macbook for analysis
location='d:\lab\Somatostatin_project_shared_folder\MK_data_SomArch\ChRSom\';
combine_ONOFF=0;

% sorter='simpleclust';
% recordings = cell_list_ira_som_OE;
% for i=1:length(recordings)
%     if strcmp(recordings(i).expdate, expdate) && strcmp(recordings(i).session, session) && strcmp(recordings(i).filenum, filenum)
%     sorter=recordings(i).sorter;
%     end
% end
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%Get PPA lazer params

try
    [on, PPAstart, width, numpulses, isi]=getPPALaserParams(expdate,session,filenum);
catch
    ProcessData_single(expdate,session,filenum);
    [on, PPAstart, width, numpulses, isi]=getPPALaserParams(expdate,session,filenum);
end


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
    load(OEeventsfile); %Not smart enough to check for different
    %parameters. Reprocessing every time. AKH 7/14/14
    %not sure what the problem is - switching back. mw 7-24-20145
catch
    OEgetEvents(expdate, session, filenum);
    load(OEeventsfile)
end

% check for missing soundcard triggers
for i=1:length(event)
    sct(i)=event(i).soundcardtriggerPos/30e3;
end
time=(event(2).Param.duration+event(2).Param.next)/1000;%convert it to sec
if time>diff(sct)
    fprintf('\n POSSIBLE ISSUES WITH SOUNDCARD TRIGGERS. One or more SCT is closer in time than stim dur + isi. Check SCTs!!! \n')
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

%% Find OE data directory
try
    oepathname=getOEdatapath(expdate, session, filenum);
    cd(oepathname);
catch
    %     cd('C:\Program Files\Open Ephys')
    %     switch sorter
    %         case 'MClust'
    %             [OEdatafile, oepathname] = uigetfile('*.t', 'pick an MClust output file (*.t)');
    %             if isequal(OEdatafile,0) || isequal(oepathname,0)
    %                 return;
    %             else
    %                 cd(oepathname)
    %             end
    %         case 'simpleclust'
    %             [OEdatafile, oepathname] = uigetfile('*simpleclust.mat', 'pick a simpleclust.mat file');
    %     end
    oepathname(1)='d';
    fprintf('\n Switching from Drive C to Drive D. C is no longer on this computer\n. Data was copied to drive D\n'); %ira
    cd(oepathname);
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
    elseif strcmp(event(i).Type, 'amtone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allbws(j)=0;
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

%delete
expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
M1=[];
nreps=zeros(numfreqs, numamps, numdurs);

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
dur=max([durs 100]);

inRange=zeros(1, Nclusters);
%extract the traces into a big matrix M
j=0;

for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'grating') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'noise') | strcmp(event(i).Type, 'amtone') | strcmp(event(i).Type, 'fmtone')
        if  isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos/samprate;
        end
        if isempty(pos) & ~isempty(event(i).Position)
            pos=event(i).Position;
            fprintf('\nWARNING! Missing a soundcard trigger. Using hardware trigger instead.')
            
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
                    modfreq=0;
                    moddepth=0;
                elseif  strcmp(event(i).Type, 'tonetrain')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.toneduration;
                    bw=0;
                    modfreq=0;
                    moddepth=0;
                elseif  strcmp(event(i).Type, 'grating')
                    freq=event(i).Param.angle*1000;
                    dur=event(i).Param.duration;
                    bw=0;
                    modfreq=0;
                    moddepth=0;
                elseif strcmp(event(i).Type, 'whitenoise')
                    dur=event(i).Param.duration;
                    freq=-1;
                    bw=inf;
                    modfreq=0;
                    moddepth=0;
                elseif strcmp(event(i).Type, 'clicktrain')
                    dur=event(i).Param.clickduration;
                    freq=-1;
                    bw=0;
                    modfreq=0;
                    moddepth=0;
                elseif strcmp(event(i).Type, 'noise')
                    dur=event(i).Param.duration;
                    bw=event(i).Param.bandwidthOct;
                    freq=event(i).Param.center_frequency;
                    modfreq=0;
                    moddepth=0;
                elseif strcmp(event(i).Type, 'amtone')
                    dur=event(i).Param.duration;
                    freq=event(i).Param.frequency;
                    modfreq=event(i).Param.modulation_frequency;
                    moddepth=event(i).Param.modulation_depth;
                    bw=0;
                elseif strcmp(event(i).Type, 'fmtone')
                    dur=event(i).Param.duration;
                    freq=event(i).Param.carrier_frequency;
                    modfreq=event(i).Param.modulation_frequency;
                    moddepth=1;
                    bw=0;
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
                bwindex= find(bws==bw); %not written to process NBN
                for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
                    st=spiketimes(clust).spiketimes;
                    spiketimes1=st(st>start & st<stop); % spiketimes in region
                    spiketimes2=st(st>pos & st<(pos+.150)); %ON responses, 150 ms after the onset
                    if dur>25
                        spiketimes3=st(st>(pos+dur/1000) & st<(pos+dur/1000+.2)); % OFF response 200 ms after the end of the stimulus
                        spiketimes4=st(st>(pos+.1) & st<(pos+dur/1000)); % Continuous response 100 ms- end
                    else
                        spiketimes3=[];
                        spiketimes4=[];
                    end
                    
                    spikecount=length(spiketimes1); % No. of spikes fired in response to this rep of this stim.
                    inRange(clust)=inRange(clust)+ spikecount; %accumulate total spikecount in region
                    spiketimes1=(spiketimes1-pos)*1000;%covert to ms after tone onset
                    spiketimes2=(spiketimes2-pos)*1000;
                    spiketimes3=(spiketimes3-pos)*1000;
                    spiketimes4=(spiketimes4-pos)*1000;
                    spont_spikecount=length(find(st<start & st>(start-(stop-start))));
                    
                    % No. spikes in a region of same length preceding response window
                    if aopulseon
                        if clust==1
                            nrepsON(findex, aindex, dindex)=nrepsON(findex, aindex, dindex)+1;
                        end
                        M1ONp(clust, findex,aindex,dindex, nrepsON(findex, aindex, dindex)).spiketimes=spiketimes1; % Spike times
                        M1ONp2(clust, findex,aindex,dindex, nrepsON(findex, aindex, dindex)).spiketimes=spiketimes2;
                        M1ONp3(clust, findex,aindex,dindex, nrepsON(findex, aindex, dindex)).spiketimes=spiketimes3;
                        M1ONp4(clust, findex,aindex,dindex, nrepsON(findex, aindex, dindex)).spiketimes=spiketimes4;
                        M1ONspikecounts(clust, findex,aindex,dindex,nrepsON(findex, aindex, dindex))=spikecount; % No. of spikes
                        M1spontON(clust, findex,aindex,dindex, nrepsON(findex, aindex, dindex))=spont_spikecount; % No. of spikes in spont window, for each presentation.
                        % Could save actual spont spiketimes here, in addition
                        % to count...
                        
                    else
                        if clust==1
                            nrepsOFF(findex, aindex, dindex)=nrepsOFF(findex, aindex, dindex)+1;
                        end
                        M1OFFp(clust, findex,aindex,dindex, nrepsOFF(findex, aindex, dindex)).spiketimes=spiketimes1;
                        M1OFFp2(clust, findex,aindex,dindex, nrepsOFF(findex, aindex, dindex)).spiketimes=spiketimes2;
                        M1OFFp3(clust, findex,aindex,dindex, nrepsOFF(findex, aindex, dindex)).spiketimes=spiketimes3;
                        M1OFFp4(clust, findex,aindex,dindex, nrepsOFF(findex, aindex, dindex)).spiketimes=spiketimes4;
                        M1OFFspikecounts(clust, findex,aindex,dindex,nrepsOFF(findex, aindex, dindex))=spikecount;
                        M1spontOFF(clust, findex,aindex,dindex, nrepsOFF(findex, aindex, dindex))=spont_spikecount;
                        
                    end
                end
            end
        end
    end
end

fprintf('\nmin num ON reps: %d\nmax num ON reps: %d', min(min(min(nrepsON))), max(max(max(nrepsON))))
fprintf('\nmin num OFF reps: %d\nmax num OFF reps: %d', min(min(min(nrepsOFF))), max(max(max(nrepsOFF))))
for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
    fprintf('\ncell %d:', clust)
    fprintf('\ntotal num spikes: %d', length(spiketimes(clust).spiketimes))
    fprintf('\nIn range: %d', inRange(clust))
end

% Accumulate spiketimes across trials, for psth...
for dindex=1:length(durs); % Hardcoded.
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            for clust=1:Nclusters
                
                % on
                spiketimesON=[];
                spiketimesON2=[];
                spiketimesON3=[];
                spiketimesON4=[];
                spikecountsON=[];
                for rep=1:nrepsON(findex, aindex, dindex)
                    spiketimesON=[spiketimesON M1ONp(clust, findex, aindex, dindex, rep).spiketimes];
                    %                     spiketimesON2=[spiketimesON2 M1ONp2(clust, findex, aindex, dindex, rep).spiketimes]; %ON
                    %                     spiketimesON3=[spiketimesON3 M1ONp3(clust, findex, aindex, dindex, rep).spiketimes]; %OFF
                    %                     spiketimesON4=[spiketimesON4 M1ONp4(clust, findex, aindex, dindex, rep).spiketimes]; %Co
                    % Accumulate spike times for all presentations of each
                    % laser/f/a combo.
                end
                
                % All spiketimes for a given f/a/d combo, for psth:
                mM1ONp(clust, findex, aindex, dindex).spiketimes=spiketimesON;
                mM1ONp2(clust, findex, aindex, dindex).spiketimes=spiketimesON2;
                mM1ONp3(clust, findex, aindex, dindex).spiketimes=spiketimesON3;
                mM1ONp4(clust, findex, aindex, dindex).spiketimes=spiketimesON4;
                
                % off
                spiketimesOFF=[];
                spiketimesOFF2=[];
                spiketimesOFF3=[];
                spiketimesOFF4=[];
                spikecountsOFF=[];
                for rep=1:nrepsOFF(findex, aindex, dindex)
                    spiketimesOFF=[spiketimesOFF M1OFFp(clust, findex, aindex, dindex, rep).spiketimes];
                    spiketimesOFF2=[spiketimesOFF2 M1OFFp2(clust, findex, aindex, dindex, rep).spiketimes];
                    spiketimesOFF3=[spiketimesOFF3 M1OFFp3(clust, findex, aindex, dindex, rep).spiketimes];
                    spiketimesOFF4=[spiketimesOFF4 M1OFFp4(clust, findex, aindex, dindex, rep).spiketimes];
                end
                mM1OFFp(clust, findex, aindex, dindex).spiketimes=spiketimesOFF;
                mM1OFFp2(clust, findex, aindex, dindex).spiketimes=spiketimesOFF2;
                mM1OFFp3(clust, findex, aindex, dindex).spiketimes=spiketimesOFF3;
                mM1OFFp4(clust, findex, aindex, dindex).spiketimes=spiketimesOFF4;
            end
        end
    end
end

dindex=1;
m=mM1ONp.spiketimes;
% ON, evoked
if isempty(m) %no laser pulses in this file
    mM1ONspikecount=[];
    sM1ONspikecount=[];
    semM1ONspikecount=[];
    M1ONspikecounts=[];
else
    mM1ONspikecount=mean(M1ONspikecounts,5); % Mean spike count
    sM1ONspikecount=std(M1ONspikecounts,[],5); % Std of the above
    for clust=1:Nclusters
        semM1ONspikecount(clust, :,:)=squeeze(sM1ONspikecount(clust, :,:))./sqrt(max(max(nrepsON(:,:,1)))); % Sem of the above
    end
    % Spont
    mM1spontON=mean(M1spontON,5);
    sM1spontON=std(M1spontON,[],5);
    for clust=1:Nclusters
        semM1spontON(clust, :,:)=squeeze(sM1spontON(clust, :,:))./sqrt(max(max((nrepsON(:,:,1)))));
    end
end
if isempty(mM1OFFp) %no laser pulses in this file
    mM1OFFspikecount=[];
    sM1OFFspikecount=[];
    semM1OFFspikecount=[];
    M1OFFspikecounts=[];
else
    mM1OFFspikecount=mean(M1OFFspikecounts,5); % Mean spike count
    sM1OFFspikecount=std(M1OFFspikecounts,[],5); % Std of the above
    for clust=1:Nclusters
        semM1OFFspikecount(clust, :,:)=squeeze(sM1OFFspikecount(clust, :,:))./sqrt(max(max(nrepsOFF(:,:,1)))); % Sem of the above
    end
    % Spont
    mM1spontOFF=mean(M1spontOFF,5);
    sM1spontOFF=std(M1spontOFF,[],5);
    for clust=1:Nclusters
        semM1spontOFF(clust, :,:)=squeeze(sM1spontOFF(clust, :,:))./sqrt(max(max(nrepsOFF(:,:,1))));
    end
end
%find axis limits

if ylimits==-1
    for clust=1:Nclusters
        ymax=0;
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                st=mM1ONp(clust, findex, aindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(st, X);
                N=N./nrepsON(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                ymax= max(ymax,max(N));
                
                st=mM1OFFp(clust, findex, aindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(st, X);
                N=N./nrepsOFF(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
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



% ttest
% if isempty(mM1ONspikecount) %no laser pulses in this file
%     pvalues=nan(size(nrepsON));alpha=[];
% else
%     [h,pvalues]=ttest2(M1ONspikecounts,M1OFFspikecounts,[],[],[],5);
%     alpha=0.05/(numamps*numfreqs);
% end

% Plot psth, ON/OFF overlay

if ~isempty(cell)
    
    
        clust=cell;
        figure
        p=0;if numdurs==1
            subplot1(numamps,numfreqs)
        else
            subplot1(numdurs, numamps)
        end
        for aindex=numamps:-1:1
            for findex=1:numfreqs
                for dindex=1:length(durs);
                p=p+1;
                subplot1(p)
                hold on
                
                spiketimesON=mM1ONp(clust, findex, aindex, dindex).spiketimes;
                spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex).spiketimes;
                
                X=xlimits(1):binwidth:xlimits(2);
                [NON, xON]=hist(spiketimesON, X);
                [NOFF, xOFF]=hist(spiketimesOFF, X);
                
                NON=NON./nrepsON(findex, aindex, dindex); %
                NON=1000*NON./binwidth; %normalize to spike rate in Hz
                NOFF=NOFF./nrepsOFF(findex, aindex, dindex);
                NOFF=1000*NOFF./binwidth;
                
                bON=bar(xON, NON,1);
                hold on
                bOFF=bar(xOFF,NOFF,1);
                offset=0;
                yl=ylimits1(clust,:);
                inc=(yl(2))/max(max(max(nrepsOFF)));
                if rasters==1
                    for n=1:nrepsOFF(findex, aindex, dindex)
                        spiketimes2=M1OFFp(clust, findex, aindex, dindex, n).spiketimes;
                        offset=offset+inc;
                        h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.k');
                    end
                    for n=1:nrepsON(findex, aindex, dindex)
                        spiketimes2=M1ONp(clust, findex, aindex, dindex, n).spiketimes;
                        offset=offset+inc;
                        h=plot(spiketimes2, ylimits1(clust,2)+ones(size(spiketimes2))+offset, '.g');
                    end
                end
                
                
                set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                if aindex==1 && findex==1
                    line([PPAstart width+PPAstart], [-.05 -.05], 'color', 'c', 'linewidth', 2)
                end
                line(xlimits, [0 0], 'color', 'k')
                
                xlim(xlimits)
                if rasters==1
                    ylimits2(clust,2)=ylimits1(clust,2)*3;
                    ylim(ylimits2(clust,:))
                else
                    ylim(ylimits1(clust,:));
                end
                
                % Add stars for ttest.
                %                 if pvalues(clust,findex,aindex)<alpha
                %                     text((xlimits(2)*.1),(ylimits1(clust,2)*.6),'*','fontsize',30,'color','r');
                %                     fprintf('On trial is significantly different from OFF trial, freg= %.2f, amp= %.2f', freqs(findex), amps(aindex));
                %                 end
                
            end
        end
        
        % Label amps and freqs.
        p=0;
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                p=p+1;
                subplot1(p)
                if findex==1
                    ylabel(sprintf('%.0f',amps(aindex)))
                    if aindex~=1
                        set(gca, 'yticklabel', '')
                    end
                end
                vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/10;
                if aindex==1 && findex~=1
                    text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
                    set(gca,'xticklabel','')
                end
                grid off
                box off
                if aindex==1 && findex==1
                    axis on
                    set(gca,'xtick',xlimits)
                    set(gca,'xticklabel',{xlimits})
                    xlabel('Time (ms)');
                    ylabel('F.R. (Hz)');
                else
                    set(gca, 'yticklabel', '')
                end
                if aindex==numamps && findex==round(numfreqs/2)
                    title(sprintf('%s-%s-%s cell %d: ON & OFF trials (Min reps = %.0f ON, %.0f OFF) %.1f-%.1f kHz @ %.0f-%.0f dB',...
                        expdate,session,filenum,clust,min(min(min(nrepsON))),min(min(min(nrepsOFF))),freqs(1)/1000,...
                        freqs(end)/1000,amps(1),amps(end)))
                    if modfreq~=0
                        title(sprintf('%s-%s-%s cell %d: ON & OFF trials %.1f-%.1f kHz @ %.0f-%.0f dB, mod freq=%d, mod depth= %d',...
                            expdate,session,filenum,clust,min(min(min(nrepsON))),min(min(min(nrepsOFF))),freqs(1)/1000,...
                            freqs(end)/1000,amps(1),amps(end), modfreq, moddepth))
                        
                    end
                end
            end
        end
        subplot1(ceil(numfreqs/3))
        
        
    end % dindex
else
    
        for clust=1:Nclusters
            
            figure
            
            p=0;
            if numdurs==1
            subplot1(numamps,numfreqs)
        else
            subplot1(numdurs, numamps)
        end
            for aindex=numamps:-1:1
                for findex=1:numfreqs
                    for dindex=1:length(durs);
                    offset=0;
                    p=p+1;
                    subplot1(p)
                    hold on
                    
                    yl=ylimits1(clust,:);
                    inc=(yl(2))/max(max(max(nrepsOFF)));
                    spiketimesON=mM1ONp(clust, findex, aindex, dindex).spiketimes;
                    spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex).spiketimes;
                    
                    X=xlimits(1):binwidth:xlimits(2);
                    [NON, xON]=hist(spiketimesON, X);
                    [NOFF, xOFF]=hist(spiketimesOFF, X);
                    
                    NON=NON./nrepsON(findex, aindex, dindex); %
                    NON=1000*NON./binwidth; %normalize to spike rate in Hz
                    NOFF=NOFF./nrepsOFF(findex, aindex, dindex);
                    NOFF=1000*NOFF./binwidth;
                    
                    bON=bar(xON, NON,1);
                    hold on
                    bOFF=bar(xOFF,NOFF,1);
                    
                    
                    set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                    set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                    if clust==4
                        set(bOFF, 'facecolor', [.5 0 0],'edgecolor', [.5 0 0]);
                        set(bON, 'facecolor', [0 0 .5],'edgecolor', [0 0 .5]);
                    end
                    
                    line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                    if aindex==1 && findex==1
                        line([PPAstart width+PPAstart], [-.05 -.05], 'color', 'c', 'linewidth', 2)
                    end
                    line(xlimits, [0 0], 'color', 'k')
                    
                    if rasters==1
                        
                        
                        for n=1:nrepsOFF(findex, aindex, dindex)
                            spiketimes2=M1OFFp(clust, findex, aindex, dindex, n).spiketimes;
                            offset=offset+inc;
                            h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.k');
                            if clust==4
                                h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.r');
                            end
                        end
                        for n=1:nrepsON(findex, aindex, dindex)
                            spiketimes2=M1ONp(clust, findex, aindex, dindex, n).spiketimes;
                            offset=offset+inc;
                            h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.g');
                            if clust==4
                                h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.r');
                            end
                        end
                    end
                    
                    
                    
                    xlim(xlimits)
                    ylimits2(clust,2)=ylimits1(clust,2)*3;
                    ylim(ylimits2(clust,:))
                    
                    % Add stars for ttest.
                    %                     if pvalues(findex,aindex)<alpha
                    %                         text((xlimits(2)*.1),(ylimits1(clust,2)*.6),'*','fontsize',30,'color','r')
                    %                     end
                    
                end
            end
            end
            % Label amps and freqs.
            p=0;
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                    p=p+1;
                    subplot1(p)
                    if findex==1
                        ylabel(sprintf('%.0f',amps(aindex)))
                        if aindex~=1
                            set(gca, 'yticklabel', '')
                        end
                    end
                    vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/10;
                    if aindex==1 && findex~=1
                        text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
                        set(gca,'xticklabel','')
                    end
                    grid off
                    box off
                    if aindex==1 && findex==1
                        axis on
                        set(gca,'xtick',xlimits)
                        set(gca,'xticklabel',{xlimits})
                        xlabel('Time (ms)');
                        ylabel('F.R. (Hz)');
                    else
                        set(gca, 'yticklabel', '')
                    end
                    if aindex==numamps && findex==round(numfreqs/2)
                        title(sprintf('%s-%s-%s cell %d: ON & OFF trials (Min reps = %.0f ON, %.0f OFF) %.1f-%.1f kHz @ %.0f-%.0f dB',...
                            expdate,session,filenum,clust,min(min(min(nrepsON))),min(min(min(nrepsOFF))),freqs(1)/1000,...
                            freqs(end)/1000,amps(1),amps(end)))
                    end
                end
            end
            subplot1(ceil(numfreqs/3))
            
            
         % dindex
    end %nclust
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for m=1:length(recordings)
%     if strcmp(recordings(m).expdate, expdate) && strcmp(recordings(m).session, session) && strcmp(recordings(m).filenum, filenum)
%     for j=1:size(recordings(m).tetrode)
%         for k=1:size(recordings(m).tetrode(j,:).cluster)
%         clust1(k,:)=recordings(m).tetrode(j,:).cluster(k,:).number;
%         end
%     end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot ON only
if ~isempty(cell)
    clust=cell;
   
        figure
        p=0;
        if numdurs==1
            subplot1(numamps,numfreqs)
        else
            subplot1(numdurs, numamps)
        end
        for aindex=numamps:-1:1
            for findex=1:numfreqs
                 for dindex=1:length(durs);
                p=p+1;
                subplot1(p)
                hold on
                spiketimesON=mM1ONp(clust, findex, aindex, dindex).spiketimes; % All spiketimes.
                X=xlimits(1):binwidth:xlimits(2); % Histogram w/specified bin centers
                [NON, xON]=hist(spiketimesON, X);
                NON=NON./nrepsON(findex, aindex, dindex); % Bin count / # trials
                NON=1000*NON./binwidth; %normalize to spike rate in Hz
                bON=bar(xON, NON,1);
                
                
                set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                if aindex==1 && findex==1
                    line([PPAstart width+PPAstart], [-.05 -.05], 'color', 'c', 'linewidth', 2)
                end
                line(xlimits, [0 0], 'color', 'k')
                xlim(xlimits)
                ylim(ylimits1(clust,:))
            end
        end
        end
        % Label amps and freqs.
        p=0;
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                p=p+1;
                subplot1(p)
                if findex==1
                    ylabel(sprintf('%.0f',amps(aindex)))
                    if aindex~=1
                        set(gca, 'yticklabel', '')
                    end
                end
                vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/10;
                if aindex==1 && findex~=1
                    text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
                    set(gca,'xticklabel','')
                end
                grid off
                box off
                if aindex==1 && findex==1
                    axis on
                    set(gca,'xtick',xlimits)
                    set(gca,'xticklabel',{xlimits})
                    xlabel('Time (ms)');
                    ylabel('F.R. (Hz)');
                else
                    set(gca, 'yticklabel', '')
                end
                if findex==round(numfreqs/2) && aindex==numamps
                    title(sprintf('%s-%s-%s cell %d tetrode %s: ON trials only',expdate,session,filenum, clust, channel))
                end
            end
        end
        subplot1(ceil(numfreqs/3))
    %dindex
else
    for clust=1:Nclusters
        %      for i=1:length(clust1)
        %         clust=clust1(i);
        
            figure
            p=0;        if numdurs==1
                subplot1(numamps,numfreqs)
            else
                subplot1(numdurs, numamps)
            end
            for aindex=numamps:-1:1
                for findex=1:numfreqs
                    for dindex=1:length(durs);
                    p=p+1;
                    subplot1(p)
                    hold on
                    spiketimesON=mM1ONp(clust, findex, aindex, dindex).spiketimes; % All spiketimes.
                    X=xlimits(1):binwidth:xlimits(2); % Histogram w/specified bin centers
                    [NON, xON]=hist(spiketimesON, X);
                    NON=NON./nrepsON(findex, aindex, dindex); % Bin count / # trials
                    NON=1000*NON./binwidth; %normalize to spike rate in Hz
                    bON=bar(xON, NON,1);
                    set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                    line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                    if aindex==1 && findex==1
                        line([PPAstart width+PPAstart], [-.05 -.05], 'color', 'c', 'linewidth', 2)
                    end
                    line(xlimits, [0 0], 'color', 'k')
                    xlim(xlimits)
                    ylim(ylimits1(clust,:))
                end
            end
            end
            % Label amps and freqs.
            p=0;
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                    p=p+1;
                    subplot1(p)
                    if findex==1
                        ylabel(sprintf('%.0f',amps(aindex)))
                        if aindex~=1
                            set(gca, 'yticklabel', '')
                        end
                    end
                    vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/10;
                    if aindex==1 && findex~=1
                        text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
                        set(gca,'xticklabel','')
                    end
                    grid off
                    box off
                    if aindex==1 && findex==1
                        axis on
                        set(gca,'xtick',xlimits)
                        set(gca,'xticklabel',{xlimits})
                        xlabel('Time (ms)');
                        ylabel('F.R. (Hz)');
                    else
                        set(gca, 'yticklabel', '')
                    end
                    if findex==round(numfreqs/2) && aindex==numamps
                        title(sprintf('%s-%s-%s cell %d tetrode %s: ON trials only',expdate,session,filenum, clust, channel))
                    end
                end
            end
            subplot1(ceil(numfreqs/3))
         %dindex
    end %clust
end



% Plot OFF Only
if ~isempty(cell)
    clust=cell;
    
        figure
        p=0;        
        if numdurs==1
            subplot1(numamps,numfreqs)
        else
            subplot1(numdurs, numamps)
        end
        for aindex=numamps:-1:1
            for findex=1:numfreqs
                for dindex=1:length(durs);
                p=p+1;
                subplot1(p)
                hold on
                spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); % specify bin centers
                [NOFF, xOFF]=hist(spiketimesOFF, X);
                NOFF=NOFF./nrepsOFF(findex, aindex, dindex);
                NOFF=1000*NOFF./binwidth; %normalize to spike rate in Hz
                bOFF=bar(xOFF, NOFF,1);
                set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                line(xlimits, [0 0], 'color', 'k')
                xlim(xlimits)
                ylim(ylimits1(clust,:))
            end
        end
        end
        % Label amps and freqs.
        p=0;
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                p=p+1;
                subplot1(p)
                if findex==1
                    ylabel(sprintf('%.0f',amps(aindex)))
                    if aindex~=1
                        set(gca, 'yticklabel', '')
                    end
                end
                vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/10;
                if aindex==1 && findex~=1
                    text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
                    set(gca,'xticklabel','')
                end
                grid off
                box off
                if aindex==1 && findex==1
                    axis on
                    set(gca,'xtick',xlimits)
                    set(gca,'xticklabel',{xlimits})
                    xlabel('Time (ms)');
                    ylabel('F.R. (Hz)');
                else
                    set(gca, 'yticklabel', '')
                end
                if findex==round(numfreqs/2) && aindex==numamps
                    title(sprintf('%s-%s-%s cell %d tetrode %s: OFF trials only',expdate,session,filenum, clust, channel))
                end
            end
        end
        subplot1(ceil(numfreqs/3))
  %dindex
else
    for clust=1:Nclusters
        %      for i=1:length(clust1)
        %         clust=clust1(i);
        
            figure
            p=0;       
            if numdurs==1
                subplot1(numamps,numfreqs)
            else
                subplot1(numdurs, numamps)
            end
            for aindex=numamps:-1:1
                for findex=1:numfreqs
                    for dindex=1:length(durs);
                    p=p+1;
                    subplot1(p)
                    hold on
                    spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); % specify bin centers
                    [NOFF, xOFF]=hist(spiketimesOFF, X);
                    NOFF=NOFF./nrepsOFF(findex, aindex, dindex);
                    NOFF=1000*NOFF./binwidth; %normalize to spike rate in Hz
                    bOFF=bar(xOFF, NOFF,1);
                    set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                    line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    xlim(xlimits)
                    ylim(ylimits1(clust,:))
                end
            end
            end
            % Label amps and freqs.
            p=0;
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                    
                        p=p+1;
                    
                    subplot1(p)
                    if findex==1
                        ylabel(sprintf('%.0f',amps(aindex)))
                        if aindex~=1
                            set(gca, 'yticklabel', '')
                        end
                    end
                    vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/10;
                    if aindex==1 && findex~=1
                        text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
                        set(gca,'xticklabel','')
                    end
                    grid off
                    box off
                    if aindex==1 && findex==1
                        axis on
                        set(gca,'xtick',xlimits)
                        set(gca,'xticklabel',{xlimits})
                        xlabel('Time (ms)');
                        ylabel('F.R. (Hz)');
                    else
                        set(gca, 'yticklabel', '')
                    end
                    if findex==round(numfreqs/2) && aindex==numamps
                        title(sprintf('%s-%s-%s cell %d tetrode %s: OFF trials only',expdate,session,filenum, clust, channel))
                    end
                end
            end
            subplot1(ceil(numfreqs/3))
         %dindex
    end %clust
end


%%
if combine_ONOFF==1
    for dindex=1:length(durs);
        for clust=1:Nclusters;
            figure
            p=0;        if numdurs==1
                subplot1(numamps,numfreqs)
            else
                subplot1(numdurs, numamps)
            end
            for aindex=numamps:-1:1
                for findex=1:numfreqs
                    p=p+1;
                    subplot1(p)
                    hold on
                    
                    spiketimes=[mM1ONp(clust, findex, aindex, dindex).spiketimes mM1OFFp(clust, findex, aindex, dindex).spiketimes];
                    
                    
                    X=xlimits(1):binwidth:xlimits(2);
                    [N, x]=hist(spiketimes, X);
                    
                    N=N./nrepsON(findex, aindex, dindex); %
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    
                    
                    b=bar(x, N,1);
                    hold on
                    offset=0;
                    yl=ylimits1(clust,:);
                    inc=(yl(2))/max(max(max(nrepsOFF)));
                    if rasters==1
                        for n=1:nrepsOFF(findex, aindex, dindex)
                            spiketimes2=[M1OFFp(clust, findex, aindex, dindex, n).spiketimes M1ONp(clust, findex, aindex, dindex, n).spiketimes];
                            offset=offset+inc;
                            h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.k');
                        end
                    end
                    
                    
                    
                    set(b, 'facecolor', 'none','edgecolor', [0 0 0]);
                    line([0 0+durs(dindex)], [-.01 -.01], 'color', 'm', 'linewidth', 2)
                    if aindex==1 && findex==1
                        line([PPAstart width+PPAstart], [-.05 -.05], 'color', 'c', 'linewidth', 2)
                    end
                    line(xlimits, [0 0], 'color', 'k')
                    
                    xlim(xlimits)
                    if rasters==1
                        ylimits2(clust,2)=ylimits1(clust,2)*3;
                        ylim(ylimits2(clust,:))
                    else
                        ylim(ylimits1(clust,:));
                    end
                    
                end
            end
        end
            % Label amps and freqs.
            p=0;
            for aindex=[numamps:-1:1]
                for findex=1:numfreqs
                    if numdurs==1
                        p=p+1;
                    end
                    subplot1(p)
                    if findex==1
                        ylabel(sprintf('%.0f',amps(aindex)))
                        if aindex~=1
                            set(gca, 'yticklabel', '')
                        end
                    end
                    vpos=ylimits1(clust,1)-diff(ylimits1(clust,:))/10;
                    if aindex==1 && findex~=1
                        text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
                        set(gca,'xticklabel','')
                    end
                    grid off
                    box off
                    if aindex==1 && findex==1
                        axis on
                        set(gca,'xtick',xlimits)
                        set(gca,'xticklabel',{xlimits})
                        xlabel('Time (ms)');
                        ylabel('F.R. (Hz)');
                    else
                        set(gca, 'yticklabel', '')
                    end
                    if aindex==numamps && findex==round(numfreqs/2)
                        title(sprintf('%s-%s-%s cell %d: ON & OFF trials combined %.1f-%.1f kHz @ %.0f-%.0f dB',...
                            expdate,session,filenum,clust,freqs(1)/1000,...
                            freqs(end)/1000,amps(1),amps(end)))
                    end
                end
            end
            subplot1(ceil(numfreqs/3))
            
            
        % dindex
    end
end

%% Save it to an outfile!

% Evoked spikes.
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.tetrode=channel;
out.cluster=cell;
out.M1OFFp=M1OFFp; % All spiketimes, trial-by-trial.
out.M1ONp=M1ONp;
out.mM1OFFp=mM1OFFp; % Accumulated spike times for *all* presentations of each laser/f/a combo.
out.mM1ONp=mM1ONp;
out.mM1ONspikecount=mM1ONspikecount; % Mean spikecount for each laser/f/a combo.
out.sM1ONspikecount=sM1ONspikecount;
out.semM1ONspikecount=semM1ONspikecount;
out.mM1OFFspikecount=mM1OFFspikecount;
out.sM1OFFspikecount=sM1OFFspikecount;
out.semM1OFFspikecount=semM1OFFspikecount;
% Spont spikes.
out.mM1spontON=mM1spontON;
out.sM1spontON=sM1spontON;
out.semM1spontON=semM1spontON;
out.mM1spontOFF=mM1spontOFF;
out.sM1spontOFF=sM1spontOFF;
out.semM1spontOFF=semM1spontOFF;
out.amps=amps;
out.freqs=freqs;
out.nrepsON=nrepsON;
out.nrepsOFF=nrepsOFF;
out.xlimits=xlimits;
out.PPAstart=PPAstart;
out.width=width;
out.numpulses=numpulses;
out.oepathname=oepathname;
out.OEdatafile=OEdatafile;
out.isi=isi;
out.spiketimes=spiketimes;
godatadir(expdate,session,filenum);
outfilename=sprintf('out%sArch_TC%s-%s-%s',channel,expdate,session, filenum);
save (outfilename, 'out')


if save_the_outfile==1
    out.user=whoami;
    out.expdate=expdate;
    out.session=session;
    out.filenum=filenum;
    out.tetrode=channel;
    out.cluster=cell;
    out.M1OFFp=squeeze(M1OFFp(cell,:,:,:,:)); % All spiketimes, trial-by-trial.
    out.M1ONp=squeeze(M1ONp(cell,:,:,:,:));
    out.mM1OFFp=squeeze(mM1OFFp(cell,:,:)); % Accumulated spike times for *all* presentations of each laser/f/a combo.
    out.mM1ONp=squeeze(mM1ONp(cell,:,:));
    out.M1OFFp2=squeeze(M1OFFp2(cell,:,:,:,:)); % All spiketimes, trial-by-trial, ON
    out.M1ONp2=squeeze(M1ONp2(cell,:,:,:,:));
    out.mM1OFFp2=squeeze(mM1OFFp2(cell,:,:)); % Accumulated spike times for *all* presentations of each laser/f/a combo.
    out.mM1ONp2=squeeze(mM1ONp2(cell,:,:));
    out.M1OFFp3=squeeze(M1OFFp3(cell,:,:,:,:)); % All spiketimes, trial-by-trial,
    out.M1ONp3=squeeze(M1ONp3(cell,:,:,:,:));
    out.mM1OFFp3=squeeze(mM1OFFp3(cell,:,:)); % Accumulated spike times OFF
    out.mM1ONp3=squeeze(mM1ONp3(cell,:,:));
    out.M1OFFp4=squeeze(M1OFFp4(cell,:,:,:,:)); % All spiketimes, trial-by-trial.
    out.M1ONp4=squeeze(M1ONp4(cell,:,:,:,:));
    out.mM1OFFp4=squeeze(mM1OFFp4(cell,:,:)); % Accumulated spike times Continuous
    out.mM1ONp4=squeeze(mM1ONp4(cell,:,:));
    %     out.mM1ONspikecount=squeeze(mM1ONspikecount(cell,:,:)); % Mean spikecount for each laser/f/a combo.
    %     out.sM1ONspikecount=squeeze(sM1ONspikecount(cell,:,:));
    %     out.semM1ONspikecount=squeeze(semM1ONspikecount(cell,:,:));
    %     out.mM1OFFspikecount=squeeze(mM1OFFspikecount(cell,:,:));
    %     out.sM1OFFspikecount=squeeze(sM1OFFspikecount(cell,:,:));
    %     out.semM1OFFspikecount=squeeze(semM1OFFspikecount(cell,:,:));
    %   Spont spikes.
    %     out.mM1spontON=squeeze(mM1spontON(cell,:,:));
    %     out.sM1spontON=squeeze(sM1spontON(cell,:,:));
    %     out.semM1spontON=squeeze(semM1spontON(cell,:,:));
    %     out.mM1spontOFF=squeeze(mM1spontOFF(cell,:,:));
    %     out.sM1spontOFF=squeeze(sM1spontOFF(cell,:,:));
    %     out.semM1spontOFF=squeeze(semM1spontOFF(cell,:,:));
    out.amps=amps;
    out.freqs=freqs;
    out.combine_ONOFF=combine_ONOFF;
    out.nrepsON=nrepsON;
    out.nrepsOFF=nrepsOFF;
    out.xlimits=xlimits;
    out.PPAstart=PPAstart;
    out.width=width;
    out.numpulses=numpulses;
    out.oepathname=oepathname;
    out.OEdatafile=OEdatafile;
    out.isi=isi;
    out.spiketimes=spiketimes;
    out.inRange=inRange(cell);
    
    %out.M1ONspikecounts=squeeze(M1ONspikecounts(cell,:,:,:,:));
    out.M1OFFspikecounts=squeeze(M1OFFspikecounts(cell,:,:,:,:));
    outfilename=sprintf('out%sArch_TC%s-%s-%s-%d',channel,expdate,session, filenum, cell);
    cd(location);
    save (outfilename, 'out');
    fprintf('\nsaved the outfile in a synced folder');
end
godatadir(expdate,session,filenum);
fprintf('\n Saved to %s.\n', outfilename)





fprintf('\n\n')

