function PlotBII(expdate, session, filenum, varargin)
% extracts spikes and plots Binaural Interaction Index based on spike count
%BII is defined as
% (BothEars-RightEar)/(BothEars+RightEar), and
% (BothEars-LeftEar)/(BothEars+LeftEar)
% (there is a right BII and a left BII)
% usage: PlotBII('expdate','session','filenum',[thresh],[xlimits],[ylimits])
% (thresh, xlimits, ylimits are optional)
%
%  defaults: thresh=7sd, axes autoscaled
%  thresh is in number of standard deviations
%  to use an absolute threshold (in mV) pass [-1 mV] as the thresh
%  argument, where mV is the desired threshold
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
elseif nargin==4
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    ylimits=-1;
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
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
    godatadir(expdate, session, filenum)
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
t=1:length(scaledtrace);
t=1000*t/samprate;
fprintf('\nresponse window: %d to %d ms relative tone onset',round(xlimits(1)), round(xlimits(2)));

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
dspikes=[spikes(1) dspikes'];

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

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'bintone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allRamps(j)=event(i).Param.Ramplitude;
        allLamps(j)=event(i).Param.Lamplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'binwhitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allRamps(j)=event(i).Param.Ramplitude;
        allLamps(j)=event(i).Param.Lamplitude;
        alldurs(j)=event(i).Param.duration;
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
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'bintone') | strcmp(event(i).Type, 'binwhitenoise')
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
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))
fprintf('\ntotal num spikes: %d', length(dspikes))

%accumulate across trials
for dindex=[1:numdurs]
    for Raindex=1:numamps
        for  Laindex=1:numamps
            for findex=1:numfreqs
                spiketimes1=[];
                for rep=1:nreps(findex, Raindex, Laindex, dindex)
                    spiketimes1=[spiketimes1 M1(findex, Raindex, Laindex, dindex, rep).spiketimes];
                end
                mM1(findex, Raindex, Laindex, dindex).spiketimes=spiketimes1;
                M1count(findex, Raindex, Laindex, dindex)=length(spiketimes1);
            end
        end
    end
end








% assume amp(1) is always -1000
if Ramps(1)~=-1000 | Lamps(1)~=-1000
    error('first amp not -1000???')
end

% plot right BII

for dindex=[1:numdurs]
    for findex=1:numfreqs
        M=squeeze(M1count(findex, :, :, dindex));
        Ralone=M(:,1);
        Ralone=repmat(Ralone, 1, numamps);
        RBII=(M-Ralone)./(M+Ralone);
        RBII(isnan(RBII))=1000; %set nan values to black by setting value to 1000, adding a black row to colormap, and setting caxis
        figure
        map=colormap;
        map(length(map)+1,:)=[0 0 0];
        colormap(map);
        imagesc(RBII)
        caxis([-1 1]);
        set(gca, 'ydir', 'norm');
        set(gca, 'fontsize', fs)
        xlabel('Left')
        ylabel('Right')
        set(gca, 'ytick', 1:numamps, 'xtick', 1:numamps)
        set(gca, 'yticklabel', round(Ramps), 'xticklabel', round(Lamps))
        if length(nstd)==1
            title(sprintf('Right BII %s-%s-%s ch 1, %.1f kHz, dur=%d, nstd=%g, %d total spikes',expdate,session, filenum, freqs(findex)/1000, durs(dindex), nstd,length(dspikes)))
        else
            title(sprintf('Right BII %s-%s-%s ch 1, %.1f kHz, dur=%d, nstd=%g mV, %d total spikes',expdate,session, filenum, freqs(findex)/1000, durs(dindex), nstd(2),length(dspikes)))
        end            
        c=colorbar;
        h=get(c, 'ylabel');
        set(h, 'string', 'Right BII')

        Lalone=M(1,:);
        Lalone=repmat(Lalone, numamps,1);
        LBII=(M-Lalone)./(M+Lalone);
        RBII(isnan(RBII))=1000; %set nan values to zero
        figure;
        map=colormap;
        map(length(map)+1,:)=[0 0 0];
        colormap(map);
        imagesc(LBII)
        set(gca, 'ydir', 'norm');
        set(gca, 'fontsize', fs)
        xlabel('Left')
        ylabel('Right')
        set(gca, 'ytick', 1:numamps, 'xtick', 1:numamps)
        set(gca, 'yticklabel', round(Ramps), 'xticklabel', round(Lamps))
        if length(nstd)==1
        title(sprintf('Left BII %s-%s-%s ch 1, %.1f kHz, dur=%d, nstd=%g, %d total spikes',expdate,session, filenum, freqs(findex)/1000, durs(dindex), nstd,length(dspikes)))
        else
            title(sprintf('Left BII %s-%s-%s ch 1, %.1f kHz, dur=%d, nstd=%g mV, %d total spikes',expdate,session, filenum, freqs(findex)/1000, durs(dindex), nstd(2),length(dspikes)))
        end  
        c=colorbar;
        h=get(c, 'ylabel');
        set(h, 'string', 'Left BII')


    end
end





fprintf('\n\n')

