function ProcessTC_psth(expdate, session, filenum, varargin)
% Same as PlotTC_psth except it doesn't plot, and it saves the output in an
% outfile
% extracts spikes and sorts into a response matrix, and saves in an outfile
%
% usage: ProcessTC_psth(expdate, session, filenum, [thresh], [xlimits], [ylimits], [binwidth])
% (thresh, xlimits, ylimits, binwidth are optional)
%
%  defaults: thresh=7sd, binwidth=5ms, xlimits=[0 100]
%  thresh is in number of standard deviations
%  to use an absolute threshold (in mV) pass [-1 mV] as the thresh
%  argument, where mV is the desired threshold
% mw 070406
% mw 011811 - now plots mean spike rate (in Hz) averaged across trials

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    nstd=7;
    ylimits=-1;
    %     durs=getdurs(expdate, session, filenum);
    %     dur=max([durs 100]);
    %     xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    xlimits=[0 100];
    binwidth=5;
elseif nargin==4
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    ylimits=-1;
    %     durs=getdurs(expdate, session, filenum);
    %     dur=max([durs 100]);
    %     xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    xlimits=[0 100];
    binwidth=5;
elseif nargin==5
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
    %     durs=getdurs(expdate, session, filenum);
    %     dur=max([durs 100]);
    %     xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    xlimits=[0 100];
    end
    ylimits=-1;
    binwidth=5;
elseif nargin==6
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
    %     durs=getdurs(expdate, session, filenum);
    %     dur=max([durs 100]);
    %     xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    xlimits=[0 100];
    end
    ylimits=varargin{3};
    if isempty(ylimits)
        ylimits=-1;
    end
    binwidth=5;
elseif nargin==7
    nstd=varargin{1};
    if isempty(nstd); nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
    %     durs=getdurs(expdate, session, filenum);
    %     dur=max([durs 100]);
    %     xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    xlimits=[0 100];
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

monitor=1; %0=off; 1=on
lostat=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

fs=10;

[D E S]=gogetdata(expdate,session,filenum);
event=E.event;
if isempty(event) fprintf('\nno tones\n'); return; end
scaledtrace=D.nativeScaling*double(D.trace)+ D.nativeOffset;
clear D E S


fprintf('\ncomputing tuning curve...');

samprate=1e4;
if lostat==-1 lostat=length(scaledtrace);end
fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));

high_pass_cutoff=300; %Hz
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace=filtfilt(b,a,scaledtrace);
hiCutOff = nan;

    % If there's a hard mV thresh...
    if nstd(1)==-1
if length(nstd)==2
        thresh=nstd(2);
        nstd=thresh/std(filteredtrace);
        fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh, nstd);
    end
    
elseif length(nstd)==3
    % If there's a hard mV thresh AND a high cut off...
    % AKH 5/22/12
    if nstd(1)==-1
        thresh=nstd(2);
        hiCutOff=nstd(3);
        nstd=thresh/std(filteredtrace);
        fprintf('\nusing absolute spike detection threshold of %.1f mV (%.1f sd)', thresh, nstd);
        fprintf('\nIgnoring spikes >%.1f mV',hiCutOff)
    end    
else
    thresh=nstd*std(filteredtrace);
    if thresh>1
    fprintf('\nusing spike detection threshold of %.1f mV (%g sd)', thresh, nstd);
    elseif thresh<=1
    fprintf('\nusing spike detection threshold of %.4f mV (%g sd)', thresh, nstd);
    end
end
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace)>thresh);

% keyboard
% spikesWithout = [];
% if ~isnan(hiCutOff)
%     % Keep only those that are less than the high voltage cut off.
%     %spikesToss=find(hiCutOff>abs(filteredtrace)>thresh);
%     
%     for i=1:length(spikes)
%     if filteredtrace(spikes(i)) < hiCutOff
%         spikesWithout=[spikesWithout spikes(i)];
%     end
%     end
%     
% end
% 
% spikes = spikesWithout;
% keyboard
% spikes = times of ALL threshold crossing events.

dspikes=spikes(1+find(diff(spikes)>refract));

%keyboard
try
dspikes=[spikes(1) dspikes'];
catch
    fprintf('\n\ndspikes is empty; either the cell never spiked or the nstd is set too high\n');
    return
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
% if monitor
%     figure
%     ylim([min(filteredtrace) max(filteredtrace)]);
%     for ds=dspikes(1:20)
%         xlim([ds-100 ds+100])
%         t=1:length(filteredtrace);
%         region=[ds-100:ds+100];
%         if min(region)<1
%             region=[1:ds+100];
%         end
%         hold on
%         plot(t(region), filteredtrace(region), 'b')
%         plot(spikes, thresh*ones(size(spikes)), 'g*')
%         plot(dspikes, thresh*ones(size(dspikes)), 'r*')
%         line(xlim, thresh*[1 1])
%         line(xlim, thresh*[-1 -1])
%         pause(.05)
%         hold off
%     end
%     pause(.5)
%     close
% end

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
   elseif strcmp(event(i).Type, 'gapinnoise') | strcmp(event(i).Type, 'gapintone')
        j=j+1;
        allfreqs(j)=event(i).Param.gapdur*1000; %using gapdur as "frequency"
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

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
M1=[];
nreps=zeros(numfreqs, numamps, numdurs);


%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') | strcmp(event(i).Type, 'naturalsound') | strcmp(event(i).Type, 'grating') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain') | strcmp(event(i).Type, 'gapinnoise') | strcmp(event(i).Type, 'gapintone') 
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
                elseif strcmp(event(i).Type, 'fmtone')
                    freq=event(i).Param.carrier_frequency;
                    dur=event1(i).Param.duration;
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
                elseif strcmp(event(i).Type, 'gapinnoise') | strcmp(event(i).Type, 'gapintone')
                    dur=event(i).Param.duration;
                    freq=event(i).Param.gapdur*1000;
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
                nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                spiketimes1=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
                spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
                M1(findex,aindex,dindex, nreps(findex, aindex, dindex)).spiketimes=spiketimes1;
                spont_spikecount=length(find(dspikes<start & dspikes>(start-(stop-start)))); %num spikes in a region of same length preceding response window
                spont_spikerate=1000*spont_spikecount/diff(xlimits); %in Hz
                M1spont(findex,aindex,dindex, nreps(findex, aindex, dindex))=spont_spikerate;

            end
        end
    end
end

fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps))), max(max(max(nreps))))
fprintf('\ntotal num spikes: %d', length(dspikes))

%accumulate across trials
for dindex=[1:numdurs]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            spiketimes1=[];
            for rep=1:nreps(findex, aindex, dindex)
                spikecounts(rep)=length( M1(findex, aindex, dindex, rep).spiketimes);
                spikerates(rep)=1000*spikecounts(rep)/diff(xlimits); %in Hz
            end
            mM1(findex, aindex, dindex)=mean(spikerates); %spike rate in Hz
            sM1(findex, aindex, dindex)=std(spikerates);
            semM1(findex, aindex, dindex)=std(spikerates)./sqrt(nreps(findex, aindex, dindex));
        end
    end
end
mM1spont=mean(M1spont, 4);
sM1spont=std(M1spont, [],4);
semM1spont=std(M1spont, [],4)./sqrt(nreps(findex, aindex, dindex)); %this is not the right nreps
mmM1spont=mean(mean(mean(mM1spont))); %grand average spontaneous spike rate
ssMspont1=std(M1spont(:));
ssemM1spont=std(M1spont(:))./sqrt(length(M1spont(:)));


out_psth.M1=M1;
out_psth.mM1=mM1;
out_psth.sM1=sM1;
out_psth.expdate=expdate;
out_psth.session=session;
out_psth.filenum=filenum;
out_psth.freqs=freqs;
out_psth.amps=amps;
out_psth.numfreqs=length(freqs);
out_psth.numamps=length(amps);
out_psth.durs=durs;
out_psth.ylimits=ylimits;
out_psth.nstd=nstd;
out_psth.thresh=thresh;
out_psth.binwidth=binwidth;

out_psth.samprate=samprate;
out_psth.nreps=nreps;
out_psth.ntrials=sum(sum(squeeze(nreps)));
out_psth.xlimits=xlimits;

out_psth.dspikes=dspikes; %all spikestimes

out_psth.semM1=semM1;
out_psth.M1spont=M1spont; %spontaneous rate preceding each stimulus on each trial
out_psth.mM1spont=mM1spont; %spontaneous rate preceding each stimulus, trial average
out_psth.sM1spont=sM1spont; %s.d. of above
out_psth.semM1spont=semM1spont; %s.e.m. of above

out_psth.mmM1spont=mmM1spont; %grand average spontaneous spike rate across all stimuli/tials
out_psth.ssMspont1=ssMspont1; %s.d. of above
out_psth.ssemM1spont=ssemM1spont; %s.e.m. of above
out_psth.filteredtrace=filteredtrace;
outfilename=sprintf('out_psth%s-%s-%s', expdate, session, filenum);
% outfilename=sprintf('out_0-40ms_%s-%s-%s', expdate, session, filenum);
% outfilename=sprintf('out_40-80ms_%s-%s-%s', expdate, session, filenum);




godatadir(expdate, session, filenum)
save(outfilename, 'out')
fprintf('\n saved to %s\n\n', outfilename);
