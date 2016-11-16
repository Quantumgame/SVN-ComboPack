function PlotGPIAS(expdate1,session1,filenum1 )

%usage: PlotGPIAS(expdate,session,filenum )
%
% E2 tuning curve script
%plot GPIAS
%data needs to be COPIED into data-backup first
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%xlimits=[700 900]; %x limits for axis
xlimits=[0 500]; %x limits for axis


global pref
if isempty(pref) Prefs; end
username=pref.username;

datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat',expdate1,username, session1, filenum1);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat',expdate1, username, session1, filenum1);
stimfile1=sprintf('%s-%s-%s-%s-stim.mat', expdate1, username, session1, filenum1);
lostat1=-1; %discard data after this position (in samples), -1 to skip


fprintf('load file 1: ')
try
    fprintf('\ntrying to load %s...', datafile1)
    godatadir(expdate1, session1, filenum1)
    D=load(datafile1);
    E=load(eventsfile1);
    S=load(stimfile1);
catch
    error('failed. could not find processed data')
end
fprintf('done.');

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
baseline=0; %in ms

%get freqs/amps
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'GPIAS')
        j=j+1;
        allgapdurs(j)=event1(i).Param.gapdur;
        allnoisefreqs(j)=event1(i).Param.center_frequency;
        allpulseamps(j)=event1(i).Param.pulseamp;
    end
end
M1=[];
gapdurs=unique(allgapdurs);
pulseamps=unique(allpulseamps);
noisefreqs=unique(allnoisefreqs);
numgapdurs=length(gapdurs);
numpulseamps=length(pulseamps);
numnoisefreqs=length(noisefreqs);
nreps1=zeros( numgapdurs, numpulseamps);


if numnoisefreqs~=1
    error('not able to handle multiple noisefreqs')
end
noisefreq=noisefreqs;

%extract the traces into a big matrix M
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'GPIAS')
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

                gapdur=event1(i).Param.gapdur;
                gdindex= find(gapdur==gapdurs);
                pulseamp=event1(i).Param.pulseamp;
                paindex= find(pulseamp==pulseamps);
                nreps1(gdindex, paindex)=nreps1(gdindex, paindex)+1;
                M1(gdindex, paindex, nreps1(gdindex, paindex),:)=scaledtrace1(region);
                M1stim(gdindex, paindex, nreps1(gdindex, paindex),:)=stim1(region);
            end
        end
    end
end

dindex=1;
traces_to_keep=[];
if ~isempty(traces_to_keep)
    fprintf('\n using only traces %d, discarding others', traces_to_keep);
    mM1=mean(M1(:,:, traces_to_keep,:), 3);
else
    mM1=mean(M1, 3);
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
axmax(1)=min(min(min(min(M1))));
axmax(2)=max(max(max(max(M1))));

%axmax(2)=.2;

%Plots a figure for each gap duration with subplots containing the...
%...traces from each trial

%for paindex=1:numpulseamps;
%    for gdindex=1:numgapdurs;
%        figure;
%        q=0;
%        subplot1(nreps1(gdindex), 1)
%        xlabel('Time (ms)')
%        subplot1(1);
%        title(sprintf('Traces for Each Trial\nBackground Noise Frequency: %dHz, Pulse Amplitude: %ddB & Gap Duration: %dms %s \nDate:%s, Dir:%s, File:%s',noisefreq,pulseamps(paindex),gapdurs(gdindex),'',expdate1,session1,filenum1));
%        subplot1(6)
%        ylabel('Startle Response Amplitude')
%        for k=[1:nreps1(gdindex)]
%            q=q+1;
%            subplot1( q)
%            trace1=squeeze(M1(gdindex, paindex, k, :));
%            t=1:length(trace1);
%            t=t/10;
%            plot(t, trace1, 'g');
%            ylim([-5e4 5e4])
%        end
%    end
%end

%xlabel('Time (msec)')
%subplot1(1);
%title(sprintf('%ddB %s \nDate:%s, Dir:%s, File:%s',prepulseamps(ppaindex),'PPA: Traces for Each Trial',expdate1,session1,filenum1));
%subplot1(6)
%ylabel('Startle Response Amplitude (mV)')


%plot trials and mean
for paindex=1:numpulseamps
    %    figure;hold on
    p=0;
    %    subplot1(numgapdurs, 1)
    for gdindex=[1:numgapdurs]
        p=p+1;
        %        subplot1( p)
        %        hold on
        for i=1:nreps1(gdindex, paindex)
            trace1=squeeze(M1(gdindex,paindex, i,:));
            trace1=trace1-mean(trace1(1:100));
            t=1:length(trace1);
            t=t/10;
            %            plot(t, trace1, 'b');
        end
        stimtrace=squeeze(M1stim(gdindex, paindex, 1, :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*5*diff(axmax);
        stimtrace=stimtrace+axmax(1);
        trace1=squeeze(mM1(gdindex, paindex,:));
        trace1=trace1-mean(trace1(1:100));
        %        plot(t, stimtrace, 'g' );
        %        r=plot(t, trace1, 'r');
        %        set(r, 'linewidth', 2)
        %        ylim([-15e4 15e4]);
        %xlim([250 400])
        %        xlim(xlimits)
        %         axis off
    end
    %    xlabel('Time (ms)')
    %    subplot1(1)
    %    title(sprintf('Traces and Mean for Each Gap Duration\nBackground Noise Frequency: %dHz\nDate:%s, Dir:%s, File:%s',noisefreq,expdate1,session1,filenum1))
    %    try
    %       subplot1(3)
    %        ylabel('Startle Response Amplitude')
    %    catch
    %        subplot1(1)
    %        ylabel('Startle Response Amplitude')
    %        subplot1(2)
    %        ylabel('Startle Response Amplitude')
    %    end


    %label gap durations
    p=0;
    for gdindex=[1:numgapdurs]
        p=p+1;
        %        subplot1(p)

        %        text(400, 5e4, [int2str(pulseamps(paindex)), ' dB, ', int2str(gapdurs(gdindex)), ' ms'])

    end
end
fprintf('\n\nRat: _______ ; TOD: _______ ; Background nf:%dHz; na: _______ ', noisefreq);

%Displays the rat's peak response for each gap duration in the MATLAB Command Window
%for paindex=1:numpulseamps
%    for gdindex=1:numgapdurs;
%        for k=1:nreps1(gdindex, paindex);
%            trace1=squeeze(M1(gdindex,paindex, k, :));
%            peak(gdindex, paindex, k)=(max(abs(trace1(225*samprate/1000:275*samprate/1000))));
%        end
%        maxpeak=max(peak(gdindex,paindex, 1:nreps1(gdindex, paindex)));
%        fprintf('\n  The %ddB pulse amplitude,', pulseamps(paindex));
%        fprintf(' and %dms gap duration,', gapdurs(gdindex));
%        fprintf(' with an absolute peak response of %.1f.', maxpeak);
%    end
%end

figure
if numpulseamps==4
    subplot1(2, 2, 'Gap', [.05 .18]);
else
    subplot1(numpulseamps, 1, 'Gap', [.05 .18]);
end
%Plot the mean of the peaks for each gap duration
for paindex=1:numpulseamps
    subplot1(paindex);hold on
    for gdindex=1:numgapdurs;
        for k=1:15;
            trace1=squeeze(M1(gdindex,paindex, k, :));
            peak(gdindex,paindex, k)=(max(abs(trace1(225*samprate/1000:275*samprate/1000))));
            plot(gdindex, peak(gdindex,paindex, k),'ko');
        end
        m(gdindex, paindex)=mean(peak(gdindex,paindex, 1:15));
        s(gdindex, paindex)=(std(peak(gdindex,paindex, 1:15)))/sqrt(length(peak(gdindex, paindex, 1:15)));
        %Displays the rat's mean peak response for each gap duration in the MATLAB Command Window
        fprintf('\n  pa:%ddB,', pulseamps(paindex));
        fprintf(' & gapdur:%dms,', gapdurs(gdindex));
        fprintf(' mean peak response:%.1f.', (m(gdindex, paindex)));
    end


    %Displays the rat's mean percent Gap Pre-pulse Inhibition for the Acoustic Startle...
    %... (GPIAS) for each gap duration in the MATLAB Command Window

    %sanity check that first gapdur is 0 (i.e. control condition)
    if gapdurs(1)~=0
        error('first gapdur is not 0, what is wrong?')
    end

    %only makes sense for numgapdurs==2
    for p=2:numgapdurs;
        m1=m(1, paindex);
        m2=m(p, paindex);
        percentGPIAS=((m1-m2)/m1)*100;
        A=peak(1,paindex, 1:15);
        B=peak(p,paindex, 1:15);
        [H,P]=ttest2(A,B);
        fprintf('\n  pa:%ddB,', pulseamps(paindex));
        fprintf(' %%GPIAS = %.1f%%; T-test:%d, p-value:%.3f',percentGPIAS,H,P);
    end
    %fprintf('\n  (Percent GPIAS = ([(no gap)-(gap)]/no gap)*100)');
    plot(1:numgapdurs, m(:, paindex), 'r*')
    errorbar(1:numgapdurs, m(:, paindex), s(:, paindex), 'b')
    set(gca, 'xtick', 1:numgapdurs,  'xticklabel', gapdurs)
    if paindex==1
        title(sprintf('Average Peak Response for Each Gap Duration\nBackground Noise Frequency: %dHz\nDate:%s, Dir:%s, File:%s\nRat: _______ Noise Amp: _______ \nPulse Amplitude: %ddB \nPercent GPIAS is %.1f%%; p-value:%.3f',noisefreq,expdate1,session1,filenum1,pulseamps(paindex),percentGPIAS,P))
    else
        title(sprintf('Pulse Amplitude: %ddB; \nPercent GPIAS is %.1f%%; p-value:%.3f',pulseamps(paindex),percentGPIAS,P))
    end
    ylabel('Startle Response Amplitude')
    xlabel('Gap Duration (ms)')
    ylim([0 10e4])
end
fprintf('\n NOTE: T-test (alpha:0.05), 0=Null & 1=Null Rejected');

%figure
%hold on
%plot(1:numpulseamps, m(1,:),'-b*', 1:numpulseamps, m(2,:),'-r*')
%for paindex=1:numpulseamps
%    plot(paindex, squeeze(peak(1,paindex,:)),'bo', paindex, squeeze(peak(2,paindex,:)),'ro')
%end
%title(sprintf('Average Peak Responses for each Pulse Amplitude\nBackground Noise Frequency: %dHz\nDate:%s, Dir:%s, File:%s',noisefreq,expdate1,session1,filenum1))
%ylabel('Startle Response Amplitude')
%xlabel('Pulse Amplitude (dB)')
%set(gca, 'xtick', 1:numpulseamps,  'xticklabel', pulseamps)
%legend(int2str(gapdurs(1)), int2str(gapdurs(2)))
%ylim([0 6e4])

