function PlotMClustAOTC_NL(expdate, session, filenum, varargin)
% same as PlotMClustAOTC but for tetrode data recorded on neuralynx
% here we need to solve the synchronization problem between the neuralynx and exper
%
%  for use with tetrode or other data cluster-cut with MClust
% plots spike rasters and psth tuning curve
% separately for sounds and for AO pulses
%
% usage: PlotMClustAOTC_NL(expdate, session, filenum, [xlimits], [ylimits], [binwidth], [events2Plot])
% Where 'events2Plot' is the number of events (pulses &/or sounds) to plot. Defaults to all.
%(xlimits, ylimits, binwidth, events are optional)
%
%  defaults: binwidth=5ms, xlimits=[0 100]
% mw 12-19-2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    ylimits=-1;
    xlimits=[0 100];
    binwidth=5;
    events2Plot = nan;
elseif nargin==4
    xlimits=varargin{1};
    if isempty(xlimits)
        xlimits=[0 100];
    end
    ylimits=-1;
    binwidth=5;
    events2Plot = nan;
elseif nargin==5
    xlimits=varargin{1};
    if isempty(xlimits)
        xlimits=[0 100];
    end
    ylimits=varargin{2};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=5;
    events2Plot = nan;
elseif nargin==6
    xlimits=varargin{1};
    if isempty(xlimits)
        xlimits=[0 100];
    end
    ylimits=varargin{2};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=varargin{3};
    if isempty(binwidth)
        binwidth=5;
    end
    events2Plot = nan;
elseif nargin==7
    xlimits=varargin{1};
    if isempty(xlimits)
        xlimits=[0 100];
    end
    ylimits=varargin{2};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=varargin{3};
    if isempty(binwidth)
        binwidth=5;
    end
    events2Plot = varargin{4};
    if isempty(events2Plot)
        events2Plot = nan;
    end
    
else
    error('wrong number of arguments');
end

lostat=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

fs=10;

[ D, E, S, AO]=gogetdata(expdate,session,filenum);
stim=S.nativeScalingStim*double(S.stim);
event=E.event;
%T1trace=T1.nativeScaling*double(T1.trace) +T1.nativeOffset;
AOtrace=AO.nativeScaling*double(AO.trace) +AO.nativeOffset;
clear  AO E S
if isempty(event) fprintf('\nno tones\n'); end

% % %MClust spiketime files are of the form 121811-001-003_1.t
% % %there is one for each cluster
% % user=whoami;
% % basefn=sprintf('%s-%s-%s-%s_*', expdate, user, session, filenum);
% % d=dir(basefn);
% % numclusters=size(d, 1);
% % for clustnum=1:numclusters
% %     fn=sprintf('%s-%s-%s-%s_%d.t', expdate, user, session, filenum, clustnum);
% %     fprintf('\nreading MClust output file %s cluster %d', fn, clustnum)
% %     spiketimes(clustnum).st=read_MClust_output(fn);
% %     totalnumspikes(clustnum)=length(spiketimes(clustnum).st);
% %     fprintf('\nfile %s has %d total spikes', fn, totalnumspikes(clustnum))
% % end

% here is where we want to find the timing of the first event in the
% neuralynx events file and compare it to the first event in the exper
% events file.
%check to make sure the event type matches

fprintf('\nextracting AO pulse responses\n');

%get durs
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'aopulse')
        j=j+1;
        
        allAOdurs(j)=event(i).Param.width;
        
    end
end
if isempty(allAOdurs)
    error('No AO pulses found. Use PlotMClustTC instead')
else
    AOdurs=unique(allAOdurs);
end
numAOdurs=length(AOdurs);
if isempty(xlimits)
    xlimits=[-.5*max(AOdurs) 1.5*max(AOdurs)]; %x limits for axis
end

%get neuralynx events (modified from getSpikesForEvents.m)
eventFile    = 'Events.nev';
FieldSelection(1:5) = 1;
ExtractHeader = 0;
ExtractMode = 1;
[eventTimeStamps, EventIDs, x, y, eventStrings] = Nlx2MatEV( eventFile, FieldSelection, ExtractHeader, ExtractMode);

uniqueEventStrings=(unique(eventStrings));
fprintf('\nNL events file contains the following eventStrings:\n')
fprintf('\n%s', uniqueEventStrings{:})

%split events into their types
for n=1:length(uniqueEventStrings)
    x=find(strcmp(eventStrings,uniqueEventStrings{n}));
    eventTypeTimeStamps(n).eventTimeStamps=eventTimeStamps(x);
    eventTypeTimeStamps(n).eventString=uniqueEventStrings{n};
end
%note: my current strategy is to mimic the kentros lab workflow as follows:
%record neuralynx data. add manual timestamps to separate into files that
%match our exper files. split these files. Load .ntt files into MClust,
%cut clusters, and write files (creates .t timestamp files). Then launch
%SpikeSort3D, open spike files (.ntt), then open Timestamp files (.t)
%created by MClust, then save spike file (overwrite). Then Move the .ntt
%file into the exper processed data directory if it is not already there
%(the same one with e.g. axopatch-data). Name it TT1-session-filenum.ntt.
%mw 07-25-12
%get spiketimes from neuralynx spike file (.ntt)  (modified from getSpikesForEvents.m)
nttFilePath = sprintf('TT1-%s-%s.ntt', session, filenum); %might want more flexibility here
FieldSelection(1:3)      = 1; % set some values for the Nlx2MatSpike_v3 command
FieldSelection(4:5)      = 0;
ExtractHeader            = 1; % set some values for the Nlx2MatSpike_v3 command
ExtractMode              = 1; % set some values for the Nlx2MatSpike_v3 command
try
    [SpikeTimeStamps, ~, CellNumbers, ~] = Nlx2MatSpike( nttFilePath, FieldSelection, ExtractHeader, ExtractMode );
catch
    disp(['error processing ' nttFilePath '. File may not contain any clusters.']);
end

% skip this tetrode if there are either no cells cut, or there are
% no timestamps associated with it.
if ~any(CellNumbers>0) || length(SpikeTimeStamps) < 1
    disp(['-> No data has been loaded for ' nttFilePath '. Check that the cluster numbers have been assigned to the file']);
end %if

lastSpikeTime = max(SpikeTimeStamps);

numclusters = max(CellNumbers);

%might want to list all event names/codes, and possibly look at
%spiketimes with respect to all event types
%hard coding event types as I do here is very brittle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first plot the AO pulses, same as PlotAOPulse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M1=[];
nreps=zeros(numAOdurs);
samprate=getsamplerate(expdate, session, filenum);
samprateNL= 1e6; %NL and Mclust both always report spiketimes in microseconds;
aopulse_ONeventtype='Cheetah 32 DIO board 0 input TTL (0xFFFD)';
both_OFFeventtype='Cheetah 32 DIO board 0 input TTL (0xFFFC)';
sound_ONeventtype='Cheetah 32 DIO board 0 input TTL (0xFFFE)';
both_ONeventtype='Cheetah 32 DIO board 0 input TTL (0xFFFF)';
fprintf('\nassuming the following eventString mapping:')
fprintf('\naopulse_ONeventtype=%s', aopulse_ONeventtype)
fprintf('\nsound_ONeventtype=%s', sound_ONeventtype)
fprintf('\nboth_ONeventtype=%s', both_ONeventtype)
fprintf('\nboth_OFFeventtype=%s', both_OFFeventtype)
fprintf('\n')
%follow the binary logic: 
% a tone will produce EC
% an aopulse will produce DC
% a tone embedded in an aopulse will produce DFDC

%extract the traces into a big matrix M

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %sanity check: plot all NL events with respect to exper AOPulse events
% figure
% hold on
% offset=0;
% m=0; %index for counting aopulse exper events
% c=['rx'; 'bx'; 'gx'; 'mx'; 'kx'; 'cx'; 'ro'; 'bo'; 'go'; 'mo'; 'ko'; 'co'];
% for i=1:length(event)
%     if strcmp(event(i).Type, 'aopulse')
%         m=m+1;
%         pos=round(event(i).Position);%in samples
%         start=(pos+xlimits(1)*1e-3*samprate); %in samples
%         stop=(pos+xlimits(2)*1e-3*samprate)-1;%in samples
%         if stop > length(AOtrace)
%             winsize=stop-start;
%             stop=length(AOtrace);
%             start=stop-winsize;
%         end
%         region=start:stop;
%         t=1:length(region);
%         t=t*1000/samprate; %convert to to ms
%         t=t+xlimits(1); %convert to to ms after pos
%         plot(t, AOtrace(region)+offset, 'c');
%         plot(t, stim(region)+offset, 'm'); %t is in ms after pos
%         
%         %I know that eventTypeTimeStamps(3) is the 'start 001-006-CFRLF2' event
%         %I know that eventTypeTimeStamps(4) is the of the next file
%         startingeventTS=eventTypeTimeStamps(3).eventTimeStamps;
%         endingeventTS=eventTypeTimeStamps(4).eventTimeStamps;
%         %get the position in samples of the first TTL event of the right type
%         for type=1:length(eventTypeTimeStamps)
%             posNL=[];
%                     k=0; %index for counting aopulse NL events
%             for j=1:length(eventTypeTimeStamps(type).eventTimeStamps)
%                 if  eventTypeTimeStamps(type).eventTimeStamps(j)>=startingeventTS & eventTypeTimeStamps(type).eventTimeStamps(j)<endingeventTS
%                     k=k+1;
%                     if k==m
%                         posNL=eventTypeTimeStamps(type).eventTimeStamps(j);
%                         
%                         e=eventTypeTimeStamps(type).eventTimeStamps-posNL; %all events of this type, in microseconds after posNL
%                         e=e/1000; %convert events to ms after posNL
%                         plot(e, offset*ones(size(e)), c(type,:))
%                                 offset=offset+.1;
% 
%                         break
%                     end
%                 end
%                 
%             end
%         end
%         offset=offset+1;
%     end
% end
% xlim(xlimits)
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j=0;
cont=1;

if isnan(events2Plot)
    events2Plot = length(event);
    fprintf('Plotting all %d events.',length(event))
else
    fprintf('\nPlotting %d of %d events.',events2Plot,length(event))
end

%count aopulse exper events
numaopulses=0;
for i=1:length(event)
     if strcmp(event(i).Type, 'aopulse')
         numaopulses=numaopulses+1;
     end
end
fprintf('\n%d aopulse exper events', numaopulses)

%count aopulse NL events
for n=1:length(uniqueEventStrings)
    if(strcmp('Starting Recording',uniqueEventStrings{n})); 
SR=n;
    end
end
StartRecs=eventTypeTimeStamps(SR).eventTimeStamps;
[Selection,OK] = listdlg('ListString',uniqueEventStrings, 'SelectionMode', 'single', 'PromptString', ...
    'Select the manual user event that marks the beginning of this recording');
if ~OK fprintf('\nuser pressed cancel, goodbye.'); return, end
manualEventTS=eventTypeTimeStamps(Selection).eventTimeStamps;
fprintf('\nuser selected event %s at timestamp %d', eventTypeTimeStamps(Selection).eventString, eventTypeTimeStamps(Selection).eventTimeStamps) 
StartRecTS=max(StartRecs(StartRecs<manualEventTS));
nextStartRecTS=min(StartRecs(StartRecs>manualEventTS));
fprintf('\nStart Recording event prior to manual user event is %d', StartRecTS)
StartRecIdx=find(eventTimeStamps==StartRecTS);

if isempty(nextStartRecTS)
    StopRecIdx=size(eventTimeStamps); % If no next 'starting recording' exists, use last ts as stop. AKH 7/30/12
else
    StopRecIdx=find(eventTimeStamps==nextStartRecTS); % using next start recording as "stop recording"
end

numNLaopulses=0;
for i=StartRecIdx:StopRecIdx
     if strcmp(eventStrings, aopulse_ONeventtype) %note this will miss aopulses embedded inside a sound, which should be rare
         numNLaopulses=numNLaopulses+1;
     end
end
fprintf('\n%d aopulse NL events', numNLaopulses)

m=0; %index for counting aopulse exper events
for i=1:events2Plot
    if (cont)
        if strcmp(event(i).Type, 'aopulse')
            m=m+1;
            pos=round(event(i).Position);%in samples
            
            
            %get the position in samples of the TTL event of the right type
            k=0; %index for counting aopulse NL events
            for j=1:length(eventTimeStamps)
                if strcmp(eventStrings{j}, aopulse_ONeventtype)
                    k=k+1;
                    if k==m
                        posNL=eventTimeStamps(j);
                        break
                    end
                end
            end
            
            start=(pos+xlimits(1)*1e-3*samprate); %in samples
            stop=(pos+xlimits(2)*1e-3*samprate)-1;%in samples
            if stop > length(AOtrace)
                winsize=stop-start;
                stop=length(AOtrace);
                start=stop-winsize;
            end
            region=start:stop;
            
            startNL=(posNL+xlimits(1)*1e-3*samprateNL); %in NL samples
            stopNL=(posNL+xlimits(2)*1e-3*samprateNL);%in NL samples
            regionNL=startNL:stopNL;
            
            if isempty(find(region<0)) %(disallow negative start times)
                dur=event(i).Param.width;
                dindex= find(AOdurs==dur);
                nreps(dindex)=nreps(dindex)+1;
                %                M1(dindex, nreps(dindex),:)=T1trace(region);
                if ~isempty(AOtrace)
                    M2(dindex, nreps(dindex),:)=AOtrace(region);
                end
                M1stim(dindex, nreps(dindex),:)=stim(region);
                for cn=1:numclusters                      %sorted spikes from MClust
                    st=SpikeTimeStamps(CellNumbers==cn); %in microseconds (=NL samples)
                    %st=10*1000*st/samprateNL; %convert from "timestamp" to ms
                    %st_in=st(st>start & st<stop); % spiketimes in region (convert start/stop to ms)
                    %st_in=(st_in-pos);%covert to samples after aopulse onset
                    %st_in=(1000*st_in/samprate);%covert to samples after aopulse onset
                    st_in=st(st>startNL & st<stopNL); % spiketimes in region
                    st_in=st_in-posNL; %covert to microseconds after tone onset
                    st_in=1000*st_in/samprateNL;%covert to ms
                    M3(cn,dindex, nreps(dindex)).spiketimes=st_in;
                    
                    %                     I'm unclear as to where the reference point is for the time stamps in NL
                    %                     is it the beginning of acquisition?
                    
                end
                %                 figure(1)
                %                 clf;hold on
                %                 t=1:length(region);t=t/32;t=t+xlimits(1);
                %                 plot(t, T1trace(region),'b')
                %                 plot(t, AOtrace(region),'c')
                %                 plot(t, stim(region),'m')
                %                 plot(st_in, ones(size(st_in)),'r.')
                %                 pause(.1)
                %                 if length(st_in)>1
                %                    % keyboard
                %                 end
            end
            
        end
    end
end

%sorted by AOPulses
% M1: scaledtrace axopatch data 1
% M2: voltage trace AOpulse
% M3: sorted MClust spiketimes
%
%sorted by sounds
% M4: sorted MClust spiketimes


%accumulate spikes across trials
totalspikecount=[];
for cn=1:numclusters
    for dindex=[1:numAOdurs]
        spiketimes1=[];
        for rep=1:nreps(dindex)
            spiketimes1=[spiketimes1 M3(cn, dindex, rep).spiketimes];
        end
        mM3(cn, dindex).spiketimes=spiketimes1;
        totalspikecount(cn)=length(spiketimes1);
    end
end
for cn=1:numclusters
    fprintf('\ncluster %d: total spikes in window: %d', cn, totalspikecount(cn))
end

for dindex=1:numAOdurs
    %mM1(dindex,:)=mean(M1(dindex, 1:nreps(dindex),:), 2);
    if ~isempty(AOtrace)
        mM2(dindex,:)=mean(M2(dindex, 1:nreps(dindex),:), 2);
    end
    mM1stim(dindex,:)=mean(M1stim(dindex, 1:nreps(dindex),:), 2);
end



trials=1:min(min(min(min(nreps))));
trialstring=sprintf(' all trials (%d-%d)', trials(1), trials(end));


%find optimal axis limits
if isempty(ylimits) |  ylimits<0
    ylimits=[0 0]
    for dindex=1:numAOdurs
        for rep=1:nreps(dindex)
            trace2=squeeze(M2(dindex,rep, :));
            trace2=trace2-mean(trace2(1:100));
            if min(min([trace2]))<ylimits(1) ylimits(1)=min(min([trace2]));end
            if max(max([trace2]))>ylimits(2) ylimits(2)=max(max([trace2]));end
        end
    end
end

%plot the mean across AOPulses
for cn=1:numclusters
    figure
    c=get(gca, 'colororder');
    p=0;
    subplot1(numAOdurs, 1)
    for dindex=[1:numAOdurs]
        p=p+1;
        subplot1( p)
        %         trace1=squeeze(mM1(dindex, :));
        %         trace1=trace1-mean(trace1(1:100));
        if ~isempty(AOtrace)
            trace2=squeeze(mM2(dindex, :));
            trace2=trace2-mean(trace2(1:100));
            trace2=trace2./max(abs(AOtrace));
            trace2=trace2*.1*diff(ylimits);
            trace2=trace2+ylimits(1);
        end
        stimtrace=squeeze(mM1stim(dindex,  :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*.1*diff(ylimits);
        stimtrace=stimtrace+ylimits(1);
        stimtrace=stimtrace+.05*diff(ylimits);
        
        t=1:length(trace2);
        t=1000*t/samprate;
        t=t+xlimits(1);
        plot(t, stimtrace, 'm',t, trace2,'c');
        ylim(ylimits)
        xlim(xlimits)
        
        %      plot psth
        spiketimes1=mM3(cn, dindex).spiketimes;
        %         %use this code to plot curves
        %         [n, x]=hist(spiketimes1, numbins);
        %         r=plot(x, n);
        %         set(r, 'linewidth', 2)
        %use this code to plot histograms
        X=xlimits(1):binwidth:xlimits(2); %specify bin centers
        %          hist(spiketimes1, X);
        [N, x]=hist(spiketimes1, X);
        N=N./nreps(dindex); %normalize to spike rate (averaged across trials)
        N=1000*N./binwidth; %normalize to spike rate in Hz
        N=.9*ylimits(2)*N/max(N); %normalize to ylimits(2)
        b=bar(x, N,1);
        set(b, 'facecolor', c(cn,:));
        line([0 0+AOdurs(dindex)], [-.2 -.2], 'color', 'm', 'linewidth', 2)
        line(xlimits, [0 0], 'color', 'k')
        title(sprintf('mean across AO pulses, cluster %d', cn))
    end
end

%plot all AOPulse trials
if (0)
    
    for cn=1:numclusters
        figure
        c=get(gca, 'colororder');
        offset_increment=diff(ylimits);
        p=0;
        subplot1(numAOdurs, 1)
        for dindex=[1:numAOdurs]
            p=p+1;
            subplot1( p)
            hold on
            offset=offset_increment;
            for rep=trials
                
                %             trace1=squeeze(M1(dindex,rep, :));
                %             trace1=trace1-mean(trace1(1:100));
                %             trace1=trace1+offset;
                trace2=0.*trace1;
                if ~isempty(AOtrace)
                    trace2=squeeze(M2(dindex,rep, :));
                    trace2=trace2-mean(trace2(1:100));
                    trace2=trace2./max(abs(AOtrace));
                    trace2=trace2*.1*diff(ylimits);
                    trace2=trace2+offset;
                end
                stimtrace=squeeze(mM1stim(dindex,  :));
                stimtrace=stimtrace-mean(stimtrace(1:100));
                stimtrace=stimtrace./max(abs(stimtrace));
                stimtrace=stimtrace*.1*diff(ylimits);
                stimtrace=stimtrace+ylimits(1);
                stimtrace=stimtrace+.05*diff(ylimits);
                
                t=1:length(trace2);
                t=1000*t/samprate;
                t=t+xlimits(1);
                plot(t, stimtrace, 'm',t, trace2,'c');
                xlim(xlimits)
                
                %      plot psth
                spiketimes1=mM3(cn, dindex).spiketimes;
                %         %use this code to plot curves
                %         [n, x]=hist(spiketimes1, numbins);
                %         r=plot(x, n);
                %         set(r, 'linewidth', 2)
                %use this code to plot histograms
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                %          hist(spiketimes1, X);
                [N, x]=hist(spiketimes1, X);
                N=N./nreps(dindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                N=.9*offset_increment*N/max(N); %normalize to offset_increment
                b=bar(x, N,1);
                set(b, 'facecolor', c(cn,:));
                line([0 0+AOdurs(dindex)], [-.2 -.2], 'color', 'm', 'linewidth', 2)
                line(xlimits, [0 0], 'color', 'k')
                
                %plot rasters
                spiketimes2=M3(cn, dindex, rep).spiketimes;
                h=plot(spiketimes2, .5*offset_increment+offset+zeros(size(spiketimes2)), '.');
                %                 h=plot(spiketimes2, offset+ones(size(spiketimes2))+(rep-1)*inc, '.');
                %                 set(h, 'markersize', 5)
                set(h, 'color', c(cn,:));
                
                
                offset=offset+offset_increment;
                
            end
        end
        subplot1(1)
        title(sprintf('AO Pulses, Mean across trials %s. %s-%s-%s ',trialstring, expdate,session, filenum))
        subplot1(p)
    end
    
    
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the tuning curve, same as PlotMClustTC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(event)
    fprintf('\nno tones\n');
    return;
end

%count tone exper events
numtones=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'grating') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain')
         numtones=numtones+1;
     end
end
fprintf('\n%d tone exper events', numtones)

%count tone NL events
numNLtones=0;
for i=StartRecIdx:StopRecIdx
     if strcmp(eventStrings{i}, sound_ONeventtype) % tone alone
         numNLtones=numNLtones+1;
     end
end
fprintf('\n%d tone-alone NL events', numNLtones)

numEmbeddedNLtones=0;
for i=StartRecIdx:StopRecIdx
     if strcmp(eventStrings{i}, both_ONeventtype) 
         numEmbeddedNLtones=numEmbeddedNLtones+1;
     end
end
fprintf('\n%d embedded tone NL events', numEmbeddedNLtones)
fprintf('\n(%d total embedded and isolated tone NL events', numNLtones+numEmbeddedNLtones)

fprintf('\nAll NL event types in session:')
for i=StartRecIdx:StopRecIdx
     fprintf('%s', eventStrings{i}(end-1)) %
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    elseif strcmp(event(i).Type, 'tonetrain')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.toneduration;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'grating')
        j=j+1;
        allfreqs(j)=event(i).Param.angle*1000;
        allamps(j)=event(i).Param.spatialfrequency;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.clickduration; %        alldurs(j)=event(i).Param.duration; gives trial duration not tone duration
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
M4=[];
nreps=zeros(numfreqs, numamps, numdurs);


%extract the traces into a big matrix M
j=0;
m=0; %NL event counter
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'grating') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos) &~isempty(event(i).Position_rising)
                pos=event(i).Position_rising;
            end
        else
            pos=event(i).Position_rising;
        end
        %convert pos to ms after tone onset
        pos=1000*pos/samprate;
        start=(pos+xlimits(1));
        stop=(pos+xlimits(2))-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            
            if strcmp(event(i).Type, 'tone')
                freq=event(i).Param.frequency;
                dur=event(i).Param.duration;
            elseif strcmp(event(i).Type, 'fmtone')
                freq=event(i).Param.carrier_frequency;
                dur=event1(i).Param.duration;
            elseif  strcmp(event(i).Type, 'tonetrain')
                freq=event(i).Param.frequency;
                dur=event(i).Param.toneduration;
            elseif  strcmp(event(i).Type, 'grating')
                freq=event(i).Param.angle*1000;
                dur=event(i).Param.duration;
            elseif strcmp(event(i).Type, 'whitenoise')
                dur=event(i).Param.duration;
                freq=-1;
            elseif strcmp(event(i).Type, 'clicktrain')
                dur=event(i).Param.clickduration;
                freq=-1;
            end
            try
                amp=event(i).Param.amplitude;
            catch
                amp=event(i).Param.spatialfrequency;
            end
            findex= find(freqs==freq);
            aindex= find(amps==amp);
            dindex= find(durs==dur);
            nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
            m=m+1;
            
            %get the position in samples of the TTL event of the right type
            k=0; %index for counting aopulse NL events
                for j=StartRecIdx:StopRecIdx
                if strcmp(eventStrings{j}, sound_ONeventtype)
                    k=k+1;
                    if k==m
                        posNL=eventTimeStamps(j);
                        
                        break
                    end
                end
            end
            
            startNL=(posNL+xlimits(1)*1e-3*samprateNL); %in NL samples
            stopNL=(posNL+xlimits(2)*1e-3*samprateNL);%in NL samples
            regionNL=startNL:stopNL;
            

            for cn=1:numclusters
                st=SpikeTimeStamps(CellNumbers==cn); %in microseconds (=NL samples)
                h=plot(st, '.');
                set(h, 'color', c(cn,:))
                %st=10*1000*st/samprateNL; %convert from "timestamp" to ms
                %st_in=st(st>start & st<stop); % spiketimes in region (convert start/stop to ms)
                %st_in=(st_in-pos);%covert to samples after aopulse onset
                %st_in=(1000*st_in/samprate);%covert to samples after aopulse onset
                st_in=st(st>startNL & st<stopNL); % spiketimes in region
                st_in=st_in-posNL; %covert to microseconds after tone onset
                st_in=1000*st_in/samprateNL;%covert to ms
                
                M4(cn, findex,aindex,dindex, nreps(findex, aindex, dindex)).spiketimes=st_in;
            end
            
        end
    end
end
fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))

%sanity check
figure
hold on;
plot(eventTimeStamps(StartRecIdx:StopRecIdx), 'b.')
for cn=1:numclusters
    st=SpikeTimeStamps(CellNumbers==cn); %in microseconds (=NL samples)
    h=plot(st, '.');
    set(h, 'color', c(cn,:))
end
keyboard

%accumulate across trials
totalnumspikes=[];
for cn=1:numclusters
    for dindex=[1:numdurs]
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                spiketimes2=[];
                for rep=1:nreps(findex, aindex, dindex)
                    spiketimes2=[spiketimes2 M4(cn, findex, aindex, dindex, rep).spiketimes];
                end
                mM4(cn, findex, aindex, dindex).spiketimes=spiketimes2;
                M5(cn, findex, aindex, dindex)=length(spiketimes2);
            end
        end
    end
end
dindex=1;
for cn=1:numclusters
totalnumspikes(cn)=sum(M5(cn, :,:,:));
end
%find axis limits
if ylimits==-1
    ylimits=[-.3 0];
    for cn=1:numclusters
        for aindex=numamps:-1:1
            for findex=1:numfreqs
                spiketimes=mM4(cn, findex, aindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(spiketimes, X);
                N=N./nreps(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                ylimits(2)=max(ylimits(2), max(N));
            end
        end
    end
end

%plot ch1


for dindex=1:numdurs
    for cn=1:numclusters
        figure
        p=0;
        subplot1( numamps,numfreqs)
        for aindex=numamps:-1:1
            for findex=1:numfreqs
                p=p+1;
                subplot1(p)
                hold on
                spiketimes1=mM4(cn, findex, aindex, dindex).spiketimes;
                %         %use this code to plot curves
                %         [n, x]=hist(spiketimes1, numbins);
                %         r=plot(x, n);
                %         set(r, 'linewidth', 2)
                %use this code to plot histograms
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                %          hist(spiketimes1, X);
                [N, x]=hist(spiketimes1, X);
                N=N./nreps(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                
                b=bar(x, N,1);
                set(b, 'facecolor', c(cn,:));
                line([0 0+durs(dindex)], [-.2 -.2], 'color', 'm', 'linewidth', 2)
                line(xlimits, [0 0], 'color', 'k')
                %                 ylim(ylimits)
                xlim(xlimits)
                %xlim([-10 500])
                axis on
                grid off
                set(gca, 'fontsize', fs)
                ylimits=ylim;
                %plot rasters
                inc=(ylimits(2))/max(max(max(nreps)));
                for n=1:nreps(findex, aindex, dindex)
                    spiketimes2=M4(cn, findex,aindex,dindex, n).spiketimes;
                    h=plot(spiketimes2, ylimits(2)+ones(size(spiketimes2))+(n-1)*inc, '.');
                    %                 set(h, 'markersize', 5)
                    set(h, 'color', c(cn,:));
                    
                end
                ylim([ylimits(1) 2*ylimits(2)])
                xlim(xlimits)
                set(gca, 'fontsize', fs)
            end
            subplot1(ceil(numfreqs/3))
            title(sprintf('sound-psth, %s-%s-%s cluster %d, dur=%d,  %d ms bins, %d total spikes',expdate,session, filenum, cn, durs(dindex), binwidth,totalnumspikes(cn)))
        end
    end
    
    
    %label amps and freqs
    p=0;
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                T=text(xlimits(1)-diff(xlimits)/2, mean(ylimits), int2str(amps(aindex)));
                set(T, 'HorizontalAlignment', 'right')
            else
                set(gca, 'xticklabel', '')
            end
            set(gca, 'xtickmode', 'auto')
            %             grid on
            if aindex==1
                %             if mod(findex,2) %odd freq
                %                 vpos=axmax(1);
                %  %           else
                vpos=ylimits(1)-diff(ylimits)/10;
                %            end
                text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
            else
                set(gca, 'yticklabel', '')
            end
        end
    end
    
end %for dindex


out.M1=M1; %currently [], would normally put axopatch data here
out.M1stim=M1stim; % stimulus traces aligned to AOpulses
out.M2=M2; %AOpulse trace aligned to AOpulse
out.M3=M3; %spiketimes aligned to AOpulse, M3(clusters,durations, nreps).spiketimes
out.M4=M4; %spiketimes aligned to tone onset, M4(cn, findex,aindex,dindex, nreps).spiketimes
out.mM2=mM2; %M2 averaged across AOpulse reps
out.mM3=mM3; %M3 averaged across AOpulse reps, mM3(cn, dindex).spiketimes
out.mM4=mM4; %M4 averaged across tone reps, mM4(cn, findex, aindex, dindex).spiketimes
out.M5=M5; %spike counts across tone reps, M5(cn, findex, aindex, dindex)
out.mM1stim=mM1stim; %trial average of M1stim
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.freqs=freqs;
out.amps=amps;
out.numfreqs=length(freqs);
out.numamps=length(amps);
out.durs=durs;
out.ylimits=ylimits;


out.samprate=samprate;
out.nreps=nreps;
out.ntrials=sum(sum(squeeze(nreps)));
out.xlimits=xlimits;


% out.semM1=semM1;
% out.M1spont=M1spont; %spontaneous rate preceding each stimulus on each trial
% out.mM1spont=mM1spont; %spontaneous rate preceding each stimulus, trial average
% out.sM1spont=sM1spont; %s.d. of above
% out.semM1spont=semM1spont; %s.e.m. of above
% 
% out.mmM1spont=mmM1spont; %grand average spontaneous spike rate across all stimuli/tials
% out.ssMspont1=ssMspont1; %s.d. of above
% out.ssemM1spont=ssemM1spont; %s.e.m. of above


outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
godatadir(expdate, session, filenum)
save(outfilename, 'out')
fprintf('\n saved to %s\n\n', outfilename);
fprintf('\n\n')

