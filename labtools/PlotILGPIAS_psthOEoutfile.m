function PlotILGPIAS_psthOEoutfile(out)
% like PlotILGPIAS_psthOEoutfile, but you just send it an outfile. Send it
% the actual outfile, not just the name. All params (xlimits, etc) are taken from the
% outfile.

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

combine_ONOFF=0; %if you want to plot on and off trials together without splitting them

refract=15;
fs=12; %fontsize for figures

if nargin==0 fprintf('\nno input');return;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fs=10; %fontsize

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
user=out.user;
xlimits=out.xlimits;
tetrode=out.tetrode;
clust=out.cluster;

fprintf('\n%s-%s-%s %s',expdate,session, filenum, user);

% get ylimits
for gdindex=1:numgapdurs;
    ylimits=[-.3 0];
    spiketimes1=mM1OFFtc( gdindex).spiketimes; %in ms relative to gap offset
    X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
    [N, x]=hist(spiketimes1, X);
    N=N./nrepsOFF(gdindex); %normalize to spike rate (averaged across trials)
    N=1000*N./binwidth; %normalize to spike rate in Hz
    ylimits(2)= max(ylimits(2),max(N));
    
    spiketimes1=mM1ONtc( gdindex).spiketimes; %in ms relative to gap offset
    X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
    [N, x]=hist(spiketimes1, X);
    N=N./nrepsON(gdindex); %normalize to spike rate (averaged across trials)
    N=1000*N./binwidth; %normalize to spike rate in Hz
    ylimits(2)= max(ylimits(2),max(N));
    
    ylimits(2)=1.05*ylimits(2);
end



M1ONtc2=[];
% Plot psth ON
figure
p=0;
subplot1(numgapdurs,1)

for gdindex=1:numgapdurs
    p=p+1;
    subplot1(p)
    hold on
    
    if p==1
        title(sprintf('%s-%s-%s, tetrode %s, cell %d, Green=Laser ON; Black=Laser OFF',expdate,session,filenum, tetrode, clust))
    end
    
    if ~isempty (M1ONtc2) & ~isempty (M1OFFtc2(:))
        %only makes sense to do the t-test if you have both ON and
        %OFF only in 0-150 ms window from gap termination
        ONcounts=[mM1ONtc2(clust, gdindex,paindex).spiketimes];
        OFFcounts=[mM1OFFtc2(clust, gdindex,paindex).spiketimes];
        [h,pvalues]=ttest2(ONcounts,OFFcounts);
        if pvalues<0.05
            if length(ONcounts)>length(OFFcounts)
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
        
        spiketimes1=mM1OFFtc( gdindex).spiketimes;
        %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
        X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
        [N, x]=hist(spiketimes1, X);
        N=N./nrepsOFF(gdindex); % averaged across trials
        N=1000*N./binwidth; %normalize to spike rate in Hz
        bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
    end
    
    BinCenters=X-gapdelay; %for writing bin centers to aldis file
    
    % plot on psth
    if ~isempty (mM1ONtc)
        spiketimes1=mM1ONtc( gdindex).spiketimes;
        %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
        X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
        [N, x]=hist(spiketimes1, X);
        N=N./nrepsON(gdindex); % averaged across trials
        N=1000*N./binwidth; %normalize to spike rate in Hz
        bar(x-gapdelay, N,1,'facecolor','none','edgecolor',[0 .8 0]);
    end
    
    %plot stim
    if(0)
        %when we load the stim we should plot it here
        stim=squeeze(mM1ONtcstim(gdindex,:));
        stim=stim-median(stim(1:(length(stim))));
        stim=stim./max(abs(stim));
        
        t=1:length(stim);
        t=t/10;
        t=t+xlimits(1)+gapdelay;
        hold on; plot(t, (stim*(ylimmax/2)), 'm');
    end
    
    xlim([(xlimits(1)) xlimits(2)])
    ylim(ylimits)
    ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
    
    if gapdurs(gdindex)>0
        line([0 0],[ylim],'color','m')
        line(-[(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
    end
end

xlabel('ms')



% Plotpsth ON/OFF again, this time with rasters
figure
p=0;
subplot1(numgapdurs,1)

for gdindex=1:numgapdurs
    p=p+1;
    subplot1(p)
    hold on
    
    if p==1
        title(sprintf('%s-%s-%s, tetrode %s, cell %d, Green=Laser ON; Black=Laser OFF',expdate,session,filenum, tetrode, clust))
    end
    
    % plot off psth
    offset=0;
    yl=ylimits;
    inc=(yl(2))/max(max(max(nrepsOFF)));
    if ~isempty (mM1OFFtc)
        
        spiketimes1=mM1OFFtc( gdindex).spiketimes;
        %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
        X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
        [N, x]=hist(spiketimes1, X);
        N=N./nrepsOFF(gdindex); % averaged across trials
        N=1000*N./binwidth; %normalize to spike rate in Hz
        bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
    end
    
    for n=1:nrepsOFF(gdindex)
        spiketimes2=M1OFFtc( gdindex, n).spiketimes;
        offset=offset+inc;
        h=plot(spiketimes2-gapdelay, yl(2)+ones(size(spiketimes2))+offset, '.k');
    end
    % plot on psth
    if ~isempty (mM1ONtc)
        spiketimes1=mM1ONtc( gdindex).spiketimes;
        X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
        [N, x]=hist(spiketimes1, X);
        N=N./nrepsON(gdindex); % averaged across trials
        N=1000*N./binwidth; %normalize to spike rate in Hz
        bar(x-gapdelay, N,1,'facecolor','none','edgecolor',[0 .8 0]);
    end
    
    
    for n=1:nrepsON(gdindex)
        spiketimes2=M1ONtc( gdindex, n).spiketimes;
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
    ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
    
    ylim([0 yl(2)+offset])
end


xlabel('ms')


% Plot OFF trials
figure
p=0;
subplot1(numgapdurs,1)

for gdindex=1:numgapdurs
    p=p+1;
    subplot1(p)
    hold on
    
    if p==1
        title(sprintf('%s-%s-%s, tetrode %s, cell %d, laser OFF',expdate,session,filenum, tetrode, clust))
    end
    
    
    
    % plot off psth
    offset=0;
    yl=ylimits;
    inc=(yl(2))/max(max(max(nrepsOFF)));
    if ~isempty (mM1OFFtc)
        
        spiketimes1=mM1OFFtc( gdindex).spiketimes;
        %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
        X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
        [N, x]=hist(spiketimes1, X);
        N=N./nrepsOFF(gdindex); % averaged across trials
        N=1000*N./binwidth; %normalize to spike rate in Hz
        bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
    end
    
    for n=1:nrepsOFF(gdindex)
        spiketimes2=M1OFFtc( gdindex, n).spiketimes;
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


xlabel('ms')
set(gcf,'Position',[100 50 800 900]);


if combine_ONOFF==1
    fprintf('\n\nCombinging on and off trials!!\n\n')
    
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
                    spiketimes1=[mM1OFFtc(clust, gdindex,paindex).spiketimes mM1ONtc(clust, gdindex,paindex).spiketimes] ;
                    %                X=(xlimits(1)):binwidth:(xlimits(2)); %specify bin centers
                    X=(xlimits(1)+gapdelay):binwidth:(xlimits(2)+gapdelay); %specify bin centers
                    [N, x]=hist(spiketimes1, X);
                    N=N./nrepsOFF(gdindex,paindex); % averaged across trials
                    N=1000*N./binwidth; %normalize to spike rate in Hz
                    bar(x-gapdelay, N,1,'facecolor',[0 0 0]);
                end
                
                for n=1:nrepsOFF(gdindex,paindex)
                    spiketimes2= [M1OFFtc(clust, gdindex,paindex, n).spiketimes M1ONtc(clust, gdindex,paindex, n).spiketimes];
                    offset=offset+inc;
                    h=plot(spiketimes2-gapdelay, yl(2)+ones(size(spiketimes2))+offset, '.k');
                end
                
                %plot stim
                if gapdurs(gdindex)>0
                    line([0 0],[ylim],'color','m')
                    line(-[(gapdurs(gdindex)) (gapdurs(gdindex))],[ylim],'color','m')
                end
                
                
                xlim([(xlimits(1)) xlimits(2)])
                %            xlim([(xlimits(1)+gapdelay) xlimits(2)+gapdelay])
                %ylim(ylimits1(clust, :))
                ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
                
            end
        end
        
        xlabel('ms')
    end
    
end

%do some stats and generate some output data for Aldis
%mw 11-2015

return
    
        for gdindex=1:numgapdurs
            fprintf('\n%s-%s-%s, tetrode %s, cell %d, gd:%d',expdate,session,filenum, tetrode, clust, gapdurs(gdindex))
            % PGI 1: 0-25 ms
            % PGI 2: 25-50 ms
            
            region='Gap 0-50 ms ("Off")';
            if gapdurs(gdindex)>50
                start=0-gapdurs(gdindex)+gapdelay;
                stop=50-gapdurs(gdindex)+gapdelay;
                in=find(spiketimes1>start & spiketimes1<stop);
                spikecount=length(in);
            else spikecount=nan; %exclude gaps<50ms
            end
            spikerate=spikecount/nrepsOFF(gdindex);
            fprintf('\n%s spikerate=%.1f', region, spikerate)
            SpikerateTable(clust, 1,gdindex)=spikerate;
            regions{1}=region;
            
            region='Gap 50-end ("Off-Sustained")';
            if gapdurs(gdindex)>50
                start=50-gapdurs(gdindex)+gapdelay;
                stop=0+gapdelay;
                in=find(spiketimes1>start & spiketimes1<stop);
                spikecount=length(in);
            else spikecount=nan; %exclude gaps<50ms
            end
            spikerate=spikecount/nrepsOFF(gdindex);
            fprintf('\n%s spikerate=%.1f', region, spikerate)
            SpikerateTable(clust, 2,gdindex)=spikerate;
            regions{2}=region;
            
            spiketimes1=mM1OFFtc(gdindex).spiketimes;
            region='PGI 0-25 ms ("PGI A")';
            start=0+gapdelay;
            stop=25+gapdelay;
            in=find(spiketimes1>start & spiketimes1<stop);
            spikecount=length(in);
            spikerate=spikecount/nrepsOFF(gdindex);
            fprintf('\n%s spikerate=%.1f', region, spikerate)
            SpikerateTable(clust, 3,gdindex)=spikerate;
            regions{3}=region;
            
            region='PGI 25-50 ms ("PGI B")';
            start=25+gapdelay;
            stop=50+gapdelay;
            in=find(spiketimes1>start & spiketimes1<stop);
            spikecount=length(in);
            spikerate=spikecount/nrepsOFF(gdindex);
            fprintf('\n%s spikerate=%.1f', region, spikerate)
            SpikerateTable(clust, 4,gdindex)=spikerate;
            regions{4}=region;
            
            region='PGI 0-50 ms ("PGI")';
            start=0+gapdelay;
            stop=50+gapdelay;
            in=find(spiketimes1>start & spiketimes1<stop);
            spikecount=length(in);
            spikerate=spikecount/nrepsOFF(gdindex);
            fprintf('\n%s spikerate=%.1f', region, spikerate)
            SpikerateTable(clust, 5,gdindex)=spikerate;
            regions{5}=region;
            
            region='PGI 50-100 ms  ("Post")';
            start=50+gapdelay;
            stop=100+gapdelay;
            in=find(spiketimes1>start & spiketimes1<stop);
            spikecount=length(in);
            spikerate=spikecount/nrepsOFF(gdindex);
            fprintf('\n%s spikerate=%.1f', region, spikerate)
            SpikerateTable(clust, 6,gdindex)=spikerate;
            regions{6}=region;
            
            
            
            
end
