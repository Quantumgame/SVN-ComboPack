function PlotMClustAOTC(expdate, session, filenum, varargin)
% for use with tetrode or other data cluster-cut with MClust
% plots spike rasters and psth tuning curve
% separately for sounds and for AO pulses
%
% usage: PlotMClustAOTC(expdate, session, filenum, [xlimits], [ylimits], [binwidth], [events2Plot])
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

[T1, ~, ~, ~, AO, E, S]=GoGetTetrodeData(expdate,session,filenum);
stim=S.nativeScalingStim*double(S.stim);
event=E.event;
T1trace=T1.nativeScaling*double(T1.trace) +T1.nativeOffset;
AOtrace=AO.nativeScaling*double(AO.trace) +AO.nativeOffset;
clear  AO E S
if isempty(event) fprintf('\nno tones\n'); end

%MClust spiketime files are of the form 121811-001-003-wf_1.t
%there is one for each cluster
basefn=sprintf('%s-%s-%s-wf_*.t', expdate, session, filenum);
d=dir(basefn);
numclusters=size(d, 1);
for clustnum=1:numclusters
    fn=sprintf('%s-%s-%s-wf_%d.t', expdate, session, filenum, clustnum);
    fprintf('\nreading MClust output file %s cluster %d', fn, clustnum)
    spiketimes(clustnum).st=read_MClust_output(fn);
    totalnumspikes(clustnum)=length(spiketimes(clustnum).st);
end

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first plot the AO pulses, same as PlotAOPulse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M1=[];
nreps=zeros(numAOdurs);
samprate=getsamplerate(expdate, session, filenum);

%extract the traces into a big matrix M
j=0;
cont=1;

if isnan(events2Plot)
    events2Plot = length(event);
    fprintf('Plotting all %d events.',length(event))
else
    fprintf('\nPlotting %d of %d events.',events2Plot,length(event))
end

for i=1:events2Plot
    if (cont)
        if strcmp(event(i).Type, 'aopulse')
            
            pos=round(event(i).Position);%in samples
            
            
            start=(pos+xlimits(1)*1e-3*samprate); %in samples
            stop=(pos+xlimits(2)*1e-3*samprate)-1;%in samples
            region=start:stop;
            if isempty(find(region<0)) %(disallow negative start times)
                dur=event(i).Param.width;
                dindex= find(AOdurs==dur);
                nreps(dindex)=nreps(dindex)+1;
                M1(dindex, nreps(dindex),:)=T1trace(region);
                if ~isempty(AOtrace)
                    M2(dindex, nreps(dindex),:)=AOtrace(region);
                end
                M1stim(dindex, nreps(dindex),:)=stim(region);
                for cn=1:numclusters                      %sorted spikes from MClust
                    st=spiketimes(cn).st; %in ms??? or samples???
                    st=10*1000*st/samprate; %convert from "timestamp" to ms
                    %st_in=st(st>start & st<stop); % spiketimes in region (convert start/stop to ms)
                    %st_in=(st_in-pos);%covert to samples after aopulse onset
                    %st_in=(1000*st_in/samprate);%covert to samples after aopulse onset
                    st_in=st(st>1000*start/samprate & st<1000*stop/samprate); % spiketimes in region (convert start/stop to ms)
                    st_in=(st_in-1000*pos/samprate);%covert to ms after tone onset
                    M3(cn,dindex, nreps(dindex)).spiketimes=st_in;
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
for cn=1:numclusters
    for dindex=[1:numAOdurs]
        spiketimes1=[];
        for rep=1:nreps(dindex)
            spiketimes1=[spiketimes1 M3(cn, dindex, rep).spiketimes'];
        end
        mM3(cn, dindex).spiketimes=spiketimes1;
    end
end


for dindex=1:numAOdurs
    mM1(dindex,:)=mean(M1(dindex, 1:nreps(dindex),:), 2);
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
            trace1=squeeze(M1(dindex,rep, :));
            trace1=trace1-mean(trace1(1:100));
            if min(min([trace1]))<ylimits(1) ylimits(1)=min(min([trace1]));end
            if max(max([trace1]))>ylimits(2) ylimits(2)=max(max([trace1]));end
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
        trace1=squeeze(mM1(dindex, :));
        trace1=trace1-mean(trace1(1:100));
        trace2=0.*trace1;
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
        
        t=1:length(trace1);
        t=1000*t/samprate;
        t=t+xlimits(1);
        plot(t, trace1, 'b', t, stimtrace, 'm',t, trace2,'c');
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
            
            trace1=squeeze(M1(dindex,rep, :));
            trace1=trace1-mean(trace1(1:100));
            trace1=trace1+offset;
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
            
            t=1:length(trace1);
            t=1000*t/samprate;
            t=t+xlimits(1);
            plot(t, trace1, 'b', t, stimtrace, 'm',t, trace2,'c');
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
        %convert pos to ms
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
            %                 dur=event(i).Param.duration;
            findex= find(freqs==freq);
            aindex= find(amps==amp);
            dindex= find(durs==dur);
            nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
            for cn=1:numclusters
                st=spiketimes(cn).st; %in ms
                st_in=st(st>start & st<stop); % spiketimes in region
                st_in=(st_in-pos);%covert to ms after tone onset
                M4(cn, findex,aindex,dindex, nreps(findex, aindex, dindex)).spiketimes=st_in;
                
            end
            
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))

%accumulate across trials
for cn=1:numclusters
    for dindex=[1:numdurs]
        for aindex=[numamps:-1:1]
            for findex=1:numfreqs
                spiketimes1=[];
                for rep=1:nreps(findex, aindex, dindex)
                    spiketimes1=[spiketimes1 M4(cn, findex, aindex, dindex, rep).spiketimes'];
                end
                mM4(cn, findex, aindex, dindex).spiketimes=spiketimes1;
            end
        end
    end
end
dindex=1;

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



fprintf('\n\n')

