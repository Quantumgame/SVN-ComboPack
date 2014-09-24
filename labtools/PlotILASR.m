function PlotILASR(varargin)
%
%plots data from an Interleaved Laser ASR Protocol
%separates tones embedded in an AO Pulse from isolated tones/clicks and
% plots a tuning curve for each
%
%usage:
%PlotILASR(expdate, session, filename)
%PlotILASR(expdate, session, filename, xlimits)
%PlotILASR(expdate, session, filename, xlimits, ylimits)
%PlotILASR(expdate, session, filename, [xlimits], [ylimits], [trials])
%
%optional argument [trials] is a vector of trials to plot, defaults to all
% default xlimits = [-100 200]
% NOTE xlimits(1) must be <= -100 ms otherwise some functions below will fail
% default ylimits are determined by max(mean(response(alltrials)))

global pref
if isempty(pref); Prefs; end
username=pref.username;

PreStartleWindowms=[-100 0]; % in ms relative to onset of pre-pulse
PostStartleWindowms=[0 100]; % in ms relative to onset of startle-pulse


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
    xlimits=[-100 200]; % default x limits for axis
end
if xlimits(1)>-100
    error('xlimits(1) must be <= -100 ms otherwise some functions below will fail')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lostat1=[]; %discard data after this position (in samples), -1 to skip
% For marking where a cell is lost
if     strcmp(username,'apw') && strcmp(expdate,'062712') && strcmp(session,'001') && strcmp(filenum,'004')
    lostat1=1.0493e7;
% elseif     strcmp(username,'user') && strcmp(expdate,'date') && strcmp(session,'ses') && strcmp(filenum,'file')
%     lostat1=###e#;
end
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first plot the AO pulses, same as PlotAOPulse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the tuning curve, same as PlotASR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wb=waitbar(0,'computing tuning curve (sounds)...');

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'ASR')
        j=j+1;
        allprepulseamps(j)=event(i).Param.prepulseamp;
        allprepulsedur(j)=event(i).Param.prepulsedur;
        allpulsedur=event(i).Param.pulsedur;
        allsoas(j)=event(i).Param.soa;
        pulseamp(j)=event(i).Param.pulseamp;
    end
end

M1=[];
prepulseamps=unique(allprepulseamps);
numprepulseamps=length(prepulseamps);
prepulsedurs=unique(allprepulsedur);
pulsedurs=unique(allpulsedur);
pulseamps=unique(pulseamp);
soa=unique(allsoas);
if length(soa)>1 error('cannot handle multiple soas');end

M1ONtc=[];
M2ONtc=[];
M1ONtcstim=[];
M1OFFtc=[];
M2OFFtc=[];
M1OFFtcstim=[];

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

nrepsON=zeros(1, numprepulseamps);
nrepsOFF=zeros(1, numprepulseamps);

%extract the traces into a big matrix M

for i=1:length(event)
    waitbar( i/length(event), wb);
    if strcmp(event(i).Type, 'ASR')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
        else
            pos=event(i).Position_rising;
        end
        
        start=(pos+xlimits(1)*1e-3*samprate);
        stop=(pos+xlimits(2)*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) % disallow negative start times
            if stop>lostat1
                fprintf('\ndiscarding trace')
            else
                prepulseamp=event(i).Param.prepulseamp;
                
                dur=event(i).Param.prepulsedur;
                aopulseon=event(i).Param.AOPulseOn;
                ppaindex=find(prepulseamp==prepulseamps);
                if aopulseon
                    nrepsON(ppaindex)=nrepsON(ppaindex)+1;
                    M1ONtc(ppaindex, nrepsON(ppaindex),:)=scaledtrace(region);
                    M2ONtc(ppaindex, nrepsON(ppaindex),:)=scaledtrace2(region);
                    M1ONtcstim(ppaindex, nrepsON(ppaindex),:)=stim(region);
                else
                    nrepsOFF(ppaindex)=nrepsOFF(ppaindex)+1;
                    M1OFFtc(ppaindex, nrepsOFF(ppaindex),:)=scaledtrace(region);
                    M2OFFtc(ppaindex, nrepsOFF(ppaindex),:)=scaledtrace2(region);
                    M1OFFtcstim(ppaindex, nrepsOFF(ppaindex),:)=stim(region);
                end
            end
        end
    end
end

%find optimal ylimits
if isempty(ylimits) || ylimits<0
    ylimits=[0 0];
    for ppaindex=1:numprepulseamps
        for nnrepindex=1:nrepsOFF(ppaindex)
            trace1=squeeze(M1ONtc(ppaindex,nrepsOFF(ppaindex), :));
            trace1=trace1-median(trace1(1:1000));
            if min(trace1)<ylimits(1); ylimits(1)=min(trace1);end
            if max(trace1)>ylimits(2); ylimits(2)=max(trace1);end
        end
        for nnrepindex=1:nrepsON(ppaindex)
            trace1=squeeze(M1OFFtc(ppaindex,nrepsON(ppaindex), :));
            trace1=trace1-median(trace1(1:1000));
            if min(trace1)<ylimits(1); ylimits(1)=min(trace1);end
            if max(trace1)>ylimits(2); ylimits(2)=max(trace1);end
        end
    end
end
%adjust ylimits a bit
ylimits(1)=ylimits(1)-2*diff(ylimits);
ylimits(2)=ylimits(2)+2*diff(ylimits);

close(wb)

if trials_specified
    %     fprintf('\n using only traces %s, discarding others', trialstring);
    mM1ONtc=mean(M1ONtc(:,trials,:), 2);
    mM1OFFtc=mean(M1OFFtc(:,trials,:), 2);
    mM2ONtc=mean(M2ONtc(:,trials,:), 2);
    mM2OFFtc=mean(M2OFFtc(:,trials,:), 2);
    mM1ONtcstim=mean(M1ONtcstim(:,trials,:), 2);
    mM1OFFtcstim=mean(M1OFFtcstim(:,trials,:), 2);
else
    for ppaindex=1:numprepulseamps
        mM1ONtc(ppaindex,:)=mean(M1ONtc(ppaindex, 1:nrepsON(ppaindex),:), 2);
        mM2ONtc(ppaindex,:)=mean(M2ONtc(ppaindex, 1:nrepsON(ppaindex),:), 2);
        mM1ONtcstim(ppaindex,:)=mean(M1ONtcstim(ppaindex, 1:nrepsON(ppaindex),:), 2);
        mM1OFFtc(ppaindex,:)=mean(M1OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:), 2);
        mM2OFFtc(ppaindex,:)=mean(M2OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:), 2);
        mM1OFFtcstim(ppaindex,:)=mean(M1OFFtcstim(ppaindex, 1:nrepsOFF(ppaindex),:), 2);
        
%         rsM1ONtc(ppaindex,:)=mean(sqrt(M1ONtc(ppaindex, 1:nrepsON(ppaindex),:).^2), 2);
%         rsM2ONtc(ppaindex,:)=mean(sqrt(M2ONtc(ppaindex, 1:nrepsON(ppaindex),:).^2), 2);
%         rsM1ONtcstim(ppaindex,:)=mean(sqrt(M1ONtcstim(ppaindex, 1:nrepsON(ppaindex),:).^2), 2);
%         rsM1OFFtc(ppaindex,:)=mean(sqrt(M1OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:).^2), 2);
%         rsM2OFFtc(ppaindex,:)=mean(sqrt(M2OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:).^2), 2);
%         rsM1OFFtcstim(ppaindex,:)=mean(sqrt(M1OFFtcstim(ppaindex, 1:nrepsOFF(ppaindex),:).^2), 2);
%         
%         medM1ONtc(ppaindex,:)=median(M1ONtc(ppaindex, 1:nrepsON(ppaindex),:), 2);
%         medM2ONtc(ppaindex,:)=median(M2ONtc(ppaindex, 1:nrepsON(ppaindex),:), 2);
%         medM1ONtcstim(ppaindex,:)=median(M1ONtcstim(ppaindex, 1:nrepsON(ppaindex),:), 2);
%         medM1OFFtc(ppaindex,:)=median(M1OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:), 2);
%         medM2OFFtc(ppaindex,:)=median(M2OFFtc(ppaindex, 1:nrepsOFF(ppaindex),:), 2);
%         medM1OFFtcstim(ppaindex,:)=median(M1OFFtcstim(ppaindex, 1:nrepsOFF(ppaindex),:), 2);
    end
end

%convert Pre/PostStartleWindow to samples:
PreStartleWindow=1+(PreStartleWindowms-xlimits(1))*samprate/1000
PostStartleWindow=(PostStartleWindowms-xlimits(1)+soa)*samprate/1000

% Plot the actual trace with mean trace overlayed 
% Seperated into 2 figures with laser OFF/ON 
if true 
    %plot the mean Laser OFF tuning curve
    figure;
    p=0;
    subplot1(numprepulseamps,1)
    for ppaindex=numprepulseamps:-1:1
        p=p+1;
        subplot1(p)
        hold on
        
        % add the stimulus in magenta
        if length(prepulsedurs)~=1
            warning('This function only knows how to plot one prepulsedur') %#ok
        elseif length(prepulsedurs)==1
            line([0 prepulsedurs],[0 0],'color','m','linewidth',10);
        end
        
        % plot each trial in blue
        for i=1:nrepsOFF(ppaindex)
            trace1=squeeze(M1OFFtc(ppaindex,i,:));
            trace1=trace1-median(trace1(1:1000));
            
            t=1:length(trace1);
            t=t/10;
            t=t+xlimits(1);
            plot(t, trace1, 'b');
        end
        
        % plot the mean trace in red
        trace1=squeeze(mM1OFFtc(ppaindex,:));
        trace1=trace1-median(trace1(1:1000));
        t=1:length(trace1);
        t=t/10;
        t=t+xlimits(1);
        plot(t, trace1, 'r');
        
        ylim(ylimits)
        xlim(xlimits)
        ylabel(sprintf('%d dB',prepulseamps(ppaindex)));
        text(xlimits(1)+10,ylimits(2)/2,sprintf('n=%d',nrepsOFF(ppaindex)))
        %axis off
        
    end
    subplot1(1)
    h=title(sprintf('Laser OFF, %s-%s-%s', expdate, session, filenum));
    subplot1(numprepulseamps)
    xlabel('Time (ms)');
    
    %plot the mean Laser ON tuning curve
    figure;
    p=0;
    subplot1(numprepulseamps,1)
    for ppaindex=numprepulseamps:-1:1
        p=p+1;
        subplot1(p)
        hold on
        
        % add the laser in cyan
        line([0-laserbegin 0-laserbegin+durs],[0 0],'color','c','linewidth',20);
        
        % add the stimulus in magenta
        if length(prepulsedurs)~=1
            warning('This function only knows how to plot one prepulsedur') %#ok
        elseif length(prepulsedurs)==1
            line([0 prepulsedurs],[0 0],'color','m','linewidth',10);
        end
        
        % plot each trial in blue
        for i=1:nrepsON(ppaindex)
            trace1=squeeze(M1ONtc(ppaindex,i,:));
            trace1=trace1-median(trace1(1:1000));
            
            t=1:length(trace1);
            t=t/10;
            t=t+xlimits(1);
            plot(t, trace1, 'b');
        end
        
        % plot the mean trace in red
        trace1=squeeze(mM1ONtc(ppaindex,:));
        trace1=trace1-median(trace1(1:1000));
        t=1:length(trace1);
        t=t/10;
        t=t+xlimits(1);
        plot(t, trace1, 'r');
        
        ylim(ylimits)
        xlim(xlimits)
        ylabel(sprintf('%d dB',prepulseamps(ppaindex)));
        text(xlimits(1)+10,ylimits(2)/2,sprintf('n=%d',nrepsOFF(ppaindex)))
        %axis off
        
    end
    subplot1(1)
    h=title(sprintf('Laser ON, %s-%s-%s', expdate, session, filenum));
    subplot1(numprepulseamps)
    xlabel('Time (ms)');
    
    pos=get(gcf, 'pos');
    pos(1)=pos(1)+pos(3); %shift ON to right
    set(gcf, 'pos', pos)
end

% Plot the integration of the abs(trace)  
% Seperated into 2 figures with laser OFF/ON 
if true 
    
    LaserOFFstartle=nan(numprepulseamps,max(nrepsOFF));
    LaserONstartle=nan(numprepulseamps,max(nrepsON));
    
    %plot the mean Laser OFF tuning curve
    figure;
    p=0;
    subplot1(numprepulseamps,1)
    for ppaindex=numprepulseamps:-1:1
        p=p+1;
        subplot1(p)
        hold on
        
        % add the stimulus in magenta
        if length(prepulsedurs)~=1
            warning('This function only knows how to plot one prepulsedur') %#ok
        elseif length(prepulsedurs)==1
            line([0 prepulsedurs],[0 0],'color','m','linewidth',10);
        end
        
                % add the startle stimulus in magenta
        if length(pulsedurs)~=1
            warning('This function only knows how to plot one pulsedur') %#ok
        elseif length(pulsedurs)==1
            line([soa soa+pulsedurs],[0 0],'color','m','linewidth',10);
        end
        
        % plot each trial in blue
        prestartle=[];
        poststartle=[];
        %note: PreStartleWindow and PostStartleWindow set at top
        for i=1:nrepsOFF(ppaindex)
            trace1=squeeze(M1OFFtc(ppaindex,i,:));
            trace1=trace1-median(trace1(1:1000));
            trace1=abs(trace1);
            sumprestartle=sum(trace1(PreStartleWindow(1):PreStartleWindow(2)));
            prestartle=[prestartle sumprestartle];
            sumstartle=sum(trace1(PostStartleWindow(1):PostStartleWindow(2)));
            poststartle=[poststartle sumstartle];
            trace2=[0 trace1' 0];
            
            t=1:length(trace1);
            t=t/10;
            t=t+xlimits(1);
            t=[t(1) t t(end)];
            patch(t,trace2,'b','edgecolor','b')
            clear t sumprestartle sumstartle
        end
        if length(prestartle)==length(poststartle)
            [H,P,CI,STATS] = ttest(prestartle,poststartle,[],'left');
        else
            [H,P,CI,STATS] = ttest2(prestartle,poststartle,[],'left');
        end
        LaserOFFstartle(ppaindex,1:length(poststartle))=poststartle;
        LaserOFFprestartle(ppaindex,1:length(prestartle))=prestartle;

        % plot the mean trace in red
        trace1=squeeze(mM1OFFtc(ppaindex,:));
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

        ylim(ylimits)
        xlim(xlimits)
        ylabel(sprintf('%d dB',prepulseamps(ppaindex)));
        
        text(xlimits(1)+10,ylimits(2)/2,sprintf('n=%d\np = %.3f',nrepsOFF(ppaindex),P))
        text(xlimits(1)+10,ylimits(1)/2,sprintf('Pre-startle mean = %.1f +/- %.1f\n(%d:%d samples)',mean(prestartle),std(prestartle), PreStartleWindow(1),PreStartleWindow(2)))
        text(50,ylimits(1)/2,sprintf('Post-startle mean = %.1f +/- %.1f\n(%d:%d samples)',mean(poststartle),std(poststartle), PostStartleWindow(1),PostStartleWindow(2)))

        clear prestartle poststartle
    end
    subplot1(1)
    h=title(sprintf('Laser OFF -- Integration, %s-%s-%s', expdate, session, filenum));
    subplot1(numprepulseamps)
    xlabel('Time (ms)');
    
    %plot the mean Laser ON tuning curve
    figure;
    p=0;
    subplot1(numprepulseamps,1)
    for ppaindex=numprepulseamps:-1:1
        p=p+1;
        subplot1(p)
        hold on
        
        % add the laser in cyan
        line([0-laserbegin 0-laserbegin+durs],[0 0],'color','c','linewidth',20);
        
        % add the prepulse stimulus in magenta
        if length(prepulsedurs)~=1
            warning('This function only knows how to plot one prepulsedur') %#ok
        elseif length(prepulsedurs)==1
            line([0 prepulsedurs],[0 0],'color','m','linewidth',10);
        end
        
        % add the startle stimulus in magenta
        if length(pulsedurs)~=1
            warning('This function only knows how to plot one pulsedur') %#ok
        elseif length(pulsedurs)==1
            line([soa soa+pulsedurs],[0 0],'color','m','linewidth',10);
        end
        
        % plot each trial in blue
        prestartle=[];
        poststartle=[];
        for i=1:nrepsON(ppaindex)
            trace1=squeeze(M1ONtc(ppaindex,i,:));
            trace1=trace1-median(trace1(1:1000));
            trace1=abs(trace1);
            sumprestartle=sum(trace1(PreStartleWindow(1):PreStartleWindow(2)));
            prestartle=[prestartle sumprestartle];
            sumstartle=sum(trace1(PostStartleWindow(1):PostStartleWindow(2)));
            poststartle=[poststartle sumstartle];
            trace2=[0 trace1' 0];
            
            t=1:length(trace1);
            t=t/10;
            t=t+xlimits(1);
            t=[t(1) t t(end)];
            patch(t,trace2,'b','edgecolor','b')
            clear t sumprestartle sumstartle
        end
        if length(prestartle)==length(poststartle)
            [H,P,CI,STATS] = ttest(prestartle,poststartle,[],'left');
        else
            [H,P,CI,STATS] = ttest2(prestartle,poststartle,[],'left');
        end
        LaserONstartle(ppaindex,1:length(poststartle))=poststartle;
        LaserONprestartle(ppaindex,1:length(prestartle))=prestartle;
        
        % plot the mean trace in red
        trace1=squeeze(mM1ONtc(ppaindex,:));
        trace1=trace1-median(trace1(1:1000));
        t=1:length(trace1);
        t=t/10;
        t=t+xlimits(1);
        plot(t, abs(trace1), 'r');
        
        % add the actual integration windows in grey
        plot(t([PreStartleWindow(1) PreStartleWindow(2)]), -.1*diff(ylimits)+0*t([PreStartleWindow(1) PreStartleWindow(2)]), 'color',[.8 .8 .8], 'linewidth', 4);
        plot(t([PostStartleWindow(1) PostStartleWindow(2)]), -.1*diff(ylimits)+0*t([PostStartleWindow(1) PostStartleWindow(2)]), 'color',[.8 .8 .8], 'linewidth', 4);

        ylim(ylimits)
        xlim(xlimits)
        ylabel(sprintf('%d dB',prepulseamps(ppaindex)));
        
        text(xlimits(1)+10,ylimits(2)/2,sprintf('n=%d\np = %.3f',nrepsOFF(ppaindex),P))
        text(xlimits(1)+10,ylimits(1)/2,sprintf('Pre-startle mean = %.1f +/- %.1f\n(%d:%d samples)',mean(prestartle),std(prestartle), PreStartleWindow(1),PreStartleWindow(2)))
        text(50,ylimits(1)/2,sprintf('Post-startle mean = %.1f +/- %.1f\n(%d:%d samples)',mean(poststartle),std(poststartle), PostStartleWindow(1),PostStartleWindow(2)))
        
    end
    subplot1(1)
    h=title(sprintf('Laser ON -- Integration, %s-%s-%s', expdate, session, filenum));
    subplot1(numprepulseamps)
    xlabel('Time (ms)');
    
    pos=get(gcf, 'pos');
    pos(1)=pos(1)+pos(3); %shift ON to right
    set(gcf, 'pos', pos)
    
    for ppaindex=numprepulseamps:-1:1
        
        if sum(~isnan(LaserONstartle(ppaindex,:)))==sum(~isnan(LaserOFFstartle(ppaindex,:)))
            [H,P,CI,STATS] = ttest(LaserONstartle(ppaindex,:),LaserOFFstartle(ppaindex,:));
            if H==0
                fprintf('\nAt %d dB, the laser did not affect the startle (ttest: p = %.3f)',prepulseamps(ppaindex),P);
            elseif H==1
                fprintf('\nAt %d dB, the laser SIGNIFICANTLY changed the startle (ttest: p = %.3f)',prepulseamps(ppaindex),P);
            end
        else
            [H,P,CI,STATS] = ttest2(LaserONstartle(ppaindex,:),LaserOFFstartle(ppaindex,:));
            if H==0
                fprintf('\nAt %d dB, the laser did not affect the startle (ttest2: p = %.3f)',prepulseamps(ppaindex),P);
            elseif H==1
                fprintf('\nAt %d dB, the laser SIGNIFICANTLY changed the startle (ttest2: p = %.3f)',prepulseamps(ppaindex),P);
            end
        end
    end
end

figure;hold on
errorbar(mean(LaserOFFstartle'),std(LaserOFFstartle')/sqrt(size(LaserONstartle,2)), 'k-o')
set(gca, 'xtick', 1:numprepulseamps)
set(gca, 'xticklabel', prepulseamps)
errorbar(mean(LaserONstartle'),std(LaserONstartle')/sqrt(size(LaserONstartle,2)), 'c-o')
set(gca, 'xtick', 1:numprepulseamps)
set(gca, 'xticklabel', prepulseamps)
title ('LaserON/OFF startle')
xlabel('pre pulse amplitude')
ylabel('startle response +- sem')
 legend('Laser OFF', 'Laser ON')
fprintf('\n\n')

txtfilename=sprintf('%s-%s-%sout.txt', expdate, session, filenum);
fid=fopen(txtfilename, 'wt');
for ppaindex=1:numprepulseamps
    fprintf(fid, '%d\t%d\t', prepulseamps(ppaindex),prepulseamps(ppaindex));
end
fprintf(fid, '\n');
for ppaindex=1:numprepulseamps
    fprintf(fid, 'pre\tpost\t', prepulseamps(ppaindex));
end
fprintf(fid, '\nLaserON\n');


for rep= 1:size(LaserONstartle, 2)
    for ppaindex=1:numprepulseamps
        fprintf(fid, '%f\t', LaserONprestartle(ppaindex, rep));
        fprintf(fid, '%f\t', LaserONstartle(ppaindex, rep));
    end
    fprintf(fid, '\n');
end

 fprintf(fid, '\nLaserOFF\n');

for rep= 1:size(LaserONstartle, 2)
    for ppaindex=1:numprepulseamps
        fprintf(fid, '%f\t', LaserOFFprestartle(ppaindex, rep));
        fprintf(fid, '%f\t', LaserOFFstartle(ppaindex, rep));
    end
    fprintf(fid, '\n');
end
    fprintf(fid, '\n');
    fprintf(fid, '\n');


    fclose(fid)







