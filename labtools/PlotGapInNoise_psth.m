function PlotGapInNoise_psth(expdate,session,filenum,varargin)
% PlotGapInNoise_psth(expdate,session,filenum,[thresh],[xlimits],[ylimits],[binwidth])
% AKH 7/29/13

refract=15;
fs=12; % Fontsize for figures
global pref
if isempty(pref); Prefs; end

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
% Defaults
if ~exist('nstd','var'); nstd=7; end
if isempty(nstd); nstd=7; end
if ~exist('xlimits','var'); xlimits=[0 100]; end
if isempty(xlimits); xlimits=[0 100]; end
if ~exist('ylimits','var'); ylimits=-1; end
if isempty(ylimits); ylimits=-1; end
if ~exist('binwidth','var'); binwidth=5; end
if isempty(binwidth); binwidth=5; end

monitor=0;
outfile_exists=0;

if ~outfile_exists
    lostat1=-1; %discard data after this position (in samples), -1 to skip
    [D E S]=gogetdata(expdate,session,filenum);
    event=E.event;
    if isempty(event); fprintf('\nevent is empty\n'); return; end
    scaledtrace=D.nativeScaling*double(D.trace)+ D.nativeOffset;
    stim=S.nativeScalingStim*double(S.stim);
    clear D E S
    samprate=1e4;
    if lostat1==-1; lostat=length(scaledtrace);end
else
end

% Filtering (filteredtrace, thresh, nstd, spikes, dspikes)
fprintf('\ncomputing tuning curve...');
high_pass_cutoff=600; %Hz
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

if monitor % full trace
    
    figure
    plot(filteredtrace, 'b')
    hold on
    plot(thresh+zeros(size(filteredtrace)), 'm--')
    L1=line(xlim, thresh*[1 1]);
    L2=line(xlim, thresh*[-1 -1]);
    set([L1 L2], 'color', 'g');
    title(sprintf('%s-%s-%s -- %.2f mV, %.2f std',expdate,session,filenum,thresh,nstd))
end


if ~outfile_exists
    j=0;
    
    for i=1:length(event)
        if strcmp(event(i).Type, 'gapinnoise')
            j=j+1;
            allsoas(j)=event(i).Param.duration-event(i).Param.pregap-event(i).Param.amplitude;
            allgapdurs(j)=event(i).Param.gapdur;
            allgapdelays(j)=event(i).Param.pregap;
            allnoiseamps(j)=event(i).Param.amplitude;
            duration(j)=event(i).Param.duration;
        end
    end
    M1=[];
    gapdurs=unique(allgapdurs);
    soa=unique(allsoas);
    gapdelay=unique(allgapdelays);
    noiseamp=unique(allnoiseamps);
    pulseamp=unique(allnoiseamps);
    numpulseamps=length(pulseamp);
    numgapdurs=length(gapdurs);
    nreps=zeros(numgapdurs);
    duration=unique(duration);
end

% Extract into big matrix M
if ~outfile_exists
    for i=1:length(event)
        if strcmp(event(i).Type, 'gapinnoise')
            
            if isfield(event(i), 'soundcardtriggerPos')
                pos=event(i).soundcardtriggerPos;
                %             pr=event(i).Position_rising;
                %             Delta(i)=pos-pr;
            else
                pos=event(i).Position_rising;
            end
            
            start=(pos+(xlimits(1)+0)*1e-3*samprate);
            stop=(pos+(xlimits(2)+0)*1e-3*samprate)-1;
            
            region=start:stop;
            if isempty(find(region<0)) % Disallow negative start times
                gapdur=event(i).Param.gapdur;
                gdindex= find(gapdur==gapdurs);
                pulseamp=event(i).Param.amplitude;
                paindex= find(pulseamp==pulseamp);
                spiketimes1=dspikes(dspikes>start & dspikes<stop);
                spiketimes1=(spiketimes1-pos)/(samprate*1e-3);
                nreps(gdindex, paindex)=nreps(gdindex, paindex)+1;
                M1(gdindex, paindex, nreps(gdindex, paindex)).spiketimes=spiketimes1;
                M1stim(gdindex, paindex, nreps(gdindex, paindex),:)=stim(start:stop);
            end
        end
    end
end

% Accumulate across trials
for paindex=1:numpulseamps
    for gdindex=1:numgapdurs
        
        spiketimes1=[];
        for rep=1:nreps(gdindex,paindex)
            spiketimes1=[spiketimes1 M1(gdindex,paindex, rep).spiketimes];
        end
        mM1(gdindex,paindex).spiketimes=spiketimes1;
        
    end
end

if ylimits==-1
    ylimmax=.0001;
    for paindex=1:numpulseamps
        for gdindex=1:numgapdurs
            spiketimes1=mM1(gdindex,paindex).spiketimes;
            X=(xlimits(1)+0):binwidth:(xlimits(2)+0); %specify bin centers
            [N, x]=hist(spiketimes1, X);
            N=N./nreps(gdindex,paindex); % averaged across trials
            N=1000*N./binwidth; %normalize to spike rate in Hz
            if max(N)>ylimmax
                ylimmax=max(N);
            end
        end
    end
else
    ylimmax=ylimits(2);
end

figure
for paindex=1:numpulseamps
    p=0;
    subplot1(numgapdurs,1)
    for gdindex=1:numgapdurs
        p=p+1;
        subplot1(p)
        %figure
        hold on
        if p==1
            title(sprintf('%s-%s-%s',expdate,session,filenum))
        end
        spiketimes1=mM1(gdindex,paindex).spiketimes;
        X=(xlimits(1)+0):binwidth:(xlimits(2)+0); %specify bin centers
        [N, x]=hist(spiketimes1, X);
        N=N./nreps(gdindex,paindex); % averaged across trials
        N=1000*N./binwidth; %normalize to spike rate in Hz
        bar(x, N,1,'facecolor',[0 0 0]);
        line([0 gapdelay],[-.1 -.1],'color','m','linewidth',1.5)
        if gapdurs(gdindex)>0
            line([gapdelay+gapdurs(gdindex) max(duration)],[-.1 -.1],'color','m','linewidth',1.5) % Assuming a single duration.
        end
        yl=ylim;
% % %         offset=ylimmax;
% % %         %plot rasters
% % %         inc=(ylimmax)/15;
% % %         for n=1:nreps(gdindex,paindex)
% % %             spiketimes2=M1(gdindex,paindex, n).spiketimes;
% % %             h=plot(spiketimes2, offset+zeros(size(spiketimes2)), '.');
% % %             offset=offset+inc;
% % %             set(h, 'markersize', 15)
% % %             set(h,'Color','k');
% % %         end
        
        xlim([(xlimits(1)) xlimits(2)])
        %        ylim([-.2 (2*ylimmax)])
        yl=ylim;
        yl(1)=-.2;
        ylim(yl);
        ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
        
    end
end

xlabel('ms')

%plot stimulus as a sanity check
if(0)
    figure
    for paindex=1:numpulseamps
        p=0;
        subplot1(numgapdurs,1)
        for gdindex=1:numgapdurs
            p=p+1;
            subplot1(p)
            hold on
            if p==1
                title(sprintf('%s-%s-%s',expdate,session,filenum))
            end
            spiketimes1=mM1(gdindex,paindex).spiketimes;
            X=(xlimits(1)+0):binwidth:(xlimits(2)+0); %specify bin centers
            [N, x]=hist(spiketimes1, X);
            N=N./nreps(gdindex,paindex); % averaged across trials
            bar(x, N,1,'facecolor',[0 0 0]);
            line([ 0 gapdelay ],[-.1 -.1],'color','g','linewidth',1.5)
            if gapdurs(gdindex)>0
                line([gapdelay+gapdurs(gdindex) max(duration)],[-.1 -.1],'color','m','linewidth',1.5) % Assuming a single duration.
            end
            xlim([(xlimits(1)) xlimits(2)])
            ylim([-.2 (1.1*ylimmax)])
            ylabel(sprintf('%.0f ms',gapdurs(gdindex)));
            stimtrace=squeeze(M1stim(gdindex, paindex, nreps(gdindex, paindex),:));
            stimtrace=.1*diff(ylim)*stimtrace./max(abs(stimtrace));
            t=1:length(stimtrace);
            t=t/10;t=t+xlimits(1);
            plot(t, stimtrace, 'r')
        end
    end
    
    xlabel('ms')
end

end