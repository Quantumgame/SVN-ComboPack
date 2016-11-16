function PlotTC_spikes(varargin)
% extracts spikes and plots a single psth tuning curve
% usage: PlotTC_spikes(expdate, session, filenum)
% PlotTC_spikes(expdate, session, filenum, thresh)
% PlotTC_spikes(expdate, session, filenum, thresh, xlimits)
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
lostat=[];%getlostat(expdate, session, filenum);
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
        fprintf('\nfailed. Could not find data')
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
M1=[];
nreps=zeros(numfreqs, numamps, numdurs);


%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        
        if isfield(event(i), 'soundcardtriggerPos') & use_soundcard_triggers
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
                freq=event(i).Param.frequency;
                amp=event(i).Param.amplitude;
                dur=event(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                spikecount=length(find(dspikes>start & dspikes<stop)); %num spikes in region
                spikerate=1000*spikecount/tracelength; %in Hz
                M1(findex,aindex,dindex, nreps(findex, aindex, dindex))=spikecount;
            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))
fprintf('\nnum spikes in response window: %d', sum(sum(sum(sum(M1))))                )
fprintf('\ntotal num spikes: %d', length(dspikes))

dindex=1;
traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,:,:,traces_to_keep,:), 4);
    sM1=std(M1(:,:,:,traces_to_keep,:), [],4);
else
    mM1=mean(M1, 4);
    sM1=std(M1, [],4);
end

%mM=mean(M(:,:,:,21:38,:), 4);

figure
hold on

c='rgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmykrgbcmyk';
for findex=1:numfreqs
    plot(amps, squeeze(mM1(findex, :, dindex, 1)), c(findex))
end
title('rate level functions for each frequency')
ylabel('spikecount')
xlabel('amplitude, dB')

figure
set(gca, 'fontsize', fontsize)
i=imagesc(mM1');
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
set(clab, 'string','spike count')
title(sprintf('%s-%s-%s',expdate,session, filenum), 'fontsize', fontsize)

%saveas(gcf, sprintf('TC%s-%s-%s.fig',expdate,session, filenum));
%fprintf('\n\n')

outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
out.M1=M1;
out.mM1=mM1;
out.sM1=sM1;
out.xlimits=xlimits;
out.numfreqs=numfreqs;
out.numamps=numamps;
out.mM1=mM1;
out.nreps=nreps;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.freqs=freqs;
out.amps=amps;
out.durs=durs;
godatadir(expdate,session, filenum)
save (outfilename, 'out')
fprintf('\n saved to %s', outfilename)
