function PlotILArch_VmTC(expdate,session,filenum,varargin)

% usage: (expdate,session,filenum,[xlimits],[ylimits])
% xlimits default to [0 150]
% AKH 8/12/13

fs=12; %fontsize for figures
global pref
if isempty(pref); Prefs; end

if nargin==0
    fprintf('\nno input'); return;
elseif nargin==3
elseif nargin==4
    xlimits=varargin{1};
elseif nargin==5
    xlimits=varargin{1};
    ylimits=varargin{2};
else
    fprintf('\nWrong number of arguments'); return;
end
% varargin defaults
if ~exist('xlimits','var'); xlimits=[0 150]; end
if isempty(xlimits); xlimits=[0 150]; end
if ~exist('ylimits','var'); ylimits=-1; end
if isempty(ylimits); ylimits=-1; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lostat1=-1; %discard data after this position (in samples), -1 to skip
[D E S]=gogetdata(expdate,session,filenum);
event=E.event;
if isempty(event); fprintf('\nevent is empty\n'); return; end
scaledtrace=D.nativeScaling*double(D.trace)+ D.nativeOffset;
clear D E S
samprate=1e4;
if lostat1==-1; lostat=length(scaledtrace);end

fprintf('\nComputing tuning curve...');

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') || strcmp(event(i).Type, 'whitenoise') ||...
            strcmp(event(i).Type, 'fmtone')
        j=j+1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        if strcmp(event(i).Type, 'tone')
            allfreqs(j)=event(i).Param.frequency;
        elseif strcmp(event(i).Type, 'fmtone')
            allfreqs(j)=event(i).Param.carrier_frequency;
        elseif strcmp(event(i).Type, 'whitenoise')
            allfreqs(j)=-1;
        end
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);
nrepsON=zeros(numfreqs, numamps, numdurs);
nrepsOFF=zeros(numfreqs, numamps, numdurs);
M1=[];

%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') || strcmp(event(i).Type, 'whitenoise') ||...
            strcmp(event(i).Type, 'fmtone')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos) && ~isempty(event(i).Position_rising)
                pos=event(i).Position_rising;
            end
        else
            pos=event(i).Position_rising;
        end
        
        aopulseon=event(i).Param.AOPulseOn;
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat
                fprintf('\ndiscarding trace')
            else
                if strcmp(event(i).Type, 'tone')
                    freq=event(i).Param.frequency;
                elseif strcmp(event(i).Type, 'whitenoise')
                    freq=-1;
                elseif strcmp(event(i).Type, 'fmtone')
                    freq=event(i).Param.carrier_frequency;
                end
                amp=event(i).Param.amplitude;
                dur=event(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                
                if aopulseon
                nrepsON(findex, aindex, dindex)=nrepsON(findex, aindex, dindex)+1;
                M1ON(findex,aindex,dindex, nrepsON(findex, aindex, dindex),:)=scaledtrace(region);
                else
                nrepsOFF(findex, aindex, dindex)=nrepsOFF(findex, aindex, dindex)+1;
                M1OFF(findex,aindex,dindex, nrepsOFF(findex, aindex, dindex),:)=scaledtrace(region);
            end
        end
    end
end
end

baseline=[];
if false % Find baseline trace (median value of trace 50ms before soundcardtriggerPos)
    for i=1:length(event)
        if strcmp(event(i).Type, 'tone') || strcmp(event(i).Type, 'whitenoise') ||...
                strcmp(event(i).Type, 'fmtone')
            if isfield(event(i), 'soundcardtriggerPos')
                pos=event(i).soundcardtriggerPos;
                if isempty(pos) && ~isempty(event(i).Position_rising)
                    pos=event(i).Position_rising;
                end
            else
                pos=event(i).Position_rising;
            end
            
            start=(pos-50*1e-3*samprate);
            stop=pos-1;
            region=start:stop;
            if isempty(find(region<0)) %(disallow negative start times)
                if stop>lostat
                else
                    baseline(i,:)=median(scaledtrace(region));
                end
            end
        end
    end
    baseline=median(baseline);
end

traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1ON=mean(M1ON(:,:,:,traces_to_keep,:), 4);
    mM1OFF=mean(M1OFF(:,:,:,traces_to_keep,:), 4);
else
    for aindex=1:numamps
        for findex=1:numfreqs
            for dindex=1:numdurs
                
                for rep=1:nrepsON(findex, aindex, dindex)
                trace1=M1ON(findex, aindex, dindex, rep,:);
                trace1=trace1 -mean(trace1(1:10));
                meanONbl(findex, aindex, dindex,:)=trace1;
                end
                
                for rep=1:nrepsOFF(findex, aindex, dindex)
                trace1=M1OFF(findex, aindex, dindex, rep,:);
                trace1=trace1 -mean(trace1(1:10));
                meanOFFbl(findex, aindex, dindex,:)=trace1;
                end
                
                mM1ON(findex, aindex, dindex,:)=mean(M1ON(findex, aindex, dindex, 1:nrepsON(findex, aindex, dindex),:), 4);
                mM1OFF(findex, aindex, dindex,:)=mean(M1OFF(findex, aindex, dindex, 1:nrepsOFF(findex, aindex, dindex),:), 4);
            end
        end
    end
end

%find optimal axis limits
if ylimits==-1
    ylimits=[0 0];
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            trace1=squeeze(mM1ON(findex, aindex, dindex, :));
            trace1=trace1 -mean(trace1(1:100));
            if min([trace1])<ylimits(1); ylimits(1)=min([trace1]);end
            if max([trace1])>ylimits(2); ylimits(2)=max([trace1]);end
        end
    end
end
ylimits=round(ylimits*100)/100;

%plot the mean tuning curve BOTH
for dindex=1:numdurs
    figure
    p=0;
    subplot1(numamps,numfreqs)
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            
            for i=1:length(nrepsON)
            end
            
            
            trace1=squeeze(squeeze(meanONbl(findex, aindex, dindex, :)));
            trace2=(squeeze(meanOFFbl(findex, aindex, dindex, :)));
            
            trace1=trace1 -mean(trace1(1:10)); 
            trace2=trace2;%-mean(trace2(1:10));
            
            
            
            
            
%              trace1=(squeeze(M1ON(findex, aindex, dindex, :)));
%             trace2=(squeeze(M1OFF(findex, aindex, dindex, :)));
            
            t=1:length(trace1);
            t=t/10;
            line([0 0+durs(dindex)], [0 0], 'color', 'm', 'linewidth', 5)
            plot(t, trace1, 'b');
            hold on; plot(t, trace2, 'k');
            ylim([-20 60])
            box off
%             xlim(xlimits)
            
        end
    end
    subplot1(1)
    h=title(sprintf('%s-%s-%s: %dms, nreps: %d-%d',expdate,session,filenum,durs(dindex),min(min(min(nrepsOFF))),max(max(max(nrepsOFF)))));
    set(h, 'HorizontalAlignment', 'left')
    
    %label amps and freqs
    p=0;
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(-400, mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(findex,2) %odd freq
                    vpos=ylimits(1)-mean(ylimits);
                else
                    vpos=ylimits(1)-mean(ylimits);
                end
                text(xlimits(1), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
%             if findex==numfreqs && aindex==numamps
%                 axis on
%                 ylab=[ceil(ylimits(1)*10)/10 floor(ylimits(2)*10)/10];
%                 set(gca,'ytick',ylab,'yticklabel',ylab,'YAxisLocation','right')
%             end
        end
    end
end



%plot the mean tuning curve OFF
for dindex=1:numdurs
    figure
    p=0;
    subplot1(numamps,numfreqs)
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            for rep=1:nrepsOFF(findex,aindex,dindex)
                        trace1=squeeze(M1OFF(findex, aindex, dindex, rep,:));
            if isempty(baseline)
                trace1=trace1 -mean(trace1(1:100));
            else
                trace1=trace1-baseline;
            end
            t=1:length(trace1);
            t=t/10;
            line([0 0+durs(dindex)], [0 0], 'color', 'm', 'linewidth', 5)
            hold on; plot(t, trace1, 'k');
            ylim(ylimits)
            xlim(xlimits)
            axis off
            end
        end
    end
    subplot1(1)
    h=title(sprintf('OFF %s-%s-%s: %dms, nreps: %d-%d',expdate,session,filenum,durs(dindex),min(min(min(nrepsOFF))),max(max(max(nrepsOFF)))));
    set(h, 'HorizontalAlignment', 'left')
    
    %label amps and freqs
    p=0;
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(-400, mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(findex,2) %odd freq
                    vpos=ylimits(1)-mean(ylimits);
                else
                    vpos=ylimits(1)-mean(ylimits);
                end
                text(xlimits(1), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
%             if findex==numfreqs && aindex==numamps
%                 axis on
%                 ylab=[ceil(ylimits(1)*10)/10 floor(ylimits(2)*10)/10];
%                 set(gca,'ytick',ylab,'yticklabel',ylab,'YAxisLocation','right')
%             end
        end
    end
end

%% plot on
for dindex=1:numdurs
    figure
    p=0;
    subplot1(numamps,numfreqs)
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            for rep=1:nrepsON(findex,aindex,dindex)
            
            trace1=squeeze(M1ON(findex, aindex, dindex, rep,:));
            if isempty(baseline)
                trace1=trace1 -mean(trace1(1:100));
            else
                trace1=trace1-baseline;
            end
            t=1:length(trace1);
            t=t/10;
            line([0 0+durs(dindex)], [0 0], 'color', 'm', 'linewidth', 5)
            hold on; plot(t, trace1, 'b');
            ylim(ylimits)
            xlim(xlimits)
            axis off
            end
        end
    end
    subplot1(1)
    h=title(sprintf('%s-%s-%s: %dms, nreps: %d-%d',expdate,session,filenum,durs(dindex),min(min(min(nrepsON))),max(max(max(nrepsON)))));
    set(h, 'HorizontalAlignment', 'left')
    
    %label amps and freqs
    p=0;
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(-400, mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(findex,2) %odd freq
                    vpos=ylimits(1)-mean(ylimits);
                else
                    vpos=ylimits(1)-mean(ylimits);
                end
                text(xlimits(1), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
%             if findex==numfreqs && aindex==numamps
%                 axis on
%                 ylab=[ceil(ylimits(1)*10)/10 floor(ylimits(2)*10)/10];
%                 set(gca,'ytick',ylab,'yticklabel',ylab,'YAxisLocation','right')
%             end
        end
    end
end

fprintf('\n\n');
