function PlotTC_spikelatency(varargin)
% extracts spikes and plots a tuning curve based on first spike latency
% usage: PlotTC_spikelatency(expdate, session, filenum)
% PlotTC_spikelatency(expdate, session, filenum, thresh)
% PlotTC_spikelatency(expdate, session, filenum, thresh, xlimits)
% thresh is in number of std (default: 3) 
%  to use an absolute threshold (in mV) pass [-1 mV] as the thresh
%  argument, where mV is the desired threshold
% default xlimits are -.5:1.5*dur
% mw 070406
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tracelength=-1;
if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=3;
    durs=getdurs(expdate, session, filenum);
    dur=max(durs);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis

elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    durs=getdurs(expdate, session, filenum);
    dur=max(durs);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis

elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    xlimits=varargin{5};

else
    error('wrong number of arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

monitor=0;
lostat=getlostat(expdate, session, filenum);
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
fontsize=12;

 use_soundcard_triggers=1; %this flag is normally set to 1. Set it to 0 if
% you want to use hardware trigger (Position_rising), which is less
% accurate, but a useful backup in case there is a glitch in a soundcard
% trigger. You can check for a glitch with this code snippet: for i=1:length(event);sc(i)=event(i).soundcardtriggerPos;pr(i)=event(i).Position_rising;end;figure;plot(sc-pr)
if ~use_soundcard_triggers 
    fprintf('\n\nWarning: using hardware triggers instead of soundcard triggers... this is less accurate! \n')
end

try
    fprintf('\ntrying to load %s...', datafile)
    godatadir(expdate, session, filenum)
    D=load(datafile);
    E=load(eventsfile);
    S=load(stimfile);
    fprintf('done.');
catch
 fprintf('\nCould not find data in %s', pwd)
    try
        godatadirbak(expdate, session, filenum)
        D=load(datafile);
        E=load(eventsfile);
        S=load(stimfile);
        fprintf('\nfound and loaded data.');
    catch
        error('\nfailed. Could not find data')
        return
    end
end

event=E.event;
stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
clear D E S

fprintf('\ncomputing tuning curve...');

samprate=1e4;

if isempty(lostat) lostat=length(scaledtrace);end
t=1:length(scaledtrace);
t=1000*t/samprate;
tracelength=diff(xlimits); %in ms
fprintf('\nresponse window: %.1f to %.1f ms relative to tone onset',xlimits);

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
figure
plot(filteredtrace, 'b')
hold on
plot(thresh+zeros(size(filteredtrace)), 'm--')
plot(spikes, thresh*ones(size(spikes)), 'g*')
dspikes=spikes(1+find(diff(spikes)>refract));
dspikes=[spikes(1) dspikes'];
plot(dspikes, thresh*ones(size(dspikes)), 'r*')
line(xlim, thresh*[1 1])
line(xlim, thresh*[-1 -1])
if monitor
    figure
    ylim([min(filteredtrace) max(filteredtrace)]);
    for ds=dspikes(1:20)
        xlim([ds-100 ds+100])
        t=1:length(filteredtrace);
        region=[ds-100:ds+100];
        hold on
        plot(t(region), filteredtrace(region), 'b')
        plot(spikes, thresh*ones(size(spikes)), 'g*')
        plot(dspikes, thresh*ones(size(dspikes)), 'r*')
        line(xlim, thresh*[1 1])
        line(xlim, thresh*[-1 -1])
        pause(.1)
        hold off
    end
end

%this is a hack to clean out double-tone events from old (pre-PPASound)
%data files
for i=1:length(event)
    if length(event(i).Param)==2
         event(i).Type=event(i).Type{1};
         event(i).Param=event(i).Param{1};
    end
end

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    elseif strcmp(event(i).Type, 'whitenoise')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event(i).Param.amplitude;
        alldurs(j)=event(i).Param.duration;
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

freqs1=freqs;

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
%M1=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1_sl=[];
nreps=zeros(numfreqs, numamps, numdurs);


%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') || strcmp(event(i).Type, 'whitenoise')
        
        if isfield(event(i), 'soundcardtriggerPos') & use_soundcard_triggers
            pos=event(i).soundcardtriggerPos;
            if isempty(pos) &~isempty(event(i).Position_rising)
                pos=event(i).Position_rising;
            end
        else
            pos=event(i).Position_rising;
        end

        start=(pos-xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        start2=(pos-0*1e-3*samprate);
        stop2=(pos+80*1e-3*samprate)-1;
        region=start:stop;
         region2=start2:stop2;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat
                fprintf('\ndiscarding trace')
            else
                if strcmp(event(i).Type, 'tone')
                freq=event(i).Param.frequency;
                elseif strcmp(event(i).Type, 'whitenoise')
                    freq=-1;
                end
                amp=event(i).Param.amplitude;
                dur=event(i).Param.duration;
                
                
                
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                
                
                spikes=dspikes(find(dspikes>start & dspikes<stop)); % L
                spiketimes2=dspikes(dspikes>start2 & dspikes<stop2); % psth
                
                % L
                spikes=spikes-start;
                spikes=spikes/(1e-3*samprate);
                if isempty(spikes) spikes=nan; end
                % We'll want to improve this. Won't work well w/a high
                % spont. FR.
                firstspikelatency=spikes(1);
                M1_sl(findex,aindex,dindex, nreps(findex, aindex, dindex))=firstspikelatency;
                
                % psth
                spiketimes2=(spiketimes2-pos)*1000/samprate;%covert to ms after tone onset
                M1(findex,aindex,dindex, nreps(findex, aindex,dindex)).spiketimes=spiketimes2;
                
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))              
fprintf('\ntotal num spikes: %d', length(dspikes))

% psth ------------------------
for dindex=[1:numdurs]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            spiketimes2=[];
            for rep=1:nreps(findex, aindex, dindex)
                spiketimes2=[spiketimes2 M1(findex, aindex, dindex, rep).spiketimes];
            end
            mM1(findex, aindex, dindex).spiketimes=spiketimes2;
        end
    end
end
%find axis limits

    ylimits2=[-.3 0];
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            spiketimes=mM1(findex, aindex, dindex).spiketimes;
            X=0:2:80; %specify bin centers
            [N, x]=hist(spiketimes, X);
            N=N./nreps(findex, aindex, dindex); %normalize to spike rate (averaged across trials)
            N=1000*N./2; %normalize to spike rate in Hz
        end
    end
    
    ResponseLatencyII=[];
    
    for findex=1:numfreqs
        for aindex=[numamps:-1:1] % For each amplitude...
            
            % 2ms bins, 0-80ms from onset.
            % Value first exceeds 20% of max.
            
            dindex=1; 
            spiketimes1=mM1(findex, aindex, dindex).spiketimes;
            X=0:2:80; 
            [N, x]=hist(spiketimes1, X);
            N=N./nreps(findex, aindex, dindex); 
            N=1000*N./2; 
            
            timeFromOnset=x(:); 
            spikeRate=N(:);
            twentyOMax=max(spikeRate)*.2;
            LatencyII=min(find(spikeRate>twentyOMax));
            if isempty(LatencyII)
                ResponseLatencyII=[ResponseLatencyII nan];
            else
            ResponseLatencyII=[ResponseLatencyII LatencyII];
            end
        end 
    end

    

out.ResponseLatencyII=ResponseLatencyII;
    %---------------------------------------------





dindex=1;
traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1_sl=nanmean(M1_sl(:,:,:,traces_to_keep,:), 4);
    sM1_sl=std(M1_sl(:,:,:,traces_to_keep,:), [],4);
else
    mM1_sl=nanmean(M1_sl, 4);
    sM1_sl=nanstd(M1_sl, [],4);
end

%mM=mean(M(:,:,:,21:38,:), 4);

% figure
% hold on
% 
% c='rgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmyk';
% for findex=1:numfreqs
%     plot(amps, squeeze(mM1(findex, :, dindex, 1)), c(findex))
% end
% title('rate level functions for each frequency')
% ylabel('spikecount')
% xlabel('amplitude, dB')

figure
set(gca, 'fontsize', fontsize)
i=imagesc(mM1_sl');
map=colormap;
map=flipud(map);
map(1,:)=[1 1 1];
colormap(map)
set(gca, 'ydir', 'normal')
% xtick=1:length(freqs);
xtick=1:3:length(freqs);
set(gca, 'xtick', xtick)
set(gca, 'xticklabel',  round(freqs(xtick)/100)/10)
set(gca, 'ytick', 1:length(amps))
set(gca, 'yticklabel', round(amps))

xlabel('frequency')
ylabel('amplitude')
c=colorbar;
clab=get(c, 'ylabel');
set(clab, 'string','spike latency')
title(sprintf('%s-%s-%s',expdate,session, filenum), 'fontsize', fontsize)

%saveas(gcf, sprintf('TC%s-%s-%s.fig',expdate,session, filenum));
%fprintf('\n\n')

godatadir(expdate,session, filenum);
outfilename=sprintf('out%s-%s-%s-lat',expdate,session, filenum);
out.M1_sl=M1_sl;
out.mM1_sl=mM1_sl;
out.sM1_sl=sM1_sl;
out.xlimits=xlimits;
out.numfreqs=numfreqs;
out.numamps=numamps;
out.nreps=nreps;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.freqs=freqs;
out.amps=amps;
out.durs=durs;

save (outfilename, 'out')
fprintf('\n saved to %s', outfilename)
