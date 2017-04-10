function PlotTC_spikes_PrePost(expdate1, session1, filenum1, expdate2, session2, filenum2, varargin)
% extracts spikes and plots two single-channel psth tuning curves (a pre and a post) 
% usage: PlotTC_psth_PrePost(expdate1, session1, filenum1, expdate2, session2, filenum2, [thresh], [xlimits], [ylimits], [chan])
% [thresh], [xlimits], [ylimits], [chan] are optional)
%
% chan defaults to 1; for dual electrode experiments, set to either 1 or 2
% mw 042309
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref
if isempty(pref) Prefs; end
username=pref.username;

if nargin==0 
    fprintf('\nno input');
    return;
elseif nargin==6
    nstd=3;
    durs=getdurs(expdate1, session1, filenum1);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    ylimits=-1;
    chan=1;
elseif nargin==7 
    nstd=varargin{1};
    if isempty(nstd) nstd=3;end
    durs=getdurs(expdate1, session1, filenum1);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    ylimits=-1;
    chan=1;
elseif nargin==8
    nstd=varargin{1};
    if isempty(nstd) nstd=3;end
    xlimits=varargin{2};
    if isempty(xlimits) 
        durs=getdurs(expdate1, session1, filenum1);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    ylimits=-1;
    chan=1;
elseif nargin==9
    nstd=varargin{1};
    if isempty(nstd) nstd=3;end
    xlimits=varargin{2};
    if isempty(xlimits) 
        durs=getdurs(expdate1, session1, filenum1);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    ylimits=varargin{3};
    if isempty(ylimits) ylimits=-1;end
    chan=1;
elseif nargin==10
    nstd=varargin{1};
    if isempty(nstd) nstd=3;end
    xlimits=varargin{2};
    if isempty(xlimits) 
        durs=getdurs(expdate1, session1, filenum1);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
    ylimits=varargin{3};
    if isempty(ylimits) ylimits=-1;end
    chan=varargin{4};
    if isempty(chan) chan=1;end
end
monitor=0;
lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip
lostat2=-1; %discard data after this position (in samples), -1 to skip
not_got_till1=-1;%discard data before this position (in samples), -1 to skip
not_got_till2=-1;%discard data before this position (in samples), -1 to skip

datafile1=sprintf('%s-%s-%s-%s-AxopatchData%d-trace.mat', expdate1, username, session1, filenum1, chan);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData%d-events.mat', expdate1, username, session1, filenum1, chan);
datafile2=sprintf('%s-%s-%s-%s-AxopatchData%d-trace.mat', expdate2, username, session2, filenum2, chan);
eventsfile2=sprintf('%s-%s-%s-%s-AxopatchData%d-events.mat', expdate2, username, session2, filenum2, chan);

fs=9;


fprintf('\nload file 1: ')
fprintf('\ntrying to load %s...', datafile1)
godatadir(expdate1, session1, filenum2)
L=load(datafile1);
E=load(eventsfile1);
fprintf('done.');
event1=E.event;
trace1=L.trace;
nativeOffset1=L.nativeOffset;
nativeScaling1=L.nativeScaling;
clear E L

fprintf('\nload file 2: ')
fprintf('\ntrying to load %s...', datafile2)
godatadir(expdate2, session2, filenum2)
L=load(datafile2);
E=load(eventsfile2);
fprintf('done.');
event2=E.event;
trace2=L.trace;
nativeOffset2=L.nativeOffset;
nativeScaling2=L.nativeScaling;
clear E L


fprintf('\ncomputing tuning curve...');

samprate=1e4;
scaledtrace1=nativeScaling1*double(trace1)+ nativeOffset1;
if lostat1==-1 lostat1=length(scaledtrace1);end
scaledtrace2=nativeScaling1*double(trace2)+ nativeOffset2;
if lostat2==-1 lostat2=length(scaledtrace2);end
tracelength=diff(xlimits); %in ms
if xlimits(1)<0
    baseline=abs(xlimits(1));
else
    baseline=0;
end
fprintf('\nresponse window: %d to %d ms after tone onset',xlimits(1), xlimits(2));

high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace1=filtfilt(b,a,scaledtrace1);
filteredtrace2=filtfilt(b,a,scaledtrace2);

    thresh1=nstd*std(filteredtrace1);
    thresh2=nstd*std(filteredtrace2);
    fprintf('\nfile1: using spike detection threshold of %.1f mV (%d sd)', thresh1, nstd);
    fprintf('\nfile2: using spike detection threshold of %.1f mV (%d sd)', thresh2, nstd);

refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );

spikes1=find(abs(filteredtrace1)>thresh1);
dspikes1=spikes1(1+find(diff(spikes1)>refract));
dspikes1=[spikes1(1) dspikes1'];
if monitor
figure
plot(filteredtrace1, 'b')
hold on
plot(thresh1+zeros(size(filteredtrace1)), 'm--')
plot(spikes1, thresh1*ones(size(spikes1)), 'g*')
plot(dspikes1, thresh1*ones(size(dspikes1)), 'r*')
L1=line(xlim, thresh1*[1 1]);
L2=line(xlim, thresh1*[-1 -1]);
set([L1 L2], 'color', 'g');
end


spikes2=find(abs(filteredtrace2)>thresh2);
dspikes2=spikes2(1+find(diff(spikes2)>refract));
dspikes2=[spikes2(1) dspikes2'];
if monitor
figure
plot(filteredtrace2, 'b')
hold on
plot(thresh2+zeros(size(filteredtrace2)), 'm--')
plot(spikes2, thresh2*ones(size(spikes2)), 'g*')
plot(dspikes2, thresh2*ones(size(dspikes2)), 'r*')
L1=line(xlim, thresh2*[1 1]);
L2=line(xlim, thresh2*[-1 -1]);
set([L1 L2], 'color', 'g');
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
        plot(spikes1, thresh1*ones(size(spikes1)), 'g*')
        plot(dspikes1, thresh1*ones(size(dspikes1)), 'r*')
        line(xlim, thresh1*[1 1])
        line(xlim, thresh1*[-1 -1])
        pause(.1)
        hold off
    end
    ylim([min(filteredtrace2) max(filteredtrace2)]);
    for ds=dspikes(1:20)
        xlim([ds-100 ds+100])
        t=1:length(filteredtrace2);
        region=[ds-100:ds+100];
        if min(region)<1
            region=[1:ds+100];
        end
        hold on
        plot(t(region), filteredtrace2(region), 'b')
        plot(spikes2, thresh2*ones(size(spikes2)), 'g*')
        plot(dspikes2, thresh2*ones(size(dspikes2)), 'r*')
        line(xlim, thresh2*[1 1])
        line(xlim, thresh2*[-1 -1])
        pause(.1)
        hold off
    end
end

%get freqs/amps !!! assuming freqs/amps same for both file 1 and 2
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
M2=[];
nreps2=zeros(numfreqs, numamps, numdurs);


%extract the traces into a big matrix M1
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
            if start<not_got_till1 | stop>lostat1
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
                         spikecount=length(find(dspikes1>start & dspikes1<stop)); %num spikes in region
                spikerate=1000*spikecount/tracelength; %in Hz
                M1(findex,aindex,dindex, nreps1(findex, aindex, dindex))=spikecount;

            end
        end
    end
end
fprintf('\nfile1: min num reps: %d\nmax num reps: %d', min(min(min(nreps1))), max(max(max(nreps1))))
fprintf('\nfile1: total num spikes: %d', length(dspikes1))

%extract the traces into a big matrix M2
j=0;
for i=1:length(event2)
    if strcmp(event2(i).Type, 'tone') | strcmp(event2(i).Type, 'tonetrain') | strcmp(event2(i).Type, 'whitenoise') | strcmp(event2(i).Type, 'clicktrain')
        pos=event2(i).Position;
        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if start<not_got_till2 | stop>lostat2
                fprintf('\ndiscarding trace')
            else
                if strcmp(event2(i).Type, 'tone') 
                    freq=event2(i).Param.frequency;
                    dur=event2(i).Param.duration;
                elseif  strcmp(event2(i).Type, 'tonetrain')
                    freq=event2(i).Param.frequency;
                    dur=event2(i).Param.toneduration;
                elseif strcmp(event2(i).Type, 'whitenoise') 
                    dur=event2(i).Param.duration;
                    freq=-1;
                elseif strcmp(event2(i).Type, 'clicktrain')
                    dur=event2(i).Param.clickduration;
                    freq=-1;
                end
                amp=event2(i).Param.amplitude;
%                 dur=event2(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps2(findex, aindex, dindex)=nreps2(findex, aindex, dindex)+1;
                    spikecount=length(find(dspikes2>start & dspikes2<stop)); %num spikes in region
                spikerate=1000*spikecount/tracelength; %in Hz
                M2(findex,aindex,dindex, nreps2(findex, aindex, dindex))=spikecount;

            end
        end
    end
end
fprintf('\nfile2: min num reps: %d\nmax num reps: %d', min(min(min(nreps2))), max(max(max(nreps2))))
fprintf('\nfile2: total num spikes: %d', length(dspikes2))

%accumulate across trials
dindex=1;
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        mM1(findex, aindex)=mean(M1(findex, aindex, dindex,1:nreps1(findex, aindex, dindex)), 4);
    end
end
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        mM2(findex, aindex)=mean(M2(findex, aindex, dindex,1:nreps2(findex, aindex, dindex)), 4);
    end
end


% %find axis limits
% if ylimits==-1
%     ylimits=0;
%     for aindex=[numamps:-1:1]
%         for findex=1:numfreqs
%             spiketimes1=mM1(findex, aindex, dindex).spiketimes;
%             spiketimes2=mM2(findex, aindex, dindex).spiketimes;
%             X=-baseline:binwidth:tracelength; %specify bin centers
%             [n1, x1]=hist(spiketimes1, X);
%             [n2, x2]=hist(spiketimes2, X);
%             ylimits=max(ylimits, max([n1 n2]));
%         end
%     end
% end
% 
% 
% %plot file1
% figure
% p=0;
% subplot1( numamps,numfreqs)
% for aindex=[numamps:-1:1]
%     for findex=1:numfreqs
%         p=p+1;
%         subplot1( p)
%         spiketimes1=mM1(findex, aindex, dindex).spiketimes;
%         spiketimes2=mM2(findex, aindex, dindex).spiketimes;
%         %         %use this code to plot curves
%         X=-baseline:binwidth:tracelength; %specify bin centers
%         [n1, x1]=hist(spiketimes1, X);
%         [n2, x2]=hist(spiketimes2, X);
%          r=plot(x1, n1, 'b', x2, n2, 'r');
%          set(r, 'linewidth', 1)
%         %use this code to plot histograms
% %        hist(spiketimes1, numbins);
%         
%         ylim([0 ylimits])
%         xlim([0-baseline tracelength])
%         %xlim([200 400])
%         %xlim([400 600])
% %     axis off
% %set(gca, 'xtick', [0:20:tracelength])
% %grid on
%     set(gca, 'fontsize', fs)
% 
%     end
% end
% 
% 
% %label amps and freqs
% p=0;
% for aindex=[numamps:-1:1]
%     for findex=1:numfreqs
%         p=p+1;
%         subplot1(p)
%         if findex==1
%             text(-2*tracelength, ylimits/2, int2str(amps(aindex)))
%         else
%             set(gca, 'xtick', [])
%         end
%         if aindex==1
% %             if mod(findex,2) %odd freq
% %                 vpos=ylimits(1);
% %  %           else
%                 vpos=-ylimits/2;
% %            end
%             text(0, vpos, sprintf('%.1f', freqs(findex)/1000))
%         end
%     end
% end
% subplot1(round(numfreqs/3))
% title(sprintf('%s-%s-%s, %s-%s-%s, ch%d, nstd=%d, %dms bins, %d,%d total spikes',expdate1,session1, filenum1,expdate2,session2, filenum2, chan, nstd,binwidth,length(dspikes1), length(dspikes2)))
% 
% 
% 
% fprintf('\n\n')
% 

figure
i=imagesc(mM1');
set(gca, 'ydir', 'normal')
%set(gca, 'xtick', 1:length(freqs))
xtick=1:3:length(freqs);
set(gca, 'xtick', xtick)
set(gca, 'xticklabel',  round(freqs(xtick)/100)/10)
set(gca, 'ytick', 1:length(amps))
set(gca, 'yticklabel', round(amps))

xlabel('frequency')
ylabel('amplitude')
c=colorbar;
clab=get(c, 'ylabel');
set(clab, 'string','spike count')
title(sprintf('%s-%s-%s',expdate1,session1, filenum1))

figure
i=imagesc(mM2');
set(gca, 'ydir', 'normal')
%set(gca, 'xtick', 1:length(freqs))
xtick=1:3:length(freqs);
set(gca, 'xtick', xtick)
set(gca, 'xticklabel',  round(freqs(xtick)/100)/10)
set(gca, 'ytick', 1:length(amps))
set(gca, 'yticklabel', round(amps))

xlabel('frequency')
ylabel('amplitude')
c=colorbar;
clab=get(c, 'ylabel');
set(clab, 'string','spike count')
title(sprintf('%s-%s-%s',expdate2,session2, filenum2))

figure
dM=mM2-mM1;
i=imagesc(dM');
set(gca, 'ydir', 'normal')
%set(gca, 'xtick', 1:length(freqs))
xtick=1:3:length(freqs);
set(gca, 'xtick', xtick)
set(gca, 'xticklabel',  round(freqs(xtick)/100)/10)
set(gca, 'ytick', 1:length(amps))
set(gca, 'yticklabel', round(amps))
clim=max(abs(caxis));
caxis([-clim clim])

xlabel('frequency')
ylabel('amplitude')
c=colorbar;
clab=get(c, 'ylabel');
set(clab, 'string','subtracted spike count')
title(sprintf('subtraction: %s-%s-%s - %s-%s-%s',expdate1,session1, filenum1, expdate2,session2, filenum2))

