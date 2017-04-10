function PlotMClustTC(expdate, session, filenum, varargin)
% for use with tetrode or other data cluster-cut with MClust
% plots spike rasters and psth tuning curve
%
% usage: PlotTC_psth(expdate, session, filenum, [xlimits], [ylimits], [binwidth])
%  xlimits, ylimits, binwidth are optional)
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
elseif nargin==4
    xlimits=varargin{1};
    if isempty(xlimits)
        xlimits=[0 100];
    end
    ylimits=-1;
    binwidth=5;
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
    
else
    error('wrong number of arguments');
end

lostat=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

fs=10;

godatadir(expdate,session,filenum);
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
eventsfile=strrep(eventsfile, 'AxopatchData1', 'TetrodeData1');
E=load(eventsfile);
event=E.event;
if isempty(event) fprintf('\nno tones\n'); end
clear D E S

%MClust spiketime files are of the form 121811-001-003-wf_1.t
%there is one for each cluster
basefn=sprintf('%s-%s-%s-wf_*.t', expdate, session, filenum);
d=dir(basefn);
numclusters=size(d, 1);
if numclusters==0 error('PlotMClustTC: no cluster files found');end
for clustnum=1:numclusters
    fn=sprintf('%s-%s-%s-wf_%d.t', expdate, session, filenum, clustnum);
fprintf('\nreading MClust output file %s cluster %d', fn, clustnum)
    spiketimes(clustnum).st=read_MClust_output(fn);
    totalnumspikes(clustnum)=length(spiketimes(clustnum).st);
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
M1=[];
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
        samprate=10000;
        pos=pos/10;
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
                M1(cn, findex,aindex,dindex, nreps(findex, aindex, dindex)).spiketimes=st_in;
               
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
                    spiketimes1=[spiketimes1 M1(cn, findex, aindex, dindex, rep).spiketimes'];
                end
                mM1(cn, findex, aindex, dindex).spiketimes=spiketimes1;
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
                spiketimes=mM1(cn, findex, aindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(spiketimes, X);
                N=N./nreps(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
                N=1000*N./binwidth; %normalize to spike rate in Hz
                ylimits(2)=max(ylimits(2), max(N));
            end
        end
    end
end

%plot psth
c=get(gca, 'colororder');
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
                spiketimes1=mM1(cn, findex, aindex, dindex).spiketimes;
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
                ylim(ylimits)
                xlim(xlimits)
                %xlim([-10 500])
                axis on
                grid off
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
        subplot1(ceil(numfreqs/3))
        title(sprintf('%s-%s-%s cluster %d, dur=%d,  %d ms bins, %d total spikes',expdate,session, filenum, cn, durs(dindex), binwidth,totalnumspikes(cn)))
        
    end %for dindex
end %for clusternum

%plot psth with rasters
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
                spiketimes1=mM1(cn, findex, aindex, dindex).spiketimes;
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
                ylim(ylimits)
                xlim(xlimits)
                %xlim([-10 500])
                axis on
                grid off
                set(gca, 'fontsize', fs)
                
                
            %plot rasters
            inc=(ylimits(2))/max(max(max(nreps)));
            for n=1:nreps(findex, aindex, dindex)
                spiketimes2=M1(cn, findex,aindex,dindex, n).spiketimes;
                h=plot(spiketimes2, ylimits(2)+ones(size(spiketimes2))+(n-1)*inc, '.');
                set(h, 'color', c(cn,:));
            end
            ylim([ylimits(1) 2*ylimits(2)])
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
        subplot1(ceil(numfreqs/3))
        title(sprintf('%s-%s-%s cluster %d, dur=%d,  %d ms bins, %d total spikes',expdate,session, filenum, cn, durs(dindex), binwidth,totalnumspikes(cn)))
        
    end %for dindex
end %for clusternum





fprintf('\n\n')

