function PlotBinTC_psth(expdate, session, filenum, varargin)
% extracts spikes and plots spike rasters with a single psth tuning curve
%
% usage: PlotBinTC_psth('expdate','session','filenum',[thresh],[xlimits],[ylimits],[binwidth],monitor)
% (thresh, xlimits, ylimits, binwidth, monitor are optional)
%
%  defaults: thresh=[-1 5], xlimits=[0 100], y-axis autoscaled, binwidth=5ms,
%  monitor=1 (plot is turned on, 0=off)
%  thresh is number of standard deviations
%  to use absolute threshold (in mV) pass [-1 mV] as the thresh argument, where mV is the desired threshold
% mw 070406
% latest updates:
% mak 14feb2011 added the stimulus locked response plot
% mak 10jun2011 added spike counts (full file, xlim pre stim onset, non-xlim)
% mak 20jun2011 added monitor to command line and removed the durs
% mak 22jun2011 added firing rates output to command window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
fs=10; %fontsize for figures
refract=15;

global pref
if isempty(pref); Prefs; end
username=pref.username;

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
% varargin defaults
if ~exist('nstd','var'); nstd=[-1 5]; end
if isempty(nstd); nstd=[-1 5]; end
if ~exist('xlimits','var'); xlimits=[0 100]; end
if isempty(xlimits); xlimits=[0 100]; end
if ~exist('ylimits','var'); ylimits=-1; end
if isempty(ylimits); ylimits=-1; end
if ~exist('binwidth','var'); binwidth=5; end
if isempty(binwidth); binwidth=5; end
if ~exist('monitor','var'); monitor=0; end
if isempty(monitor); monitor=0; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some files have evidence of two cells, to isolate the cell with stronger spikes the nstd
% is adjusted here for that reason
% mk 20Jan2012
if     strcmp(username,'whit') && strcmp(expdate,'090810') && strcmp(session,'001') && strcmp(filenum,'013') %noted in cell_list
    nstd=[-1 4];
    fprintf('\nnstd adjusted to %d mV due to simultaneous recording of two cells\n',nstd(2));
elseif strcmp(username,'whit') && strcmp(expdate,'090710') && strcmp(session,'001') && strcmp(filenum,'011') %noted in cell_list
    nstd=[-1 2];
    fprintf('\nnstd adjusted to %d mV due to simultaneous recording of two cells\n',nstd(2));
elseif strcmp(username,'whit') && strcmp(expdate,'081110') && strcmp(session,'001') && strcmp(filenum,'008') %noted in cell_list
    nstd=[-1 1];
    fprintf('\nnstd adjusted to %d mV due to simultaneous recording of two cells\n',nstd(2));
elseif strcmp(username,'whit') && strcmp(expdate,'080210') && strcmp(session,'001') && strcmp(filenum,'013') %noted in cell_list
    nstd=[-1 1];
    fprintf('\nnstd adjusted to %d mV due to simultaneous recording of two cells\n',nstd(2));
elseif strcmp(username,'whit') && strcmp(expdate,'071510') && strcmp(session,'001') && strcmp(filenum,'007') %noted in cell_list
    nstd=[-1 1];
    fprintf('\nnstd adjusted to %d mV due to simultaneous recording of two cells\n',nstd(2));
elseif strcmp(username,'whit') && strcmp(expdate,'071410') && strcmp(session,'001') && strcmp(filenum,'012') %noted in cell_list
    nstd=[-1 1];
    fprintf('\nnstd adjusted to %d mV due to simultaneous recording of two cells\n',nstd(2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[D E S]=gogetdata(expdate,session,filenum);
event=E.event;
if isempty(event); fprintf('\nno tones\n'); return; end
% stim1=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace)+ D.nativeOffset;
clear D E S

samprate=1e4;
lostat1=-1; %discard data after this position (in samples), -1 to skip
if     strcmp(username,'mak') && strcmp(expdate,'080410') && strcmp(session,'005') && strcmp(filenum,'002') %noted in cell_list
    lostat1=1.785e6;
elseif strcmp(username,'mak') && strcmp(expdate,'101810') && strcmp(session,'002') && strcmp(filenum,'003') %noted in cell_list
    lostat1=1.276e6;
elseif strcmp(username,'mak') && strcmp(expdate,'102710') && strcmp(session,'001') && strcmp(filenum,'003') %noted in cell_list
    lostat1=4.45e5;
elseif strcmp(username,'mak') && strcmp(expdate,'051211') && strcmp(session,'007') && strcmp(filenum,'001') %noted in cell_list
    lostat1=7.805e5;
elseif strcmp(username,'mak') && strcmp(expdate,'061411') && strcmp(session,'004') && strcmp(filenum,'001') %noted in cell_list
    lostat1=1.595e6;
% elseif strcmp(username,'username') && strcmp(expdate,'expdate') && strcmp(session,'session') && strcmp(filenum,'filenum') %noted?
%     lostat1=e6;
end
lostin1=-1; %discard data before this position (in samples), -1 to skip
            %find this value the same way you would for lostat1 mak 19Jan2012
if     strcmp(username,'whit') && strcmp(expdate,'072310') && strcmp(session,'001') && strcmp(filenum,'017') %noted?
    lostin1=1.484e6;
% elseif strcmp(username,'username') && strcmp(expdate,'expdate') && strcmp(session,'session') && strcmp(filenum,'filenum') %noted?
%     lostin1=e6;
end

if lostat1==-1; lostat1=length(scaledtrace); end
if lostin1==-1; lostin1=0; end
fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));
tracelength=diff(xlimits); %in ms
if xlimits(1)<0
    baseline=abs(xlimits(1));
else
    baseline=0;
end

% loads in this cell's data from cell_list_Binaural.m
labtools
cell_list_exists=0;
if false
    if exist('cell_list_Binaural.m','file')==2
        
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
end

% I'd like to bypass the filtering step here if the outfile exists 
% But, I'll need to ensure that command line inputs are used as well as any new lostat1
% maybe later...

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
catch
    dspikes=0;
end

% Plots entire file with nstd (green) and shows where spikes were counted (red)
if monitor % set 1 to plot, 0 to ignore 
    if (monitor)
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
            line([lostat1 lostat1],[ylim],'linewidth',2,'linestyle',':','color','k')
        end
        if lostin1~=length(scaledtrace) 
            line([lostin1 lostin1],[ylim],'linewidth',2,'linestyle',':','color','k')
        end
        title(sprintf('%s-%s-%s-%s',expdate,username,session,filenum));
        %pause(.5)
        %close
    end
end

% t=1:length(scaledtrace);
% t=1000*t/samprate;

% Monitors the filtering of spikes, pausing at each counted spike
if false 
    if monitor
        figure
        ylim([min(filteredtrace) max(filteredtrace)]);
        for ds=dspikes(1:20)
            xlim([ds-100 ds+100])
            t=1:length(filteredtrace);
            region=[ds-100:ds+100];
            if min(region)<1
                region=[1:ds+100];
            end
            hold on
            plot(t(region), filteredtrace(region), 'b')
            plot(spikes, thresh*ones(size(spikes)), 'g*')
            plot(dspikes, thresh*ones(size(dspikes)), 'r*')
            line(xlim, thresh*[1 1])
            line(xlim, thresh*[-1 -1])
            pause(.05)
            hold off
        end
        pause(.5)
        close
    end
end
%get freqs/amps

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
freqs=unique(allfreqs);
Ramps=unique(allRamps);
Lamps=unique(allLamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(Ramps);
numdurs=length(durs);

M1=[];
nreps=zeros(numfreqs, numamps, numamps, numdurs);
%extract the traces into a big matrix M
for i=1:length(event)
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
            region1=start1:stop1; % this could be unnecessary
        else 
%             warning('spikes in the pre-xlim window aren''t counted, because xlimit(1)~=0');
        end
        if isempty(find(region<0)) %(disallow negative start times)
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
                Ramp=event(i).Param.Ramplitude;
                Lamp=event(i).Param.Lamplitude;
                findex= find(freqs==freq);
                Raindex= find(Ramps==Ramp);
                Laindex= find(Lamps==Lamp);
                dindex= find(durs==dur);
                nreps(findex, Raindex, Laindex, dindex)=nreps(findex, Raindex, Laindex, dindex)+1;
                spiketimes1=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
                spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
                M1(findex,Raindex, Laindex,dindex, nreps(findex, Raindex, Laindex, dindex)).spiketimes=spiketimes1;
%                 M1stim(findex,Raindex, Laindex,dindex, nreps(findex, Raindex, Laindex, dindex),:)=stim1(region);
                % The 3 lines below find all the spikes in the prespike window (mak 16june2011)
                if xlimits(1) == 0 && xlimits(2) <= 0.5*(event(i).Param.next)
                    pre_xlim_flag=1;
                    spiketimes1pre=dspikes(dspikes>start1 & dspikes<stop1); % spiketimes in same sized region window, before stim onset
                    spiketimes1pre=(spiketimes1pre-pos)*1000/samprate;%covert to ms after tone onset
                    M1(findex,Raindex, Laindex,dindex, nreps(findex, Raindex, Laindex, dindex)).pre_spiketimes=spiketimes1pre;
                else
                    pre_xlim_flag=0;
                end
            end
        end
    end
end
ntrials=sum(sum(squeeze(nreps)));
nrepsmax=max(max(max(nreps)));
nrepsmin=min(min(min(nreps)));
nreps0=nreps(1, 1, 1, 1);
totreps=sum(sum(nreps))-nreps0;
fprintf('\nreps -- min: %d; max: %d',nrepsmin,nrepsmax)
if dspikes==0
    ds=dspikes;
else
    ds=length(dspikes);
end    

%accumulate across trials
counter=0;
spiketimes2=[];
pre_spiketimes2=[];
spiketimesipsi=[];
pre_spiketimesipsi=[];
spiketimescontra=[];
pre_spiketimescontra=[];
spiketimesbin=[];
pre_spiketimesbin=[];
counter_pre=0;
fr_mean=zeros(numfreqs, numamps, numamps, numdurs);
fr_std=zeros(numfreqs, numamps, numamps, numdurs);
fr_sem=zeros(numfreqs, numamps, numamps, numdurs);
for dindex=1:numdurs
    for Raindex=1:numamps
        for  Laindex=1:numamps
            for findex=1:numfreqs
                spiketimes1=[];
                pre_spiketimes1=[];
                for rep=1:nreps(findex, Raindex, Laindex, dindex)
                    spiketimes1=[spiketimes1 M1(findex, Raindex, Laindex, dindex, rep).spiketimes];
                    try pre_spiketimes1=[pre_spiketimes1 M1(findex, Raindex, Laindex, dindex, rep).pre_spiketimes];
                    catch
                    end
                    firingrate(rep)=length(M1(findex, Raindex, Laindex, dindex, rep).spiketimes);
                end
                fr_mean(findex, Raindex, Laindex, dindex)=mean(firingrate);
                fr_std(findex, Raindex, Laindex, dindex)=std(firingrate);
                fr_sem(findex, Raindex, Laindex, dindex)=std(firingrate)/sqrt(nreps(findex, Raindex, Laindex, dindex)-1);
                if Laindex~=1 && Raindex==1  
                    spiketimesipsi=[spiketimesipsi spiketimes1];
                    try pre_spiketimesipsi=[pre_spiketimesipsi pre_spiketimes1];
                    catch
                    end
                end
                if Laindex==1 && Raindex~=1
                    spiketimescontra=[spiketimescontra spiketimes1];
                    try pre_spiketimescontra=[pre_spiketimescontra pre_spiketimes1];
                    catch
                    end
                end
                if Laindex==1 || Raindex==1
                else
                    spiketimesbin=[spiketimesbin spiketimes1];
                    try pre_spiketimesbin=[pre_spiketimesbin pre_spiketimes1];
                    catch
                    end
                end
                
                if Raindex==1 && Laindex==1
                else
                    counter=counter+length(spiketimes1);
                    spiketimes2=[spiketimes2 spiketimes1];
                    
                    counter_pre=counter_pre+length(pre_spiketimes1);
                    pre_spiketimes2=[pre_spiketimes2 pre_spiketimes1];
                    
                    mM1(findex, Raindex, Laindex, dindex).spiketimes=spiketimes1;
                    mM1(findex, Raindex, Laindex, dindex).pre_spiketimes=pre_spiketimes1;
                end
            end
        end
    end
end

numbins=diff(xlimits)/binwidth;
dindex=1;

%find axis limits
if ylimits==-1
    ylimits=[-1 0];
    for Raindex=numamps:-1:1
        for Laindex=numamps:-1:1
            for findex=1:numfreqs
                spiketimes=mM1(findex, Raindex, Laindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(spiketimes, X);
                ylimits(2)=max(ylimits(2), max(N));
            end
        end
    end
end
ylimits(2)=ylimits(2)-rem(ylimits(2),5)+5;

ipsispikesxlim=length(spiketimesipsi);
pre_ipsispikesxlim=length(pre_spiketimesipsi);

contraspikesxlim=length(spiketimescontra);
pre_contraspikesxlim=length(pre_spiketimescontra);

binspikesxlim=length(spiketimesbin);
pre_binspikesxlim=length(pre_spiketimesbin);

dspikesxlim=length(spiketimes2);
pre_dspikesxlim=length(pre_spiketimes2);


filelength=length(scaledtrace);
spikerateFF=(ds/filelength)*samprate; %spikerate for the full file
spikerateRW=(dspikesxlim*1000)/(diff(xlimits)*ntrials); %spikerate for the response window only
spikerateRW_pre=(pre_dspikesxlim*1000)/(diff(xlimits)*ntrials); %spikerate for the response window only
spikerateNonRW=((ds-dspikesxlim)*1000)/((filelength*0.1)-(ntrials*diff(xlimits))); %spikerate for the full file minus the response window

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\nTime to process and load all data = %.1f seconds\n',toc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot square BinTC_psth
if false 
    for dindex=1:numdurs
        for findex=1:numfreqs
            figure
            p=0;
            subplot1(numamps,numamps)
            for Raindex=numamps:-1:1
                for Laindex=1:numamps
                    
                    p=p+1;
                    subplot1(p)
                    hold on
                    spiketimes1=mM1(findex, Raindex, Laindex, dindex).spiketimes;
                    %         %use this code to plot curves
                    %         [n, x]=hist(spiketimes1, numbins);
                    %         r=plot(x, n);
                    %         set(r, 'linewidth', 2)
                    
                    %use this code to plot histograms
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes1, X);
                    line([0 0+durs(dindex)], [-1 -1], 'color', [.5 .5 .5], 'linewidth', 4)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits)
                    xlim(xlimits)
                    set(gca, 'fontsize', fs)
                end
            end
            
            
            %label amps and freqs
            p=0;
            for Raindex=numamps:-1:1
                for Laindex=1:numamps
                    p=p+1;
                    subplot1(p)
                    if Laindex==1
                        if Ramps(Raindex)==-1000
                            text(xlimits(1), mean(ylimits), 'silence', 'HorizontalAlignment', 'center');
                        else
                            text(xlimits(1), mean(ylimits), int2str(Ramps(Raindex)))
                        end
                    end
                    if Raindex==1
                        vpos=ylimits(1)-.1*diff(ylimits);
                        if Lamps(Laindex)==-1000
                            text(mean(xlimits), vpos, 'silence','HorizontalAlignment', 'center');
                        else
                            text(mean(xlimits), vpos, int2str(Lamps(Laindex)))
                        end
                    end
                    
                    if Laindex==1 & Raindex==floor(numamps/2)
                        vpos=mean(ylimits);
                        T=text(xlimits(1)-.2*diff(xlimits), vpos, 'Contralateral','rotation', 90,'HorizontalAlignment', 'center');
                    end
                    if Laindex==floor(numamps/2) & Raindex==1
                        vpos=ylimits(1)-.3*diff(ylimits);
                        T=text(mean(xlimits), vpos, 'Ipsilateral','HorizontalAlignment', 'center');
                    end
                    axis off
                end
            end
            
            
            subplot1(1)
            if freqs(findex)/1000 < 1
                if length(nstd)==1
                    h=title(sprintf('%s-%s-%s-%s, WN (%d ms), nstd=%g, %d bins, %d/%d spikes, %d/%d Max/min trials',expdate,username,session,filenum,durs(dindex),nstd,numbins,dspikesxlim,ds,nrepsmax,nrepsmin));
                else
                    h=title(sprintf('%s-%s-%s-%s, WN (%d ms), nstd=%.1f mV, %d bins, %d/%d spikes, %d/%d Max/min trials',expdate,username,session,filenum,durs(dindex),nstd(2),numbins,dspikesxlim,ds,nrepsmax,nrepsmin));
                end
            else
                if length(nstd)==1
                    h=title(sprintf('%s-%s-%s-%s, %.1f kHz (%d ms), nstd=%g, %d bins, %d/%d spikes, %d/%d Max/min trials',expdate,username,session,filenum,freqs(findex)/1000,durs(dindex),nstd,numbins,dspikesxlim,ds,nrepsmax,nrepsmin));
                else
                    h=title(sprintf('%s-%s-%s-%s, %.1f kHz (%d ms), nstd=%.1f mV, %d bins, %d/%d spikes, %d/%d Max/min trials',expdate,username,session,filenum,freqs(findex)/1000,durs(dindex),nstd(2),numbins,dspikesxlim,ds,nrepsmax,nrepsmin));
                end
            end
            set(h,'HorizontalAlignment','Left','Position',[-50 ylimits(2)])
            
        end %for findex
    end %for dindex
end

%plot square BinTC_psth rasters
if false 
    for dindex=1:numdurs
        for findex=1:numfreqs
            figure
            p=0;
            subplot1(numamps,numamps)
            for Raindex=numamps:-1:1
                for Laindex=1:numamps
                    p=p+1;
                    subplot1(p)
                    hold on
                    for rep=1:nreps(findex, Raindex, Laindex, dindex)
                        spiketimes1=M1(findex, Raindex, Laindex, dindex, rep).spiketimes;
                        if ~isempty(spiketimes1)
                            plot(spiketimes1,rep,'b.');
                        end
                    end
                    line([0 0+durs(dindex)], [-1 -1], 'color', [.5 .5 .5], 'linewidth', 2)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim([-2 11])
                    xlim(xlimits)
                    set(gca, 'fontsize', fs)
                end
            end
            
            
            %label amps and freqs
            p=0;
            for Raindex=numamps:-1:1
                for Laindex=1:numamps
                    p=p+1;
                    subplot1(p)
                    if Laindex==1
                        if Ramps(Raindex)==-1000
                            text(xlimits(1), mean(ylimits), 'silence', 'HorizontalAlignment', 'center');
                        else
                            text(xlimits(1), mean(ylimits), int2str(Ramps(Raindex)))
                        end
                    end
                    if Raindex==1
                        vpos=ylimits(1)-.1*diff(ylimits);
                        if Lamps(Laindex)==-1000
                            text(mean(xlimits), vpos, 'silence','HorizontalAlignment', 'center');
                        else
                            text(mean(xlimits), vpos, int2str(Lamps(Laindex)))
                        end
                    end
                    
                    if Laindex==1 & Raindex==floor(numamps/2)
                        vpos=mean(ylimits);
                        T=text(xlimits(1)-.2*diff(xlimits), vpos, 'Contralateral','rotation', 90,'HorizontalAlignment', 'center');
                    end
                    if Laindex==floor(numamps/2) & Raindex==1
                        vpos=ylimits(1)-.3*diff(ylimits);
                        T=text(mean(xlimits), vpos, 'Ipsilateral','HorizontalAlignment', 'center');
                    end
                    axis off
                end
            end
            
            
            subplot1(1)
            if freqs(findex)/1000 < 1
                if length(nstd)==1
                    h=title(sprintf('%s-%s-%s-%s, WN (%d ms), nstd=%g, %d bins, %d/%d spikes, %d/%d Max/min trials',expdate,username,session,filenum,durs(dindex),nstd,numbins,dspikesxlim,ds,nrepsmax,nrepsmin));
                else
                    h=title(sprintf('%s-%s-%s-%s, WN (%d ms), nstd=%.1f mV, %d bins, %d/%d spikes, %d/%d Max/min trials',expdate,username,session,filenum,durs(dindex),nstd(2),numbins,dspikesxlim,ds,nrepsmax,nrepsmin));
                end
            else
                if length(nstd)==1
                    h=title(sprintf('%s-%s-%s-%s, %.1f kHz (%d ms), nstd=%g, %d bins, %d/%d spikes, %d/%d Max/min trials',expdate,username,session,filenum,freqs(findex)/1000,durs(dindex),nstd,numbins,dspikesxlim,ds,nrepsmax,nrepsmin));
                else
                    h=title(sprintf('%s-%s-%s-%s, %.1f kHz (%d ms), nstd=%.1f mV, %d bins, %d/%d spikes, %d/%d Max/min trials',expdate,username,session,filenum,freqs(findex)/1000,durs(dindex),nstd(2),numbins,dspikesxlim,ds,nrepsmax,nrepsmin));
                end
            end
            set(h,'HorizontalAlignment','Left','Position',[-50 ylimits(2)])
            
        end %for findex
    end %for dindex
end

%plot ABL-ILD BinTC_psth 
if true 
    ABLs=[];ILDs=[];
    for Raindex=numamps:-1:2
        for Laindex=2:numamps
            ABLs=[ABLs mean([Ramps(Raindex) Lamps(Laindex)])];
            ILDs=[ILDs (Ramps(Raindex)- Lamps(Laindex))];
        end
    end
    ILDs=unique(ILDs);
    ABLs=unique(ABLs);
    for dindex=1:numdurs
        for findex=1:numfreqs
            figure
            subplot1(length(ABLs),length(ILDs)+2)
            
            %note: don't use aindex=1 (-1000 dB) since ABL/ILD undefined for monaural sounds
            for Raindex=numamps:-1:2
                for Laindex=2:numamps
                    
                    
                    ABL=mean([Ramps(Raindex) Lamps(Laindex)]);
                    ILD=(Ramps(Raindex)- Lamps(Laindex));
                    ILDindex=find(ILD==ILDs);
                    ABLindex=find(ABL==ABLs);
                    subplot1([length(ABLs)-ABLindex+1 ILDindex+1]);
                    % str=sprintf('\nR %d L %d ABL %d ILD %d', Ramps(Raindex), Lamps(Laindex), ABL, ILD);
                    spiketimes7=mM1(findex, Raindex, Laindex, dindex).spiketimes;
                    %         %use this code to plot curves
                    %         [n, x]=hist(spiketimes1, numbins);
                    %         r=plot(x, n);
                    %         set(r, 'linewidth', 2)
                    
                    %use this code to plot histograms
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes7, X);
                    line([0 0+durs(dindex)], [-1 -1], 'color','m', 'linewidth', 2)
                    str=sprintf('\nL %d R %d', Lamps(Laindex), Ramps(Raindex));
                    text(0,0, str, 'fontsize', 9)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits)
                    xlim(xlimits)
                    set(gca, 'fontsize', fs)
                    axis off
                    
                end
            end
            % Now add in the Ipsi ear
            p=1;
            for Raindex=1
                for Laindex=numamps:-1:2
                    subplot1(p);
                    spiketimes8=mM1(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes8, X);
                    line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
                    str=sprintf('\nL %d', Lamps(Laindex));
                    text(0,0, str, 'fontsize', 9)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits)
                    xlim(xlimits)
                    set(gca, 'fontsize', fs)
                    axis off
                    p=p+22;
                end
            end
            % Now add in the Contra ear
            p=11;
            for Raindex=numamps:-1:2
                for Laindex=1
                    subplot1(p);
                    spiketimes9=mM1(findex, Raindex, Laindex, dindex).spiketimes;
                    X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                    hist(spiketimes9, X);
                    line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
                    str=sprintf('\nR %d', Ramps(Raindex));
                    text(0,0, str, 'fontsize', 9)
                    line(xlimits, [0 0], 'color', 'k')
                    ylim(ylimits)
                    xlim(xlimits)
                    set(gca, 'fontsize', fs)
                    axis off
                    p=p+22;
                end
            end
            subplot1(1)
            if cell_list_exists==1
                if freqs(findex)/1000 < 1 && ~isfield(celldata,'inorm')
                    h=title(sprintf('%s-%s-%s, WN (%d ms), %d/%d (%d) trials, depth %d um', expdate,session,filenum,durs(dindex),nrepsmin,nrepsmax,totreps,depth));
                    set(h, 'HorizontalAlignment', 'left')
                elseif freqs(findex)/1000 < 1 && isfield(celldata,'inorm')
                    h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), %d/%d (%d) trials, depth %d um, inorm=%.1f pA', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmin,nrepsmax,totreps,depth,inorm));
                    set(h, 'HorizontalAlignment', 'left')
                else
                    if isfield(celldata,'inorm')
                        h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), %d/%d (%d) trials, depth %d um, inorm=%.1f pA', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmin,nrepsmax,totreps,depth,inorm));
                        set(h, 'HorizontalAlignment', 'left')
                    else
                        h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), %d/%d (%d) trials, depth %d um', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmin,nrepsmax,totreps,depth));
                        set(h, 'HorizontalAlignment', 'left')
                    end
                end
            else
                if freqs(findex)/1000 < 1
                    h=title(sprintf('%s-%s-%s, WN (%d ms), %d/%d (%d) trials, depth UNK', expdate,session,filenum,durs(dindex),nrepsmin,nrepsmax,totreps));
                    set(h, 'HorizontalAlignment', 'left')
                else
                    h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), %d/%d (%d) trials, depth UNK', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmin,nrepsmax,totreps));
                    set(h, 'HorizontalAlignment', 'left')
                end
            end
            
            h=get(gcf, 'children');
            axis(h, 'off')
            
            %label amps and freqs
            fs=14;
            p=0;
            xl=xlimits;
            % I'm seriously hacking this to make the plot look awesome (6Ramp, 6Lamp)
            % mk 10Oct2011
            for ABLindex=length(ABLs):-1:1
                for ILDindex=1:length(ILDs)+2
                    p=p+1;
                    %                     if p>9 && rem(p,9)==1
                    %                         p=p+2;
                    %                     end
                    subplot1(p)
                    if p==89
                        subplot1(p)
                        vpos=ylimits(1)-.4*diff(ylimits);
                        T=text(mean(xl), vpos, 'Ipsi');
                        
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    if p==99
                        subplot1(p)
                        vpos=ylimits(1)-.4*diff(ylimits);
                        T=text(mean(xl), vpos, 'Contra');
                        
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    if p<98
                    if ABLindex==1
                        subplot1(p+1)
                        vpos=ylimits(1)-.4*diff(ylimits);
                        T=text(mean(xl), vpos, int2str(ILDs(ILDindex)));
                        
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    if ILDindex==1
                        subplot1(p)
                        T=text(xl(1)-.5*diff(xl), mean(ylimits), int2str(ABLs(ABLindex)));
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    
                    if ABLindex==1 & ILDindex==ceil(length(ILDs)/2)
                        subplot1(p+1)
                        vpos=ylimits(1)-0.8*diff(ylimits);
                        
                        T=text(mean(xl), vpos, 'ILD (dB)','HorizontalAlignment', 'center');
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        
                        %axis on
                    end
                    if ABLindex==floor(length(ABLs)/2) & ILDindex==1
                        vpos=mean(ylimits);
                        T=text(xl(1)-1.1*diff(xl), vpos, 'ABL (dB)','rotation', 90,'HorizontalAlignment', 'center');
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    end
                    thecat='meow';
                    
                end
            end
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
if true 
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

% Process ILD into ABL and convert from spikecount into firing rate
% This code ignores mono stimuli
if true 
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
    
    FRbyABL.meanFR=[];
    FRbyABL.semFR=[];
    FRbyABL.ILD_FR=[];
    FRbyABL.ILD_nreps=[];
    for q=1:length(ABLs)+2
        if q>1 && q<length(ABLs)+2
            ILDcounter=0;
            for p=1:length(ILDs)
                if size(ILD2(p,q-1).nreps1,1)~=0
                    ILDcounter=ILDcounter+1;
                    ILD2spikes=length(ILD2(p,q-1).spikes1);
                    ILD2nreps(ILDcounter)=ILD2(p,q-1).nreps1;
                    ILD2FR(ILDcounter)=(ILD2spikes*1e3)/(ILD2nreps(ILDcounter)*xlimits(2));
                    breakstop='now';
                end
            end
            FRbyABL(q).ILD_FR=ILD2FR;
            FRbyABL(q).ILD_nreps=ILD2nreps;
            FRbyABL(q).meanFR=mean(ILD2FR);
            FRbyABL(q).semFR=std(ILD2FR)/sqrt(length(ILD2FR));
            clear ILD2spikes ILD2nreps ILD2FR
        end
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
            h=title(sprintf('All %d:%d (%d) spikes, %d total trials',pre_dspikesxlim,dspikesxlim,ds,totreps));
            set(h,'HorizontalAlignment', 'center')
        end
    end
end

% This code assumes only 1 dur and 1 freq
aa=squeeze(mM1);
a=zeros(6,6);
for i=1:6
    for j=1:6
        if ~isempty(aa(i,j).spiketimes)
            a(i,j)=length(aa(i,j).spiketimes);
        end
    end
end
bb=squeeze(nreps);
spikes_stim=a./bb;
minspikes=min(min(spikes_stim));
maxspikes=max(max(spikes_stim));
spikerate_stim=spikes_stim/maxspikes;

%plot ABL-ILD BinTC_psth; Normalized FR in grayscale 
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
    for dindex=1:numdurs
        for findex=1:numfreqs
            figure
            subplot1(length(ABLs),length(ILDs)+2)
            h=get(gcf, 'children');
            axis(h, 'off')
            
            %note: don't use aindex=1 (-1000 dB) since ABL/ILD undefined for monaural sounds
            for Raindex=numamps:-1:2
                for Laindex=2:numamps
                    
                    
                    ABL=mean([Ramps(Raindex) Lamps(Laindex)]);
                    ILD=(Ramps(Raindex)- Lamps(Laindex));
                    ILDindex=find(ILD==ILDs);
                    ABLindex=find(ABL==ABLs);
                    subplot1([length(ABLs)-ABLindex+1 ILDindex+1]);
                    % str=sprintf('\nR %d L %d ABL %d ILD %d', Ramps(Raindex), Lamps(Laindex), ABL, ILD);
                    
                    graycode=1-spikerate_stim(Raindex,Laindex);
                    set(gca,'color',[graycode graycode graycode])
                    str=sprintf('\nL %d R %d', Lamps(Laindex), Ramps(Raindex));
                    text(0,0, str, 'fontsize', 9)
                    set(gca, 'fontsize', fs)
                    axis on
                    
                end
            end
            % Now add in the Ipsi ear
            p=1;
            for Raindex=1
                for Laindex=numamps:-1:2
                    subplot1(p);
                    
                    graycode=1-spikerate_stim(Raindex,Laindex);
                    set(gca,'color',[graycode graycode graycode])
                    str=sprintf('\nL %d', Lamps(Laindex));
                    text(0,0, str, 'fontsize', 9)
                    set(gca, 'fontsize', fs)
                    axis on
                    p=p+22;
                end
            end
            % Now add in the Contra ear
            p=11;
            for Raindex=numamps:-1:2
                for Laindex=1
                    subplot1(p);
                    
                    graycode=1-spikerate_stim(Raindex,Laindex);
                    set(gca,'color',[graycode graycode graycode])
                    str=sprintf('\nR %d', Ramps(Raindex));
                    text(0,0, str, 'fontsize', 9)
                    set(gca, 'fontsize', fs)
                    axis on
                    p=p+22;
                end
            end
            subplot1(1)
            if cell_list_exists==1
                if freqs(findex)/1000 < 1 && ~isfield(celldata,'inorm')
                    h=title(sprintf('%s-%s-%s, WN (%d ms), %d/%d (%d) trials, depth %d um', expdate,session,filenum,durs(dindex),nrepsmin,nrepsmax,totreps,depth));
                    set(h, 'HorizontalAlignment', 'left')
                elseif freqs(findex)/1000 < 1 && isfield(celldata,'inorm')
                    h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), %d/%d (%d) trials, depth %d um, inorm=%.1f pA', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmin,nrepsmax,totreps,depth,inorm));
                    set(h, 'HorizontalAlignment', 'left')
                else
                    if isfield(celldata,'inorm')
                        h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), %d/%d (%d) trials, depth %d um, inorm=%.1f pA', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmin,nrepsmax,totreps,depth,inorm));
                        set(h, 'HorizontalAlignment', 'left')
                    else
                        h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), %d/%d (%d) trials, depth %d um', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmin,nrepsmax,totreps,depth));
                        set(h, 'HorizontalAlignment', 'left')
                    end
                end
            else
                if freqs(findex)/1000 < 1
                    h=title(sprintf('%s-%s-%s, WN (%d ms), %d/%d (%d) trials, depth UNK', expdate,session,filenum,durs(dindex),nrepsmin,nrepsmax,totreps));
                    set(h, 'HorizontalAlignment', 'left')
                else
                    h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), %d/%d (%d) trials, depth UNK', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmin,nrepsmax,totreps));
                    set(h, 'HorizontalAlignment', 'left')
                end
            end
            
            
            %label amps and freqs
            fs=14;
            p=0;
            xl=xlimits;
            % I'm seriously hacking this to make the plot look awesome (6Ramp, 6Lamp)
            % mk 10Oct2011
            for ABLindex=length(ABLs):-1:1
                for ILDindex=1:length(ILDs)+2
                    p=p+1;
                    %                     if p>9 && rem(p,9)==1
                    %                         p=p+2;
                    %                     end
                    subplot1(p)
                    if p==89
                        subplot1(p)
                        vpos=ylimits(1)-.4*diff(ylimits);
                        T=text(mean(xl), vpos, 'Ipsi');
                        
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    if p==99
                        subplot1(p)
                        vpos=ylimits(1)-.4*diff(ylimits);
                        T=text(mean(xl), vpos, 'Contra');
                        
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    if p<98
                    if ABLindex==1
                        subplot1(p+1)
                        vpos=ylimits(1)-.4*diff(ylimits);
                        T=text(mean(xl), vpos, int2str(ILDs(ILDindex)));
                        
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    if ILDindex==1
                        subplot1(p)
                        T=text(xl(1)-.5*diff(xl), mean(ylimits), int2str(ABLs(ABLindex)));
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    
                    if ABLindex==1 & ILDindex==ceil(length(ILDs)/2)
                        subplot1(p+1)
                        vpos=ylimits(1)-0.8*diff(ylimits);
                        
                        T=text(mean(xl), vpos, 'ILD (dB)','HorizontalAlignment', 'center');
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        
                        %axis on
                    end
                    if ABLindex==floor(length(ABLs)/2) & ILDindex==1
                        vpos=mean(ylimits);
                        T=text(xl(1)-1.1*diff(xl), vpos, 'ABL (dB)','rotation', 90,'HorizontalAlignment', 'center');
                        set(T, 'fontsize', fs)
                        xlim(xlimits)
                        ylim(ylimits)
                        %axis on
                    end
                    end
                    thecat='meow';
                    
                end
            end
        end
    end
end

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
out.FRbyILD=FRbyILD;
out.FRbyABL=FRbyABL;

if cell_list_exists==1
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
    out.FRbyABL=FRbyABL;
    if exist('inorm')
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

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
godatadir(expdate, session, filenum)
save(outfilename, 'out')
fprintf('\n saved to %s\n\n', outfilename);

fprintf('\nTotal run time = %.1f seconds\n',toc);

