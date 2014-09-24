function PlotNB_ASR(expdate, session, filenum )

%usage: PlotNB_ASR(expdate, session, filenum )
% modified from PlotASRMike1(expdate,session,filenum ) to handle NB_ASR
% stimuli (with a narrow-band prepulse)
%
% E2 tuning curve script
%plot ASR
%data needs to be COPIED into data-backup first
%
if nargin==0 fprintf('\nno input'); return; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xlimits=[50 500]; %x limits for axis

global pref
if isempty(pref) Prefs; end
username=pref.username;

datafile=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat',expdate,username, session, filenum);
eventsfile=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat',expdate, username, session, filenum);
stimfile=sprintf('%s-%s-%s-%s-stim.mat', expdate, username, session, filenum);
godatadir(expdate, session, filenum)
outfile=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
try
    load(outfile)
    M1=out.M1;
mM1=out.mM1;
M1stim=out.M1stim;
nreps1=out.nreps;
peak=out.peak; %peak startle response (gapdurs, pulseamps, reps)
m=out.mpeak; %mean of peak
s=out.speak; %std of peak
numprepulseamps=out.numprepulseamps;
prepulseamps=out.prepulseamps;
samprate=1e4;
catch  %load and process data
    
    lostat1=-1; %discard data after this position (in samples), -1 to skip
    
    fprintf('\nload file 1: ')
    try
        fprintf('\ntrying to load %s...', datafile)
        godatadir(expdate, session, filenum)
        D=load(datafile);
        E=load(eventsfile);
        S=load(stimfile);
        fprintf('done.');
    catch
        try
            ProcessData_single(expdate, session, filenum)
            godatadir(expdate,  session, filenum);
            D=load(datafile);
            E=load(eventsfile);
            S=load(stimfile);
            fprintf('done.');
        catch
            try
                fprintf('\nCould not find data in %s', pwd)
                fprintf('\nlooking for data on backup server')
                godatadirbak(expdate, session, filenum)
                D=load(datafile);
                E=load(eventsfile);
                S=load(stimfile);
                fprintf('\nfound and loaded data.');
            catch
                fprintf('\nfailed. Could not find data')
                error('\nProcessed data: %s not found. \nDid you copy into Backup?', datafile)
            end
        end
    end
    
    
    event1=E.event;
    trace1=D.trace;
    nativeOffset1=D.nativeOffset;
    nativeScaling1=D.nativeScaling;
    stim1=S.nativeScalingStim*double(S.stim);
    clear E D S
    
    fprintf('\ncomputing tuning curve...');
    
    samprate=1e4;
    scaledtrace1=nativeScaling1*double(trace1) + nativeOffset1;
    if lostat1==-1 lostat1=length(scaledtrace1);end
    %t=1:length(scaledtrace1);
    %t=1000*t/samprate;
    tracelength=500; %in ms
    baseline=100; %in ms
    
    %get freqs/amps
    j=0;
    for i=1:length(event1)
        if strcmp(event1(i).Type, 'ASR')
            j=j+1;
            allprepulseamps(j)=event1(i).Param.prepulseamp;
        end
    end
    M1=[];
    prepulseamps=unique(allprepulseamps);
    numprepulseamps=length(prepulseamps);
    nreps1=zeros(1, numprepulseamps);
    
    %extract the traces into a big matrix M
    j=0;
    for i=1:length(event1)
        if strcmp(event1(i).Type, 'ASR')
            if isfield(event1(i), 'soundcardtriggerPos')
                pos=event1(i).soundcardtriggerPos;
            else
                pos=event1(i).Position_rising;
            end
            
            start=(pos-baseline*1e-3*samprate);
            stop=(start+tracelength*1e-3*samprate)-1;
            region=start:stop;
            if isempty(find(region<0)) %(disallow negative start times)
                if stop>lostat1
                    fprintf('\ndiscarding trace')
                else
                    
                    prepulseamp=event1(i).Param.prepulseamp;
                    ppaindex= find(prepulseamp==prepulseamps);
                    nreps1(ppaindex)=nreps1(ppaindex)+1;
                    M1(ppaindex, nreps1(ppaindex),:)=scaledtrace1(region);
                    M1stim(ppaindex, nreps1(ppaindex),:)=stim1(region);
                end
            end
        end
    end
    
    dindex=1;
    traces_to_keep=[];
    if ~isempty(traces_to_keep)
        fprintf('\n using only traces %d, discarding others', traces_to_keep);
        mM1=mean(M1(:,traces_to_keep,:), 2);
    else
        mM1=mean(M1, 2);
    end
    
end %load and process data

%find optimal axis limits
axmax=[0 0];
% for ppaindex=[1:numprepulseamps]
%         trace1=squeeze(mM1(ppaindex,:));
%         trace1=trace1-mean(trace1(1:100));
% %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
%         if min([trace1])<axmax(1) axmax(1)=min([trace1]);end
%         if max([trace1])>axmax(2) axmax(2)=max([trace1]);end
% end
axmax(1)=min(min(min(M1)));
axmax(2)=max(max(max(M1)));
ylimits=axmax;
%axmax(2)=.2;

%Plot a figure for each ppa with subplots containing the traces from...
%...each trial
for ppaindex=1:numprepulseamps;
    figure;
    q=0;
    subplot1(nreps1(ppaindex), 1)
    xlabel('Time (ms)')
    subplot1(1);
    title(sprintf('Traces for Each Trial \nPre-pulse Amplitude: %ddB \nDate:%s, Dir:%s, File:%s',prepulseamps(ppaindex),expdate,session, filenum));
    for k=[1:nreps1(ppaindex)]
        q=q+1;
        subplot1( q)
        trace1=squeeze(M1(ppaindex, k, :));
        t=1:length(trace1);
        t=t/10;
        plot(t, trace1, 'g');
        ylim(ylimits)
        
    end
end
%subplot1(6)
%ylabel('Startle Response Amplitude')

%plot traces for trials and mean
figure;hold on
p=0;
subplot1(numprepulseamps, 1)
for ppaindex=[1:numprepulseamps]
    p=p+1;
    subplot1( p)
    hold on
    for i=1:nreps1(ppaindex)
        trace1=squeeze(M1(ppaindex,i,:));
        trace1=trace1-mean(trace1(1:100));
        t=1:length(trace1);
        t=t/10;
        plot(t, trace1, 'k');
    end
    stimtrace=squeeze(M1stim(ppaindex, 1, :));
    stimtrace=stimtrace-mean(stimtrace(1:100));
    stimtrace=stimtrace./max(abs(stimtrace));
    stimtrace=stimtrace*1*diff(axmax);
    cropL=.25*diff(axmax);
    stimtrace(stimtrace>cropL)=cropL+0.*stimtrace(stimtrace>cropL); %clip top of stimtrace
    stimtrace(stimtrace<-cropL)=-cropL+0.*stimtrace(stimtrace<-cropL); %clip top of stimtrace
    
    
    stimtrace=stimtrace+ylimits(1)+.05*diff(ylimits);
    %                 stimtrace=stimtrace+axmax(1);
    trace1=squeeze(mM1(ppaindex,:));
    trace1=trace1-mean(trace1(1:100));
    r=plot(t, stimtrace, 'g' );
    set(r, 'color', [.4 .4 .4], 'linewidth', 2)
    r=plot(t, trace1, 'b');
    set(r, 'linewidth', 2)
    
    ylim(ylimits)
    
    
    %xlim([250 400])
    xlim(xlimits)
    %         axis off
    if ppaindex==1
        vpos=   ylimits(1)+.2*diff(ylimits);
        T=text(25, vpos, 'No prepulse');
    elseif ppaindex==2
        T=text(25, vpos, 'prepulse');
    end
    set(T, 'fontsize', 18')
    axis off
end
xlabel('Time (ms)')
subplot1(1)
title(sprintf('Traces and Mean for Each Pre-pulse Amplitude\nDate:%s, Dir:%s, File:%s', expdate, session, filenum))
try
    subplot1(3)
    ylabel('Startle Response Amplitude')
catch
    subplot1(1)
    ylabel('Startle Response Amplitude')
    %     subplot1(2)
    %     ylabel('Startle Response Amplitude')
end


%label amps and freqs
p=0;
for ppaindex=[1:numprepulseamps]
    p=p+1;
    subplot1(p)
    
    T=   text(405, 5e4, [int2str(prepulseamps(ppaindex)), ' dB']);
    set(T, 'tag', 'gap')
    
end

fprintf('\n\nDuring this set of trials, from 125-275ms, Rat: _______ had the following responses:'),

%displays the rat's peak response for each PPA in the MATLAB Command Window
for ppaindex=1:numprepulseamps;
    for k=1:nreps1(ppaindex);
        trace1=squeeze(M1(ppaindex, k, :));
        peak(ppaindex, k)=max(abs(trace1(125*samprate/1000:275*samprate/1000)));
        %Only peaks between 125ms--275ms are used for this calculation
    end
    maxpeak=max(peak(ppaindex, 1:nreps1(ppaindex)));
    fprintf('\n  For the %ddB pre-pulse amplitude,', prepulseamps(ppaindex));
    fprintf(' the absolute peak response was %.1f.', maxpeak);
end

%Plot the PPI curve based on peak startle response 
figure;hold on
for ppaindex=1:numprepulseamps;
    for k=1:nreps1(ppaindex);
        trace1=squeeze(M1(ppaindex, k, :));
        peak(ppaindex, k)=(max(abs(trace1(125*samprate/1000:275*samprate/1000))));
        %Only peaks between 125ms--275ms are used for this calculation
        area(ppaindex, k)=(sum(abs(trace1(125*samprate/1000:275*samprate/1000))));
        sq_area(ppaindex, k)=(sum((trace1(125*samprate/1000:275*samprate/1000)).^2));
        
        plot(ppaindex, peak(ppaindex, k), 'ko');
    end
    m(ppaindex)=mean(peak(ppaindex, 1:nreps1(ppaindex)));
    s(ppaindex)=(std(peak(ppaindex, 1:nreps1(ppaindex))))/sqrt(length(peak(ppaindex, 1:nreps1(ppaindex))));
    %Displays the rat's mean peak response for each pre-pulse amplitude in the MATLAB Command Window
    fprintf('\n  For the %ddB pre-pulse amplitude,', prepulseamps(ppaindex));
    fprintf(' the mean peak response was %.1f.', (m(ppaindex)));
end
plot(1:numprepulseamps, m, 'r:o')
errorbar(1:numprepulseamps, m, s, 'b')
set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps)
title(sprintf('PPI curve based on peak startle response \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
ylabel('Startle Response Amplitude')
xlabel('Pre-pulse Amplitude (dB)')
for p=2:numprepulseamps;
    [h, P]=ttest( peak(1, 1:nreps1(1)), peak(p, 1:nreps1(1)), [], 'right');
    yl=ylim;
    if P<.05
        text(p, yl(2)-.05*diff(yl), '*', 'fontsize', 24)
    elseif P<.01
        text(p, yl(2)-.05*diff(yl), '**', 'fontsize', 24)
    end
end
   
   
   
%Plot the PPI curve based on area under startle response 
figure;hold on
plot(1:numprepulseamps, area, 'ko')
plot(1:numprepulseamps, mean(area, 2), 'r:o')
errorbar(1:numprepulseamps, mean(area, 2), std(area, [], 2)./sqrt(nreps1)', 'b')
set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps)
title(sprintf('PPI curve based on area under startle response \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
ylabel('Startle Response Amplitude')
xlabel('Pre-pulse Amplitude (dB)')
for p=2:numprepulseamps;
    [h, P]=ttest( area(1, 1:nreps1(1)), area(p, 1:nreps1(1)), [], 'right');
    yl=ylim;
    if P<.05
        text(p, yl(2)-.05*diff(yl), '*', 'fontsize', 24)
    elseif P<.01
        text(p, yl(2)-.05*diff(yl), '**', 'fontsize', 24)
    end
end

%Plot the PPI curve based on square of area under startle response 
figure;hold on
plot(1:numprepulseamps, sq_area, 'ko')
plot(1:numprepulseamps, mean(sq_area, 2), 'r:o')
errorbar(1:numprepulseamps, mean(sq_area, 2), std(sq_area, [], 2)./sqrt(nreps1)', 'b')
set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps)
title(sprintf('PPI curve based on squared area under startle response \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
ylabel('Startle Response Amplitude')
xlabel('Pre-pulse Amplitude (dB)')
for p=2:numprepulseamps;
    [h, P]=ttest( sq_area(1, 1:nreps1(1)), sq_area(p, 1:nreps1(1)), [], 'right');
    yl=ylim;
    if P<.05
        text(p, yl(2)-.05*diff(yl), '*', 'fontsize', 24)
    elseif P<.01
        text(p, yl(2)-.05*diff(yl), '**', 'fontsize', 24)
    end
end

%Displays the rat's mean percent Noise Burst Pre-pulse Inhibition for the Acoustic Startle...
%...  (NBPIAS) for each gap duration in the MATLAB Command Window

%sanity check that first ppa is -1000 (i.e. control condition)
if prepulseamps(1)~=-1000
    error('first ppa is not 0, what is wrong?')
end

for p=2:numprepulseamps;
    m1=m(1);
    m2=m(p);
    [H, P]=ttest( peak(1, 1:nreps1(1)), peak(p, 1:nreps1(1)), [], 'right');
    percentNBPIAS=((m1-m2)/m1)*100;
    fprintf('\n  For the pre-pulse amplitude of %ddB, the percent NBPIAS was %.1f%%,H=%d, p=%.3f)', prepulseamps(p),percentNBPIAS,  H, P);
end

fprintf('\n \n')

godatadir(expdate, session, filenum)
out.M1=M1;
out.mM1=mM1;
out.M1stim=M1stim;
out.nreps=nreps1;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.peak=peak; %peak startle response (gapdurs, pulseamps, reps)
out.mpeak=m; %mean of peak
out.speak=s; %std of peak
out.area=area; %mean of peak
out.sq_area=sq_area; %mean of peak
out.numprepulseamps=numprepulseamps;
out.prepulseamps=prepulseamps;
save (outfile, 'out')
fprintf('\n saved to %s', outfile)

