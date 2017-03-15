function PlotAO_rasters(expdate, session, filenum, varargin)
% 
% usage: PlotTC_rasters(expdate, session, filenum, thresh, xlimits, ylimits, binwidth)
% (thresh, xlimits, ylimits, and binwidth are optional)
% 
%  thresh is in number of standard deviations
%  to use an absolute threshold (in mV) pass [-1 mV] as the thresh
% 
% 8/11/13 AKH
% Corrects spiketimes for laser jitter, on a trial-by-trial
% basis. All trials aligned to '0', the actual onset of the laser pulse.
% mM1corr -- all spiketimes, corrected for laser jitter. (0 ms = start of pulse.)
% M1corr -- trial-by-trial spiketimes, corrected for laser jitter.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    nstd=7;
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=50;
elseif nargin==4
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=50;
elseif nargin==5
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    ylimits=-1;
    binwidth=50;
elseif nargin==6
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    ylimits=varargin{3};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=50;
elseif nargin==7
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    ylimits=varargin{3};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=varargin{4};
    if isempty(binwidth)
        binwidth=50;
    end

else
    error('wrong number of arguments');
end
tracelength=diff(xlimits); %in ms
if xlimits(1)<0
    baseline=abs(xlimits(1));
else
    baseline=0;
end

monitor=0;
lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

global pref
if isempty(pref) Prefs; end
username=pref.username;
datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate, username, session, filenum);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate, username, session, filenum);
fs=8;


fprintf('\nload file 1: ')
[L E S D2]=gogetdata(expdate,session,filenum);


event=E.event;
trace1=L.trace;
nativeOffset1=L.nativeOffset;
nativeScaling1=L.nativeScaling;

scaledtrace2=[]; % Laser copy.
try scaledtrace2=D2.nativeScaling*double(D2.trace) +D2.nativeOffset;
end
clear L E S D2

samprate=1e4;
scaledtrace1=nativeScaling1*double(trace1)+ nativeOffset1;
if lostat1==-1 lostat1=length(scaledtrace1);end
t=1:length(scaledtrace1);
t=1000*t/samprate;

high_pass_cutoff=300; %Hz
fprintf('\nHigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace1=filtfilt(b,a,scaledtrace1);
if length(nstd)==2
    if nstd(1)==-1
        thresh=nstd(2);
        nstd=thresh/std(filteredtrace1);
        fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh, nstd);
    end
else
    thresh=nstd*std(filteredtrace1);
    if thresh>1
    fprintf('\nusing spike detection threshold of %.1f mV (%g sd)', thresh, nstd);
    elseif thresh<=1
    fprintf('\nusing spike detection threshold of %.4f mV (%g sd)', thresh, nstd);
    end
end
refract=5;
thresh2=7*std(filteredtrace1);
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes1=find(abs(filteredtrace1)>thresh);
spikes2=find(abs(filteredtrace1)>thresh2);
for i=1:length(spikes2)
artifact(i)=find(spikes2(i)==spikes1);
end

spikes1(artifact)=NaN;
spikes=spikes1(~isnan(spikes1));

dspikes=spikes(1+find(diff(spikes)>refract));
% dspikes1=spikes1(1+find(diff(spikes1)>refract));
% dspikes2=spikes2(1+find(diff(spikes2)>refract));
% for i=1:length(dspikes2)
% dartifact(i)=find(dspikes2(i)==dspikes1);
% end
% dspikes1(dartifact)=NaN;
% dspikes=dspikes1(~isnan(dspikes));
dspikes=[spikes(1) dspikes'];

if (monitor)
    figure
    plot(filteredtrace1, 'b')
    hold on
    plot(thresh+zeros(size(filteredtrace1)), 'm--')
    plot(spikes, thresh*ones(size(spikes)), 'g*')
    plot(dspikes, thresh*ones(size(dspikes)), 'r*')
    L1=line(xlim, thresh*[1 1]);
    L2=line(xlim, thresh*[-1 -1]);
    set([L1 L2], 'color', 'g');
    pause(.5)
    close
end
if monitor
    figure
    ylim([min(filteredtrace1) max(filteredtrace1)]);
    for ds=dspikes(1:20)
        xlim([ds-100 ds+100])
        t=1:length(filteredtrace1);
        region=[ds-100:ds+100];
        if min(region)<1
            region=[1:ds+100];
        end
        hold on
        plot(t(region), filteredtrace1(region), 'b')
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


j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'aopulsetrain') 
        j=j+1;
        alldurs(j)=event(i).Param.duration;
    end
    
    if strcmp(event(i).Type, 'aopulse')
        j=j+1;
        alldurs(j)=event(i).Param.width;
    end
    
end
durs=unique(alldurs);
numdurs=length(durs);

%M1=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1=[];
M2=[];
nreps=zeros(numdurs);



%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'aopulse') || strcmp(event(i).Type, 'aopulsetrain')        
        
        if isfield(event(i), 'soundcardtriggerPos') || isfield(event(i), 'Position_rising')
            pos=event(i).Position_rising;
        end

        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat1
                    fprintf('\ndiscarding trace')
                else
                    if strcmp(event(i).Type, 'aopulse') 
                        dur=event(i).Param.width;
                    elseif strcmp(event(i).Type, 'aopulsetrain') 
                        dur=event(i).Param.duration;
                    end
                    dindex= find(durs==dur);
                    nreps(dindex)=nreps(dindex)+1;
                    
                    
                    
                    
                    if ~isempty(scaledtrace2) % Get laser snippet.
                        M2(dindex, nreps(dindex),:)=scaledtrace2(region);
                    end
                                        
                    spiketimes1=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
                    spiketimes1=(spiketimes1-pos)*1000/samprate;
                    M1(dindex, nreps(dindex)).spiketimes=spiketimes1;
                       
            end
        end
    end
end


% Correct for laser jitter, and...
% Accumulate across trials

for dindex=[1:numdurs]
        
    accspiketimes=[];
    
            for rep=1:nreps(dindex)
                
                spiketimes1=M1(dindex, rep).spiketimes; % Not corrected
                % Get delay
                trace1=squeeze(M2(dindex,rep, :));
                laserdelay=min(find(trace1>.4))/10; % in ms
                laserdelay=xlimits(1)+laserdelay; % delay relative to '0'
                
                
                
                % Sanity check -
                % Plot laser trace1.
%                 t=xlimits(1):.1:(xlimits(2)-.1); % plot laser on ms timescale
%                 figure;plot(t,trace1,'r')
%                 % Plot unchanged spiketimes1.
%                 hold on
%                 h=plot(spiketimes1, 6+ones(size(spiketimes1)), 'r.');
%                 ylim([-1 8])
%                 

                % Corrected spiketimes.
                spiketimes2=spiketimes1-laserdelay;
                accspiketimes=[accspiketimes spiketimes2];
                
                M1corr(dindex, rep).spiketimes=spiketimes2;
%                 trace2=trace1((laserdelay*10):end);
%                 t2=xlimits(1):.1:(xlimits(2)-laserdelay);

%                 figure;plot(t2,trace2)
%                 hold on
%                 h=plot(spiketimes2, 6+ones(size(spiketimes2)), '.');
%                 ylim([-1 8])
            end
            
            mM1corr(dindex).spiketimes=accspiketimes;
            % (Mean, now corrected for laser jitter.)
            
            %     if ~isempty(scaledtrace2)
            %         mM2(dindex,:)=mean(M2(dindex, 1:nreps(dindex),:), 2);
            %     end
end


numbins=tracelength/binwidth;

dindex=1;

%find axis limits
if ylimits==-1
    ylimits=[-2 -2];
    spiketimes=mM1corr(dindex).spiketimes;
    N=hist(spiketimes, numbins);
    ylimits(2)=max(ylimits(2), max(N));
end

%plot ch1
for dindex=[1:numdurs]
    figure
    
            hold on
            spiketimes1=mM1corr(dindex).spiketimes;
            hist(spiketimes1, numbins);
            h = findobj(gca,'Type','patch');
            set(h,'FaceColor',[.5 .5 .5],'EdgeColor','w')
            line([0 0+durs(dindex)], [-1 -1], 'color', [0 .2 .8], 'linewidth', 4)
            line(xlimits, [0 0], 'color', 'k')
            ylim(ylimits)
            %xlim([0-baseline tracelength])

            xlim(xlimits)
            %xlim([-10 500])
            %axis off
            %set(gca, 'xtick', [0:20:tracelength])
            %grid on


            %plot rasters
            inc=(ylimits(2))/max(max(max(nreps)));
            for n=1:nreps(dindex)
                
                if ~isempty(scaledtrace2) 
                    trace2=squeeze(M2(dindex,n, :));
                    laserdelay=min(find(trace2>.4))/10; % in ms
                    laserdelay=xlimits(1)+laserdelay; % delay relative to '0'
                end
                    

                
                spiketimes1=M1(dindex, n).spiketimes;
                spiketimes2=spiketimes1-laserdelay; % Now relative to actual rise.
                h=plot(spiketimes2, ylimits(2)+ones(size(spiketimes2))+(n-1)*inc, '.')
                set(h,'Color',[.5 .5 .5]);
                %                 set(h, 'markersize', 5)
            end
            ylim([ylimits(1) 2*ylimits(2)])
            xlim(xlimits)
            set(gca, 'fontsize', fs)
            xlabel('time (ms)')
            ylabel('Number of spikes')

    title(sprintf('%s-%s-%s ch 1, dur=%d, nstd=%d, %d bins, %d total spikes',expdate,session, filenum, durs(dindex), nstd,numbins,length(dspikes)))
    

end %for dindex



fprintf('\n\n')
