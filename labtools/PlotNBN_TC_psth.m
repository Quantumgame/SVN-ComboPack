function PlotNBN_TC_psth(expdate, session, filenum, varargin)
% extracts spikes and plots spike rasters with a single psth tuning curve
%for narrow-band noise tuning curve data
%
% usage: PlotNBN_TC_psth(expdate, session, filenum, [thresh], [xlimits], [ylimits], [binwidth])
% (thresh, xlimits, ylimits, binwidth are optional)
%
%  defaults: thresh=7sd, binwidth=50ms, axes autoscaled
%  thresh is in number of standard deviations
%  to use an absolute threshold (in mV) pass [-1 mV] as the thresh
%  argument, where mV is the desired threshold
% mw 032410
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
    binwidth=5;
elseif nargin==4
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=5;
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
    binwidth=5;
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
    if isempty(ylimits) | length(ylimits)~=2
        ylimits=-1;
    end
    binwidth=5;
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
        binwidth=5;
    end

else
    error('wrong number of arguments');
end

monitor=0;
lostat=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
fs=10;

fprintf('\nload file 1: ')
try
    fprintf('\ntrying to load %s...', datafile)
    global pref
    if isempty (pref) Prefs; end
    if pref.usebak
        godatadirbak(expdate, session, filenum)
    else
        godatadir(expdate, session, filenum)
    end
    L=load(datafile);
    E=load(eventsfile);
    fprintf('done.');
catch
    try
        ProcessData_single(expdate, session, filenum)
        L=load(datafile);
        E=load(eventsfile);
        fprintf('done.');
    catch
        fprintf('\nProcessed data: %s not found. \nDid you copy into Backup?', datafile)
    end
end

event=E.event;
if isempty(event) fprintf('\nno tones\n'); return; end
scaledtrace=L.nativeScaling*double(L.trace)+ L.nativeOffset;
clear E L


fprintf('\ncomputing tuning curve...');

samprate=1e4;
if lostat==-1 lostat=length(scaledtrace);end
fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));

high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
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
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
if length(spikes)>0
    dspikes=[spikes(1) dspikes'];
else
    dspikes=[];
end
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
    %pause(.5)
    %close
end
if monitor
    figure
    ylim([min(filteredtrace) max(filteredtrace)]);
    numspikes2plot=min(length(dspikes), 20);
    for ds=dspikes(1:numspikes2plot)
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

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allbws(j)=0;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
        allbws(j)=inf;
    elseif strcmp(event(i).Type, 'noise')
        j=j+1;
        allfreqs(j)=event(i).Param.center_frequency;
        allbws(j)=event(i).Param.bandwidthOct;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
bws=unique(allbws);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);
numbws=length(bws);

fprintf('\n frequencies:')
fprintf('%.1f  ', freqs/1000)
fprintf('\n amplitudes:')
fprintf('%d  ', round(amps))
fprintf('\n bandwidths:')
fprintf('%.1f  ', bws)
fprintf('\n durations:')
fprintf('%d  ', durs)

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
M1=[];
nreps=zeros(numfreqs, numamps, numbws);


%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')  | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'noise')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos) &~isempty(event(i).Position_rising)
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
                    bw=0;
                elseif strcmp(event(i).Type, 'whitenoise')
                    dur=event(i).Param.duration;
                    freq=-1;
                    bw=inf;
                elseif strcmp(event(i).Type, 'noise')
                    dur=event(i).Param.duration;
                    freq=event(i).Param.center_frequency;
                    bw=event(i).Param.bandwidthOct;
                end

                amp=event(i).Param.amplitude;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                %Note: not using dindex since MakeNBNProtocol is contrained to a single duration
                bwindex=find(bws==bw);
                nreps(findex, aindex, bwindex)=nreps(findex, aindex, bwindex)+1;
                spiketimes1=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
                spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
                M1(findex,aindex,bwindex, nreps(findex, aindex, bwindex)).spiketimes=spiketimes1;
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))
fprintf('\ntotal num spikes: %d', length(dspikes))

%accumulate across trials
for bwindex=[1:numbws]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            spiketimes1=[];
            for rep=1:nreps(findex, aindex, bwindex)
                spiketimes1=[spiketimes1 M1(findex, aindex, bwindex, rep).spiketimes];
            end
            mM1(findex, aindex, bwindex).spiketimes=spiketimes1;
        end
    end
end

dindex=1;

%find axis limits
if ylimits==-1
    ylimits=[-1 0];
    for aindex=[numamps:-1:1]
        for bwindex=1:numbws
            for findex=2:numfreqs

                spiketimes=mM1(findex, aindex, bwindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(spiketimes, X);
                ylimits(2)=max(ylimits(2), max(N));
            end
        end
    end
end

%not plotting an entire separate freq column for whitenoise, just plotting
%it as the "inf" bandwidth for each freq

%plot ch1
for aindex=[1:numamps]
    figure
    p=0;
    subplot1( numbws,numfreqs-1)
    for bwindex=[1:numbws]
        for findex=2:numfreqs
            if bwindex==numbws %inf==wn
                findex=1;
            end
            p=p+1;
            subplot1( p)
            hold on
            spiketimes1=mM1(findex, aindex, bwindex).spiketimes;
            %         %use this code to plot curves
            %         [n, x]=hist(spiketimes1, numbins);
            %         r=plot(x, n);
            %         set(r, 'linewidth', 2)
            %use this code to plot histograms
            X=xlimits(1):binwidth:xlimits(2); %specify bin centers
            hist(spiketimes1, X);
            line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
            line(xlimits, [0 0], 'color', 'k')
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
    for bwindex=[1:numbws]
        for findex=2:numfreqs
            p=p+1;
            subplot1(p)
            if findex==2
                T=text(xlimits(1)-diff(xlimits)/16, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                set(T, 'HorizontalAlignment', 'right')

                if bwindex==1
                    T=text(xlimits(1)-diff(xlimits)/16, ylimits(2), sprintf('BW\nOct'));
                    set(T, 'HorizontalAlignment', 'right')
                end
            else
                set(gca, 'xticklabel', '')
            end
            set(gca, 'xtickmode', 'auto')
            grid on
            if bwindex==numbws
                %             if mod(findex,2) %odd freq
                %                 vpos=axmax(1);
                %  %           else
                vpos=ylimits(1)-diff(ylimits)/4;
                %            end
                text(mean(xlimits), vpos, sprintf('%.1f kHz', freqs(findex)/1000))
            else
                set(gca, 'yticklabel', '')
            end
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s ch 1, dur=%d, nstd=%g, %d ms bins, %d total spikes',expdate,session, filenum, durs(dindex), nstd,binwidth,length(dspikes)))

    pos=get(gcf, 'pos');
    pos(2)=pos(2)-600;
    pos(4)=pos(4)+600;
    set(gcf, 'pos', pos);
    text
end %for aindex


%assign outputs
out.scaledtrace=scaledtrace;
out.M1=M1;
% out.M1stim=M1stim;
% out.mM1stim=mM1stim;
out.mM1=mM1;
out.expdate=expdate;
out.filenum=filenum;
out.session=session;
out.lostat=lostat;
out.freqs=freqs;
out.amps=amps;
out.durs=durs;
out.bws=bws;
out.nreps=nreps;
out.numfreqs=numfreqs;
out.numamps=numamps;
out.numdurs=numdurs;
out.event=event;
out.xlimits=xlimits;
out.ylimits=ylimits;
out.samprate=samprate;
out.nstd=nstd;
out.thresh=thresh;
out.refract=refract;
out.high_pass_cutoff=high_pass_cutoff;
out.dspikes=dspikes;
godatadir(expdate, session, filenum);
outfile=sprintf('outspikes%s-%s-%s.mat', expdate, session, filenum);
save(outfile, 'out')

fprintf('\nsaved %s in %s\n', outfile,pwd)

