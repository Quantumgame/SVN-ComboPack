
function Plot_Mouse_PPI_new(expdate1,session1,filenum1 )


% ***THIS IS THE PLOT TO USE FOR PPI!!!
% Plot_Mouse_PPI_new('DDMMYY','DIR','FIL')
%   Renamed and updated on 9-24-8 at 5:25PM by Michael

% E2 tuning curve script
%data needs to be COPIED into data-backup first

startle_start=225; %in ms, start of window for startle response
window_duration=75; %in ms, duration of window for startle response
prepulse_start=125; %start of window for pre-pulse startle
baseline_start=25; %start of control window (background noise level)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loadit=1;
xlimits=[0 500]; %x limits for axis

[datafile1, eventsfile1, stimfile1]=getfilenames(expdate1, session1, filenum1);
godatadir(expdate1,session1,filenum1 )
processed_data_dir1=pwd;
lostat1=-1; %discard data after this position (in samples), -1 to skip

% fprintf('\nload file 1: ')

fprintf('--> Trying to load %s...', datafile1)
D=load(datafile1);
E=load(eventsfile1);
S=load(stimfile1);
fprintf('done.');

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


%find optimal axis limits
axmax=[0 0];
axmax(1)=min(min(min(M1)));
axmax(2)=max(max(max(M1)));


% Plot TRIALS and MEAN
% List mean peak responses for each ppa in the MatLab command window
fprintf('\n\nMouse #__________ Mass:__________g Pulse Amp:_____dB DOB: ________ Sex: _____'),
figure;hold on
p=0;
subplot1(numprepulseamps, 1)
for ppaindex=[1:numprepulseamps]
    p=p+1;
    subplot1( p)
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
    plot(t, stimtrace, 'g' );
    for i=1:nreps1(ppaindex)
        trace1=squeeze(M1(ppaindex,i,:));
        trace1=trace1-mean(trace1(1:100));
        t=1:length(trace1);
        t=t/10;
        plot(t, trace1, 'b');
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
    ylim([-1000 1000]);
    xlim(xlimits)
    text(25, 500, [int2str(prepulseamps(ppaindex)), ' dB'])


end
xlabel('Time (ms)')
subplot1(1)
title(sprintf('PPI: Traces and Mean for Each Pre-pulse Amplitude \nMouse #             Pulse Amp:       (dB SPL) \nFile: %s, %s, %s\nDate Printed: %s', expdate1,session1,filenum1,datestr(floor(now))))
try
    subplot1(3)
    ylabel('Startle Response Amplitude (mV)')
catch
    subplot1(1)
    ylabel('Startle Response Amplitude (mV)')
end

%displays the rat's peak response for each PPA in the MATLAB Command Window
%for ppaindex=1:numprepulseamps;
%    for k=1:nreps1(ppaindex);
%        trace1=squeeze(M1(ppaindex, k, :));
%        trace1=trace1-mean(trace1(1:100));
%        peak(ppaindex, k)=max(abs(trace1(:)));
%        Only peaks between 125ms--275ms are used for this calculation
%    end
%    maxpeak=max(peak(ppaindex, 1:nreps1(ppaindex)));
%    fprintf('\n  For the %ddB pre-pulse amplitude,', prepulseamps(ppaindex));
%    fprintf(' the absolute peak response was %.1f.', maxpeak);
%end

%Plot the mean of the peaks for each ppa
figure;hold on
for ppaindex=1:numprepulseamps;
    for k=1:nreps1(ppaindex);
        trace1=squeeze(M1(ppaindex, k, :));
        peak(ppaindex, k)=(max(abs(trace1(startle_start*samprate/1000:(startle_start+window_duration)*samprate/1000))));
        peak_prepulse(ppaindex, k)=(max(abs(trace1(prepulse_start*samprate/1000:(prepulse_start+window_duration)*samprate/1000))));
        peak_baseline(ppaindex, k)=(max(abs(trace1(baseline_start*samprate/1000:(baseline_start+window_duration)*samprate/1000))));

        %Only peaks between startle_start--startle_start+window_duration are used for this calculation

        plot(ppaindex, peak(ppaindex, k), 'bo');
        plot(ppaindex+0.3, peak_prepulse(ppaindex, k), 'ro')
        plot(ppaindex+0.65, peak_baseline(ppaindex, k), 'mo')

    end
    m(ppaindex)=mean(peak(ppaindex, 1:nreps1(ppaindex)));
    mPP(ppaindex)=mean(peak_prepulse(ppaindex, 1:nreps1(ppaindex)));
    mBL(ppaindex)=mean(peak_baseline(ppaindex, 1:nreps1(ppaindex)));
    s(ppaindex)=(std(peak(ppaindex, 1:nreps1(ppaindex))))/sqrt(length(peak(ppaindex, 1:nreps1(ppaindex))));

    %Displays the rat's mean peak response for each pre-pulse amplitude in the MATLAB Command Window
    fprintf('\n  For the %ddB pre-pulse amplitude,', prepulseamps(ppaindex));
    fprintf(' the mean peak response was %.1f mV.', (m(ppaindex)));
    %      plot(ppaindex+0.2, mean(peak_prepulse(m(ppaindex))), 'ko')
    %      plot(ppaindex+0.4, mean(peak_baseline(m(ppaindex))), 'ko')
    text(ppaindex+0.25, -25, 'PP')
    text(ppaindex+0.6, -25, 'BL')
end

%sanity check that first ppa is -1000 (i.e. control condition)
if prepulseamps(1)~=-1000
    error('The first ppa is not -1000, fix it!')
end


plot(1:numprepulseamps, m, 'k*')
plot((1:numprepulseamps)+0.3, mPP, 'k*')
plot((1:numprepulseamps)+0.65, mBL, 'k*')
errorbar(1:numprepulseamps, m, s, 'k')
set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps)
title(sprintf('PPI: Average Peak Response for Each Pre-pulse Amplitude \nMouse #           Pulse Amp:      (dB SPL)  \nFile: %s, %s, %s \nDate Printed: %s',expdate1,session1,filenum1,datestr(floor(now))))
ylabel('Startle Response Amplitude (mV)')
xlabel('Pre-pulse Amplitude (dB SPL)')
ylim([0 2500])

fprintf('\n');
figure
for p=2:numprepulseamps;
    m1=m(1);
    m2=m(p);
    percentNBPIAS(p)=((m1-m2)/m1)*100;
    A=peak(1, 1:nreps1(1));
    B=peak(p, 1:nreps1(p));
    [H,P]=ttest2(A,B);
    fprintf('\n  For the %ddB PPA,', prepulseamps(p));
    fprintf(' %%NBPIAS = %.1f%%; T-test:%d, p-value:%.3f',percentNBPIAS(p),H,P);
end
hold on
plot(prepulseamps(2:numprepulseamps),percentNBPIAS(2:numprepulseamps),'bd-')
fprintf('\n NOTE: T-test (alpha:0.05), 0=Null & 1=Null Rejected\n');
title(sprintf('Percent Pre-Pulse Inhibition \n%%PPI=[(No Startle at -1000)-(Startle at Prepulses)]/(No Startle at -1000) \nMouse #           Pulse Amp: 80(dB SPL)  \nFile: %s, %s, %s \nDate Printed: %s',expdate1,session1,filenum1,datestr(floor(now))))
ylabel('Percent Inhibition')
xlabel('Pre-pulse Amplitude (dB SPL)')
xlim([-5 prepulseamps(end)+5])



