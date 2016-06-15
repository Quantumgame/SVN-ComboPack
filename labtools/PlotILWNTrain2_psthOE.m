
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
location='D:\lab\ClickTrainOutfiles';
location='D:\lab\SomArchData\WNtrains';
save_outfile=0;
rasters=1;
pot_outline=1;

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

outfilename=sprintf('out_T%s_ILWNTrain%s-%s-%s-psth',channel,expdate,session, filenum);
fprintf('\ntrying to load %s...', outfilename)
% try
%     godatadir(expdate, session, filenum)
%     load(outfilename)
% if out.xlimits~=xlimits
%     ProcessILWNTrain2_psthOE(expdate, session, filenum, channel, xlimits,varargin);
% end
% catch
fprintf('\nCould not find an outfile, processing data');
%     fprintf('failed to load outfile')
ProcessILWNTrain2_psthOE(expdate, session, filenum, channel, xlimits,ylimits,binwidth, cell);
load(outfilename);
%end

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


if isempty(event); fprintf('\nno stimuli\n'); return; end

samprate=out.samprate;
fprintf('\ncomputing tuning curve...');

fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));
event=out.event;
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
M1OFFp=out.M1OFFp;
M1ONp=out.M1ONp;
nrepsON=out.nrepsON;
nrepsOFF=out.nrepsOFF;
M1ONspikecounts=out.M1ONspikecounts;
M1spontON=out.M1spontON;
M1OFFspikecounts=out.M1OFFspikecounts;
M1spontOFF=out.M1spontOFF;
inRange=out.inRange;
spiketimes=out.spiketimes;
ylimits1=out.ylimits1;
mM1ONp=out.mM1ONp;
mM1OFFp=out.mM1OFFp;
PPAstart=out.PPAstart;
width=out.width;
numpulses=out.numpulses;
PPAisi=out.PPAisi;

for clust=1:Nclusters %could be multiple clusts (cells) per tetrode
    fprintf('\ncell %d:', clust)
    fprintf('\ntotal num spikes: %d', length(spiketimes(clust).spiketimes))
    fprintf('\nIn range: %d', inRange(clust))
end

%%%%%%%%%%%%% DONE PROCESSING %%%%%%%%%% PLOTTING NOW %%%%%%%%%%%%%%%%%%%
if ~isempty(M1ONp)
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
                        NON=1000*NON./binwidth; %normalize to spike rate in Hz
                        NOFF=NOFF./nrepsOFF(findex, aindex, dindex,iindex);
                        NOFF=1000*NOFF./binwidth;
                        bON=bar(xON, NON,1);
                        hold on
                        bOFF=bar(xOFF,NOFF,1);
                        set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                        set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                        offset=0;
                        yl=ylimits1(clust,:);
                        inc=(yl(2))/max(max(max(nrepsOFF)));
                        if rasters==1
                            
                            for n=1:nrepsOFF(findex, aindex, dindex)
                                spiketimes2=M1OFFp(clust, findex, aindex, dindex, iindex, n).spiketimes;
                                offset=offset+inc;
                                h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.k');
                            end
                            for n=1:nrepsON(findex, aindex, dindex)
                                spiketimes2=M1ONp(clust, findex, aindex, dindex, iindex, n).spiketimes;
                                offset=offset+inc;
                                h=plot(spiketimes2, ylimits1(clust,2)+ones(size(spiketimes2))+offset, '.g');
                            end
                        end
                        if rasters==1
                            ylimits2(clust,2)=ylimits1(clust,2)*3;
                            ylim(ylimits2(clust,:))
                        else
                            ylim(ylimits1(clust,:));
                        end
                        line([PPAstart width+PPAstart], [-.1 -.1], 'color', 'c', 'linewidth', 2)
                        line(xlimits, [0 0], 'color', 'k')
                        
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
                        ylabel(sprintf('%dms', isis(iindex)));;
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
        
        if pot_outline==1
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
                            NON=1000*NON./binwidth; %normalize to spike rate in Hz
                            NOFF=NOFF./nrepsOFF(findex, aindex, dindex,iindex);
                            NOFF=1000*NOFF./binwidth;
                            non=smooth(NON);
                            noff=smooth(NOFF);
                            hold on;
                            plot(xON, non,'Color',([51 204 0]/255),'LineWidth',2);
                            plot(xOFF, noff, 'Color',[0 0 0], 'LineWidth',2);
                            ylimits2(clust,2)=ylimits1(clust,2)-ylimits1(clust,2)*.30;
                            ylim(ylimits2(clust,:));
                            
                            line([PPAstart width+PPAstart], [-.1 -.1], 'color', 'c', 'linewidth', 3)
                            line(xlimits, [0 0], 'color', 'k')
                            
                            xlim(xlimits)
                            
                            stim=[1:clickdurs];
                            line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                            for i=1:nclicks(iindex)-1
                                from_this_point=max(max(stim)+isis(iindex)-clickdurs);
                                add_this=max(max(stim)+isis(iindex));
                                stim=[stim from_this_point:add_this];
                                line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
                            end
                            ylabel(sprintf('%dms', isis(iindex)));;
                        end
                    end
                end
                xlabel('time (ms)');
                all_stims(iindex).stim=stim;
            end
            
            subplot1(1)
            title(sprintf('%s-%s-%s laser ON and OFF, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
            set(gcf, 'pos', [618    72      520   900])
            shg
            refresh
            orient tall
        end
        
        
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
                            NON=1000*NON./binwidth; %normalize to spike rate in Hz
                            NOFF=NOFF./nrepsOFF(findex, aindex, dindex,iindex);
                            NOFF=1000*NOFF./binwidth;
                            bON=bar(xON, NON,1);
                            hold on
                            bOFF=bar(xOFF,NOFF,1);
                            set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
                            set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
                            offset=0;
                            yl=ylimits1(clust,:);
                            inc=(yl(2))/max(max(max(nrepsOFF)));
                            if rasters==1
                                
                                for n=1:nrepsOFF(findex, aindex, dindex)
                                    spiketimes2=M1OFFp(clust, findex, aindex, dindex, iindex, n).spiketimes;
                                    offset=offset+inc;
                                    h=plot(spiketimes2, yl(2)+ones(size(spiketimes2))+offset, '.k');
                                end
                                for n=1:nrepsON(findex, aindex, dindex)
                                    spiketimes2=M1ONp(clust, findex, aindex, dindex, iindex, n).spiketimes;
                                    offset=offset+inc;
                                    h=plot(spiketimes2, ylimits1(clust,2)+ones(size(spiketimes2))+offset, '.g');
                                end
                            end
                            
                            %line([PPAstart width+PPAstart], [-.1 -.1], 'color', 'c', 'linewidth', 2)
                            line(xlimits, [0 0], 'color', 'k')
                            if rasters==1
                                ylimits2(clust,2)=ylimits1(clust,2)*3;
                                ylim(ylimits2(clust,:))
                            else
                                ylim(ylimits1(clust,:));
                            end
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
end
% %plot the OFF
% if ~isempty(cell)
%     clust=cell;
%     figure;
%     p=0;
%     subplot1(numisis, 1)
%     for iindex=[1:numisis]
%         for dindex=1:numdurs
%             for findex=1:numfreqs
%                 for aindex=numamps
%                     p=p+1;
%                     subplot1( p)
%                     hold on
%                     spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex, iindex).spiketimes;
%                     X=xlimits(1):binwidth:xlimits(2); %specify bin centers
%                     [NOFF, xOFF]=hist(spiketimesOFF, X);
%                     NOFF=NOFF./nrepsOFF(findex, aindex, dindex,iindex);
%                     NOFF=1000*NOFF./binwidth;
%                     bOFF=bar(xOFF,NOFF,1);
%                     set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
%                     line(xlimits, [0 0], 'color', 'k')
%                     ylim(ylimits1(clust,:))
%                     xlim(xlimits)
%                     stim=[1:clickdurs];
%                     line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
%                     for i=1:nclicks(iindex)-1
%                         from_this_point=max(max(stim)+isis(iindex)-clickdurs);
%                         add_this=max(max(stim)+isis(iindex));
%                         stim=[stim from_this_point:add_this];
%                         line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
%                     end
%                     title(sprintf('isi %dms', isis(iindex)));
%                 end
%             end
%         end
%         all_stims(iindex).stim=stim;
%     end
%
%     subplot1(1)
%     title(sprintf('%s-%s-%s laser OFF, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
%     set(gcf, 'pos', [618    72      520   900])
%     shg
%     refresh
%     orient tall
% else
%
%     for clust=1:Nclusters
%         figure;
%         p=0;
%         subplot1(numisis, 1)
%         for iindex=[1:numisis]
%             for dindex=1:numdurs
%                 for findex=1:numfreqs
%                     for aindex=numamps
%                         p=p+1;
%                         subplot1( p)
%                         hold on
%                         spiketimesOFF=mM1OFFp(clust, findex, aindex, dindex, iindex).spiketimes;
%                         X=xlimits(1):binwidth:xlimits(2); %specify bin centers
%                         [NOFF, xOFF]=hist(spiketimesOFF, X);
%                         NOFF=NOFF./nrepsOFF(findex, aindex, dindex,iindex);
%                         NOFF=1000*NOFF./binwidth;
%                         bOFF=bar(xOFF,NOFF,1);
%                         set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
%                         line(xlimits, [0 0], 'color', 'k')
%                         ylim(ylimits1(clust,:))
%                         xlim(xlimits)
%                         stim=[1:clickdurs];
%                         line([0 clickdurs], [-2 3], 'color', 'm', 'linewidth', 4)
%                         for i=1:nclicks(iindex)-1
%                             from_this_point=max(max(stim)+isis(iindex)-clickdurs);
%                             add_this=max(max(stim)+isis(iindex));
%                             stim=[stim from_this_point:add_this];
%                             line([from_this_point add_this], [-2 3], 'color', 'm', 'linewidth', 4)
%                         end
%                         ylabel(sprintf('%dms', isis(iindex)));
%                     end
%                 end
%             end
%             add_this=[];
%             from_this_point=[];
%             all_stims(iindex).stim=stim;
%         end
%
%         subplot1(1)
%         title(sprintf('%s-%s-%s laser OFF, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
%         set(gcf, 'pos', [618    72      520   900])
%         shg
%         refresh
%         orient tall
%     end
%
% end
% if ~isempty(M1ONp)
%
%     %plot the ON
%     if ~isempty(cell)
%         clust=cell;
%         figure;
%         p=0;
%         subplot1(numisis, 1)
%         for iindex=[1:numisis]
%             for dindex=1:numdurs
%                 for findex=1:numfreqs
%                     for aindex=numamps
%                         p=p+1;
%                         subplot1( p)
%                         spiketimesON=mM1ONp(clust, findex, aindex, dindex, iindex).spiketimes;
%                         X=xlimits(1):binwidth:xlimits(2); %specify bin centers
%                         [NON, xON]=hist(spiketimesON, X);
%                         NON=NON./nrepsON(findex, aindex, dindex,iindex);
%                         bON=bar(xON, NON,1);
%                         set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
%                         line([PPAstart width+PPAstart], [-.1 -.1], 'color', 'c', 'linewidth', 2)
%                         line(xlimits, [0 0], 'color', 'k')
%                         ylim(ylimits1(clust,:))
%                         xlim(xlimits)
%
%                         hold on
%
%                         stim=[1:clickdurs];
%                         line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
%                         for i=1:nclicks(iindex)-1
%                             from_this_point=max(max(stim)+isis(iindex)-clickdurs);
%                             add_this=max(max(stim)+isis(iindex));
%                             stim=[stim from_this_point:add_this];
%                             line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
%                         end
%                         title(sprintf('isi %dms', isis(iindex)));
%                     end
%                 end
%             end
%             all_stims(iindex).stim=stim;
%         end
%
%         subplot1(1)
%         title(sprintf('%s-%s-%s laser ON, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
%         set(gcf, 'pos', [618    72      520   900])
%         shg
%         refresh
%         orient tall
%     else
%         for clust=1:Nclusters
%             figure;
%             p=0;
%             subplot1(numisis, 1)
%             for iindex=[1:numisis]
%                 for dindex=1:numdurs
%                     for findex=1:numfreqs
%                         for aindex=numamps
%                             p=p+1;
%                             subplot1( p)
%                             spiketimesON=mM1ONp(clust, findex, aindex, dindex, iindex).spiketimes;
%                             X=xlimits(1):binwidth:xlimits(2); %specify bin centers
%                             [NON, xON]=hist(spiketimesON, X);
%                             NON=NON./nrepsON(findex, aindex, dindex,iindex);
%                             bON=bar(xON, NON,1);
%                             set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
%                             %line([PPAstart width+PPAstart], [-.1 -.1], 'color', 'c', 'linewidth', 2)
%                             line(xlimits, [0 0], 'color', 'k')
%                             ylim(ylimits1(clust,:))
%                             xlim(xlimits)
%
%                             hold on
%
%                             stim=[1:clickdurs];
%                             line([0 clickdurs], [-.02 -.02], 'color', 'm', 'linewidth', 4)
%                             for i=1:nclicks(iindex)-1
%                                 from_this_point=max(max(stim)+isis(iindex)-clickdurs);
%                                 add_this=max(max(stim)+isis(iindex));
%                                 stim=[stim from_this_point:add_this];
%                                 line([from_this_point add_this], [-.02 -.02], 'color', 'm', 'linewidth', 4)
%                             end
%                             title(sprintf('isi %dms', isis(iindex)));
%                         end
%                     end
%                 end
%                 all_stims(iindex).stim=stim;
%             end
%
%             subplot1(1)
%             title(sprintf('%s-%s-%s laser ON, tetrode %s, cell %d   %s', expdate,session, filenum, channel, clust, get(get(gca, 'title'), 'string')))
%             set(gcf, 'pos', [618    72      520   900])
%             shg
%             refresh
%             orient tall
%         end
%     end
% end


%%
%plot spikerate MTF

mMtON=out.mMtON;
mMtOFF=out.mMtOFF;
MtON=out.MtON;
MtOFF=out.MtOFF;
%mMs=out.mMs;
numisis=out.numisis;
start=0;
if isempty(cell)
    for clust=1:Nclusters
        figure;
        for isiindex=[1:numisis]
            dindex=1; findex=1; aindex=1;
            spiketimesON=mM1ONp(clust,dindex, findex,aindex,isiindex).spiketimes;
            spiketimesOFF=mM1OFFp(clust,dindex, findex,aindex,isiindex).spiketimes;
            spikecountON(isiindex)=length(find(spiketimesON>start & spiketimesON<(out.durs+start) ));
            spikecountOFF(isiindex)=length(find(spiketimesOFF>start & spiketimesOFF<(out.durs+start) ));
            spikecountON(isiindex)=spikecountON(isiindex)./out.nrepsON(isiindex); %normalize to trial average
            spikecountOFF(isiindex)=spikecountOFF(isiindex)./out.nrepsOFF(isiindex);
            spikerateON(isiindex)=1000*spikecountON(isiindex)/out.durs;%normalize to spike rate in Hz
            spikerateOFF(isiindex)=1000*spikecountOFF(isiindex)/out.durs;
        end
        pON=plot(spikerateON, 'g.-'); hold on
        set(pON, 'markersize', 30)
        pOFF=plot(spikerateOFF, 'k.-');
        set(pOFF, 'markersize', 30)
        ylabel('firing rate, Hz')
        set(gca, 'xtick', 1:numisis, 'xticklabel', out.isis)
        xlim([.5 numisis+.5])
        xlabel('ISI, ms')
        title(sprintf('%s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
    end
    %plot spikerate cycle histograms
    
    for clust=1:Nclusters
        figure
        yl=0;
        subplot1(numisis, 1)
        
        for isiindex=[1:numisis]
            isi=out.isis(isiindex);
            onsets=isi*(0:nclicks(isiindex)-1);
            %     trace_stim=squeeze(mMs(isiindex, :));
            %     t=1:length(trace_stim);
            %     t=t/10;
            %     plot(t, trace_stim,'r', onsets, zeros(size(onsets)), '.')
            dindex=1; findex=1; aindex=1;
            spiketimesON=mM1ONp(clust,dindex, findex,aindex,isiindex).spiketimes;
            spiketimesOFF=mM1OFFp(clust,dindex, findex,aindex,isiindex).spiketimes;
            phaseON=[];
            phaseOFF=[];
            for s=spiketimesON
                if s>0 & s<onsets(end)+isi
                    p=s-onsets;
                    q=p(p>0);
                    u=q(end);
                    phaseON=[phaseON 2*pi*u/isi];
                end
            end
            for s=spiketimesOFF
                if s>0 & s<onsets(end)+isi
                    p=s-onsets;
                    q=p(p>0);
                    u=q(end);
                    phaseOFF=[phaseOFF 2*pi*u/isi];
                end
            end
            subplot1(isiindex)
            [NON xON]=hist(phaseON, [0:pi/10:2*pi]); hold on;
            [NOFF xOFF]=hist(phaseOFF, [0:pi/10:2*pi]);
            bON=bar(xON, NON,1);
            bOFF=bar(xOFF, NOFF,1);
            set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
            set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
            % spikecount(isiindex)=length(find(spiketimes>0 & spiketimes<out.durs ));
            % spikecount(isiindex)=spikecount(isiindex)./out.nreps(isiindex); %normalize to trial average
            % spikerate(isiindex)=1000*spikecount(isiindex)/out.durs;%normalize to spike rate in Hz
            xlim([0 2*pi])
            yl=max(yl, ylim);
            ylabel(sprintf('isi %dms',isi));
        end
        for isiindex=[1:numisis]
            subplot1(isiindex)
            ylim(yl)
        end
        
        xlabel('phase')
        subplot1(1)
        title(sprintf('cycle spike histogram %s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')));
        set(gcf, 'pos', [618    72      520   900])
        shg
        refresh
        orient tall
    end
else
    figure;
    clust=cell; aindex=1;dindex=1;findex=1;
    for isiindex=[1:numisis]
        spiketimesON=mM1ONp(clust,dindex, findex,aindex,isiindex).spiketimes;
            spiketimesOFF=mM1OFFp(clust,dindex, findex,aindex,isiindex).spiketimes;
        spikecountON(isiindex)=length(find(spiketimesON>start & spiketimesON<(out.durs+start) ));
        spikecountOFF(isiindex)=length(find(spiketimesOFF>start & spiketimesOFF<(out.durs+start) ));
        spikecountON(isiindex)=spikecountON(isiindex)./out.nrepsON(isiindex); %normalize to trial average
        spikecountOFF(isiindex)=spikecountOFF(isiindex)./out.nrepsOFF(isiindex);
        spikerateON(isiindex)=1000*spikecountON(isiindex)/out.durs;%normalize to spike rate in Hz
        spikerateOFF(isiindex)=1000*spikecountOFF(isiindex)/out.durs;
    end
    pON=plot(spikerateON, 'g.-'); hold on
    set(pON, 'markersize', 30)
    pOFF=plot(spikerateOFF, 'k.-');
    set(pOFF, 'markersize', 30)
    ylabel('firing rate, Hz')
    set(gca, 'xtick', 1:numisis, 'xticklabel', out.isis)
    xlim([.5 numisis+.5])
    xlabel('ISI, ms')
    title(sprintf('%s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
    
    figure
    yl=0;
    subplot1(numisis, 1)
    
    for isiindex=[1:numisis]
        isi=out.isis(isiindex);
        onsets=isi*(0:nclicks(isiindex)-1);
        spiketimesON=mM1ONp(clust,dindex, findex,aindex,isiindex).spiketimes;
        spiketimesOFF=mM1OFFp(clust,dindex, findex,aindex,isiindex).spiketimes;

        phaseON=[];
        phaseOFF=[];
        s=[];
        for s=spiketimesON
            if s>0 & s<onsets(end)+isi
                p=s-onsets;
                q=p(p>0);
                u=q(end);
                phaseON=[phaseON 2*pi*u/isi];
            end
        end
        for s=spiketimesOFF
            if s>0 & s<onsets(end)+isi
                p=s-onsets;
                q=p(p>0);
                u=q(end);
                phaseOFF=[phaseOFF 2*pi*u/isi];
            end
        end
        subplot1(isiindex)
        [NON xON]=hist(phaseON, [0:pi/10:2*pi]); hold on;
        [NOFF xOFF]=hist(phaseOFF, [0:pi/10:2*pi]);
        bON=bar(xON, NON,1);
        bOFF=bar(xOFF, NOFF,1);
        set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
        set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);

        xlim([0 2*pi])
        yl=max(yl, ylim);
        ylabel(sprintf('isi %dms',isi));
    end
    for isiindex=[1:numisis]
        subplot1(isiindex)
        ylim(yl)
    end
    
    xlabel('phase')
    subplot1(1)
    title(sprintf('cycle spike histogram %s-%s-%s   %s', expdate,session, filenum, get(get(gca, 'title'), 'string')))
    set(gcf, 'pos', [618    72      520   900])
    shg
    refresh
    orient tall
end
%%
godatadir(expdate,session,filenum);

%assign outputs
if save_outfile==1
    %cell=str2num(cell);
    out.mM1ONp=squeeze(mM1ONp(cell,:,:,:));
    out.mM1OFFp=squeeze(mM1OFFp(cell,:,:,:));
    out.M1ONp=squeeze(M1ONp(cell,:,:,:));
    out.M1OFFp=squeeze(M1OFFp(cell,:,:,:));
    out.quality=5;
    out.mouse=61;
else
    out.mM1ONp=mM1ONp;
    out.mM1OFFp=mM1OFFp;
    out.M1ONp=M1ONp;
    out.M1OFFp=M1OFFp;
end
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
out.tetrode=channel;
out.Nclusters=Nclusters;



% outfilename=sprintf('out_T%s_ILWNTrain%s-%s-%s-psth',channel,expdate,session, filenum);
% save (outfilename, 'out')
% fprintf('\n Saved to %s.\n', outfilename)



% if save_outfile==1
% cd('D:\lab\Somatostatin_project_shared_folder\Clicks\')
% outfilename=sprintf('out_T%s_ILWNTrain%s-%s-%s-%d',channel,expdate,session, filenum, cell);
% save(outfilename, 'out');
% fprintf('saved the outfile in Clicks folder'); %ira 7.29.15

if save_outfile==1
    cd(location)
    outfilename=sprintf('out_T%s_ILWNTrain%s-%s-%s-%d',channel,expdate,session, filenum, cell);
    save(outfilename, 'out');
    print (outfilename,'-dpdf');
end
end


