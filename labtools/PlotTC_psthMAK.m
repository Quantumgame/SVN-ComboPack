function PlotTC_psth(expdate1, session1, filenum1, varargin)
% extracts spikes and plots a single psth tuning curve
% usage: PlotTC_psth(expdate, session, filenum, thresh, xlimits, ylimits)
% (thresh, xlimits, and ylimits are optional)
%  thresh is in number of standard deviations
% E2 analysis function
% mw 070406
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tracelength=2000; %in ms
baseline=200; %in ms

if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    nstd=7;
    ylimits=-1;
    xlimits=[0 tracelength];
elseif nargin==4
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    ylimits=-1;
    xlimits=[0 tracelength];
elseif nargin==5
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits) xlimits=[0 tracelength];end
    ylimits=-1;
elseif nargin==6
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits) xlimits=[0 tracelength];end
    ylimits=varargin{3};
end

loadit=1;
monitor=0;
lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

global pref
if isempty(pref) Prefs; end
username=pref.username;
datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate1, username, session1, filenum1);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate1, username, session1, filenum1);
fs=6;

if loadit
    fprintf('\nload file 1: ')
    try
        fprintf('\ntrying to load %s...', datafile1)
        godatadir(username, expdate1,  session1, filenum1);
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
fprintf('\nresponse window: %d before to %d ms after tone onset',baseline, tracelength);

high_pass_cutoff=10; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace1=filtfilt(b,a,scaledtrace1);
thresh=nstd*std(filteredtrace1);
fprintf('\nusing spike detection threshold of %.1f mV (%d sd)', thresh, nstd);
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

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
%M1=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1=[];
nreps1=zeros(numfreqs, numamps, numdurs);


%extract the traces into a big matrix M
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'tone') | strcmp(event1(i).Type, 'tonetrain') | strcmp(event1(i).Type, 'whitenoise') | strcmp(event1(i).Type, 'clicktrain')
        if isfield(event1(i), 'soundcardtriggerPos')
            pos=event1(i).soundcardtriggerPos;
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
                elseif strcmp(event1(i).Type, 'whitenoise')
                    dur=event1(i).Param.duration;
                    freq=-1;
                elseif strcmp(event1(i).Type, 'clicktrain')
                    dur=event1(i).Param.clickduration;
                    freq=-1;
                end
                amp=event1(i).Param.amplitude;
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

numbins=200;

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
            subplot1( p)
            spiketimes1=mM1(findex, aindex, dindex).spiketimes;
            %         %use this code to plot curves
            %         [n, x]=hist(spiketimes1, numbins);
            %         r=plot(x, n);
            %         set(r, 'linewidth', 2)
            %use this code to plot histograms
            hist(spiketimes1, numbins);
            line([0 0+durs(dindex)], [-1 -1], 'color', 'm', 'linewidth', 2)
            line(xlimits, [0 0], 'color', 'k')
            ylim(ylimits)
            %xlim([0-baseline tracelength])

            xlim(xlimits)
            %xlim([-10 500])
            %axis off
            %set(gca, 'xtick', [0:20:tracelength])
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
    title(sprintf('%s-%s-%s ch 1, dur=%d, nstd=%d, %d bins, %d total spikes',expdate1,session1, filenum1, durs(dindex), nstd,numbins,length(dspikes)))

end %for dindex


%check if the on response is the same size as the off response
% A=ON response (0:win)
% B=OFF response (dur-:dur+win)
% if(1)
%     fprintf('\n\ntest whether OFF=ON (p->0 means different, p->1 means same)\n\n')
%     win=50;
%     p=0;
%     for dindex=[1:numdurs]
%         for aindex=[1:numamps]
%             for findex=1:numfreqs
%                 start=0;
%                 stop=start+win;
%                 for rep=1:nreps1(findex,aindex,dindex)
%                     A1=find(M1(findex,aindex,dindex, rep).spiketimes>start);
%                     A2=find(M1(findex,aindex,dindex, rep).spiketimes<stop);
%                     A(rep)=length(intersect(A1, A2));
%                 end
% 
%                 start=durs(dindex);
%                 stop=start+win;
%                 for rep=1:nreps1(findex,aindex,dindex)
%                     B1=find(M1(findex,aindex,dindex, rep).spiketimes>start);
%                     B2=find(M1(findex,aindex,dindex, rep).spiketimes<stop);
%                     B(rep)=length(intersect(B1, B2));
%                 end
%                 [h, p]=ttest2(A, B, .001);
%                 sd={'same', 'different'};
%                 fprintf('\n%.2f kHz: p=%.4f (%s) ', freqs(findex)/1000, p, sd{h+1})
%             end
%         end
%     end
% end
% 
% fprintf('\n\n')

