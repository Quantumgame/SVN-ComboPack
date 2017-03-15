function PlotTC_psth_1tone(expdate1, session1, filenum1, tone_freq, tone_amp, varargin)
%same as PlotTC_psth, except only a single tone is plotted (specified with
%freq in kHz and amp in dB)
%
%extracts spikes and plots spike rasters with a single psth tuning curve
%
% usage: PlotTC_psth(expdate, session, filenum, freq, amp, [thresh], [xlimits], [ylimits], [binwidth])
% (thresh, xlimits, ylimits, binwidth are optional)
%
%  defaults: thresh=7sd, binwidth=50ms, axes autoscaled
%  thresh is in number of standard deviations
%  to use an absolute threshold (in mV) pass [-1 mV] as the thresh
%  argument, where mV is the desired threshold
% mw 070406
% last update mw 030909
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==5
    nstd=7;
    ylimits=-1;
    durs=getdurs(expdate1, session1, filenum1);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=50;
elseif nargin==6
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    ylimits=-1;
    durs=getdurs(expdate1, session1, filenum1);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=50;
elseif nargin==7
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
        durs=getdurs(expdate1, session1, filenum1);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    ylimits=-1;
    binwidth=50;
elseif nargin==8
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
        durs=getdurs(expdate1, session1, filenum1);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    ylimits=varargin{3};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=50;
elseif nargin==9
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
        durs=getdurs(expdate1, session1, filenum1);
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


loadit=1;
monitor=0;
lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

global pref
if isempty(pref) Prefs; end
username=pref.username;
datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate1, username, session1, filenum1);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate1, username, session1, filenum1);
fs=10;

if loadit
    fprintf('\nload file 1: ')
    try
        fprintf('\ntrying to load %s...', datafile1)
        godatadir(expdate1, session1, filenum1)
        L=load(datafile1);
        E=load(eventsfile1);
        fprintf('done.');
    catch
        fprintf('failed. Could not find data')
    end
end
event1=E.event;
trace1=L.trace;
nativeOffset1=L.nativeOffset;
nativeScaling1=L.nativeScaling;
clear E L


fprintf('\ncomputing tuning curve...');

samprate=1e4;
scaledtrace1=nativeScaling1*double(trace1)+ nativeOffset1;
if lostat1==-1 lostat1=length(scaledtrace1);end
t=1:length(scaledtrace1);
t=1000*t/samprate;
fprintf('\nresponse window: %d before to %d ms after tone onset',round(baseline), round(tracelength));

high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace1=filtfilt(b,a,scaledtrace1);
if length(nstd)==2
    if nstd(1)==-1
        thresh=nstd(2);
        fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh, thresh/std(filteredtrace1));
    end
else
    thresh=nstd*std(filteredtrace1);
    fprintf('\nusing spike detection threshold of %.1f mV (%g sd)', thresh, nstd);
end
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace1)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
if ~isempty(spikes)
    dspikes=[spikes(1) dspikes'];
end

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
    %pause(.5)
    %close
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
for i=1:length(event1)
    if strcmp(event1(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event1(i).Param.frequency;
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.duration;
    elseif strcmp(event1(i).Type, 'tonetrain')
        j=j+1;
        allfreqs(j)=event1(i).Param.frequency;
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.toneduration;
    elseif strcmp(event1(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.duration;
    elseif strcmp(event1(i).Type, 'grating')
        j=j+1;
        allfreqs(j)=event1(i).Param.angle*1000;
        allamps(j)=event1(i).Param.spatialfrequency;
        alldurs(j)=event1(i).Param.duration;
    elseif strcmp(event1(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.clickduration; %        alldurs(j)=event1(i).Param.duration; gives trial duration not tone duration
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

%find findex and aindex of requested freq and amp to plot
tone_findex=find(abs(freqs-1000*tone_freq)==min(abs(freqs-1000*tone_freq)));
tone_aindex=find(abs(amps-tone_amp)==min(abs(amps-tone_amp)));

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
%M1=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1=[];
nreps1=zeros(numfreqs, numamps, numdurs);


%extract the traces into a big matrix M
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'tone') | strcmp(event1(i).Type, 'tonetrain') | strcmp(event1(i).Type, 'grating') | strcmp(event1(i).Type, 'whitenoise') | strcmp(event1(i).Type, 'clicktrain')
        if isfield(event1(i), 'soundcardtriggerPos')
            pos=event1(i).soundcardtriggerPos;
            if isempty(pos) &~isempty(event1(i).Position_rising)
                pos=event1(i).Position_rising;
            end
        else
            pos=event1(i).Position_rising;
        end

        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat1
                fprintf('\ndiscarding trace')
            else
                if strcmp(event1(i).Type, 'tone')
                    freq=event1(i).Param.frequency;
                    dur=event1(i).Param.duration;
                elseif  strcmp(event1(i).Type, 'tonetrain')
                    freq=event1(i).Param.frequency;
                    dur=event1(i).Param.toneduration;
                elseif  strcmp(event1(i).Type, 'grating')
                    freq=event1(i).Param.angle*1000;
                    dur=event1(i).Param.duration;
                elseif strcmp(event1(i).Type, 'whitenoise')
                    dur=event1(i).Param.duration;
                    freq=-1;
                elseif strcmp(event1(i).Type, 'clicktrain')
                    dur=event1(i).Param.clickduration;
                    freq=-1;
                end
                try
                    amp=event1(i).Param.amplitude;
                catch
                    amp=event1(i).Param.spatialfrequency;
                end
                %                 dur=event1(i).Param.duration;
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

numbins=tracelength/binwidth;

dindex=1;


%find axis limits
if ylimits==-1
    ylimits=0;
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            spiketimes=mM1(findex, aindex, dindex).spiketimes;
            X=-baseline:binwidth:tracelength; %specify bin centers
            [N, x]=hist(spiketimes, X);
            ylimits(2)=max(ylimits(2), max(N));
        end
    end
end

%plot ch1
findex=tone_findex;
aindex=tone_aindex;

figure
p=0;
hold on
spiketimes1=mM1(findex, aindex, dindex).spiketimes;
%         %use this code to plot curves
%         [n, x]=hist(spiketimes1, numbins);
%         r=plot(x, n);
%         set(r, 'linewidth', 2)
%use this code to plot histograms
X=-baseline:binwidth:tracelength; %specify bin centers
hist(spiketimes1, X);
h=findobj(gca, 'Type', 'patch');
set(h, 'facecolor', 'k');

line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
line(xlimits, [0 0], 'color', 'k', 'linewidth', 2)
ylim(ylimits)
%xlim([0-baseline tracelength])

xlim(xlimits)
%xlim([-10 500])
%axis off
%set(gca, 'xtick', [0:20:tracelength])
%grid on
set(gca, 'fontsize', fs)


%label amps and freqs


T=text(xlimits(1)-diff(xlimits)/2, mean(ylimits), int2str(amps(aindex)));
set(T, 'HorizontalAlignment', 'right')
set(gca, 'xtickmode', 'auto')
grid on
vpos=ylimits(1)-diff(ylimits)/10;

text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))

title(sprintf('%s-%s-%s ch 1\n%.1f kHz, %.0f dB, dur=%d\nnstd=%g, %d bins, %d total spikes',expdate1,session1, filenum1, tone_freq, tone_amp, durs(dindex), nstd(end),binwidth,length(dspikes)))






fprintf('\n\n')

