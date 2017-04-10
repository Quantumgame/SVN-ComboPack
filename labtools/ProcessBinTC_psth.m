function ProcessBinTC_psth(expdate, session, filenum, varargin)
% extracts spikes for a single psth tuning curve
% %same as PlotBinTC_psth except it doesn't plot
% usage: PlotBinTC_psth(expdate, session, filenum, [thresh], [xlimits], [ylimits], [binwidth])
% (thresh, xlimits, ylimits, binwidth are optional)
%
%  defaults: thresh=7sd, xlimits=[0 100], y-axis autoscaled, binwidth=5ms
%  thresh is number of standard deviations
%  to use absolute threshold (in mV) pass [-1 mV] as the thresh argument, where mV is the desired threshold
% mw 070406
% latest updates:
% mak 14feb2011 added the stimulus locked response plot
% mak 10jun2011 added spike counts (full file, xlim pre stim onset, non-xlim)
% mak 20jun2011 removed the durs from nargin inputs 
% mak 22jun2011 added firing rates output to command window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref
if isempty(pref); Prefs; end
username=pref.username;

if nargin==0
    fprintf('\nno input');
    return;
elseif nargin==3
    nstd=7;
    ylimits=-1;
    xlimits=[0 100];
    binwidth=5;
elseif nargin==4
    nstd=varargin{1};
    if isempty(nstd); nstd=7;end
    ylimits=-1;
    xlimits=[0 100];
    binwidth=5;
elseif nargin==5
    nstd=varargin{1};
    if isempty(nstd); nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
        xlimits=[0 100];
    end
    ylimits=-1;
    binwidth=5;
elseif nargin==6
    nstd=varargin{1};
    if isempty(nstd); nstd=7;end
    xlimits=varargin{2};
    if isempty(xlimits)
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

[D E S]=gogetdata(expdate,session,filenum);
event=E.event;
if isempty(event); fprintf('\nno tones\n'); return; end
scaledtrace=D.nativeScaling*double(D.trace)+ D.nativeOffset;
clear D E S

samprate=1e4;
lostat=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip
if     strcmp(expdate,'101810') && strcmp(session,'002') && strcmp(filenum,'003') %noted in cell_list
    lostat=1.443e5;
elseif strcmp(expdate,'080410') && strcmp(session,'005') && strcmp(filenum,'002') %noted in cell_list
    lostat=1.785e6;
end

if lostat==-1; lostat=length(scaledtrace);end
% fprintf('\nresponse window: %d to %d ms relative to tone onset',round(xlimits(1)), round(xlimits(2)));

% I'd like to bypass the filtering step here if the outfile exists 
% But, I'll need to ensure that command line inputs are used as well as any new lostat
% maybe later...

high_pass_cutoff=300; %Hz
% fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
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
% fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
try dspikes=[spikes(1) dspikes'];
catch
    dspikes=0;
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
for i=1:length(event)
    if strcmp(event(i).Type,'bintone') || strcmp(event(i).Type,'binwhitenoise')
        if isfield(event(i),'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos) && ~isempty(event(i).Position_rising)
                pos=event(i).Position_rising;
            end
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        % Inserted the three lines below to count spikes in the same sized window before
        % stim onset. start must be == 0 to work & stop should be <= half of the isi.
        % This code could be brittle. mak 16june2011
        if xlimits(1) == 0 && xlimits(2) <= 0.5*(event(i).Param.next)
            start1=(pos+(-xlimits(2))*1e-3*samprate);
            stop1=(pos+xlimits(1)*1e-3*samprate)-1;
            region1=start1:stop1; % this could be unnecessary
        else
            warning('spikes in the pre-xlim window aren''t counted, because xlimit(1)~=0');
        end
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
                % The 3 lines below find all the spikes in the prespike window (mak 16june2011)
                if xlimits(1) == 0 && xlimits(2) <= 0.5*(event(i).Param.next)
                    spiketimes1pre=dspikes(dspikes>start1 & dspikes<stop1); % spiketimes in same sized region window, before stim onset
                    spiketimes1pre=(spiketimes1pre-pos)*1000/samprate;%covert to ms after tone onset
                    M1(findex,Raindex, Laindex,dindex, nreps(findex, Raindex, Laindex, dindex)).pre_spiketimes=spiketimes1pre;
                end
            end
        end
    end
end
ntrials=sum(sum(squeeze(nreps)));
nrepsmax=max(max(max(nreps)));
nrepsmin=min(min(min(nreps)));
totreps=sum(sum(nreps));
% fprintf('\nreps -- min: %d; max: %d',nrepsmin,nrepsmax)
if dspikes==0
    ds=dspikes;
else
    ds=length(dspikes);
end    

%accumulate across trials
spiketimes2=[];
counter=0;
pre_spiketimes2=[];
counter_pre=0;
for dindex=1:numdurs
    for Raindex=1:numamps
        for  Laindex=1:numamps
            for findex=1:numfreqs
                spiketimes1=[];
                pre_spiketimes1=[];
                for rep=1:nreps(findex, Raindex, Laindex, dindex)
                    spiketimes1=[spiketimes1 M1(findex, Raindex, Laindex, dindex, rep).spiketimes];
                    pre_spiketimes1=[pre_spiketimes1 M1(findex, Raindex, Laindex, dindex, rep).pre_spiketimes];
                end
                counter=counter+length(spiketimes1);
                spiketimes2=[spiketimes2 spiketimes1];
                
                counter_pre=counter_pre+length(pre_spiketimes1);
                pre_spiketimes2=[pre_spiketimes2 pre_spiketimes1];
                
                mM1(findex, Raindex, Laindex, dindex).spiketimes=spiketimes1;
                mM1(findex, Raindex, Laindex, dindex).pre_spiketimes=pre_spiketimes1;
            end
        end
    end
end

numbins=diff(xlimits)/binwidth;
dindex=1;

%find axis limits
if ylimits==-1
    ylimits=[-1 0];
    for Raindex=numamps:-1:1
        for Laindex=numamps:-1:1
            for findex=1:numfreqs
                spiketimes=mM1(findex, Raindex, Laindex, dindex).spiketimes;
                X=xlimits(1):binwidth:xlimits(2); %specify bin centers
                [N, x]=hist(spiketimes, X);
                ylimits(2)=max(ylimits(2), max(N));
            end
        end
    end
end
ylimits(2)=ylimits(2)-rem(ylimits(2),5)+5;
dspikesxlim=length(spiketimes2);
pre_dspikesxlim=length(pre_spiketimes2);

filelength=length(scaledtrace);
spikerateFF=(ds/filelength)*samprate; %spikerate for the full file
spikerateRW=(dspikesxlim*1000)/(diff(xlimits)*ntrials); %spikerate for the response window only
spikerateRW_pre=(pre_dspikesxlim*1000)/(diff(xlimits)*ntrials); %spikerate for the response window only
spikerateNonRW=((ds-dspikesxlim)*1000)/((filelength*0.1)-(ntrials*diff(xlimits))); %spikerate for the full file minus the response window

out.M1=M1;
out.mM1=mM1;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.freqs=freqs;
out.Ramps=Ramps;
out.Lamps=Lamps;
out.durs=durs;
out.ylimits=ylimits;
out.nstd=nstd;
out.thresh=thresh;
out.binwidth=binwidth;

out.samprate=samprate;
out.nreps=nreps;
out.ntrials=sum(sum(squeeze(nreps)));
out.xlimits=xlimits;

out.dspikes=dspikes;
out.ds=ds;
out.dspikesxlim=dspikesxlim;
out.pre_dspikesxlim=pre_dspikesxlim;
out.filelength=length(scaledtrace);
out.spikerateFF=spikerateFF;
out.spikerateRW=spikerateRW;
out.spikerateRW_pre=spikerateRW_pre;
out.spikerateNonRW=spikerateNonRW;

% fprintf('\nspikes in response window %d; total spikes: %d',dspikesxlim,ds)

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
godatadir(expdate, session, filenum)
save(outfilename, 'out')
fprintf('\n saved to %s\n\n', outfilename);

