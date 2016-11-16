function PlotRLF(varargin)
% extracts spikes and plots a Rate Level Function for each tone frequency
% usage: PlotRLF(expdate, session, filenum)
% PlotRLF(expdate, session, filenum, thresh)
% PlotRLF(expdate, session, filenum, thresh, xlimits)
% thresh is in number of std (default: 3) or use [-1 thresh] to pass a fixed voltage threshold
% default xlimits are 0:100 (xlimits forms the spike count window)
%
%  to use an absolute threshold (in mV) pass [-1 mV] as the thresh
%  argument, where mV is the desired threshold
% mw 070406
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ylimits=[];
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
    dur=max([durs 100]);
    xlimits=[0 100]; %x limits for axis
    
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    nstd=varargin{4};
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[0 100]; %x limits for axis
    
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

godatadir(expdate,session, filenum)
outfilename=sprintf('outRLF%s-%s-%s.mat',expdate,session, filenum);
if exist(outfilename)==2
    load(outfilename);
    fprintf('loaded outfile %s', outfilename)
    if ~isfield(out, 'mmM1spont') %need to update outfile
        generate_outfile(expdate, session, filenum, nstd, xlimits)
        load(outfilename);
    end
else
    generate_outfile(expdate, session, filenum, nstd, xlimits)
    load(outfilename);
end

%extract variables from outfile
M1=out.M1; %matrix of spikecounts, trial-by-trial
mM1=out.mM1; %matrix of mean spikecounts across trials
sM1=out.sM1; %std dev of spikecounts across trials
semM1=out.semM1;

freqs=out.freqs;
numfreqs=out.numfreqs;
amps=out.amps;
numamps=out.numamps;
durs=out.durs;
nreps=out.nreps;
xlimits=out.xlimits;
mmM1spont=out.mmM1spont; %grand average spontaneous spike rate across all stimuli/tials
ssM1spont=out.ssMspont1; %s.d. of above
ssemM1spont=out.ssemM1spont; %s.e.m. of above


%figure
dindex=1;
for findex=1:numfreqs
    figure
    e=errorbar(amps, squeeze(mM1(findex, :, dindex, 1)), squeeze(semM1(findex, :, dindex)));
    set(e, 'marker', '.', 'markersize', 20)
    title(sprintf('Rate level function %s-%s-%s freq:%g +-s.e.m.',expdate,session, filenum, freqs(findex)))
    ylabel('firing rate, Hz')
    xlabel('amplitude, dB')
    % ylim(ylimits)
end

line(xlim, mmM1spont*[1 1], 'linestyle', '--')
line(xlim, ssemM1spont+mmM1spont*[1 1], 'linestyle', ':')
line(xlim, -ssemM1spont+mmM1spont*[1 1], 'linestyle', ':')


function generate_outfile(expdate, session, filenum, nstd, xlimits)

monitor=0;
lostat=getlostat(expdate, session, filenum);
%[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);

[L E S ]=gogetdata(expdate,session,filenum);
% try
%     fprintf('\ntrying to load %s...', datafile)
%     godatadir(expdate, session, filenum)
%     L=load(datafile);
%     E=load(eventsfile);
%     S=load(stimfile);
%     fprintf('done.');
% catch
%     fprintf('\nCould not find data in %s', pwd)
%     try
%         fprintf('\nlooking for data on backup server')
%         godatadirbak(expdate, session, filenum)
%         L=load(datafile);
%         E=load(eventsfile);
%         S=load(stimfile);
%         fprintf('\nfound and loaded data.');
%     catch
%         fprintf('\nfailed. Could not find data')
%         try
%             ProcessData_single(expdate, session, filenum)
%             L=load(datafile);
%             E=load(eventsfile);
%             S=load(stimfile);
%             fprintf('done.');
%         catch
%             fprintf('\nProcessed data: %s not found. \nDid you copy into Backup?', datafile)
%         end
%         return
%     end
% end

event=E.event;
if isempty(event) fprintf('\nno tones\n'); return; end
stim=S.nativeScalingStim*double(S.stim);
scaledtrace=L.nativeScaling*double(L.trace) +L.nativeOffset;
clear L E S

fprintf('\ncomputing RLF...');

high_pass_cutoff=300; %Hz
samprate=1e4;
if isempty(lostat) lostat=length(scaledtrace);end
t=1:length(scaledtrace);
t=1000*t/samprate;
tracelength=diff(xlimits); %in ms
fprintf('\nresponse window: %.1f to %.1f ms relative to tone onset',xlimits);

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
    if thresh>1
        fprintf('\nusing spike detection threshold of %.1f mV (%g sd)', thresh, nstd);
    elseif thresh<=1
        fprintf('\nusing spike detection threshold of %.4f mV (%g sd)', thresh, nstd);
    end
end
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );

spikes=find(abs(filteredtrace)>thresh);

dspikes=spikes(1+find(diff(spikes)>refract));
if ~isempty(spikes)
    dspikes=[spikes(1) dspikes'];
end
if monitor
    figure
    plot(filteredtrace, 'b')
    hold on
    plot(thresh+zeros(size(filteredtrace)), 'm--')
    plot(spikes, thresh*ones(size(spikes)), 'g*')
    plot(dspikes, thresh*ones(size(dspikes)), 'r*')
    line(xlim, thresh*[1 1])
    line(xlim, thresh*[-1 -1])
    
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
%     ylim([0 10]);
%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event(i).Param.frequency;
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
    end
end
if(isempty(allfreqs)) error('no tones');end
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
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'tonetrain') |strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'clicktrain')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos)
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
                elseif  strcmp(event(i).Type, 'tonetrain')
                    freq=event(i).Param.frequency;
                    dur=event(i).Param.toneduration;
                elseif  strcmp(event(i).Type, 'grating')
                    freq=event(i).Param.angle*1000;
                    dur=event(i).Param.duration;
                elseif strcmp(event(i).Type, 'whitenoise')
                    dur=event(i).Param.duration;
                    freq=-1;
                elseif strcmp(event(i).Type, 'clicktrain')
                    dur=event(i).Param.clickduration;
                    freq=-1;
                end
                amp=event(i).Param.amplitude;
                findex=find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps(findex, aindex, dindex)=nreps(findex, aindex, dindex)+1;
                spikecount=length(find(dspikes>start & dspikes<stop)); % num spikes in region
                spont_spikecount=length(find(dspikes<start & dspikes>(start-(stop-start)))); % num spikes in a region of same length preceding response window
                
                spikerate=1000*spikecount/tracelength; %in Hz
                spont_spikerate=1000*spont_spikecount/tracelength; %in Hz
                M1(findex,aindex,dindex, nreps(findex, aindex, dindex))=spikerate;
                M1spont(findex,aindex,dindex, nreps(findex, aindex, dindex))=spont_spikerate;
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
    semM1=std(M1(:,:,:,traces_to_keep,:), [],4)./sqrt(nreps(findex, aindex, dindex));
    
    mM1spont=mean(M1spont(:,:,:,traces_to_keep,:), 4);
    sM1spont=std(M1spont(:,:,:,traces_to_keep,:), [],4);
    semM1spont=std(M1spont(:,:,:,traces_to_keep,:), [],4)./sqrt(nreps(findex, aindex, dindex));
    
else
    mM1=mean(M1, 4); % 
    sM1=std(M1, [],4);
    semM1=std(M1, [],4)./sqrt(nreps(findex, aindex, dindex));
    
    mM1spont=mean(M1spont, 4);
    sM1spont=std(M1spont, [],4);
    semM1spont=std(M1spont, [],4)./sqrt(nreps(findex, aindex, dindex));
end

mmM1spont=mean(mean(mean(mM1spont))); %grand average spontaneous spike rate
ssMspont1=std(M1spont(:));
ssemM1spont=std(M1spont(:))./sqrt(length(M1spont(:)));

godatadir(expdate,session, filenum)
outfilename=sprintf('outRLF%s-%s-%s',expdate,session, filenum);
out.M1=M1; %firing rate in Hz
out.mM1=mM1;
out.sM1=sM1;
out.semM1=semM1;
out.M1spont=M1spont; %spontaneous rate preceding each stimulus on each trial
out.mM1spont=mM1spont; %spontaneous rate preceding each stimulus, trial average
out.sM1spont=sM1spont; %s.d. of above
out.semM1spont=semM1spont; %s.e.m. of above

out.mmM1spont=mmM1spont; %grand average spontaneous spike rate across all stimuli/tials
out.ssMspont1=ssMspont1; %s.d. of above
out.ssemM1spont=ssemM1spont; %s.e.m. of above

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
out.nstd=nstd;
out.xlimits=xlimits;


findex=1;
if 0% numfreqs>1
    error('WARNING! More than one frequency in this RLF file!')
end

dindex=1;


threshFR=mmM1spont+2*ssemM1spont;
%compute threshold as lowest intensity at which response is >1 s.e.m. from
%spontaneous (using s.e.m. of spontaneous)
%thresh_index=min(find(mM1>(mmM1spont+3*ssemM1spont))); %this picks up
% low-level outliers
%thresh_index=1+max(find(mM1<(mmM1spont+3*ssemM1spont))); %this picks up high-level non-monotonic outliers
thresh_index=[];
for th=1:numamps-3
    if mM1(th:th+3)>threshFR
        thresh_index=th;
        break
    end
end
if isempty(thresh_index)
    thresh_index=min(find(mM1>(threshFR)));
end
threshdB=amps(thresh_index);
if isempty(threshdB) threshdB=nan;end
out.threshdB=threshdB;

% compute output dynamic range as F.R. difference between spontaneous and max evoked F.R.
dynamicrangeFR=max(mM1)-mmM1spont;
out.dynamicrangeFR=dynamicrangeFR;

% compute input dynamic range as dB difference between threshold and dB of max evoked F.R.
peak_index=min(find(mM1(findex,:)>(max(mM1(findex, :))-ssemM1spont)));
dynamicrangedB=amps(peak_index)- threshdB;
out.dynamicrangedB=dynamicrangedB;

%compute monotonicity index MI (1 for mono, 0 for nonmono, .5 = category
%boundary
% Mi= range at max level/dynamic range
Mi=(mM1(findex,end))/max(mM1);
out.Mi=Mi;

% 




% Save results to outfile...
godatadir(expdate,session, filenum)

% if isnan(cellNum)
% outfilename=sprintf('outRLF%s-%s-%s',expdate,session, filenum);
% else
%     outfilename=sprintf('outRLF%s-%s-%s_%s',expdate,session, filenum,num2str(cellNum));
% end

outfilename=sprintf('outRLF%s-%s-%s',expdate,session, filenum);

save (outfilename, 'out')
fprintf('\n saved to %s', outfilename)
fprintf('\nin dir %s', pwd)


