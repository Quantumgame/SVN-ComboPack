function PlotTC_psth(expdate,session,filenum,varargin)
% extracts spikes and plots spike rasters with a single psth tuning curve
%
% usage: PlotTC_psth(expdate,session,filenum,[thresh],[xlimits],[ylimits],[binwidth],monitor)
% (thresh, xlimits, ylimits, binwidth, monitor are optional)
%
% defaults: thresh=7sd, binwidth=5ms, axes autoscaled, monitor=0 (off)
% thresh is in number of standard deviations
% to use an absolute threshold (in mV) pass [-1 mV] as the thresh
% argument, where mV is the desired threshold
% mw 070406
% last update mw 011811 - now plots mean spike rate (in Hz) averaged across trials
% last update mak 122512 - added monitor to command line, optimized code
% for varargin entry
% AKH -- Won't load outfile *unless* it was made with the same xlimits,
% binwidth, and raw voltage thresh.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
refract=15;
fs=12; %fontsize for figures
global pref
if isempty(pref); Prefs; end
username=pref.username;

if nargin==0
    fprintf('\nNo input'); return;
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
    fprintf('\nWrong number of arguments'); return;
end
% varargin defaults
if ~exist('nstd','var'); nstd=7; end
if isempty(nstd); nstd=7; end
if ~exist('xlimits','var'); xlimits=[0 100]; end
if isempty(xlimits); xlimits=[0 100]; end
if ~exist('ylimits','var'); ylimits=-1; end
if isempty(ylimits); ylimits=-1; end
if ~exist('binwidth','var'); binwidth=5; end
if isempty(binwidth); binwidth=5; end
if ~exist('monitor','var'); monitor=0; end
if isempty(monitor); monitor=1; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% See if an outfile is saved, ensure proper parameters are met and either load or
% reprocess data. mak 31dec2012

try godatadir(expdate,session)
    godatadir(expdate,session)
    outfilename=sprintf('out_psth%s-%s-%s.mat',expdate,session,filenum);
    if exist(outfilename,'file')
        load(outfilename)
        outfile_exists=1;
    else
        ProcessTC_psth(expdate,session,filenum,nstd,xlimits,ylimits,binwidth,monitor)
        outfile_exists=0;
    end
catch
    outfile_exists=0;
end
if outfile_exists
    if length(nstd)==2
        if out_psth.thresh~=nstd(end)
            outfile_exists=0;
        end
    else

      if out_psth.nstd~=nstd(end)
            outfile_exists=0;
        end
    end
    if ~isfield(out_psth,'xlimits')
        outfile_exists=0;
    elseif sum(out_psth.xlimits==xlimits)~=2
        outfile_exists=0;
    end
end

lostatfilename=sprintf('lostat-%s-%s-%s.mat',expdate,session,filenum);
try load(lostatfilename);catch; lostat=-1;end %#ok

% Also need to check xlimits & binwidth! --AKH
if outfile_exists
    if out_psth.xlimits(2)~=xlimits(2) || out_psth.binwidth~=binwidth || out_psth.xlimits(1)~=xlimits(1)
        outfile_exists=0;
    end
end


if ~outfile_exists
    [D, E, ~]=gogetdata(expdate,session,filenum);
    event=E.event;
    if isempty(event); fprintf('\nevent is empty\n'); return; end
    scaledtrace=D.nativeScaling*double(D.trace)+ D.nativeOffset;
    clear D E S
    samprate=1e4;

    if lostat==-1; lostat=length(scaledtrace);end
else
    try
    lostat=out_psth.lostat;
    catch
        fprintf('\nNo lostat time to load...\n')
    end
end
% fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));

if ~outfile_exists % Filtering step (filteredtrace, thresh, nstd, spikes, dspikes)
    fprintf('\ncomputing tuning curve...');
    high_pass_cutoff=300; %Hz
    fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
    [b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
    filteredtrace=filtfilt(b,a,scaledtrace);
    if length(nstd)==2
        if nstd(1)==-1
            thresh=nstd(2);
            nstd=thresh/std(filteredtrace);
            fprintf('\nusing absolute spike detection threshold of %.2f mV (%.2f sd)', thresh, nstd);
        end
    else
        thresh=nstd*std(filteredtrace);
        if thresh>1
            fprintf('\nusing spike detection threshold of %.2f mV (%.2f sd)', thresh, nstd);
        elseif thresh<=1
            fprintf('\nusing spike detection threshold of %.2f mV (%.2f sd)', thresh, nstd);
        end
    end
    fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
    spikes=find(abs(filteredtrace)>thresh);
    dspikes=spikes(1+find(diff(spikes)>refract));
    try dspikes=[spikes(1) dspikes'];
    catch
        fprintf('\n\ndspikes is empty; either the cell never spiked or the nstd is set too high\n');
        return
    end
else
    nstd=out_psth.nstd;
    thresh=out_psth.thresh;
    dspikes=out_psth.dspikes;
    filteredtrace=out_psth.filteredtrace;
end

if monitor % view spike threshold (nstd/thresh)
    MonitorSpikes(outfilename,filteredtrace,nstd,dspikes)

end

%get freqs/amps
if ~outfile_exists
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
        elseif strcmp(event(i).Type, 'naturalsound')
        j=j+1;
        allfreqs(j)=0;
        if isfield(event(i).Param, 'amplitude')
            allamps(j)=event(i).Param.amplitude;
        else
            allamps(j)=-1;
        end
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
    nreps=zeros(numfreqs, numamps, numdurs);
    M1=[];
    
    nreps=zeros(numfreqs, numamps, numdurs);
else
    freqs=out_psth.freqs;
    amps=out_psth.amps;
    durs=out_psth.durs;
    numfreqs=length(freqs);
    numamps=length(amps);
    numdurs=length(durs);
    nreps=out_psth.nreps;
    M1=out_psth.M1;
    M1stim=out_psth.M1stim;
    mM1stim=out_psth.mM1stim;
end

%extract the traces into a big matrix M
if ~outfile_exists
    j=0;
    for i=1:length(event)
        if strcmp(event(i).Type, 'tone') || strcmp(event(i).Type, 'tonetrain') || ...
                strcmp(event(i).Type, 'grating') ||   strcmp(event(i).Type, 'whitenoise') || ...
                strcmp(event(i).Type, 'clicktrain') || strcmp(event(i).Type, 'naturalsound')
            
            if isfield(event(i), 'soundcardtriggerPos')
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
            if isempty(find(region<0)) %(disallow negative start times)
                if stop>lostat
                    fprintf('\ndiscarding trace')
                else
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
                    elseif strcmp(event(i).Type, 'naturalsound') 
                        dur=event(i).Param.duration;
                        freq=0;
                    elseif strcmp(event(i).Type, 'clicktrain')
                        dur=event(i).Param.clickduration;
                        freq=-1;
                    end
                    try amp=event(i).Param.amplitude;
                    catch
                        amp=event(i).Param.spatialfrequency;
                    end
                    %                 dur=event(i).Param.duration;
                    findex= find(freqs==freq);
                    aindex= find(amps==amp);
                    dindex= find(durs==dur);
                    nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                    spiketimes1=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
                    spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
                    M1(findex,aindex,dindex, nreps(findex, aindex, dindex)).spiketimes=spiketimes1;
                end
            end
        end
    end
  
    %accumulate across trials
    for dindex=1:numdurs
        for aindex=numamps:-1:1
            for findex=1:numfreqs
                spiketimes1=[];
                for rep=1:nreps(findex, aindex, dindex)
                    spiketimes1=[spiketimes1 M1(findex, aindex, dindex, rep).spiketimes];
                end
                mM1(findex, aindex, dindex).spiketimes=spiketimes1;
            end
        end
    end
else
    mM1=out_psth.mM1;
end

dindex=1;

%find y-axis limits
if ylimits==-1
    ylimits=[-.3 0];
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            spiketimes=mM1(findex, aindex, dindex).spiketimes;
            X=xlimits(1):binwidth:xlimits(2); %specify bin centers
            [N, x]=hist(spiketimes, X);
            N=N./nreps(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
            N=1000*N./binwidth; %normalize to spike rate in Hz
            ylimits(2)=max(ylimits(2), max(N));
        end
    end
end
outfilename=sprintf('out_psth%s-%s-%s.mat', expdate, session, filenum);
% fprintf('\nOutfile name: %s', outfilename)
% fprintf('\nmin/max reps: %d/%d', min(min(min(nreps))), max(max(max(nreps))))
% fprintf('\ntotal num spikes: %d', length(dspikes))


%plot ch1
for dindex=[1:numdurs]
    figure
    p=0;
    subplot1( numamps,numfreqs)
    hold on
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            subplot1( p)
            
            spiketimes1=mM1(findex, aindex, dindex).spiketimes;
            %         %use this code to plot curves
            %         [n, x]=hist(spiketimes1, numbins);
            %         r=plot(x, n);
            %         set(r, 'linewidth', 2)
            %use this code to plot histograms
            X=xlimits(1):binwidth:xlimits(2); %specify bin centers
            %             hist(spiketimes1, X);
            [N, x]=hist(spiketimes1, X);
            N=N./nreps(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
            N=1000*N./binwidth; %normalize to spike rate in Hz
            
            bar(x, N,1);
            h=line([0 0+durs(dindex)], [-.2 -.2], 'color', 'm', 'linewidth', 4);
            h2=line(xlimits, [0 0], 'color', 'k');
            ylim(ylimits)
            xlim(xlimits)
            %xlim([-10 500])
            %axis off
            %grid on
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
            axis off
            %  set(gca, 'xtickmode', 'auto')
            %  grid on
            %  if mod(findex,2) %odd freq
            %   vpos=axmax(1);
            %  %else
            vpos=ylimits(1)-diff(ylimits)/10;
            if aindex==1
                text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
            %  end
            if aindex==numamps && findex==numfreqs
                axis on
                ylimits666=[0 round(mean(ylimits)) ceil(ylimits(2))];
                set(gca,'xtick',xlimits,'ytick',ylimits)
                set(gca,'xticklabel',{xlimits},'yticklabel',{ylimits666})
                %xlabel('time (ms)');
                %ylabel('FR (Hz)');
            end
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s: %dms, %.2f mV (%.1f SD), nreps: %d-%d, %d spikes',expdate,session,filenum,durs(dindex),thresh,nstd,min(min(min(nreps))),max(max(max(nreps))),length(dspikes)))

end %for dindex
if ~outfile_exists
    try out_psth=rmfield(out,'lostat');end %#ok this now lives in it's own outfile
    out_psth.nstd=nstd;
    out_psth.binwidth=binwidth;
    out_psth.xlimits=xlimits;
    out_psth.thresh=thresh;
    out_psth.spikes=spikes;
    out_psth.dspikes=dspikes;
    out_psth.filteredtrace=filteredtrace;
    out_psth.freqs=freqs;
    out_psth.amps=amps;
    out_psth.durs=durs;
    out_psth.nreps=nreps;
    out_psth.M1=M1;
    out_psth.mM1=mM1;
    godatadir(expdate, session, filenum)
     save(outfilename, 'out_psth')
    fprintf('\n saved to %s\n\n', outfilename);
end
fprintf('\nTotal run time = %.1f seconds\n',toc);



%check if the on response is the same size as the off response
% A=ON response (0:win)
% B=OFF response (dur-:dur+win)
if(0)
    fprintf('\n\ntest whether OFF=ON (p->0 means different, p->1 means same)\n\n')
    win=50;
    p=0;
    for dindex=[1:numdurs]
        for aindex=[1:numamps]
            for findex=1:numfreqs
                start=0;
                stop=start+win;
                for rep=1:nreps(findex,aindex,dindex)
                    A1=find(M1(findex,aindex,dindex, rep).spiketimes>start);
                    A2=find(M1(findex,aindex,dindex, rep).spiketimes<stop);
                    A(rep)=length(intersect(A1, A2));
                end
                
                start=durs(dindex);
                stop=start+win;
                for rep=1:nreps(findex,aindex,dindex)
                    B1=find(M1(findex,aindex,dindex, rep).spiketimes>start);
                    B2=find(M1(findex,aindex,dindex, rep).spiketimes<stop);
                    B(rep)=length(intersect(B1, B2));
                end
                [h, p]=ttest2(A, B, .001);
                sd={'same', 'different'};
                fprintf('\n%.2f kHz: p=%.4f (%s) ', freqs(findex)/1000, p, sd{h+1})
            end
        end
    end
end

fprintf('\n')

