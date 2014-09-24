function PlotTC_rasters(expdate, session, filenum, varargin)
% extracts spikes and plots spike rasters with a single psth tuning curve
% usage: PlotTC_rasters(expdate, session, filenum, thresh, xlimits, ylimits, binwidth)
% (thresh, xlimits, ylimits, and binwidth are optional)
% (ylimits applies to psth; room is added for rasters)
%  thresh is in number of standard deviations
%  to use an absolute threshold (in mV) pass [-1 mV] as the thresh
% E2 analysis function
% mw 070406
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
% tracelength=diff(xlimits); %in ms
% if xlimits(1)<0
%     baseline=abs(xlimits(1));
% else
%     baseline=0;
% end

monitor=0;
lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

global pref
if isempty(pref) Prefs; end
username=pref.username;
datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate, username, session, filenum);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate, username, session, filenum);
fs=8;


fprintf('\nload file 1: ')
[L E S]=gogetdata(expdate,session,filenum);


event=E.event;
trace1=L.trace;
nativeOffset1=L.nativeOffset;
nativeScaling1=L.nativeScaling;
clear E L S


fprintf('\ncomputing tuning curve...');

samprate=1e4;
scaledtrace1=nativeScaling1*double(trace1)+ nativeOffset1;
if lostat1==-1 lostat1=length(scaledtrace1);end
t=1:length(scaledtrace1);
t=1000*t/samprate;
fprintf('\nresponse window: %d to %d ms relative to tone onset',xlimits(1), xlimits(2));

high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
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
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace1)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
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


user=whoami;
expfilename=sprintf('%s-%s-%s-%s.mat', expdate, user, session, filenum);
expstructurename=sprintf('exper_%s', filenum);
if exist(expfilename)==2 %try current directory
    load(expfilename)
    exp=eval(expstructurename);
    timemarks=exp.timemark.param.timemarks.value;
    notes=exp.timemark.param.notes.value;
else %try data directory
    cd ../../..
    try
        cd(sprintf('Data-%s-backup',user))
        cd(sprintf('%s-%s',expdate,user))
        cd(sprintf('%s-%s-%s',expdate,user, session))
    end
    if exist(expfilename)==2
        load(expfilename)
        exp=eval(expstructurename);
        if isfield(exp, 'timemark')
            timemarks=exp.timemark.param.timemarks.value;
            notes=exp.timemark.param.notes.value;
        else
            timemarks=[];
            notes=[];
            fprintf('\nno timemarks in exper structure.')
        end
    else
        timemarks=[];
        notes=[];
        fprintf('\ncould not find exper structure. Cannot plot timemarks.')
    end
end
timemarks=timemarks/60;


expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
%M1=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1=[];
nreps1=zeros(numfreqs, numamps, numdurs);


%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'naturalsound') | strcmp(event(i).Type, 'grating') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end

        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat1
                fprintf('\ndiscarding trace')
            else
                if strcmp(event(i).Type, 'tone')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.duration;
                elseif strcmp(event(i).Type, 'fmtone')
                    freq=event(i).Param.carrier_frequency;
                    dur=event(i).Param.duration;
                elseif  strcmp(event(i).Type, 'tonetrain')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.toneduration;
                elseif  strcmp(event(i).Type, 'grating')
                    freq=event(i).Param.angle*1000;
                    dur=event(i).Param.duration;
                elseif strcmp(event(i).Type, 'naturalsound')
                    dur=event(i).Param.duration;
                    freq=0;
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
                    try
                    amp=event(i).Param.spatialfrequency;
                    catch
                        amp=-1;
                    end
                end
                %                 dur=event(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps1(findex, aindex, dindex)=nreps1(findex, aindex, dindex)+1;
                spiketimes1=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
                spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
                M1(findex,aindex,dindex, nreps1(findex, aindex, dindex)).spiketimes=spiketimes1;
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps1))), max(max(max(nreps1))))
fprintf('\ntotal num spikes: %d', length(dspikes))

%accumulate across trials
for dindex=[1:numdurs]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            spiketimes1=[];
            for rep=1:nreps1(findex, aindex, dindex)
                spiketimes1=[spiketimes1 M1(findex, aindex, dindex, rep).spiketimes];
            end
            mM1(findex, aindex, dindex).spiketimes=spiketimes1;
        end
    end
end


numbins=diff(xlimits)/binwidth;

dindex=1;

%find axis limits
if ylimits==-1
    ylimits=[-2 -2];
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            spiketimes=mM1(findex, aindex, dindex).spiketimes;
            N=hist(spiketimes, numbins);
            ylimits(2)=max(ylimits(2), max(N));
        end
    end
end

%plot ch1
for dindex=[1:numdurs]
    figure
    p=0;
    subplot1( numamps,numfreqs)
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            %if p==5 keyboard, end
            subplot1(p)
            hold on
            spiketimes1=mM1(findex, aindex, dindex).spiketimes;
            %         %use this code to plot curves
            %         [n, x]=hist(spiketimes1, numbins);
            %         r=plot(x, n);
            %         set(r, 'linewidth', 2)
            %use this code to plot histograms
            hist(spiketimes1, numbins);
            h = findobj(gca,'Type','patch');
            set(h,'FaceColor',[.5 .5 .5],'EdgeColor','w')
            line([0 0+durs(dindex)], [-1 -1], 'color', [.5 .2 .8], 'linewidth', 4)
            line(xlimits, [0 0], 'color', 'k')
            ylim(ylimits)
            %xlim([0-baseline tracelength])

            xlim(xlimits)
            %xlim([-10 500])
            %axis off
            %set(gca, 'xtick', [0:20:tracelength])
            %grid on


            %plot rasters
            inc=(ylimits(2))/max(max(max(nreps1)));
            for n=1:nreps1(findex, aindex, dindex)
                spiketimes2=M1(findex,aindex,dindex, n).spiketimes;
                h=plot(spiketimes2, ylimits(2)+ones(size(spiketimes2))+(n-1)*inc, '.');
                
                %                 set(h, 'markersize', 5)
                set(h,'Color',[.5 .5 .5]);
            end
            ylim([ylimits(1) 2*ylimits(2)])
            xlim(xlimits)
            set(gca, 'fontsize', fs)
        end
    end
     yl=ylim;
    ypos=yl(1)+.1*diff(yl);
    for tm=1:length(timemarks)
        line([timemarks(tm) timemarks(tm)],xlim,  'linestyle', '--', 'color', 'k')
        txt=text(timemarks(tm), ypos, notes(tm));
    end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %label amps and freqs
    p=0;
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(xlimits(1)-100, mean(ylimits), int2str(amps(aindex)))
            else

            end
            set(gca, 'xtickmode', 'auto')
            grid on
            if aindex==1
                %             if mod(findex,2) %odd freq
                %                 vpos=axmax(1);
                %  %           else
                vpos=ylimits(1)-diff(ylimits)/20;
                %            end
                text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s ch 1, dur=%d, nstd=%d, %d bins, %d total spikes',expdate,session, filenum, durs(dindex), nstd,numbins,length(dspikes)))

end %for dindex



fprintf('\n\n')

