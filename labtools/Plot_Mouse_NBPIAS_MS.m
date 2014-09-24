function [numprepulseamps,nreps1,M1,startle_start,samprate,window_duration,prepulse_start,baseline_start,prepulseamps,expdate1,session1,filenum1]=Plot_Mouse_NBPIAS_MS(expdate1,session1,filenum1 )

%Similar to the rat "PlotASRMike1(expdate,session,filenum )"
% Called by AndrewZed which calls AndrewZed2
% ONLY ALTER IF YOU KNOW HOW TO CONNECT WITH THE OTHER 2 FUNCTIONS!!!

% E2 tuning curve script
%data needs to be COPIED into data-backup first

startle_start=225; %in ms, start of window for startle response
window_duration=75; %in ms, duration of window for startle response
prepulse_start=125; %start of window for pre-pulse startle
baseline_start=25; %start of control window (background noise level)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loadit=1;
%xlimits=[700 900]; %x limits for axis
xlimits=[0 500]; %x limits for axis

global pref
if isempty(pref) Prefs; end
username=pref.username;

datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat',expdate1,username, session1, filenum1);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat',expdate1, username, session1, filenum1);
stimfile1=sprintf('%s-%s-%s-%s-stim.mat', expdate1, username, session1, filenum1);
godatadir(expdate1,session1,filenum1 )
processed_data_dir1=pwd;
lostat1=-1; %discard data after this position (in samples), -1 to skip

% fprintf('\nload file 1: ')

% fprintf('\ntrying to load %s...', datafile1)
D=load(datafile1);
E=load(eventsfile1);
S=load(stimfile1);
% fprintf('done.');

event1=E.event;
trace1=D.trace;
nativeOffset1=D.nativeOffset;
nativeScaling1=D.nativeScaling;
stim1=S.nativeScalingStim*double(S.stim);
clear E D S

% fprintf('\ncomputing tuning curve...');

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
%                 fprintf('\ndiscarding trace')
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
%     fprintf('\n using only traces %d, discarding others', traces_to_keep); 
    mM1=mean(M1(:,traces_to_keep,:), 2);
else
    mM1=mean(M1, 2);
end


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

%axmax(2)=.2;

%Plot a figure for each ppa with subplots containing the traces from each trial
%for ppaindex=1:numprepulseamps;
%    figure;
%    q=0;
%    subplot1(nreps1(ppaindex), 1)
%    xlabel('Time (ms)')
%    subplot1(1);
%    title(sprintf('Traces for Each Trial \nPre-pulse Amplitude: %ddB \nDate:%s, Dir:%s, File:%s',prepulseamps(ppaindex),expdate1,session1,filenum1));
%    for k=[1:nreps1(ppaindex)]
%        q=q+1;
%        subplot1( q)
%        trace1=squeeze(M1(ppaindex, k, :));
%        t=1:length(trace1);
%        t=t/10;
%        plot(t, trace1, 'g');
%        ylim([-5e4 5e4])
%        ylim(axmax) %mw 040908
%    end
%end
%subplot1(6)
%ylabel('Startle Response Amplitude')


% Plot TRIALS and MEAN 
% List mean peak responses for each ppa in the MatLab command window
% fprintf('\n\nMouse #__________ Pulse Amplitude:_____dB\nGenotype:_____________________ Age: ________ Sex: _____'),
% figure;hold on
p=0;
% subplot1(numprepulseamps, 1)
for ppaindex=[1:numprepulseamps];
    p=p+1;
%     subplot1( p)
    hold on 
        stimtrace=squeeze(M1stim(ppaindex, 1, :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*2*diff(axmax);
        stimtrace=stimtrace+axmax(1);
        trace1=squeeze(mM1(ppaindex,:));
        trace1=trace1-mean(trace1(1:100));
        t=1:length(trace1);
        t=t/10;
%         plot(t, stimtrace, 'g' );
    for i=1:nreps1(ppaindex)
        trace1=squeeze(M1(ppaindex,i,:));
        trace1=trace1-mean(trace1(1:100));
        t=1:length(trace1);
        t=t/10;
%         plot(t, trace1, 'b');
    end
        stimtrace=squeeze(M1stim(ppaindex, 1, :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*2*diff(axmax);
        stimtrace=stimtrace+axmax(1);
        trace1=squeeze(mM1(ppaindex,:));
        trace1=trace1-mean(trace1(1:100));
        r=plot(t, trace1, 'r');
        set(r, 'linewidth', 2)
        ylim([-12000 12000]);
        %ylim(axmax) %mw 040908
        %xlim([250 400])
        xlim(xlimits)
        text(25, 500, [int2str(prepulseamps(ppaindex)), ' dB'])
%        maxpeak=max(abs(trace1));
%        fprintf('\n  For the %ddB PPA,', prepulseamps(ppaindex));
%        fprintf(' the mean peak response was %.1f.', maxpeak);

%         axis off
end
% xlabel('Time (ms)')
% % subplot1(1)
% title(sprintf('Mouse #__________ Pulse Amplitude:_____dB \nTraces and Mean for Each Pre-pulse Amplitude\nDate:%s, Dir:%s, File:%s', expdate1,session1,filenum1))
% try
% %     subplot1(3)
%     ylabel('Startle Response Amplitude')
% catch
% %     subplot1(1)
%     ylabel('Startle Response Amplitude')
% %     subplot1(2)
% %     ylabel('Startle Response Amplitude')
% end

%fprintf('\n\nDuring this set of trials, from 125-275ms, Mouse: _______ had the following responses:'),

%displays the rat's peak response for each PPA in the MATLAB Command Window
%for ppaindex=1:numprepulseamps;
%    for k=1:nreps1(ppaindex);
%        trace1=squeeze(M1(ppaindex, k, :));
        %trace1=trace1-mean(trace1(1:100)); 
%        peak(ppaindex, k)=max(abs(trace1(:)));
        %Only peaks between 125ms--275ms are used for this calculation
%    end
%    maxpeak=max(peak(ppaindex, 1:nreps1(ppaindex)));
%    fprintf('\n  For the %ddB pre-pulse amplitude,', prepulseamps(ppaindex));
%    fprintf(' the absolute peak response was %.1f.', maxpeak);
%end


%Plot the mean of the peaks for each ppa
% figure;hold on
for ppaindex=1:numprepulseamps;
    for k=1:nreps1(ppaindex);
        trace1=squeeze(M1(ppaindex, k, :));
        peak(ppaindex, k)=(max(abs(trace1(startle_start*samprate/1000:(startle_start+window_duration)*samprate/1000))));
        peak_prepulse(ppaindex, k)=(max(abs(trace1(prepulse_start*samprate/1000:(prepulse_start+window_duration)*samprate/1000))));
        peak_baseline(ppaindex, k)=(max(abs(trace1(baseline_start*samprate/1000:(baseline_start+window_duration)*samprate/1000))));

        %Only peaks between startle_start--startle_start+window_duration are used for this calculation

%         plot(ppaindex, peak(ppaindex, k), 'bo');
%         plot(ppaindex+0.3, peak_prepulse(ppaindex, k), 'ro')
%         plot(ppaindex+0.65, peak_baseline(ppaindex, k), 'mo')

    end
    m(ppaindex)=mean(peak(ppaindex, 1:nreps1(ppaindex)));
    mPP(ppaindex)=mean(peak_prepulse(ppaindex, 1:nreps1(ppaindex)));
    mBL(ppaindex)=mean(peak_baseline(ppaindex, 1:nreps1(ppaindex)));
    s(ppaindex)=(std(peak(ppaindex, 1:nreps1(ppaindex))))/sqrt(length(peak(ppaindex, 1:nreps1(ppaindex))));
    %Displays the rat's mean peak response for each pre-pulse amplitude in the MATLAB Command Window
%     fprintf('\n  For the %ddB pre-pulse amplitude,', prepulseamps(ppaindex));
%     fprintf(' the mean peak response was %.1f.', (m(ppaindex)));
    %        plot(ppaindex+0.2, mean(peak_prepulse(m(ppaindex))), 'ko')
    %      plot(ppaindex+0.4, mean(peak_baseline(m(ppaindex))), 'ko')
%     text(ppaindex+0.25, -25, 'PP')
%     text(ppaindex+0.6, -25, 'BL')
end

        
%Displays the rat's mean percent Noise Burst Pre-pulse Inhibition for the Acoustic Startle...
%...  (NBPIAS) for each gap duration in the MATLAB Command Window

%sanity check that first ppa is -1000 (i.e. control condition)
if prepulseamps(1)~=-1000
    error('The first ppa is not -1000, fix it!')
end
%     fprintf('\n');

% for p=2:numprepulseamps; 
%     m1=m(1);
%     m2=m(p);
%     percentNBPIAS=((m1-m2)/m1)*100;
%     %fprintf('\n  For the pre-pulse amplitude of %ddB, the percent NBPIAS was %.1f%%.', prepulseamps(p),percentNBPIAS);
%     A=peak(1, 1:nreps1(1));
%     B=peak(p, 1:nreps1(p));
%     [H,P]=ttest2(A,B);
%     fprintf('\n  For the %ddB PPA,', prepulseamps(p));
%     fprintf(' %%NBPIAS = %.1f%%; T-test:%d, p-value:%.3f',percentNBPIAS,H,P);
% end
% fprintf('\n NOTE: T-test (alpha:0.05), 0=Null & 1=Null Rejected');
% plot(1:numprepulseamps, m, 'k*')
% plot((1:numprepulseamps)+0.3, mPP, 'k*')
% plot((1:numprepulseamps)+0.65, mBL, 'k*')
% errorbar(1:numprepulseamps, m, s, 'k')
% set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps)
% title(sprintf('Mouse #__________ Pulse Amplitude:_____dB \nAverage Peak Response for Each Pre-pulse Amplitude \nDate:%s, Dir:%s, File:%s \n%s',expdate1,session1,filenum1))
% ylabel('Startle Response Amplitude')
% xlabel('Pre-pulse Amplitude (dB)')
% ylim([0 20000])
%ylim(axmax) %mw 040908

