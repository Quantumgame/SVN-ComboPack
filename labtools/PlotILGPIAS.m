function PlotILGPIAS(varargin)
%
%plots data from an Interleaved Laser GPIAS Protocol
%separates stimuli embedded in an AO Pulse from isolated stimuli and
% plots a data for each
%
%usage:
%PlotILGPIAS(expdate, session, filename)
%PlotILGPIAS(expdate, session, filename, xlimits)
%PlotILGPIAS(expdate, session, filename, xlimits, ylimits)
%PlotILGPIAS(expdate, session, filename, [xlimits], [ylimits], [trials])
%
%optional argument [trials] is a vector of trials to plot, defaults to all
% default xlimits = [-100 200]
% NOTE xlimits(1) must be <= -100 ms otherwise some functions below will fail
% default ylimits are determined by max(mean(response(alltrials)))

%manually entering known PPASound seamless device restarts

global pref
if isempty(pref); Prefs; end
username=pref.username;

PreStartleWindowms=[-100 0]; % in ms relative to onset of pre-pulse
PostStartleWindowms=[0 100]; % in ms relative to onset of startle-pulse
ISIWindowms=[0 60]; % in ms relative to onset of pre-pulse    %added by APW 3_31_14

trials=[];
trials_specified=0;

if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=[];
    ylimits=[];
elseif nargin==4
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
    xlimits=varargin{4};
    ylimits=[];
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
    trials=varargin{6};
    trials_specified=1;
else
    error('wrong number of arguments');
end

if isempty(xlimits)
    xlimits=[-100 300]; % default x limits for axis
end
if xlimits(1)>-100
    error('xlimits(1) must be <= -100 ms otherwise some functions below will fail')
end

[laseron, laserstart, laserwidth, numpulses, isi]=getPPALaserParams(expdate, session, filenum);
if numpulses ~=1
    warning(sprintf('I only know how to plot a single laser pulse, but PPA Laser has numpulses=%d', numpulses))
end
if  laseron~=1
    warning('PPA Laser was turned off')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lostat1=[]; %discard data after this position (in samples), -1 to skip
% For marking where a cell is lost
if     strcmp(username,'apw') && strcmp(expdate,'062712') && strcmp(session,'001') && strcmp(filenum,'004')
    lostat1=1.0493e7;
    % elseif     strcmp(username,'user') && strcmp(expdate,'date') && strcmp(session,'ses') && strcmp(filenum,'file')
    %     lostat1=###e#;
end

gorawdatadir(expdate,session,filenum)
restart_filename=sprintf('%s-%s-%s-%sseamless_restarts.txt', expdate, username, session, filenum);
try
    restarts=load(restart_filename);
        fprintf('\n loaded restarts  from file %s', restart_filename)
    if length(restarts)==1
        restarts=[];
    elseif length(restarts)>1
        restarts=restarts(2:end);
        %         restarts=restarts-1;
    end
catch
    restarts=[];
end
fprintf('\n%d restarts:', length(restarts))
fprintf(' %d', restarts)
screwup_filename=sprintf('%s-%s-%s-%sscrewups.mat', expdate, username, session, filenum);
try
    godatadir(expdate,session,filenum)
    load(screwup_filename);
    fprintf('\n loaded screwup points from file %s', screwup_filename)
catch
    screwbackpoints=[];
    screwforwardpoints=[];
    fprintf('\n did not find screwup file %s', screwup_filename)
end
fprintf('\n%d, %d screwups:', length(screwbackpoints), length(screwforwardpoints))
fprintf(' %d', screwbackpoints)
fprintf(' back, ')
fprintf(' %d', screwforwardpoints)
fprintf(' forward.')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[D E S D2]=gogetdata(expdate,session,filenum);

event=E.event;
stim=S.nativeScalingStim*double(S.stim);
scaledtrace=D.nativeScaling*double(D.trace) +D.nativeOffset;
scaledtrace2=[];

try scaledtrace2=D2.nativeScaling*double(D2.trace) +D2.nativeOffset; %#ok
end

clear D E S D2

fprintf('\ncomputing tuning curve...');

if 0 %compute AO pulse tuning curve?
    %note that this section is now obsolete if you use PPA Laser and no
    %longer have AO Pulses in your stim protocol
    %we have pretty much shifted the whole lab over to PPA Laser only by
    %now.
    %mw 01.28.14
    
    wb=waitbar(0,'computing tuning curve (aopulses)...');
    %get laser durs
    j=0;
    for i=1:length(event)
        if strcmp(event(i).Type, 'aopulse')
            j=j+1;
            alldurs(j)=event(i).Param.width;
        end
    end
    durs=unique(alldurs); %laser dur
    numdurs=length(durs);
    samprate=1e4;
    if isempty(lostat1); lostat1=length(scaledtrace);end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %first plot the AO pulses, same as PlotAOPulse
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    M1=[];
    % ppdur=[];
    % pdur=[];
    nreps=zeros(numdurs);
    
    %extract the traces into a big matrix M
    
    laserstart=[];
    %get laser durs
    j=0;
    cont=1;
    for i=1:length(event)
        waitbar(i/length(event), wb);
        if (cont)
            if strcmp(event(i).Type, 'aopulse')
                
                pos=event(i).Position_rising;
                start=(pos+xlimits(1)*1e-3*samprate);
                stop=(pos+xlimits(2)*1e-3*samprate)-1;
                region=start:stop;
                if isempty(find(region<0)) % disallow negative start times
                    if stop>lostat1
                        fprintf('\ndiscarding trace')
                    else
                        j=j+1;
                        alldurs(j)=event(i).Param.width;
                        laserstart=[laserstart (event(i+1).soundcardtriggerPos - event(i).Position)/10];
                        
                        dur=event(i).Param.width;
                        dindex= find(durs==dur);
                        nreps(dindex)=nreps(dindex)+1;
                        M1(dindex, nreps(dindex),:)=scaledtrace(region);
                        if ~isempty(scaledtrace2)
                            M2(dindex, nreps(dindex),:)=scaledtrace2(region);
                        end
                        M1stim(dindex, nreps(dindex),:)=stim(region);
                    end
                    if ~isempty(trials)
                        if max(nreps)>max(trials)
                            cont=0; % stop extracting
                            fprintf('\nstopped computing after %d trials', max(nreps))
                        end
                    end
                end
                
            end
        end
    end
    laserbegin=round(mean(laserstart));
    close(wb)
    
    if ~isempty(trials)
        fprintf('\n using only traces %d-%d, discarding others', trials(1), trials(end));
        mM1=mean(M1(:,trials,:), 2);
        if ~isempty(scaledtrace2)
            mM2=mean(M2(:,trials,:), 2);
        end
        mM1stim=mean(M1stim(:,trials,:), 2);
    else
        for dindex=1:numdurs
            mM1(dindex,:)=mean(M1(dindex, 1:nreps(dindex),:), 2);
            if ~isempty(scaledtrace2)
                mM2(dindex,:)=mean(M2(dindex, 1:nreps(dindex),:), 2);
            end
            mM1stim(dindex,:)=mean(M1stim(dindex, 1:nreps(dindex),:), 2);
        end
    end
    
    if ~isempty(trials)
        trialstring=sprintf('%d-%d', trials(1), trials(end));
    else
        trials=1:min(min(min(min(nreps))));
        trialstring=sprintf(' all trials (%d-%d)', trials(1), trials(end));
    end
    
    fprintf(' done\n')
end %if 0 %compute AO pulse tuning curve

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the tuning curve, same as PlotASR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wb=waitbar(0,'computing tuning curve (sounds)...');
samprate=1e4;
%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'GPIAS')
        j=j+1;
        allsoas(j)=event(i).Param.soa;
        allgapdurs(j)=event(i).Param.gapdur;
        allgapdelays(j)=event(i).Param.gapdelay;
        allnoisefreqs(j)=event(i).Param.center_frequency;
        allpulseamps(j)=event(i).Param.pulseamp;
        allpulsedurs(j)=event(i).Param.pulsedur;
        allnoiseamps(j)=event(i).Param.amplitude;
        allnoiselower_frequencies(j)=event(i).Param.lower_frequency;
        allnoiseupper_frequencies(j)=event(i).Param.upper_frequency;
        %        allAOPulseOns(j)=event(i).Param.AOPulseOn;
    end
end

M1=[];
gapdurs=unique(allgapdurs);
pulsedurs=unique(allpulsedurs);
soas=unique(allsoas);
gapdelays=unique(allgapdelays);
pulseamps=unique(allpulseamps);
pulsedurs=unique(allpulsedurs);
noisefreqs=unique(allnoisefreqs);
noiseamps=unique(allnoiseamps);
noiselower_frequencies=unique(allnoiselower_frequencies);
noiseupper_frequencies=unique(allnoiseupper_frequencies);
numgapdurs=length(gapdurs);
numpulseamps=length(pulseamps);
nreps=zeros( numgapdurs, numpulseamps);
%numLaserOntrials=sum(allAOPulseOns);
%numLaserOfftrials=sum(~allAOPulseOns);
%fprintf('\n\nfound %d Laser On trials, %d Laser Off trials', numLaserOntrials, numLaserOfftrials)

if length(noisefreqs)~=1
    error('not able to handle multiple noisefreqs')
end
if length(noiselower_frequencies)~=1
    error('not able to handle multiple noiselower_frequencies')
end
if length(noiseupper_frequencies)~=1
    error('not able to handle multiple noiseupper_frequencies')
end
if length(noiseamps)~=1
    error('not able to handle multiple noiseamps')
end
if length(gapdelays)~=1
    error('not able to handle multiple gapdelays')
end
if length(pulsedurs)~=1
    error('not able to handle multiple pulsedurs')
end
if length(soas)~=1
    error('not able to handle multiple soas')
end

noiseamp=noiseamps;
soa=soas;
pulsedur=pulsedurs;
gapdelay=gapdelays;
noisefreq=noisefreqs;
noiseupper_frequency=noiseupper_frequencies;
noiselower_frequency=noiselower_frequencies;
noiseBW=log2(noiseupper_frequency/noiselower_frequency);

%preallocate so that if ON and OFF do not have identical gapdurs, it won't
%be a problem. Leave nreps blank since that needs to be accumulated for
%each condition.
M1ONtc=zeros(numgapdurs, numpulseamps, 1,  ((xlimits(2)+gapdelay)*1e-3*samprate)-((xlimits(1)+gapdelay)*1e-3*samprate));
M2ONtc=M1ONtc;
M1ONtcstim=M1ONtc;
M1OFFtc=M1ONtc;
M2OFFtc=M1ONtc;
M1OFFtcstim=M1ONtc;

mM1ONtc=[];
mM2ONtc=[];
mM1ONtcstim=[];
mM1OFFtc=[];
mM2OFFtc=[];
mM1OFFtcstim=[];

medM1ONtc=[];
medM2ONtc=[];
medM1ONtcstim=[];
medM1OFFtc=[];
medM2OFFtc=[];
medM1OFFtcstim=[];

rsM1ONtc=[];
rsM2ONtc=[];
rsM1ONtcstim=[];
rsM1OFFtc=[];
rsM2OFFtc=[];
rsM1OFFtcstim=[];

nrepsON=zeros(numgapdurs, numpulseamps);
nrepsOFF=zeros(numgapdurs, numpulseamps);

%extract the traces into a big matrix M

numrestarts=0;
%mw 070114 testing
numscrewbacks=0;
numscrewforwards=0;
abort=0;
for i=1:length(event)
    %     if i==361
    %         %keyboard
    %     end

    %correct for any ppasound restarts
    if any(i==(restarts))
        numrestarts=numrestarts+1;
        fprintf('\ndiscarding event %d due to PPA restart', i)
    end
    
    %go back for any screwups mw 07012014
    if any(i==screwbackpoints)
        numscrewbacks=numscrewbacks+1;
    elseif any(i==screwforwardpoints)
        numscrewforwards=numscrewforwards+1;
    end
    
    waitbar( i/length(event), wb);
    if strcmp(event(i).Type, 'GPIAS') & ~any([i==(restarts-1) i==(restarts-2)])
        if ~abort
            if isfield(event(i), 'soundcardtriggerPos')
                
                %go back numrestarts, skipping any aopulses
                numaopulsestoskip=0;
                for k=1:numrestarts
                    if strcmp(event(i-k).Type, 'aopulse')
                        numaopulsestoskip=numaopulsestoskip+1;
                    end
                end                
                pos=event(i-numrestarts-numaopulsestoskip-numscrewbacks+numscrewforwards).soundcardtriggerPos;
                if isempty(pos) & i>1
                    %attempting to catch situations where stimprotocol played
                    %all stimuli, but user clicked run (stopped recording)
                    %before seamless sounds stopped playing (ppasound buffer
                    %was not emptied yet). In this case hardware trigs were
                    %recorded for all stimuli, but soundcard trigs will be
                    %empty after end of file (when run was clicked). The right
                    %thing to do here is abort processing at i when
                    %soundcardtrigs become empty.
                    fprintf('\nI think user stopped recording before all gap stimuli were played.')
                    fprintf('\naborting processing at event %d/%d because soundcard trigs were empty.', i, length(event))
                    abort=1;
                    break
                end
                pr=event(i).Position_rising;
                Delta(i)=pos-pr; %how much the actual sounds lagged after the request (HW trig). in samples.
            else
                pos=event(i).Position_rising;
            end
            
            start=(pos+(xlimits(1)+gapdelay)*1e-3*samprate);
            stop=(pos+(xlimits(2)+gapdelay)*1e-3*samprate)-1;
            
            region=start:stop;
            if isempty(find(region<0)) % disallow negative start times
                if stop>lostat1
                    fprintf('\ndiscarding trace')
                else
                    gapdur=event(i).Param.gapdur;
                    gdindex= find(gapdur==gapdurs);
                    pulseamp=event(i).Param.pulseamp;
                    paindex= find(pulseamp==pulseamps);
                    if isfield(event(i).Param, 'AOPulseOn')
                        aopulseon=event(i).Param.AOPulseOn;
                    else
                        aopulseon=0;
                    end
                    if aopulseon
                        nrepsON(gdindex, paindex)=nrepsON(gdindex, paindex)+1;
                        M1ONtc(gdindex, paindex, nrepsON(gdindex, paindex),:)=scaledtrace(region);
                        M2ONtc(gdindex, paindex, nrepsON(gdindex, paindex),:)=scaledtrace2(region);
                        M1ONtcstim(gdindex, paindex, nrepsON(gdindex, paindex),:)=stim(region);
                    else
                        nrepsOFF(gdindex, paindex)=nrepsOFF(gdindex, paindex)+1;
                        M1OFFtc(gdindex, paindex, nrepsOFF(gdindex, paindex),:)=scaledtrace(region);
                        M2OFFtc(gdindex, paindex, nrepsOFF(gdindex, paindex),:)=scaledtrace2(region);
                        M1OFFtcstim(gdindex, paindex, nrepsOFF(gdindex, paindex),:)=stim(region);
                    end
                end
            end
        end
    end
end
figure
plot(Delta/samprate, '-o')
title('soundcardtrig lag behind HW triggers')
ylabel('seconds')

for paindex=1:numpulseamps;
    for gdindex=1:numgapdurs;
        nron=nrepsON(gdindex, paindex);
        nroff=nrepsOFF(gdindex, paindex);
        fprintf('\ngap %d: ',gapdurs(gdindex))
        fprintf('repsON: %d, ', nron)
        fprintf('nrepsOFF: %d', nroff)
    end
end
%find optimal ylimits
% if isempty(ylimits) || ylimits<0
%     ylimits=[0 0];
%     for ppaindex=1:numprepulseamps
%         for nnrepindex=1:nrepsOFF(ppaindex)
%             trace1=squeeze(M1ONtc(ppaindex,nrepsOFF(ppaindex), :));
%             trace1=trace1-median(trace1(1:1000));
%             if min(trace1)<ylimits(1); ylimits(1)=min(trace1);end
%             if max(trace1)>ylimits(2); ylimits(2)=max(trace1);end
%         end
%         for nnrepindex=1:nrepsON(ppaindex)
%             trace1=squeeze(M1OFFtc(ppaindex,nrepsON(ppaindex), :));
%             trace1=trace1-median(trace1(1:1000));
%             if min(trace1)<ylimits(1); ylimits(1)=min(trace1);end
%             if max(trace1)>ylimits(2); ylimits(2)=max(trace1);end
%         end
%     end
% end
if ~isempty(M1OFFtc)
    ylimits(1)=min(M1OFFtc(:));
    ylimits(2)=max(M1OFFtc(:));
elseif ~isempty(M1ONtc)
    ylimits(1)=min(M1ONtc(:));
    ylimits(2)=max(M1ONtc(:));
else
    error('WTF? this should never happen')
end
%adjust ylimits a bit
% ylimits(1)=ylimits(1)-2*diff(ylimits);
% ylimits(2)=ylimits(2)+2*diff(ylimits);

close(wb)

if trials_specified
    %     fprintf('\n using only traces %s, discarding others', trialstring);
    mM1ONtc=mean(M1ONtc(:,:,trials,:), 3);
    mM1OFFtc=mean(M1OFFtc(:,:,trials,:), 3);
    mM2ONtc=mean(M2ONtc(:,:,trials,:), 3);
    mM2OFFtc=mean(M2OFFtc(:,:,trials,:), 3);
    mM1ONtcstim=mean(M1ONtcstim(:,:,trials,:), 3);
    mM1OFFtcstim=mean(M1OFFtcstim(:,:,trials,:), 3);
else
    for paindex=1:numpulseamps;
        for gdindex=1:numgapdurs;
            if ~isempty (M1ONtc) %allow for no-laser datafiles
                mM1ONtc(gdindex, paindex,:)=mean(M1ONtc(gdindex, paindex, 1:nrepsON(gdindex, paindex),:), 3);
                mM2ONtc(gdindex, paindex,:)=mean(M2ONtc(gdindex, paindex, 1:nrepsON(gdindex, paindex),:), 3);
                mM1ONtcstim(gdindex, paindex,:)=mean(M1ONtcstim(gdindex, paindex, 1:nrepsON(gdindex, paindex),:), 3);
            end
            if ~isempty (M1OFFtc) %allow for laser-only datafiles
                mM1OFFtc(gdindex, paindex,:)=mean(M1OFFtc(gdindex, paindex, 1:nrepsOFF(gdindex, paindex),:), 3);
                mM2OFFtc(gdindex, paindex,:)=mean(M2OFFtc(gdindex, paindex, 1:nrepsOFF(gdindex, paindex),:), 3);
                mM1OFFtcstim(gdindex, paindex,:)=mean(M1OFFtcstim(gdindex, paindex, 1:nrepsOFF(gdindex, paindex),:), 3);
            end
            
            %            rsM1ONtc(ppaindex,:)=mean(sqrt(M1ONtc(ppaindex, 1:nrepsON(ppaindex),:).^2), 2);
            %            rsM2ONtc(ppaindex,:)=mean(sqrt(M2ONtc(ppaindex, 1:nrepsON(ppaindex),:).^2), 2);
            %            rsM1ONtcstim(ppaindex,:)=mean(sqrt(M1ONtcstim(ppaindex, 1:nrepsON(ppaindex),:).^2), 2);
            %            rsM1OFFtc(ppaindex,:)=mean(sqrt(M1OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:).^2), 2);
            %            rsM2OFFtc(ppaindex,:)=mean(sqrt(M2OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:).^2), 2);
            %            rsM1OFFtcstim(ppaindex,:)=mean(sqrt(M1OFFtcstim(ppaindex, 1:nrepsOFF(ppaindex),:).^2), 2);
            
            %            medM1ONtc(ppaindex,:)=median(M1ONtc(ppaindex, 1:nrepsON(ppaindex),:), 2);
            %            medM2ONtc(ppaindex,:)=median(M2ONtc(ppaindex, 1:nrepsON(ppaindex),:), 2);
            %            medM1ONtcstim(ppaindex,:)=median(M1ONtcstim(ppaindex, 1:nrepsON(ppaindex),:), 2);
            %            medM1OFFtc(ppaindex,:)=median(M1OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:), 2);
            %            medM2OFFtc(ppaindex,:)=median(M2OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:), 2);
            %            medM1OFFtcstim(ppaindex,:)=median(M1OFFtcstim(ppaindex, 1:nrepsOFF(ppaindex),:), 2);
        end
    end
end
%convert Pre/PostStartleWindow to samples:
PreStartleWindow=1+(PreStartleWindowms-xlimits(1))*samprate/1000;
PostStartleWindow=(PostStartleWindowms-xlimits(1)+soa)*samprate/1000;
ISIWindow=(ISIWindowms-xlimits(1))*samprate/1000; %added by APW 3_31_14
fprintf('\nPreStartleWindow: %d %d',PreStartleWindow)
fprintf('\nPostStartleWindow: %d %d', PostStartleWindow)
fprintf('\nISIWindow: %d %d', ISIWindow)

% Plot the actual trace with mean trace overlayed
% Separated into 2 figures with laser OFF/ON
if true
    if ~isempty (mM1OFFtc)
        
        %plot the mean Laser OFF tuning curve
        for paindex=1:numpulseamps
            figure;
            p=0;
            subplot1(numgapdurs,1)
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                
                
                offset=10*std(M1OFFtc(:));
                % plot each trial in blue
                for i=1:nrepsOFF(gdindex, paindex)
                    trace1=squeeze(M1OFFtc(gdindex, paindex,i,:));
                    trace1=trace1-median(trace1(1:1000));
                    
                    t=1:length(trace1);
                    t=t/10;
                    t=t+xlimits(1);
                    plot(t, trace1+i*offset, 'b');
                end
                
                % plot the mean trace in red
                trace1=squeeze(mM1OFFtc(gdindex, paindex,:));
                trace1=trace1-median(trace1(1:1000));
                trace2=squeeze(mM2OFFtc(gdindex, paindex,:)); %laser pulse
                trace2=trace2-median(trace2(1:1000));
                stim=squeeze(mM1OFFtcstim(gdindex, paindex,:));
                stim=stim-median(stim(1:1000));
                stim=stim./max(abs(stim));
                
                t=1:length(trace1);
                t=t/10;
                t=t+xlimits(1);
                offset=2*std(trace1);
                plot(t, trace1, 'r', t, offset*stim-offset, 'm', t, trace2, 'c');
                
                %ylim([ylimits(1)-3*offset ylimits(2)])
                xlim(xlimits)
                ylabel(sprintf('%d ms',gapdurs(gdindex)));
                text(xlimits(1)+10,ylimits(2)/2,sprintf('n=%d',nrepsOFF(gdindex, paindex)))
                %axis off
                
            end
            subplot1(1)
            h=title(sprintf('Laser OFF, %s-%s-%s', expdate, session, filenum));
            subplot1(numgapdurs)
            xlabel('Time (ms)');
        end
        
        %plot the mean Laser ON tuning curve
        if ~isempty (mM1ONtc)
            figure;
            p=0;
            subplot1(numgapdurs,1)
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                
                % add the stimulus in magenta
                %         if length(prepulsedurs)~=1
                %             warning('This function only knows how to plot one prepulsedur') %#ok
                %         elseif length(prepulsedurs)==1
                %             line([0 prepulsedurs],[0 0],'color','m','linewidth',10);
                %         end
                
                % plot each trial in blue
                for i=1:nrepsON(gdindex, paindex)
                    trace1=squeeze(M1ONtc(gdindex, paindex,i,:));
                    trace1=trace1-median(trace1(1:1000));
                    
                    t=1:length(trace1);
                    t=t/10;
                    t=t+xlimits(1);
                    plot(t, trace1+i*offset, 'b');
                end
                
                
                % plot the mean trace in red
                trace1=squeeze(mM1ONtc(gdindex, paindex,:));
                trace1=trace1-median(trace1(1:1000));
                stim=squeeze(mM1ONtcstim(gdindex, paindex,:));
                stim=stim-median(stim(1:1000));
                trace2=squeeze(mM2ONtc(gdindex, paindex,:)); %laser pulse
                trace2=trace2-median(trace2(1:1000));
                trace2=trace2./max(M2ONtc(:));
                
                t=1:length(trace1);
                t=t/10;
                t=t+xlimits(1);
                offset=2*std(trace1);
                plot(t, trace1, 'r', t, offset*stim-offset, 'm', t, offset*trace2-2*offset, 'c');
                
                % add the laser in cyan
                try
                    line([laserstart-gapdelay laserstart-gapdelay+laserwidth],-2.5*offset*[1 1],'color','c','linewidth',5);   % AW commented out to enable no laser gap detection plots
                end
                
                %ylim([ylimits(1)-3*offset ylimits(2)])
                xlim(xlimits)
                ylabel(sprintf('%d ms',gapdurs(gdindex)));
                text(xlimits(1)+10,ylimits(2)/2,sprintf('n=%d',nrepsOFF(gdindex, paindex)))
                %axis off
                
            end
            subplot1(1)
            h=title(sprintf('Laser ON, %s-%s-%s', expdate, session, filenum));
            subplot1(numgapdurs)
            xlabel('Time (ms)');
            
            pos=get(gcf, 'pos');
            pos(1)=pos(1)+pos(3); %shift ON to right
            set(gcf, 'pos', pos)
        end
    end
    
    % Plot the integration of the abs(trace)
    % Seperated into 2 figures with laser OFF/ON
    if true
        
        LaserOFFstartle=nan(numgapdurs, numpulseamps,max(nrepsOFF));
        LaserONstartle=nan(numgapdurs, numpulseamps,max(nrepsON));
        
        %plot the mean Laser OFF tuning curve
        if ~isempty (mM1OFFtc)
            
            figure;
            p=0;
            subplot1(numgapdurs,1)
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                
                
                
                % plot each trial in blue
                prestartle=[];
                poststartle=[];
                ISIamplitude=[];
                %note: PreStartleWindow, PostStartleWindow and ISIWindow set at top
                sumtrace=0;
                for i=1:nrepsOFF(gdindex, paindex)
                    trace1=squeeze(M1OFFtc(gdindex, paindex,i,:));
                    trace1=trace1-median(trace1(1:1000));
                    trace1=abs(trace1);
                    sumtrace=sumtrace+trace1;
                    sumprestartle=sum(trace1(PreStartleWindow(1):PreStartleWindow(2)));
                    prestartle=[prestartle sumprestartle];
                    sumstartle=sum(trace1(PostStartleWindow(1):PostStartleWindow(2)));
                    poststartle=[poststartle sumstartle];
                    sumISIamplitude=sum(trace1(ISIWindow(1):ISIWindow(2)));%added by APW 3_31_14
                    ISIamplitude=[ISIamplitude sumISIamplitude];%added by APW 3_31_14
                    clear t sumprestartle sumstartle sumISIstartle %added by APW 3_31_14
                end
                if nrepsOFF(gdindex, paindex)>0
                    % add the stimulus in magenta
                    line([0 gapdurs(gdindex)],[0 0],'color','m','linewidth',10);
                    
                    % add the startle stimulus in magenta
                    line([soa soa+pulsedur],[0 0],'color','m','linewidth',10);
                    
                    sumtrace=sumtrace./nrepsOFF(gdindex, paindex);
                    trace2=[0 sumtrace' 0];
                    
                    t=1:length(trace1);
                    t=t/10;
                    t=t+xlimits(1);
                    t=[t(1) t t(end)];
                    patch(t,trace2,'b','edgecolor','b')
                    
                    
                    if length(prestartle)==length(poststartle)
                        [H,P,CI,STATS] = ttest(prestartle,poststartle,[],'left');
                    else
                        [H,P,CI,STATS] = ttest2(prestartle,poststartle,[],'left');
                    end
                    LaserOFFstartle(gdindex, paindex,1:length(poststartle))=poststartle;
                    LaserOFFprestartle(gdindex, paindex,1:length(prestartle))=prestartle;
                    LaserOFFISIamplitude(gdindex, paindex,1:length(ISIamplitude))=ISIamplitude; %added by APW 3_31_14
                    
                    % plot the mean trace in red
                    trace1=squeeze(mM1OFFtc(gdindex, paindex,:));
                    trace1=trace1-median(trace1(1:1000));
                    t=1:length(trace1);
                    t=t/10;
                    t=t+xlimits(1);
                    plot(t, abs(trace1), 'r');
                    
                    % add the actual integration windows in grey
                    plot(t([PreStartleWindow(1) PreStartleWindow(2)]), -.1*diff(ylimits)+0*t([PreStartleWindow(1) PreStartleWindow(2)]), 'color',[.8 .8 .8], 'linewidth', 4);
                    plot(t([PostStartleWindow(1) PostStartleWindow(2)]), -.1*diff(ylimits)+0*t([PostStartleWindow(1) PostStartleWindow(2)]), 'color',[.8 .8 .8], 'linewidth', 4);
                    %         ch=get(gca, 'children');
                    %         set(gca, 'children', ch([3:length(ch)-1 1 2 length(ch)]));
                    
                    %ylim(ylimits)
                    xlim(xlimits)
                    ylabel(sprintf('%d ms',gapdurs(gdindex)));
                    yl=ylim;
                    text(xlimits(1)+10,yl(2)/2,sprintf('n=%d\np = %.3f',nrepsOFF(gdindex, paindex),P))
                    text(xlimits(1)+10,yl(1)/2,sprintf('Pre-startle mean = %.1f +/- %.1f\n(%d:%d samples)',mean(prestartle),std(prestartle), PreStartleWindow(1),PreStartleWindow(2)))
                    text(50,yl(1)/2,sprintf('Post-startle mean = %.1f +/- %.1f\n(%d:%d samples)',mean(poststartle),std(poststartle), PostStartleWindow(1),PostStartleWindow(2)))
                    
                    clear prestartle poststartle
                else %nreps==0, missing data for this gapdur
                    LaserOFFstartle(gdindex, paindex,1:max(nrepsOFF(:)))=nan;
                    LaserOFFprestartle(gdindex, paindex,1:max(nrepsOFF(:)))=nan;
                    LaserOFFISIamplitude(gdindex, paindex,1:max(nrepsOFF(:)))=nan;%added by APW 3_31_14
                    
                end
            end
            subplot1(1)
            h=title(sprintf('Laser OFF -- Integration, %s-%s-%s', expdate, session, filenum));
            subplot1(numgapdurs)
            xlabel('Time (ms)');
        end
        %plot the mean Laser ON tuning curve
        if ~isempty (mM1ONtc)
            figure;
            p=0;
            subplot1(numgapdurs,1)
            for gdindex=1:numgapdurs
                p=p+1;
                subplot1(p)
                hold on
                
                % plot each trial in blue
                prestartle=[];
                poststartle=[];
                sumtrace=0;
                for i=1:nrepsON(gdindex, paindex)
                    trace1=squeeze(M1ONtc(gdindex, paindex,i,:));
                    trace1=trace1-median(trace1(1:1000));
                    trace1=abs(trace1);
                    sumtrace=sumtrace+trace1;
                    sumprestartle=sum(trace1(PreStartleWindow(1):PreStartleWindow(2)));
                    prestartle=[prestartle sumprestartle];
                    sumstartle=sum(trace1(PostStartleWindow(1):PostStartleWindow(2)));
                    poststartle=[poststartle sumstartle];
                    clear t sumprestartle sumstartle
                end
                if nrepsON(gdindex, paindex)>0
                try
                    line([laserstart-gapdelay laserstart-gapdelay+laserwidth],-2.5*offset*[1 1],'color','c','linewidth',5);   % AW commented out to enable no laser gap detection plots
                end
                    
                    % add the gap stimulus in magenta
                    line([0 gapdurs(gdindex)],[0 0],'color','m','linewidth',10);
                    
                    % add the startle stimulus in magenta
                    if length(pulsedurs)~=1
                        warning('This function only knows how to plot one pulsedur') %#ok
                    elseif length(pulsedurs)==1
                        line([soa soa+pulsedurs],[0 0],'color','m','linewidth',10);
                    end
                    
                    sumtrace=sumtrace./nrepsON(gdindex, paindex);
                    trace2=[0 sumtrace' 0];
                    
                    t=1:length(trace1);
                    t=t/10;
                    t=t+xlimits(1);
                    t=[t(1) t t(end)];
                    patch(t,trace2,'b','edgecolor','b')
                    if length(prestartle)==length(poststartle)
                        [H,P,CI,STATS] = ttest(prestartle,poststartle,[],'left');
                    else
                        [H,P,CI,STATS] = ttest2(prestartle,poststartle,[],'left');
                    end
                    LaserONstartle(gdindex, paindex,1:length(poststartle))=poststartle;
                    LaserONprestartle(gdindex, paindex,1:length(prestartle))=prestartle;
                    LaserONISIamplitude(gdindex, paindex,1:length(ISIamplitude))=ISIamplitude; %added by APW 3_31_14
                    
                    % plot the mean trace in red
                    trace1=squeeze(mM1ONtc(gdindex, paindex,:));
                    trace1=trace1-median(trace1(1:1000));
                    t=1:length(trace1);
                    t=t/10;
                    t=t+xlimits(1);
                    plot(t, abs(trace1), 'r');
                    
                    % add the actual integration windows in grey
                    plot(t([PreStartleWindow(1) PreStartleWindow(2)]), -.1*diff(ylimits)+0*t([PreStartleWindow(1) PreStartleWindow(2)]), 'color',[.8 .8 .8], 'linewidth', 4);
                    plot(t([PostStartleWindow(1) PostStartleWindow(2)]), -.1*diff(ylimits)+0*t([PostStartleWindow(1) PostStartleWindow(2)]), 'color',[.8 .8 .8], 'linewidth', 4);
                    
                    %ylim(ylimits)
                    xlim(xlimits)
                    ylabel(sprintf('%d dB',gapdurs(gdindex)));
                    
                    yl=ylim;
                    text(xlimits(1)+10,yl(2)/2,sprintf('n=%d\np = %.3f',nrepsON(gdindex, paindex),P))
                    text(xlimits(1)+10,yl(1)/2,sprintf('Pre-startle mean = %.1f +/- %.1f\n(%d:%d samples)',mean(prestartle),std(prestartle), PreStartleWindow(1),PreStartleWindow(2)))
                    text(50,yl(1)/2,sprintf('Post-startle mean = %.1f +/- %.1f\n(%d:%d samples)',mean(poststartle),std(poststartle), PostStartleWindow(1),PostStartleWindow(2)))
                    
                else %nreps==0, missing data for this gapdur
                    LaserONstartle(gdindex, paindex,1:max(nrepsON(:)))=nan;
                    LaserONprestartle(gdindex, paindex,1:max(nrepsON(:)))=nan;
                    LaserONISIamplitude(gdindex, paindex,1:max(nrepsON(:)))=nan; %added by APW 3_31_14
                end
                
            end
            subplot1(1)
            h=title(sprintf('Laser ON -- Integration, %s-%s-%s', expdate, session, filenum));
            subplot1(numgapdurs)
            xlabel('Time (ms)');
            
            pos=get(gcf, 'pos');
            pos(1)=pos(1)+pos(3); %shift ON to right
            set(gcf, 'pos', pos)
            
            for gdindex=1:numgapdurs
                
                if sum(~isnan(LaserONstartle(gdindex, paindex,:)))==sum(~isnan(LaserOFFstartle(gdindex, paindex,:)))
                    [H,P,CI,STATS] = ttest(LaserONstartle(gdindex, paindex,:),LaserOFFstartle(gdindex, paindex,:));
                    if H==0
                        fprintf('\nAt %d ms, the laser did not affect the startle (ttest: p = %.3f)',gapdurs(gdindex),P);
                    elseif H==1
                        fprintf('\nAt %d ms, the laser SIGNIFICANTLY changed the startle (ttest: p = %.3f)',gapdurs(gdindex),P);
                    end
                else
                    [H,P,CI,STATS] = ttest2(LaserONstartle(gdindex, paindex,:),LaserOFFstartle(gdindex, paindex,:));
                    if H==0
                        fprintf('\nAt %d ms, the laser did not affect the startle (ttest2: p = %.3f)',gapdurs(gdindex),P);
                    elseif H==1
                        fprintf('\nAt %d ms, the laser SIGNIFICANTLY changed the startle (ttest2: p = %.3f)',gapdurs(gdindex),P);
                    end
                end
            end
        end
    end
    
    figure;hold on
    errorbar(nanmean(squeeze(LaserOFFstartle(:,paindex,:))'),nanstd(squeeze(LaserOFFstartle(:,paindex,:))')/sqrt(size(LaserOFFstartle,3)), 'k-o')
    set(gca, 'xtick', 1:numgapdurs)
    set(gca, 'xticklabel', gapdurs)
    %errorbar(mean(LaserONstartle'),std(LaserONstartle')/sqrt(size(LaserONstartle,2)), 'c-o')
    errorbar(nanmean(squeeze(LaserONstartle(:,paindex,:))'),nanstd(squeeze(LaserONstartle(:,paindex,:))')/sqrt(size(LaserONstartle,3)), 'c-o')
    set(gca, 'xtick', 1:numgapdurs)
    set(gca, 'xticklabel', gapdurs)
    title ('LaserON/OFF startle')
    xlabel('gap duration')
    ylabel('startle response +- sem')
    legend('Laser OFF', 'Laser ON')
    fprintf('\n\n')
    
end

txtfilename=sprintf('%s-%s-%sout.txt', expdate, session, filenum);
fid=fopen(txtfilename, 'wt');
for paindex=1:numpulseamps
    fprintf(fid, '\npulse amp: %d', pulseamps(paindex));
    
    fprintf(fid, '\ngap durs:');
    for gdindex=1:numgapdurs
        fprintf(fid, '\t%d', gapdurs(gdindex));
    end
    fprintf(fid, '\n');
    for gdindex=1:numgapdurs
        fprintf(fid, 'pre\tISI\tpost\t', gapdurs(gdindex));
    end
    
    fprintf(fid, '\nLaserON\n');
    
    for rep= 1:size(LaserONstartle, 3)
        for gdindex=1:numgapdurs
            fprintf(fid, '%f\t', LaserONprestartle(gdindex, paindex, rep));
            fprintf(fid, '%f\t', LaserONISIamplitude(gdindex, paindex, rep));
            fprintf(fid, '%f\t', LaserONstartle(gdindex, paindex, rep));
        end
        fprintf(fid, '\n');
    end
    
    fprintf(fid, '\nLaserOFF\n');
    
    for rep= 1:size(LaserOFFstartle, 3)
        for gdindex=1:numgapdurs
            fprintf(fid, '%f\t', LaserOFFprestartle(gdindex, paindex, rep));
            fprintf(fid, '%f\t', LaserOFFISIamplitude(gdindex, paindex, rep));
            fprintf(fid, '%f\t', LaserOFFstartle(gdindex, paindex, rep));
        end
        fprintf(fid, '\n');
    end
    fprintf(fid, '\n');
    fprintf(fid, '\n');
    
end
fclose(fid);







