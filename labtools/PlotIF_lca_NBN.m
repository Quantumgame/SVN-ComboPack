function PlotIF_lca_NBN(expdate1, session1, filenum1, expdate2, session2, filenum2, thresh2, refract2, varargin)
%usage:     PlotIF_lca_NBN(expdate1, session1, filenum1, expdate2, session2, filenum2, thresh, refract, [xlimits])
%       lca files first (expdate1), IClamp files second (expdate2)
%
%plots spikecount vs. bandwidth for cell-attached recording, and runs PlotIF_NBN
%for an Iclamp recording, so you can compare them
%which uses a simple threshold model (IFvm.m) to predict spiking output from
%Iclamp recordings of Vm
%for narrow-band stimuli
%to start, try thresh=5; refract=15
%

if nargin==0 fprintf('no input');return;
elseif nargin==8
    xlimits=[]; 
elseif nargin==9
    xlimits=varargin{1};
    if isempty(xlimits) | length(xlimits)~=2
            xlimits=[]; 
    end       
else help PlotIF_lca_NBN; error('PlotIF_lca_NBN: wrong number of inputs')
end

    if isempty(xlimits)
        durs=getdurs(expdate1, session1, filenum1);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% below is modified from  PlotNBN_TC_psth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nstd=7;
binwidth=5;

fprintf('\nload file 1: ')
[datafile, eventsfile, stimfile]=getfilenames(expdate1, session1, filenum1);
try
    fprintf('\ntrying to load %s...', datafile)
    global pref
    if isempty (pref) Prefs; end
    if pref.usebak
        godatadirbak(expdate1, session1, filenum1)
    else
        godatadir(expdate1, session1, filenum1)
    end
    L=load(datafile);
    E=load(eventsfile);
    fprintf('done.');
catch
    try
        ProcessData_single(expdate1, session1, filenum1)
        L=load(datafile);
        E=load(eventsfile);
        fprintf('done.');
    catch
        fprintf('\nProcessed data: %s not found.', datafile)
    end
end

event=E.event;
if isempty(event) fprintf('\nno tones\n'); return; end
scaledtrace=L.nativeScaling*double(L.trace)+ L.nativeOffset;
clear E L


fprintf('\ncomputing tuning curve...');

samprate=1e4;
 lostat=length(scaledtrace);
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
dspikes=[spikes(1) dspikes'];

monitor=1;
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
            spikecounts1(bwindex)=length(spiketimes1);
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
            %set(gca, 'fontsize', fs)

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
    title(sprintf('%s-%s-%s ch 1, dur=%d, nstd=%g, %d ms bins, %d total spikes',expdate1,session1, filenum1, durs(dindex), nstd,binwidth,length(dspikes)))

    pos=get(gcf, 'pos');
    pos(2)=pos(2)-600;
    pos(4)=pos(4)+600;
    set(gcf, 'pos', pos);
    
    
%     figure
%     t=1:numbws;
%     plot(t, spikecounts1, 'ko-')
%     xlim([.5 numbws+.5]);
%     set(gca, 'xtick', 1:numbws)
%     set(gca, 'xticklabel', bws)
%     xlabel('bandwidth, oct')
%     ylabel('lca spikecount')


    
end %for aindex


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% below is modified from PlotIF_NBN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outfile2=sprintf('out%s-%s-%s.mat', expdate2, session2, filenum2);
godatadir(expdate2, session2, filenum2)
if exist(outfile2, 'file')~=2 %need to generate local outfile
    global pref
    if pref.usebak
        godatadirbak(expdate2, session2, filenum2)
    else
        godatadir(expdate2, session2, filenum2)
    end
    if exist(getfilenames(expdate2, session2, filenum2))~=2 %need to create axopatchdata
        if pref.usebak
            ProcessData_singlebak(expdate2, session2, filenum2)
        else
            ProcessData_single(expdate2, session2, filenum2)
        end
    end
    ProcessTC_NBN(expdate2, session2, filenum2, xlimits);
end
load(outfile2)

fprintf('\nnumber of reps:\n')
squeeze(out.nreps)

if isempty(xlimits) xlimits=out.xlimits; 
elseif xlimits(2)>out.xlimits(2)
    ProcessTC_NBN(expdate2, session2, filenum2, xlimits)
    load(outfile2)
end

M1=out.M1;
mM1=out.mM1;
M1stim=out.M1stim;
mM1stim=out.mM1stim;
expdate=out.expdate;
session=out.session;
filenum=out.filenum;
freqs=out.freqs;
amps=out.amps;
durs=out.durs;
bws=out.bws;
samprate=out.samprate;
numamps=length(amps);
numdurs=length(durs);
numbws=length(bws);
numfreqs=length(freqs);


%find optimal axis limits
%optimized based on highest potential (will crop low potentials)

ylimits=[0 0];
dindex=1;
for bwindex=[1:numbws]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs


            trace1=squeeze(mM1(findex, aindex,bwindex, :));
            trace1=trace1-mean(trace1(1:100));
            %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
            if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
            if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
        end
    end
end
%add some room for stim 
ylimits(1)=ylimits(1)-.1*diff(ylimits);

%plot the mean tuning curve
for aindex=[1:numamps]
    figure
    c='bgrycm';
    p=0;
    subplot1( numbws,numfreqs-1)
    for bwindex=[1:numbws]
        for findex=2:numfreqs
            if bwindex==numbws %inf==wn
                findex=1;
            end
            p=p+1;
            subplot1( p)
            t=1:length(trace1);
            t=t/10;
            stimtrace=squeeze(mM1stim(findex, aindex, bwindex, :));
            stimtrace=stimtrace-mean(stimtrace(1:100));
            stimtrace=stimtrace./max(abs(stimtrace));
            stimtrace=stimtrace*.1*diff(ylimits);
            stimtrace=stimtrace+ylimits(1)+.05*diff(ylimits);
            plot(t, stimtrace, 'm')
            hold on

            vm=squeeze(mM1(findex, aindex, bwindex, :));
            vm=vm-mean(vm(1:100));

            dt=.1; 
           
            [V, spiketimes] = IFvm(vm, dt, thresh2, refract2);
            plot(t, V, 'c', t, vm, 'k');
            spikecounts2(bwindex)=length(spiketimes);
            x=repmat(spiketimes, 2, 1);
            y=repmat(ylimits, length(spiketimes), 1)';
            L=line(x, y);
            set(L, 'color', 'k')
            ylim(ylimits)
            xlim(xlimits);



        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s amp: %ddB', expdate,session, filenum, amps(aindex)))

    %label amps and freqs
    p=0;
    for bwindex=[1:numbws]
        for findex=2:numfreqs
            p=p+1;
            subplot1(p)
            pos=get(gca, 'pos');
            pos(3)=pos(3)/2;
            set(gca, 'pos', pos)
            if findex==2
                T=text(-20, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                set(T, 'HorizontalAlignment', 'right')

                set(gca, 'xtick', xlimits)
            else set(gca, 'xtick', [])

            end
            if bwindex==1
                T=text(-20, ylimits(2), sprintf('BW\nOct'));
                set(T, 'HorizontalAlignment', 'right')
            end
            if bwindex==numbws

                vpos=ylimits(1);
                text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
            else
                set(gca, 'yticklabel', '')
            end
        end
    end
    % set(gcf, 'pos', [ 90+10*aindex         619-10*aindex        1369         420])
end

figure
    t=1:numbws;
    plot(t, spikecounts1, 'ko-', t, spikecounts2, 'ro-')
    xlimits=[.5 numbws+.5];
    xlim(xlimits);
    legend('lca', 'IF')
    set(gca, 'xtick', 1:numbws)
    set(gca, 'xticklabel', bws)
    xlabel('bandwidth, oct')
    ylabel('IF spikecount')


fprintf('\n\n')
