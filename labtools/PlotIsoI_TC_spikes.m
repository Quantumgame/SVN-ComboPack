function PlotIsoI_TC_spikes(expdate, session, filenum, varargin)
% extracts spikes and plots a spikecount tuning curve for each intensity
% usage: PlotIsoI_TC_spikes(expdate, session, filenum, [thresh], [xlimits],
% [ylimits], CF, cellNum)

% 090612 AKH: This ought to calculate everything Analyze_PINP_TC does. I'm
% combining the two.

% ******Note!***** 
% xlimits passed determine the response window in which spikes are counted,
% NOT the xlimits of the tuning curve plot (out.xlimits).

% mw 022708
% Last Updated 090612, AKH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Args.
if nargin==0 fprintf('\nno input\n');return; end
monitor=0;
lostat1=-1;%2.4918e+006; %discard data after this position (in samples), -1 to skip

if nargin==3
    
    nstd=7;
    ylimits=[];
    xlimits=[0 100]; % Response window in which spikes are counted.
    CF=nan;
    cellNum=nan;

elseif nargin==4
    
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    
    ylimits=[];
    xlimits=[0 100]; 
    CF=nan;
    cellNum=nan;

elseif nargin==5
    
    nstd=varargin{1};
    if isempty(nstd) nstd=7;end
    
    xlimits=varargin{2};
    if isempty(xlimits); xlimits=[0 100]; end
    
    ylimits=[];
    CF=nan;
    cellNum=nan;

elseif nargin==6
    
    nstd=varargin{1};
    if isempty(nstd); nstd=7;end
    
    xlimits=varargin{2};
    if isempty(xlimits);xlimits=[0 100]; end
    
    ylimits=varargin{3};
    if isempty(ylimits); ylimits=[]; end
    
    CF=nan;
    cellNum=nan;

elseif nargin==7;
   
    nstd=varargin{1};
    if isempty(nstd); nstd=7;end
    
    xlimits=varargin{2};
    if isempty(xlimits)xlimits=[0 100]; end %response window in which spikes are counted

    ylimits=varargin{3};
    if isempty(ylimits); ylimits=[];end

   CF = varargin{4};
   if isempty(CF); CF=nan;end
   
   cellNum=nan;
   
elseif nargin==8;
    
    nstd=varargin{1};
    if isempty(nstd); nstd=7;end
    
    xlimits=varargin{2};
    if isempty(xlimits)xlimits=[0 100]; end %response window in which spikes are counted
    
    ylimits=varargin{3};
    if isempty(ylimits); ylimits=[];end
    
    CF = varargin{4};
    if isempty(CF); CF=nan;end
    
    cellNum=varargin{5};
    if isempty(cellNum); cellNum=nan;end
    
else
    error('wrong number of arguments');
end

global pref
if isempty(pref)
    Prefs;
end
username=pref.username;


%% Load Outfile
godatadir(expdate,session,filenum)

if ~isnan(cellNum)
 %If cellNum...
    
%     outfilename=sprintf('out%s-%s-%s_%s.mat',expdate,session, filenum,num2str(cellNum));
%     fprintf('\nTrying to load %s...', outfilename)
%     
%     if exist(outfilename)==2
%         load(outfilename)
%     else
%         fprintf('cellNum provided, but outfile can''t be found...! Replot %s,%s,%s', expdate,session,filenum);
%         return
%     end
%     
%     
%     % Extract variables from outfile:
%     M1=out.M1; % Matrix of spikecounts, trial-by-trial.
%     mM1=out.mM1; % Matrix of mean spikecounts across trials.
%     sM1=out.sM1; % Std dev of spikecounts across trials.
%     semM1=out.semM1; % s.e.m. of mean spikecounts across trials.
%     freqs=out.freqs;
%     numfreqs=out.numfreqs;
%     amps=out.amps;
%     numamps=out.numamps;
%     durs=out.durs;
%     nreps=out.nreps;
%     xlimits=out.xlimits;
%     mmM1spont=out.mmM1spont; % Grand average spontaneous spike rate across all stimuli/tials.
%     ssM1spont=out.ssMspont1; % s.d. of above.
%     ssemM1spont=out.ssemM1spont; % s.e.m. of above.
%     
else
    % If no cellNum...
    outfilename=sprintf('out%s-%s-%s.mat',expdate,session, filenum);
    fprintf('\nTrying to load %s...', outfilename)
    
    if exist(outfilename)==2
        load(outfilename)
        
        if ~exist('out') 
            ProcessTC_psth(expdate, session, filenum, nstd, xlimits, ylimits)
            % Generates outfile...
            load(outfilename);
        end
        if ~isfield(out, 'mmM1spont') 
            ProcessTC_psth(expdate, session, filenum, nstd, xlimits, ylimits)
            % Generates outfile...
            load(outfilename);
        end
        
    else
        ProcessTC_psth(expdate, session, filenum, nstd, xlimits, ylimits)
            % Generates outfile...
            load(outfilename);
    end
    
    
 % Extract variables from outfile:
        M1=out.M1; % Matrix of spikecounts, trial-by-trial.
        mM1=out.mM1; % Matrix of mean spikecounts across trials.
        sM1=out.sM1; % Std dev of spikecounts across trials.
        semM1=out.semM1; % s.e.m. of mean spikecounts across trials.
        freqs=out.freqs;
        numfreqs=out.numfreqs;
        amps=out.amps;
        numamps=out.numamps;
        durs=out.durs;
        nreps=out.nreps;
        xlimits=out.xlimits;
        mmM1spont=out.mmM1spont; % Grand average spontaneous spike rate across all stimuli/tials.
        ssM1spont=out.ssMspont1; % s.d. of above.
        ssemM1spont=out.ssemM1spont; % s.e.m. of above.  
    

% Check for conflicts with previously processed xlimits (will influence FR and spikecount)

% if ~isnan(xlimits) && (out.xlimits ~= xlimits)
%     fprintf('Specified xlimits and outfile xlimits do not agree! Reprocessing...')
%     ProcessTC_psth(expdate, session, filenum, nstd, xlimits, ylimits);
%     %% ...and load outfile.
%     load(outfilename);
%       % Extract variables from outfile:
%         M1=out.M1; % Matrix of spikecounts, trial-by-trial.
%         mM1=out.mM1; % Matrix of mean spikecounts across trials.
%         sM1=out.sM1; % Std dev of spikecounts across trials.
%         semM1=out.semM1; % s.e.m. of mean spikecounts across trials.
%         freqs=out.freqs;
%         numfreqs=out.numfreqs;
%         amps=out.amps;
%         numamps=out.numamps;
%         durs=out.durs;
%         nreps=out.nreps;
%         xlimits=out.xlimits;
%         mmM1spont=out.mmM1spont; % Grand average spontaneous spike rate across all stimuli/tials.
%         ssM1spont=out.ssMspont1; % s.d. of above.
%         ssemM1spont=out.ssemM1spont; % s.e.m. of above.
%         %%
% else
%     fprintf('Using xlimits of %d',out.xlimits);
% end


% Compute values....

halfmaxFR=(max(mM1)-mmM1spont)/2 + mmM1spont;
% (1/2 'Distance' between spont and max...)
out.halfmaxFR=halfmaxFR;

% We're going to subtract this value from all the spike counts. 
% Values <0 go to 0.
% 
% subtracted=[];
% for i=out.mM1
%     
%     if (i-out.mmM1spont) < 0
%         subtracted=[subtracted 0];
%     else
%     subtracted=[subtracted (i-out.mmM1spont)];
%     end
% end




% Compute tuning width as freq width above half max F.R.


abovethresh=find(mM1>halfmaxFR); 
% 
% min=0;
% max=0;
% distance=0;
% greatestDistance=0;

%for i=aboveThreshIndex

%end
    

(find(mM1>halfmaxFR));


% if abovethresh == 0
% printf('abovethresh = 0 -- skipping this cell for now...')
% continue 
% end

 index_range=[min(abovethresh) max(abovethresh)];
 khz_range=freqs(index_range);
 
 if isempty(khz_range)
     BWoct=nan;
 else
 
 BWoct=log2(khz_range(2)/khz_range(1));
 end
 
 
out.BWoct=BWoct;






for dindex=1:length(out.durs)
    figure
    hold on
    c='rgbcmykrgbcmykrgbcmykrgbcmykrgbcmyk';
    for aindex=1:numamps
        plot(1:length(freqs), squeeze(mM1(:, aindex, dindex, 1)), c(aindex))
        xlim([1 length(freqs)]);
        xt=get(gca, 'xtick');
        set(gca, 'xticklabel', .1*round(freqs(xt)/100))
        xlabel('freq, kHz')
        xlim([.5 length(freqs)+.5]);
    end
    title('iso-intensity tuning curves for each level')
    ylabel('spikecount')
    xlabel('frequency, kHz')
    minnreps=min(min(min(min(nreps))));
%    title(sprintf('%s-%s-%s ch 1, %d ms, nstd=%d, %s dB, response window %d-%dms, %d reps',expdate,session, filenum, out.durs(dindex), nstd, ampstr , xlimits(1), xlimits(2), minnreps))
    
    for aindex=1:numamps
        figure
        hold on
        errorbar(1:length(freqs), squeeze(mM1(:, aindex, dindex)), squeeze(sM1(:, aindex, dindex)))
        plot(1:length(freqs), squeeze(mM1(:, aindex, dindex)), 'o')
        ylabel('spikecount')
        xlim([1 length(freqs)]);
        xt=get(gca, 'xtick');
        set(gca, 'xticklabel', .1*round(freqs(xt)/100))
        xlabel('freq, kHz')
        xlim([.5 length(freqs)+.5]);
        %title(sprintf('iso-intensity tuning curve for %d dB \n%s-%s-%s ch 1, nstd=%d, %d total spikes, response window %d-%dms, %d reps', round(amps(aindex)), expdate,session, filenum, nstd, length(dspikes) , xlimits(1), xlimits(2), minnreps))
    end






% #####################################################################
% Normalizing FRs & distance from CF. For plotting group data.
    
    if numamps ~= 1
        fprintf('More than one amplitude present! Using %d dB for group data curve.', amps(1))
    end
    
    aindex = 1; % Assume one amplitude.
    
% ---------------------------------------------------------------------
% Normalize freqs ('distance from CF') for group data plotting; save to outfile.
    
    % (If the first freq is WN, discard it...)
    
    if freqs(1) < 0
        plotFreqs = freqs(2:length(freqs));
    else
        plotFreqs = freqs;
    end
    
    % 'log(hi-f/lo-f)/log(2)' gives you the octave distance from lo-f
    % TO hi-f. So, for frequencies < CF, you'll get positive values; for frequencies >
    % CF, you'll get negative values.
    
    % So, if you do it like this [CF/freq] your negative values will
    % correspond to the highest frequencies. I wan to flip that, because
    % I'm used to the lower frequencies being near the origin. Hence,
    % [plotFreqs(i)/CF].
    
    for i = 1:length(plotFreqs)
        plotFreqs(i) = log(plotFreqs(i)/CF)/log(2);
    end
    out.plotFreqs = plotFreqs;

% --------------------------------------------------------------------
% Normalize spike count values for group data plotting; save to outfile.
    
    mM1Iso = squeeze(mM1(:, aindex, dindex, 1));
    
    %If WN is missing, get rid of that index.
    if length(mM1Iso) ~= length(plotFreqs)
        mM1Iso = mM1Iso(2:length(mM1Iso));
    end
    
    % Grab normalized spike counts for group plotting.
    maxSpikes = max(mM1Iso); % (Hey, Stupid... Get this value before you start modifying mM1Iso.)
    for i = 1:length(mM1Iso)
        mM1Iso(i) = mM1Iso(i)/(maxSpikes); % Normalize them to "max"...
        % For now, this is just the max mean spike count *for this
        % amplitude*.
        % Max mean spike count for *all* amplitudes:
        % maxSpikes = max(max(squeeze(mM1(:, :, dindex, 1))))
        i=i+1;
    end
    out.mM1Iso = mM1Iso;
    
    % Save outfile.
    godatadir(expdate,session, filenum)
    outfilename=sprintf('out_IsodB%s-%s-%s',expdate,session,filenum);
    save (outfilename, 'out')
    
    
    
end %dindex
fprintf('\n\n')
    
end
end