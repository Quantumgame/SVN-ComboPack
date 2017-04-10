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
outfile=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
try
    godatadir(expdate, session, filenum)
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
    numprepulsedurs=out.numprepulsedurs;
    prepulsedurs=out.prepulsedurs;
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
            allprepulsedurs(j)=event1(i).Param.prepulsedur;
        end
    end
    M1=[];
    prepulseamps=unique(allprepulseamps);
    numprepulseamps=length(prepulseamps);
    prepulsedurs=unique(allprepulsedurs);
    numprepulsedurs=length(prepulsedurs);
    nreps1=zeros(1, numprepulseamps,numprepulsedurs);
    
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
                    prepulsedur=event1(i).Param.prepulsedur;
                    ppdindex= find(prepulsedur==prepulsedurs);
                    nreps1(ppaindex, ppdindex)=nreps1(ppaindex, ppdindex)+1;
                    M1(ppaindex, ppdindex, nreps1(ppaindex, ppdindex),:)=scaledtrace1(region);
                    M1stim(ppaindex, ppdindex, nreps1(ppaindex, ppdindex),:)=stim1(region);
                end
            end
        end
    end
    
    dindex=1;
    traces_to_keep=[];
    if ~isempty(traces_to_keep)
        fprintf('\n using only traces %d, discarding others', traces_to_keep);
        mM1=mean(M1(:,:,traces_to_keep,:), 2);
    else
        mM1=mean(M1, 3);
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
axmax(1)=min(M1(:));
axmax(2)=max(M1(:));
ylimits=axmax;
%axmax(2)=.2;

%Plot a figure for each ppa with subplots containing the traces from each trial
for ppaindex=1:numprepulseamps;
    for ppdindex=1:numprepulsedurs;
        figure;
        q=0;
        %    subplot1(nreps1(ppaindex), 1)
        xlabel('Time (ms)')
        %   subplot1(1);
        title(sprintf('Traces for Each Trial \nPre-pulse Amplitude: %ddB %dms\nDate:%s, Dir:%s, File:%s',prepulseamps(ppaindex),prepulsedurs(ppdindex),expdate,session, filenum));
        offset=0;
        hold on
        for k=[1:nreps1(ppaindex, ppdindex)]
            q=q+1;
            %      subplot1( q)
            trace1=squeeze(M1(ppaindex, ppdindex, k, :));
            t=1:length(trace1);
            t=t/10;
            plot(t, trace1+offset, 'g');
            %         ylim(ylimits)
            offset=offset+range(trace1);
            
        end
    end
end
%subplot1(6)
%ylabel('Startle Response Amplitude')

%plot traces for trials and mean
figure;hold on
p=0;
if numprepulseamps==1
    ppaindex=1;
    subplot1(numprepulsedurs, 1)
    for ppdindex=[1:numprepulsedurs]
        p=p+1;
        subplot1( p)
        hold on
        for i=1:nreps1(ppaindex, ppdindex)
            trace1=squeeze(M1(ppaindex, ppdindex,i,:));
            trace1=trace1-mean(trace1(1:100));
            t=1:length(trace1);
            t=t/10;
            plot(t, trace1, 'k');
        end
        stimtrace=squeeze(M1stim(ppaindex, ppdindex, 1, :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*1*diff(axmax);
        cropL=.25*diff(axmax);
        stimtrace(stimtrace>cropL)=cropL+0.*stimtrace(stimtrace>cropL); %clip top of stimtrace
        stimtrace(stimtrace<-cropL)=-cropL+0.*stimtrace(stimtrace<-cropL); %clip top of stimtrace
        
        
        stimtrace=stimtrace+ylimits(1)+.05*diff(ylimits);
        %                 stimtrace=stimtrace+axmax(1);
        trace1=squeeze(mM1(ppaindex, ppdindex,:));
        trace1=trace1-mean(trace1(1:100));
        r=plot(t, stimtrace, 'g' );
        set(r, 'color', [.4 .4 .4], 'linewidth', 2)
        r=plot(t, trace1, 'b');
        set(r, 'linewidth', 2)
        
        ylim(ylimits)
        
        
        xlim(xlimits)
        vpos=   ylimits(1)+.2*diff(ylimits);
        T=text(25, vpos, sprintf('%dms', prepulsedurs(ppdindex)));
        set(T, 'fontsize', 18')
        axis off
    end
elseif numprepulsedurs==1
    ppdindex=1;
    subplot1(numprepulseamps, 1)
    for ppaindex=[1:numprepulseamps]
        p=p+1;
        subplot1( p)
        hold on
        for i=1:nreps1(ppaindex, ppdindex)
            trace1=squeeze(M1(ppaindex, ppdindex,i,:));
            trace1=trace1-mean(trace1(1:100));
            t=1:length(trace1);
            t=t/10;
            plot(t, trace1, 'k');
        end
        stimtrace=squeeze(M1stim(ppaindex, ppdindex, 1, :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*1*diff(axmax);
        %scale factor to magnify small prepulses - actually this doesn't
        %really work since the prepulses are almost in the noise
        stimtrace=stimtrace*10;
        cropL=.25*diff(axmax);
        stimtrace(stimtrace>cropL)=cropL+0.*stimtrace(stimtrace>cropL); %clip top of stimtrace
        stimtrace(stimtrace<-cropL)=-cropL+0.*stimtrace(stimtrace<-cropL); %clip top of stimtrace
        stimtrace=stimtrace+ylimits(1)+.05*diff(ylimits);
        %                 stimtrace=stimtrace+axmax(1);
        trace1=squeeze(mM1(ppaindex, ppdindex,:));
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
            T=text(25, vpos, sprintf('%ddB', prepulseamps(ppaindex)));
        end
        set(T, 'fontsize', 18')
        axis off
    end
end

xlabel('Time (ms)')
subplot1(1)
title(sprintf('Traces and Mean for Each Pre-pulse Amplitude/Duration \nDate:%s, Dir:%s, File:%s', expdate, session, filenum))
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
    for ppdindex=[1:numprepulsedurs]
        p=p+1;
        subplot1(p)
        
        T=   text(405, 5e4, sprintf('%ddB %dms', prepulseamps(ppaindex), prepulsedurs(ppdindex)));
        set(T, 'tag', 'gap')
        
    end
end

%from here on, we do calculations off PPI relative to control condition,
%and plot/save them
% This needs to be handled differently if we are using prepulsedur=0 as the
% control condition or prepulseamp=-1000 as the control condition



fprintf('\n\nDuring this set of trials, from 125-275ms, Rat: _______ had the following responses:'),

%compute peak
%displays the rat's peak response for each PPA in the MATLAB Command Window
for ppaindex=1:numprepulseamps;
    for ppdindex=1:numprepulsedurs;
        for k=1:nreps1(ppaindex, ppdindex);
            trace1=squeeze(M1(ppaindex, ppdindex, k, :));
            peak(ppaindex, ppdindex, k)=max(abs(trace1(125*samprate/1000:275*samprate/1000)));
            %Only peaks between 125ms--275ms are used for this calculation
        end
        maxpeak=max(peak(ppaindex,ppdindex, 1:nreps1(ppaindex)));
        fprintf('\n  For the %ddB pre-pulse amplitude,', prepulseamps(ppaindex));
        fprintf(' the absolute peak response was %.1f.', maxpeak);
    end
end

% compute m and s, the mean and std of peak startle response
for ppaindex=1:numprepulseamps;
    for ppdindex=1:numprepulsedurs;
        for k=1:nreps1(ppaindex, ppdindex);
            trace1=squeeze(M1(ppaindex, ppdindex, k, :));
            peak(ppaindex, ppdindex, k)=(max(abs(trace1(125*samprate/1000:275*samprate/1000))));
            %Only peaks between 125ms--275ms are used for this calculation
            area(ppaindex, ppdindex, k)=(sum(abs(trace1(125*samprate/1000:275*samprate/1000))));
            sq_area(ppaindex, ppdindex, k)=(sum((trace1(125*samprate/1000:275*samprate/1000)).^2));
            
            plot(ppaindex, peak(ppaindex, ppdindex, k), 'ko');
        end
        m(ppaindex, ppdindex)=mean(peak(ppaindex, ppdindex, 1:nreps1(ppaindex, ppdindex)));
        s(ppaindex, ppdindex)=(std(peak(ppaindex, ppdindex, 1:nreps1(ppaindex, ppdindex))))/sqrt(length(peak(ppaindex, ppdindex, 1:nreps1(ppaindex, ppdindex))));
        medpeak(ppaindex, ppdindex)=median(peak(ppaindex, ppdindex, 1:nreps1(ppaindex, ppdindex)));
        %Displays the rat's mean peak response for each pre-pulse amplitude in the MATLAB Command Window
        fprintf('\n  For the %ddB pre-pulse amplitude and %d ms duration,', prepulseamps(ppaindex), prepulsedurs(ppdindex));
        fprintf(' the mean peak response was %.1f.', (m(ppaindex, ppdindex)));
    end
end

%Plot the PPI curve based on m and s (peak startle response)
figure;hold on
if numprepulsedurs==1
    plot(1:numprepulseamps, m(:,1), 'r:o')
    errorbar(1:numprepulseamps, m(:, 1), s(:,1), 'b')
    set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps)
    title(sprintf('PPI curve based on peak startle response \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
    ylabel('Startle Response Amplitude')
    xlabel('Pre-pulse Amplitude (dB)')
elseif numprepulseamps==1
    plot(1:numprepulsedurs, m(1,:), 'r:o')
    errorbar(1:numprepulsedurs, m(1,:), s(1,:), 'b')
    set(gca, 'xtick', 1:numprepulsedurs,  'xticklabel', prepulsedurs)
    title(sprintf('PPI curve based on peak startle response \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
    ylabel('Startle Response Amplitude')
    xlabel('Pre-pulse duration (ms)')
end


if numprepulsedurs==1
    for p=2:numprepulseamps;
        [h, P]=ttest( peak(1, 1, 1:nreps1(1,1)), peak(p, 1, 1:nreps1(1,1)), [], 'right');
        yl=ylim;
        if P<.05
            text(p, yl(2)-.05*diff(yl), '*', 'fontsize', 24)
        elseif P<.01
            text(p, yl(2)-.05*diff(yl), '**', 'fontsize', 24)
        end
    end
elseif numprepulseamps==1
    for p=2:numprepulsedurs;
        [h, P]=ttest( peak(1, 1, 1:nreps1(1,1)), peak(1, p, 1:nreps1(1,1)), [], 'right');
        yl=ylim;
        if P<.05
            text(p, yl(2)-.05*diff(yl), '*', 'fontsize', 24)
        elseif P<.01
            text(p, yl(2)-.05*diff(yl), '**', 'fontsize', 24)
        end
    end
end

%Plot the PPI curve based on area under startle response
figure;hold on
if numprepulsedurs==1
    plot(1:numprepulseamps, area(:,1,:), 'ko')
    plot(1:numprepulseamps, mean(area, 3), 'r:o')
    errorbar(1:numprepulseamps, mean(area, 3), std(area, [], 3)./sqrt(nreps1(1))', 'b')
    set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps)
    title(sprintf('PPI curve based on area under startle response \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
    ylabel('Startle Response Amplitude')
    xlabel('Pre-pulse Amplitude (dB)')
    for p=2:numprepulseamps;
        [h, P]=ttest( area(1,1, 1:nreps1(1)), area(p,1, 1:nreps1(1)), [], 'right');
        yl=ylim;
        if P<.05
            text(p, yl(2)-.05*diff(yl), '*', 'fontsize', 24)
        elseif P<.01
            text(p, yl(2)-.05*diff(yl), '**', 'fontsize', 24)
        end
    end
elseif numprepulseamps==1
    plot(1:numprepulsedurs, squeeze(area(1, :,:)), 'ko')
    plot(1:numprepulsedurs, mean(area, 3), 'r:o')
    errorbar(1:numprepulsedurs, mean(area, 3), std(area, [], 3)./sqrt(nreps1(1))', 'b')
    set(gca, 'xtick', 1:numprepulsedurs,  'xticklabel', prepulsedurs)
    title(sprintf('PPI curve based on area under startle response \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
    ylabel('Startle Response Amplitude')
    xlabel('Pre-pulse Duration (ms)')
    for p=2:numprepulsedurs;
        [h, P]=ttest( area(1,1, 1:nreps1(1)), area(1, p, 1:nreps1(1)), [], 'right');
        yl=ylim;
        if P<.05
            text(p, yl(2)-.05*diff(yl), '*', 'fontsize', 24)
        elseif P<.01
            text(p, yl(2)-.05*diff(yl), '**', 'fontsize', 24)
        end
    end
    
end


%Plot the PPI curve based on square of area under startle response
figure;hold on
if numprepulsedurs==1
    plot(1:numprepulseamps, sq_area(:,1,:), 'ko')
    plot(1:numprepulseamps, mean(sq_area, 3), 'r:o')
    errorbar(1:numprepulseamps, mean(sq_area, 3), std(sq_area, [], 3)./sqrt(nreps1(1))', 'b')
    set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps)
    title(sprintf('PPI curve based on squared area under startle response \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
    ylabel('Startle Response Amplitude')
    xlabel('Pre-pulse Amplitude (dB)')
    for p=2:numprepulseamps;
        [h, P]=ttest( sq_area(1,1, 1:nreps1(1)), sq_area(p,1, 1:nreps1(1)), [], 'right');
        yl=ylim;
        if P<.05
            text(p, yl(2)-.05*diff(yl), '*', 'fontsize', 24)
        elseif P<.01
            text(p, yl(2)-.05*diff(yl), '**', 'fontsize', 24)
        end
    end
elseif numprepulseamps==1
    plot(1:numprepulsedurs, squeeze(sq_area(1, :,:)), 'ko')
    plot(1:numprepulsedurs, mean(sq_area, 3), 'r:o')
    errorbar(1:numprepulsedurs, mean(sq_area, 3), std(sq_area, [], 3)./sqrt(nreps1(1))', 'b')
    set(gca, 'xtick', 1:numprepulsedurs,  'xticklabel', prepulsedurs)
    title(sprintf('PPI curve based on squared area under startle response \nDate:%s, Dir:%s, File:%s \n%s',expdate,session,filenum,'Rat:          Pulse Amp:      '))
    ylabel('Startle Response Amplitude')
    xlabel('Pre-pulse Duration (ms)')
    for p=2:numprepulsedurs;
        [h, P]=ttest( sq_area(1,1, 1:nreps1(1)), sq_area(1, p, 1:nreps1(1)), [], 'right');
        yl=ylim;
        if P<.05
            text(p, yl(2)-.05*diff(yl), '*', 'fontsize', 24)
        elseif P<.01
            text(p, yl(2)-.05*diff(yl), '**', 'fontsize', 24)
        end
    end
    
end

%Displays the rat's mean percent Noise Burst Pre-pulse Inhibition for the Acoustic Startle...
%...  (NBPIAS) for each gap duration in the MATLAB Command Window

if numprepulsedurs==1
for p=2:numprepulseamps;
    m1=m(1);
    m2=m(p,1);
    [H, P]=ttest( peak(1,1, 1:nreps1(1)), peak(p,1, 1:nreps1(1)), [], 'right');
    percentNBPIAS=((m1-m2)/m1)*100;
    fprintf('\n  For the pre-pulse amplitude of %ddB, the percent NBPIAS was %.1f%%,H=%d, p=%.3f', prepulseamps(p),percentNBPIAS,  H, P);
end
elseif numprepulseamps==1
for p=2:numprepulsedurs;
    m1=m(1);
    m2=m(1,p);
    [H, P]=ttest( peak(1,1, 1:nreps1(1)), peak(1,p, 1:nreps1(1)), [], 'right');
    percentNBPIAS=((m1-m2)/m1)*100;
    fprintf('\n  For the pre-pulse duration of %dms, the percent NBPIAS was %.1f%%,H=%d, p=%.3f', prepulsedurs(p),percentNBPIAS,  H, P);
end
end
fprintf('\n \n')

fprintf('mean area')
mean(squeeze(area(1, :,:))')
fprintf('median area')
median(squeeze(area(1, :,:))')

fprintf('median peak of startle response')
medpeak

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
out.medpeak=medpeak; %median of the peak startle response
out.area=area; %mean of peak
out.sq_area=sq_area; %mean of peak
out.numprepulseamps=numprepulseamps;
out.prepulseamps=prepulseamps;
out.numprepulsedurs=numprepulsedurs;
out.prepulsedurs=prepulsedurs;
save (outfile, 'out')
%fprintf('\n saved to %s', outfile)

