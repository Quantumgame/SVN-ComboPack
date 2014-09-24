function AnalyzePrePostTC(expdate1, session1, filenum1, expdate2, session2, filenum2, varargin)
% compares LFP, WC, or MUA tuning curves from two separate files, e.g.before and after a
% manipulation
% usage: out=AnalyzePrePostTC(expdate1, session1, filenum1, expdate2,
%        session2, filenum2,  [thresh], [xlimits], [ylimits], [binwdidth], [chan])
% (thresh, yaxislim, chan are optional)
%  thresh is in number of standard deviations
% chan defaults to 1; for dual electrode experiments, set to either 1 or 2
% E2 analysis function
% mw 070406
%added spike time outputs mw 100406
%
%saves output structure in an outfile
%last updated 111408
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref

if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==6
    nstd=3;
    ylimits=-1;
    durs=getdurs(expdate1, session1, filenum1);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=50;
    chan=1;
elseif nargin==7
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    ylimits=-1;
    durs=getdurs(expdate1, session1, filenum1);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    binwidth=50;
    chan=1;
elseif nargin==8
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
    chan=1;
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
    binwidth=50;
    chan=1;
elseif nargin==10
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
    chan=1;
elseif nargin==11
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
    chan=varargin{5};

else
    error('\nAnalyzePrePostTC: wrong number of arguments');
end

monitor=0;
do_spikes=1;
lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip
lostat2=-1;
if strcmp(expdate2,'062706') & strcmp(session2,'003') & strcmp(filenum2,'005')
    lostat2=60*10e3*22;
end

tracelength=diff(xlimits); %in ms
if xlimits(1)<0
    baseline=abs(xlimits(1));
else
    baseline=0;
end
psth_baseline=baseline; %in ms, region for counting spikes in response
psth_tracelength=tracelength;%250;%in ms, region for counting spikes in response
    username=pref.username;
    datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat',expdate1,username, session1, filenum1);
    eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat',expdate1, username, session1, filenum1);
    datafile2=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat',expdate2, username, session2, filenum2);
    eventsfile2=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat',expdate2, username, session2, filenum2);
    stimfile1=sprintf('%s-%s-%s-%s-stim.mat', expdate1, username, session1, filenum1);
    stimfile2=sprintf('%s-%s-%s-%s-stim.mat', expdate2, username, session2, filenum2);



fprintf('\nload file 1: ')
fprintf('\ntrying to load %s...', datafile1)
godatadir(pref.username, expdate1, session1, filenum1)
D=load(datafile1);
E=load(eventsfile1);
S=load(stimfile1);
fprintf('done.');

event1=E.event;
trace1=D.trace;
nativeOffset1=D.nativeOffset;
nativeScaling1=D.nativeScaling;
stim1=S.nativeScalingStim*double(S.stim);


fprintf('\nload file 2: ')
fprintf('\ntrying to load %s...', datafile2)
godatadir(pref.username, expdate2, session2, filenum2)
D=load(datafile2);
E=load(eventsfile2);
S=load(stimfile2);
fprintf('done.');

event2=E.event;
trace2=D.trace;
nativeOffset2=D.nativeOffset;
nativeScaling2=D.nativeScaling;
stim2=S.nativeScalingStim*double(S.stim);
clear D E S


fprintf('\ncomputing ...');

samprate=1e4;
scaledtrace1=nativeScaling1*double(trace1)+ nativeOffset1;
scaledtrace2=nativeScaling2*double(trace2)+ nativeOffset2;
if lostat1==-1 lostat1=length(scaledtrace1);end
if lostat2==-1 lostat2=length(scaledtrace2);end
t=1:length(scaledtrace1);
t=1000*t/samprate;

%filter for spike extraction
if ~do_spikes
    dspikes1=zeros(size(scaledtrace1));
    dspikes2=dspikes1;
else
    fprintf('\nfiltering for spike extraction...');
    [b,a]=butter(1, 300/samprate, 'high');
    filteredtrace1=filtfilt(b,a,scaledtrace1);
    filteredtrace2=filtfilt(b,a,scaledtrace2);
    fprintf('\nextracting spikes...');
    thresh1=nstd*std(filteredtrace1);
    thresh2=nstd*std(filteredtrace2);
    fprintf('\nfile1: using spike detection threshold of %.1f mV (%d sd)', thresh1, nstd);
    fprintf('\nfile2: using spike detection threshold of %.1f mV (%d sd)', thresh2, nstd);
    refract=5;
    fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );

    spikes1=find(abs(filteredtrace1)>thresh1);
    spikes2=find(abs(filteredtrace2)>thresh2);
    dspikes1=spikes1(1+find(diff(spikes1)>refract));
    if ~isempty(dspikes1) dspikes1=[spikes1(1) dspikes1'];end
    dspikes2=spikes2(1+find(diff(spikes2)>refract));
    if ~isempty(dspikes2) dspikes2=[spikes2(1) dspikes2'];end

    if monitor
        fprintf('\nplotting...');
        figure
        plot(filteredtrace1, 'b')
        hold on
        plot(filteredtrace2, 'c')
        plot(thresh+zeros(size(filteredtrace1)), 'm--')
        plot(spikes1, thresh*ones(size(spikes1)), 'g*')
        plot(dspikes1, thresh*ones(size(dspikes1)), 'r*')
        plot(spikes2, thresh*ones(size(spikes2)), 'g*')
        plot(dspikes2, thresh*ones(size(dspikes2)), 'r*')
        figure
        ylim([min(filteredtrace1) max(filteredtrace1)]);
        for ds=dspikes1
            xlim([ds-100 ds+100])
            t=1:length(filteredtrace1);
            region=[ds-100:ds+100];
            hold on
            plot(t(region), filteredtrace1(region), 'b')
            plot(spikes1, thresh*ones(size(spikes1)), 'g*')
            plot(dspikes1, thresh*ones(size(dspikes1)), 'r*')
            pause(.1)
            hold off
        end
        for ds=dspikes2
            xlim([ds-100 ds+100])
            t=1:length(filteredtrace2);
            region=[ds-100:ds+100];
            hold on
            plot(t(region), filteredtrace2(region), 'b')
            plot(spikes2, thresh*ones(size(spikes2)), 'g*')
            plot(dspikes2, thresh*ones(size(dspikes2)), 'r*')
            pause(.1)
            hold off
        end
    end
end

%get freqs/amps
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event1(i).Param.frequency;
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.duration;
    elseif strcmp(event1(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.duration;
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

%expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
expectednumrepeats=1; %growing matrix to avoid zero trials when expectations not met
M1=zeros(numfreqs, numamps, numdurs,expectednumrepeats, tracelength*samprate/1000);
M2=M1;
M1stim=M1;
M2stim=M1;

nreps1=zeros(numfreqs, numamps, numdurs);
nreps2=zeros(numfreqs, numamps, numdurs);

%extract the traces into a big matrix M
fprintf('\nextracting traces...');
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'tone') | strcmp(event1(i).Type, 'whitenoise')
        if isfield(event1(i), 'soundcardtriggerPos')
            pos=event1(i).soundcardtriggerPos;
        else
            pos=event1(i).Position_rising;
        end

        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negativestart times)
            if stop>lostat1
                fprintf('\ndiscarding trace')
            else
                if strcmp(event1(i).Type, 'tone')
                    freq=event1(i).Param.frequency;
                elseif strcmp(event1(i).Type, 'whitenoise')
                    freq=-1;
                end
                amp=event1(i).Param.amplitude;
                dur=event1(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps1(findex, aindex,dindex)=nreps1(findex, aindex, dindex)+1;
                M1(findex,aindex,dindex, nreps1(findex,aindex, dindex),:)=scaledtrace1(region);
                if length(stim1)>region(end)
                    M1stim(findex,aindex,dindex, nreps1(findex,aindex, dindex),:)=stim1(region);
                end
            end
        end
    end
end

dindex=1;
%mM1=mean(M1, 4);
%mM=mean(M(:,:,:,21:38,:), 4);

for aindex=1:numamps
    for findex=1:numfreqs
        nr=nreps1(findex, aindex, dindex);
        mM1(findex, aindex, dindex, 1, :)=mean(M1(findex, aindex, dindex, 1:nr, :), 4);
        try
            mM1stim(findex, aindex, dindex, 1, :)=mean(M1stim(findex, aindex, dindex, 1:nr, :), 4);
        catch
            mM1stim(findex, aindex, dindex, 1, :)=mean(M1stim(findex, aindex, dindex, :, :), 4);
        end
    end
end


%extract the traces into a big matrix M
j=0;
for i=1:length(event2)
    if strcmp(event2(i).Type, 'tone') | strcmp(event2(i).Type, 'whitenoise')
        if isfield(event2(i), 'soundcardtriggerPos')
            pos=event2(i).soundcardtriggerPos;
        else
            pos=event2(i).Position_rising;
        end
        
        if isempty(pos)  pos=event2(i).Position_rising;end

        start=(pos-baseline*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negativestart times)
            if stop>lostat2
                fprintf('\ndiscarding trace')
            else
                if strcmp(event2(i).Type, 'tone')
                    freq=event2(i).Param.frequency;
                elseif strcmp(event2(i).Type, 'whitenoise')
                    freq=-1;
                end
                amp=event2(i).Param.amplitude;
                dur=event2(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps2(findex, aindex,dindex)=nreps2(findex, aindex, dindex)+1;
                M2(findex,aindex,dindex, nreps2(findex,aindex, dindex),:)=scaledtrace2(region);
                if length(stim1)>region(end)
                    M2stim(findex,aindex,dindex, nreps2(findex,aindex, dindex),:)=stim2(region);
                end
            end
        end
    end
end

dindex=1;
for aindex=1:numamps
    for findex=1:numfreqs
        nr=nreps2(findex, aindex, dindex);
        mM2(findex, aindex, dindex, 1, :)=mean(M2(findex, aindex, dindex, 1:nr, :), 4);
        try
            mM2stim(findex, aindex, dindex, 1, :)=mean(M2stim(findex, aindex, dindex, 1:nr, :), 4);
        catch
            mM2stim(findex, aindex, dindex, 1, :)=mean(M2stim(findex, aindex, dindex, :, :), 4);
        end
    end
end

%extract the spikecounts into a big matrix MS and the spiketimes into matrix MST
if do_spikes
    fprintf('\nextracting spikecounts...');
    nreps1=zeros(numfreqs, numamps, numdurs);
    nreps2=zeros(numfreqs, numamps, numdurs);
    j=0;
    for i=1:length(event1)
        if strcmp(event1(i).Type, 'tone')| strcmp(event1(i).Type, 'whitenoise')
            pos=event1(i).Position;
            start=(pos-psth_baseline*1e-3*samprate);
            stop=(start+psth_tracelength*1e-3*samprate)-1;
            region=start:stop;
            if isempty(find(region<0)) %(disallow negative start times)
                if stop>lostat1
                    fprintf('\ndiscarding trace')
                else
                if strcmp(event1(i).Type, 'tone')
                    freq=event1(i).Param.frequency;
                elseif strcmp(event1(i).Type, 'whitenoise')
                    freq=-1;
                end

                    amp=event1(i).Param.amplitude;
                    dur=event1(i).Param.duration;
                    findex= find(freqs==freq);
                    aindex= find(amps==amp);
                    dindex= find(durs==dur);
                    nreps1(findex, aindex, dindex)=nreps1(findex, aindex, dindex)+1;
                    spikecount=length(find(dspikes1>start & dspikes1<stop)); %num spikes in region
                    spikerate=1000*spikecount/tracelength; %in Hz
                    MS1(findex,aindex,dindex, nreps1(findex, aindex, dindex))=spikecount;
                    spiketimeindexes=find(dspikes1>start & dspikes1<stop);
                    spiketimes=dspikes1(spiketimeindexes)-start; %in samples
                    spiketimes=spiketimes*1000/samprate; %in ms after start
                    MST1(findex,aindex,dindex, nreps1(findex, aindex, dindex)).spiketimes=spiketimes;
                    % fprintf('\nevent %d', i);
                end
            end
        end
    end
    %extract the spikes into a big matrix MS
    j=0;
    for i=1:length(event2)
        if strcmp(event2(i).Type, 'tone')| strcmp(event2(i).Type, 'whitenoise')
            pos=event2(i).Position;
            start=(pos-psth_baseline*1e-3*samprate);
            stop=(start+psth_tracelength*1e-3*samprate)-1;
            region=start:stop;
            if isempty(find(region<0)) %(disallow negative start times)
                if stop>lostat2
                    fprintf('\ndiscarding trace')
                else
                if strcmp(event2(i).Type, 'tone')
                    freq=event2(i).Param.frequency;
                elseif strcmp(event2(i).Type, 'whitenoise')
                    freq=-1;
                end

                    amp=event2(i).Param.amplitude;
                    dur=event2(i).Param.duration;
                    findex= find(freqs==freq);
                    aindex= find(amps==amp);
                    dindex= find(durs==dur);
                    nreps2(findex, aindex, dindex)=nreps2(findex, aindex, dindex)+1;
                    spikecount=length(find(dspikes2>start & dspikes2<stop)); %num spikes in region
                    spikerate=1000*spikecount/tracelength; %in Hz
                    MS2(findex,aindex,dindex, nreps2(findex, aindex, dindex))=spikecount;
                    spiketimeindexes=find(dspikes2>start & dspikes2<stop);
                    spiketimes=dspikes2(spiketimeindexes)-start; %in samples
                    spiketimes=spiketimes*1000/samprate; %in ms after start
                    MST2(findex,aindex,dindex, nreps2(findex, aindex, dindex)).spiketimes=spiketimes;

                end
            end
        end
    end
    dindex=1;
    traces_to_keep1=[];
    if ~isempty(traces_to_keep1)
        fprintf('\n using only traces %d, discarding others', traces_to_keep1);
        mMS1=mean(MS1(:,:,:,traces_to_keep1,:), 4);
    else
        mMS1=mean(MS1, 4);
    end
    dindex=1;
    traces_to_keep2=[];
    if ~isempty(traces_to_keep2)
        fprintf('\n using only traces %d, discarding others', traces_to_keep2);
        mMS2=mean(MS2(:,:,:,traces_to_keep2,:), 4);
    else
        mMS2=mean(MS2, 4);
    end

    % consolidate spiketime matrices into mMST
    for findex=1:length(freqs)
        for aindex=1:length(amps)

            st=[];
            for rep=1:nreps1(findex, aindex, dindex)
                st= [st MST1(findex, aindex, dindex, rep).spiketimes];
            end
            mMST1(findex, aindex).spiketimes=st;
        end
    end
    for findex=1:length(freqs)
        for aindex=1:length(amps)
            st=[];
            for rep=1:nreps2(findex, aindex, dindex)
                st= [st MST2(findex, aindex, dindex, rep).spiketimes];
            end
            mMST2(findex, aindex).spiketimes=st;
        end
    end
else %if do_spikes
    fprintf('\nskipping spike extraction.');
    MS1=[];
    MS2=[];
    MST1=[];
    MST2=[];
    mMST1=[];
    mMST2=[];
    mMS1=ones(length(freqs), length(amps));
    mMS2=ones(length(freqs), length(amps));
end %if do_spikes

%find optimal yaxis limits
if ylimits==-1
    ylimits(1)=min(min(min(min(min(mM1)))));
    ylimits(2)=max(max(max(max(max(mM1)))));
end

%assuming for now that freqs and amps are identical for file1 and file2 !!!!!!!!!!!!!!!

%plot the mean tuning curves for pre and post (red not inverted)
figure
offset=0; %shift traces down to make room for psth
%spike_scale_factor=2000/max(max(max([mMS1 mMS2]))); %scale spike counts to max=20 mV for co-plotting
spike_scale_factor=1/max(max(max([mMS1 mMS2]))); %scale spike counts to max=20 mV for co-plotting
p=0;
subplot1( numamps,numfreqs)
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        p=p+1;
        subplot1( p)
        trace1=squeeze(mM1(findex, aindex, dindex,:));
        trace1=trace1-mean(trace1(1:100));
        trace2=squeeze(mM2(findex, aindex, dindex,:));
        trace2=trace2-mean(trace2(1:100));
        t=1:length(trace1);
        t=t/10;
        plot(t, trace1-offset, 'b', t, trace2-offset, 'r');
        ylimits2=ylimits;ylimits2(2)=ylimits(2); %add 20 mV room for spikes
        ylim(ylimits2)
        axis off
        spikecount1=mMS1(findex, aindex);
        spikecount2=mMS2(findex, aindex);
        hold on
        L0=line([0 durs(1)], [ylimits(2) ylimits(2)]);
        L1=line([100 100],[ylimits(2) ylimits(2)+spike_scale_factor*spikecount1]);
        L2=line([200 200],[ylimits(2) ylimits(2)+spike_scale_factor*spikecount2]);
        set(L0, 'linewidth', .5, 'color', 'k')
        set(L1, 'linewidth', 5, 'color', 'b')
        set(L2, 'linewidth', 5, 'color', 'r')
        xlim(xlimits)
    end
end
subplot1(ceil(numfreqs/3))
title(sprintf('%s-%s-%s, %s-%s-%s, pre=b, post=r',expdate1,session1, filenum1,expdate2,session2,filenum2))

%label amps and freqs
p=0;
for aindex=[1:numamps]
    for findex=1:numfreqs
        p=p+1;
        subplot1(p)
        if findex==1
            text(-400, mean(ylimits),int2str(amps(aindex)))
        end
        if aindex==numamps
            if mod(findex,2) %odd freq
                vpos=ylimits(1);
            else
                vpos=ylimits(1)-mean(ylimits);
            end
            text(0, vpos, sprintf('%.1f',freqs(findex)/1000))
        end
    end
end

%label max spikecount
LL=line([300 300],[ylimits(2) ylimits(2)+spike_scale_factor*max(max(max([mMS1 mMS2]))) ]);
set(LL, 'linewidth', 1, 'color', 'k')
text(350, ylimits(2), sprintf('%.2fsp', max(max(max([mMS1 mMS2])))))


%assign outputs
out.M1=M1; %traces, i.e. lfp, trial by trial
out.M2=M2;
out.MS1=MS1; %spikecounts, trial by trial
out.MS2=MS2;
out.MST1=MST1; %spiketimes, trial by trial
out.MST2=MST2;
out.mMST1=mMST1; %spiketimes collapsed across trials
out.mMST2=mMST2;
out.mM1=mM1; %traces averaged across trials
out.mM2=mM2;
out.mMS1=mMS1;  %spikecounts averaged across trials
out.mMS2=mMS2;
out.expdate1=expdate1;
out.session1=session1;
out.filenum1=filenum1;
out.expdate2=expdate2;
out.session2=session2;
out.filenum2=filenum2;
out.freqs=freqs;
out.amps=amps;
out.samprate=samprate;
out.nreps1=nreps1;
out.nreps2=nreps2;
out.M1stim=M1stim;
out.mM1stim=mM1stim;
out.M2stim=M2stim;
out.mM2stim=mM2stim;
out.baseline=baseline;
out.nstd=nstd;
out.do_spikes=do_spikes;

outfile=sprintf('out%s-%s-%s-%s-%s-%s', expdate1, session1, filenum1, expdate2, session2, filenum2);
save(outfile, 'out')
return

%plot the subtraction of mean tuning curves for pre and post
figure
p=0;
subplot1( numamps,numfreqs)
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        p=p+1;
        subplot1( p)
        trace1=squeeze(mM1(findex, aindex, dindex, :));
        trace1=trace1-mean(trace1(1:100));
        trace2=squeeze(mM2(findex, aindex, dindex,:));
        trace2=trace2-mean(trace2(1:100));
        t=1:length(trace1);
        t=t/10;
        plot(t, trace1-trace2);
        ylim(ylimits)
        axis off

    end
end
axis on

subplot1(round(numfreqs/3))
title(sprintf('%s-%s-%s, %s-%s-%s pre-post',expdate1,session1, filenum1,expdate2,session2,filenum2))
%label amps and freqs
p=0;
for aindex=[1:numamps]
    for findex=1:numfreqs
        p=p+1;
        subplot1(p)
        if findex==1
            text(-400, mean(ylimits),int2str(amps(aindex)))
        end
        if aindex==numamps
            if mod(findex,2) %odd freq
                vpos=ylimits(1);
            else
                vpos=ylimits(1)-mean(ylimits);
            end
            text(0, vpos, sprintf('%.1f',freqs(findex)/1000))
        end
    end
end
%keyboard