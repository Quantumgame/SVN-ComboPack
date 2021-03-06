function PlotILArch_NBN(varargin)
% 
% PlotILArch_NBN() -------------------------------------------------
% Plots laser-interleaved ("IL") narrow band noise ("NBN") tuning curves.
% Saves an outfile for analysis. 
%
% Useage:
%   PlotILArch_NBN(expdate, session, filename, [xlimits], [ylimits], [thresh], [binwidth])
%   <Defaults: xlimits 0-100ms, ylimits {auto scaled}, thresh 7 std,
%   bindwidth 5ms.>
%
% Plots center frequency (x-axis) vs. bandwidth (y-axis). (If sounds were 
% presented at >1 intensities, each gets its own figure.) 
% It'll do a single 'overlay' plot with the laser-ON psth in green, and the
% laser-OFF psth in black. 
%
% Red *s ('on & off' plot) indicate a significant difference (ttest2) between spike counts 
% in the specified time window (xlimits), for laser-ON and laser-OFF trials. Significance 
% level is corrected for the number of pair-wise tests performed.
%
% 9.17.13, AKH 
%
% Notes:
% 1. 'xlimits' serve both as the limits for plotting *and* the window for computing
% spike times/counts/rates & ttest.
% 2. PlotILArch_NBN() won't load or plot from an existing outfile if you call
% the function more than once on the same file. Instead, it'll reprocesses the 
% data with the currently specified x-limits, threshold, etc. and overwrite the old outfile.
% 3. NBN stimuli -- assumes 1 duration; uses 'bwindex' instead of 'dindex'
% for indexing. Check out MakeNBNProtocol().

%% Args

global pref
if isempty(pref) Prefs; end
username=pref.username;
   
% Defaults--
nstd=7;
binwidth=5;
xlimits=[0 100]; % For plots & ttest.
ylimits=[];

if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
elseif nargin==5
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
elseif nargin==6
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
    nstd=varargin{6};
    if isempty(nstd);nstd=7;end
elseif nargin==7
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
    nstd=varargin{6};
    if isempty(nstd);nstd=7;end
    binwidth=varargin{7};
    if isempty(binwidth);binwidth=5;end
elseif nargin==8
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=varargin{5};
    nstd=varargin{6};
    if isempty(nstd);nstd=7;end
    binwidth=varargin{7};
    if isempty(binwidth);binwidth=5;end
else
    error('wrong number of arguments');
end

if isempty(xlimits)
    xlimits=[0 100]; % x limits for axis
end

lostat1=[];% getlostat(expdate, session, filenum);
[D E S D2]=gogetdata(expdate,session,filenum);
event=E.event;
stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
scaledtrace2=[];

try 
    scaledtrace2=D2.nativeScaling*double(D2.trace)+D2.nativeOffset;
end

clear D E S D2

samprate=1e4;
if isempty(lostat1) lostat1=length(scaledtrace);end
t=1:length(scaledtrace);
t=1000*t/samprate;

%% Get freqs/amps.

% Laser pulses.
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'aopulse') || strcmp(event(i).Type, 'aopulsetrain')
        j=j+1;
        alldurs(j)=event(i).Param.width;
        end
end

% Sounds.
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

fprintf('\n Frequencies:')
fprintf('%.1f  ', freqs/1000)
fprintf('\n Amplitudes:')
fprintf('%d  ', round(amps))
fprintf('\n Bandwidths:')
fprintf('%.1f  ', bws)
fprintf('\n Durations:')
fprintf('%d  ', durs)

%% Get dspikes

high_pass_cutoff=300; %Hz
fprintf('\nHigh-pass filtering at %d Hz...', high_pass_cutoff);
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
filteredtrace=filtfilt(b,a,scaledtrace);
if length(nstd)==2
    if nstd(1)==-1
        thresh=nstd(2);
        nstd=thresh/std(filteredtrace);
        fprintf('\nUsing absolute spike detection threshold of %.1f mV (%.1f sd).', thresh, nstd);
    end
else
    thresh=nstd*std(filteredtrace);
    if thresh>1
        fprintf('\nUsing spike detection threshold of %.1f mV (%g sd).', thresh, nstd);
    elseif thresh<=1
        fprintf('\nUsing spike detection threshold of %.4f mV (%g sd).', thresh, nstd);
    end
end
refract=5;
fprintf('\nUsing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
spikes=find(abs(filteredtrace)>thresh);
dspikes=spikes(1+find(diff(spikes)>refract));
try
    dspikes=[spikes(1) dspikes'];
catch
    fprintf('\n\ndspikes is empty; either the cell never spiked or the nstd is set too high.\n');
    return
end

monitor=0;

if (monitor)
    figure
%     plot(filteredtrace(1:10:end), 'b')
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

%% Spiketimes for each presentation of each stim.

M1ONp=[];
mM1ONp=[];
nrepsON=zeros(numfreqs, numamps, numbws);
M1spontON=[];
mM1spontON=[];
sM1spontON=[];
semM1spontON=[];

M1OFFp=[];
mM1OFFp=[];
nrepsOFF=zeros(numfreqs, numamps, numbws);
M1spontOFF=[];
mM1spontOFF=[];
sM1spontOFF=[]; 
semM1spontOFF=[];

% Extract the traces into a big matrix M.
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'tone') | strcmp(event(i).Type, 'whitenoise') | strcmp(event(i).Type, 'noise')
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
        if isempty(find(region<0)) % (Disallow negative start times.)
            if stop>lostat1
                fprintf('\ndiscarding trace')
            else
                
                aopulseon=event(i).Param.AOPulseOn;
                
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
                
                % Evoked
                spiketimes1=dspikes(dspikes>start & dspikes<stop); % Spiketimes in region
                spiketimes1=(spiketimes1-pos)*1000/samprate;% Covert to ms after tone onset
                spikecount=length(spiketimes1); % No. of spikes fired in response to this rep of this stim.

                % Spont
                spont_spikecount=length(find(dspikes<start & dspikes>(start-(stop-start)))); 
                % No. spikes in a region of same length preceding response window

                if aopulseon
                    nrepsON(findex, aindex, bwindex)=nrepsON(findex, aindex, bwindex)+1;
                    M1ONp(findex,aindex,bwindex, nrepsON(findex, aindex, bwindex)).spiketimes=spiketimes1; % Spike times
                    M1ONspikecounts(findex,aindex,bwindex,nrepsON(findex, aindex, bwindex))=spikecount; % No. of spikes
                    M1spontON(findex,aindex,bwindex, nrepsON(findex, aindex,bwindex))=spont_spikecount; % No. of spikes in spont window, for each presentation.
                    
                    %                     nreps(findex, aindex, bwindex)=nreps(findex, aindex, bwindex)+1;
                    %                     spiketimes1=dspikes(dspikes>start & dspikes<stop); % spiketimes in region
                    %                     spiketimes1=(spiketimes1-pos)*1000/samprate;%covert to ms after tone onset
                    %                     M1(findex,aindex,bwindex, nreps(findex, aindex, bwindex)).spiketimes=spiketimes1;
                    
                else
                    nrepsOFF(findex, aindex, bwindex)=nrepsOFF(findex, aindex, bwindex)+1;
                    M1OFFp(findex,aindex,bwindex, nrepsOFF(findex, aindex, bwindex)).spiketimes=spiketimes1;
                    M1OFFspikecounts(findex,aindex,bwindex,nrepsOFF(findex, aindex, bwindex))=spikecount;
                    M1spontOFF(findex,aindex,bwindex, nrepsOFF(findex, aindex, bwindex))=spont_spikecount;
                end
            end
        end
    end
end

% ON, evoked
mM1ONspikecount=mean(M1ONspikecounts,4); % Mean spike count
sM1ONspikecount=std(M1ONspikecounts,[],4); % Std of the above
semM1ONspikecount=sM1ONspikecount./sqrt(nrepsON(:,:,:)); % Sem of the above
% Spont
mM1spontON=mean(M1spontON,4); 
sM1spontON=std(M1spontON,[],4); 
semM1spontON=sM1spontON./sqrt(nrepsON(:,:,:)); 

% % OFF, evoked
mM1OFFspikecount=mean(M1OFFspikecounts,4); 
sM1OFFspikecount=std(M1OFFspikecounts,[],4); 
semM1OFFspikecount=sM1OFFspikecount./sqrt(nrepsOFF(:,:,:)); 
% Spont
mM1spontOFF=mean(M1spontOFF,4); 
sM1spontOFF=std(M1spontOFF,[],4); 
semM1spontOFF=sM1spontOFF./sqrt(nrepsOFF(:,:,:)); 

%% Accumulate spiketimes across trials, for psth...
for bwindex=[1:numbws]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            
            % on
            spiketimesON=[];
            spikecountsON=[];
            for rep=1:nrepsON(findex, aindex, bwindex)
                spiketimesON=[spiketimesON M1ONp(findex, aindex, bwindex, rep).spiketimes];
                % Accumulate spike times for all presentations of each
                % laser/f/a combo.
            end
            
            % All spiketimes for a given f/a/d combo, for psth:
            mM1ONp(findex, aindex, bwindex).spiketimes=spiketimesON;
            
            % off
            spiketimesOFF=[];
            for rep=1:nrepsOFF(findex, aindex, bwindex)
                spiketimesOFF=[spiketimesOFF M1OFFp(findex, aindex, bwindex, rep).spiketimes];
            end
            mM1OFFp(findex, aindex, bwindex).spiketimes=spiketimesOFF;
        end
    end
end 

%% Get bins for plotting.
if isempty(ylimits)
    ylimits=[-.1 1];
    
    for bwindex=[1:numbws]
        for aindex=numamps:-1:1
            for findex=1:numfreqs
                spiketimes=mM1OFFp(findex, aindex, bwindex).spiketimes; % accumulated spike times for all reps of a stim.
                X=xlimits(1):binwidth:xlimits(2); % specify bin centers
                [N, x]=hist(spiketimes, X);
                % x = X (0 5 10 15...80 ms from start)
                % N = # spikes in those bins
                N=N./nrepsON(findex, aindex, bwindex); % / by num trials
                ylimits(2)=max(ylimits(2), max(N));
            end
        end
    end % dindex
ylimits(2)=ylimits(2)*1.2;
end   
%% ttest
    [h,pvalues]=ttest2(M1ONspikecounts,M1OFFspikecounts,[],[],[],4);  
    alpha=0.05/(numamps*numfreqs*numbws);
    
%% Plot psth, ON/OFF overlay
% Not plotting an entire separate freq column for whitenoise, just plotting
% it as the "inf" bandwidth for each freq.

for aindex=[1:numamps]
    figure
    p=0;
    subplot1(numbws,numfreqs-1)
    for bwindex=[1:numbws]
        for findex=2:numfreqs
            if bwindex==numbws %inf==wn
                findex=1;
            end
            p=p+1;
            subplot1( p)
            hold on
            
            spiketimesON=mM1ONp(findex, aindex, bwindex).spiketimes;
            spiketimesOFF=mM1OFFp(findex, aindex, bwindex).spiketimes;
            X=xlimits(1):binwidth:xlimits(2); % specify bin centers
            
            [NON, xON]=hist(spiketimesON, X); 
            [NOFF, xOFF]=hist(spiketimesOFF, X);
            
            NON=NON./nrepsON(findex, aindex, bwindex); 
            %NON=1000*NON./binwidth; normalize to spike rate in Hz
            NOFF=NOFF./nrepsOFF(findex, aindex, bwindex);
            %NOFF=1000*NOFF./binwidth;
                       
            bON=bar(xON, NON,1);
            hold on
            bOFF=bar(xOFF,NOFF,1);
            
            set(bON, 'facecolor', ([51 204 0]/255),'edgecolor', ([51 204 0]/255));
            set(bOFF, 'facecolor', 'none','edgecolor', [0 0 0]);
            
            line([0 0+durs(dindex)], [-.1 -.1], 'color', 'm', 'linewidth', 2)
            line(xlimits, [0 0], 'color', 'k')
            ylim(ylimits)
            xlim(xlimits)
            
            if pvalues(findex,aindex)<alpha 
                text((xlimits(2)*.1),(ylimits(2)*.6),'*','fontsize',30,'color','r')
            end
            
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
                vpos=ylimits(1)-diff(ylimits)/4;
                text(mean(xlimits), vpos, sprintf('%.1f kHz', freqs(findex)/1000))
            else
                set(gca, 'yticklabel', '')
            end
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s: %.0f dB (Max reps ON=%.0f, OFF=%.0f)',expdate,session, filenum, amps(aindex), max(max(nrepsON)),max(max(nrepsOFF))))

    pos=get(gcf, 'pos');
    pos(2)=pos(2)-600;
    pos(4)=pos(4)+600;
    set(gcf, 'pos', pos);
    text
    
end %for aindex

%% Save it to an outfile!

% Evoked spikes.
out.M1OFFp=M1OFFp; % All spiketimes, trial-by-trial.
out.M1ONp=M1ONp; 
out.mM1OFFp=mM1OFFp; % Accumulated spike times for *all* presentations of each laser/f/a combo.
out.mM1ONp=mM1ONp;
out.mM1ONspikecount=mM1ONspikecount; % Mean spikecount for each laser/f/a combo.
out.sM1ONspikecount=sM1ONspikecount;
out.semM1ONspikecount=semM1ONspikecount;
out.mM1OFFspikecount=mM1OFFspikecount;
out.sM1OFFspikecount=sM1OFFspikecount;
out.semM1OFFspikecount=semM1OFFspikecount;

% Spont spikes.
out.mM1spontON=mM1spontON;
out.sM1spontON=sM1spontON;
out.semM1spontON=semM1spontON;
out.mM1spontOFF=mM1spontOFF;
out.sM1spontOFF=sM1spontOFF;
out.semM1spontOFF=semM1spontOFF;

out.amps=amps;
out.durs=durs;
out.bws=bws;
out.freqs=freqs;
out.nrepsON=nrepsON;
out.nrepsOFF=nrepsOFF;
out.xlimits=xlimits;
out.mVthresh=thresh;

godatadir(expdate,session,filenum);
outfilename=sprintf('outArch_NBN%s-%s-%s',expdate,session, filenum); 
save (outfilename, 'out')
fprintf('\n Saved to %s.\n', outfilename)

end