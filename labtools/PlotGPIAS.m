function PlotGPIAS(expdate,session,filenum )

%usage: PlotGPIAS(expdate,session,filenum )
%
% E2 tuning curve script
%plot GPIAS
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0 fprintf('\nno input');return;end

xlimits=[0 1000]; %x limits for axis

chan='1'; %connect data to channel ACh0
fprintf('load file: ')
[datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum, [], chan);
godatadir(expdate,session,filenum)
fprintf('\ntrying to load %s...', datafile)
[D E S]=gogetdata(expdate,session,filenum);

fprintf('done.');
event=E.event;
scaledtrace=D.nativeScaling*double(D.trace) + D.nativeOffset;
stim=S.nativeScalingStim*double(S.stim);
clear E D S

fprintf('\ncomputing tuning curve...');

samprate=1e4;
tracelength=1000; %in ms
baseline=50; %in ms

%get freqs/amps
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'GPIAS')
        j=j+1;
        allgapdurs(j)=event(i).Param.gapdur;
        allgapdelays(j)=event(i).Param.gapdelay;
        allnoisefreqs(j)=event(i).Param.center_frequency;
        allpulseamps(j)=event(i).Param.pulseamp;
        allnoiseamps(j)=event(i).Param.amplitude;
        allnoiselower_frequencies(j)=event(i).Param.lower_frequency;
        allnoiseupper_frequencies(j)=event(i).Param.upper_frequency;
    end
end
M1=[];
gapdurs=unique(allgapdurs);
gapdelays=unique(allgapdelays);
pulseamps=unique(allpulseamps);
noisefreqs=unique(allnoisefreqs);
noiseamps=unique(allnoiseamps);
noiselower_frequencies=unique(allnoiselower_frequencies);
noiseupper_frequencies=unique(allnoiseupper_frequencies);
numgapdurs=length(gapdurs);
numpulseamps=length(pulseamps);
nreps=zeros( numgapdurs, numpulseamps);


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

noiseamp=noiseamps;
gapdelay=gapdelays;
noisefreq=noisefreqs;
noiseupper_frequency=noiseupper_frequencies;
noiselower_frequency=noiselower_frequencies;
noiseBW=log2(noiseupper_frequency/noiselower_frequency);

%extract the traces into a big matrix M
j=0;
for i=1:length(event)
    if strcmp(event(i).Type, 'GPIAS')
        if isfield(event(i), 'soundcardtriggerPos')
            pos=event(i).soundcardtriggerPos;
            if isempty(pos)
                pos=event(i).Position_rising;
                fprintf('\nusing Pos rising')
            end
        else
            pos=event(i).Position_rising;
            fprintf('\nusing Pos rising')
        end
        
        start=(pos+(gapdelay-baseline)*1e-3*samprate);
        stop=(start+tracelength*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop<length(scaledtrace)
                
                gapdur=event(i).Param.gapdur;
                gdindex= find(gapdur==gapdurs);
                pulseamp=event(i).Param.pulseamp;
                paindex= find(pulseamp==pulseamps);
                nreps(gdindex, paindex)=nreps(gdindex, paindex)+1;
                M1(gdindex, paindex, nreps(gdindex, paindex),:)=scaledtrace(region);
                M1stim(gdindex, paindex, nreps(gdindex, paindex),:)=stim(region);
                
%                 %debugging
%                 figure(1)
%                 r=start-10000:stop+10000;
%                 plot(1:length(r), stim(r), 'm');
%                 event(i).soundcardtriggerPos-event(i).Position_rising
%                 keyboard
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
ylimits(1)=min(min(min(min(M1))));
ylimits(2)=max(max(max(max(M1))));


%Plots a figure for each gap duration with subplots containing the traces
%from each trial

for paindex=1:numpulseamps;
    for gdindex=1:numgapdurs;
        figure;
        q=0;
        subplot1(nreps(gdindex), 1)
        xlabel('Time (ms)')
        subplot1(1);
        title(sprintf('individual trials %s-%s-%s \nBGNoise: %.1fKhz %.2foct %ddB; PulseAmp: %ddB; GapDur: %dms',expdate,session,filenum,noisefreq/1000,noiseBW,noiseamp,pulseamps(paindex),gapdurs(gdindex)))
        %title(sprintf('Traces for Each Trial\nBackground Noise Frequency: %dHz, Pulse Amplitude: %ddB & Gap Duration: %dms %s \nDate:%s, Dir:%s, File:%s',noisefreq,pulseamps(paindex),gapdurs(gdindex),'',expdate,session,filenum));
        subplot1(numpulseamps)
        for k=[1:nreps(gdindex)]
            q=q+1;
            subplot1( q)
            trace1=squeeze(M1(gdindex, paindex, k, :));
            t=1:length(trace1);
            t=t/10;
            plot(t, trace1, 'k');
            ylim(ylimits)
            axis off
        end
        axis on
        ylh=ylabel('Startle Response Amplitude');
        set(ylh,'HorizontalAlignment', 'left')
        
    end
end

%Plots a figure for each gap duration with subplots containing the stimuli
%from each trial (sanity check!)
yl=[min(min(min(min(M1stim)))) max(max(max(max(M1stim))))];
for paindex=1:numpulseamps;
    for gdindex=1:numgapdurs;
        figure;
        q=0;
        subplot1(nreps(gdindex), 1)
        xlabel('Time (ms)')
        subplot1(1);
        title(sprintf('individual trials %s-%s-%s \nBGNoise: %.1fKhz %.2foct %ddB; PulseAmp: %ddB; GapDur: %dms',expdate,session,filenum,noisefreq/1000,noiseBW,noiseamp,pulseamps(paindex),gapdurs(gdindex)))
        subplot1(numpulseamps)
        for k=[1:nreps(gdindex)]
            q=q+1;
            subplot1( q)
            trace1=squeeze(M1stim(gdindex, paindex, k, :));
            t=1:length(trace1);
            t=t/10;
            plot(t, trace1, 'm');
            ylim(yl)
            axis off
        end
        axis on
        ylh=ylabel('');
        set(ylh,'HorizontalAlignment', 'left')
        
    end
end


%plot trials and mean
for paindex=1:numpulseamps
    figure;hold on
    p=0;
    subplot1(numgapdurs, 1)
    for gdindex=[1:numgapdurs]
        p=p+1;
        subplot1( p)
        hold on
        for i=1:nreps(gdindex, paindex)
            trace1=squeeze(M1(gdindex,paindex, i,:));
            trace1=trace1-mean(trace1(1:100));
            t=1:length(trace1);
            t=t/10;
            plot(t, trace1, 'b');
        end
        stimtrace=squeeze(M1stim(gdindex, paindex, 1, :));
        stimtrace=stimtrace-mean(stimtrace(1:100));
        stimtrace=stimtrace./max(abs(stimtrace));
        stimtrace=stimtrace*.1*diff(ylimits);
        stimtrace=stimtrace+ylimits(1);
        trace1=squeeze(mM1(gdindex, paindex,:));
        trace1=trace1-mean(trace1(1:100));
        plot(t, stimtrace, 'color', [.5 .5 .5] );
        r=plot(t, trace1, 'r');
        set(r, 'linewidth', 2)
        xlim(xlimits)
        ylim(ylimits)
        %         axis off
    end
    
    xlabel('Time (ms)')
    subplot1(1)
    title(sprintf('Traces and Mean for Each Gap Duration\nBackground Noise Frequency: %dHz\nDate:%s, Dir:%s, File:%s',noisefreq,expdate,session,filenum))
    try
        subplot1(3)
        ylabel('Startle Response Amplitude')
    catch
        subplot1(1)
        ylabel('Startle Response Amplitude')
        subplot1(2)
        ylabel('Startle Response Amplitude')
    end
    
    
    %label gap durations
    p=0;
    for gdindex=[1:numgapdurs]
        p=p+1;
        subplot1(p)
        
        text(400, 5e4, [int2str(pulseamps(paindex)), ' dB, ', int2str(gapdurs(gdindex)), ' ms'])
        
    end
end

%Displays the rat's peak response for each gap duration in the MATLAB Command Window
region=1:250*samprate/1000;
fprintf('\nusing peak rectified signal in region %.1f-%.1f ms from gap onset', 1000*min(region)/samprate, 1000*max(region)/samprate);

for paindex=1:numpulseamps
    for gdindex=1:numgapdurs;
        for k=1:nreps(gdindex, paindex);
            trace1=squeeze(M1(gdindex,paindex, k, :));
            peak(gdindex, paindex, k)=(max(abs(trace1(region))));
        end
        maxpeak=max(peak(gdindex,paindex, 1:nreps(gdindex, paindex)));
        fprintf('\n  pa:%ddB,', pulseamps(paindex));
        fprintf(' gapdur:%dms,', gapdurs(gdindex));
        fprintf(' absolute peak response:%.1f', maxpeak);
    end
end
fprintf('\n Mean peak responses and T-test stats:');
figure
if numpulseamps==4
    subplot1(2, 2, 'Gap', [.05 .18]);
else
    subplot1(numpulseamps, 1, 'Gap', [.05 .1]);
end

region=1:250*samprate/1000;
fprintf('\nusing peak rectified signal in region %.1f-%.1f ms from gap onset', 1000*min(region)/samprate, 1000*max(region)/samprate);

%Plot the mean of the peaks for each gap duration
for paindex=1:numpulseamps
    subplot1(paindex);hold on
    for gdindex=1:numgapdurs;
        for k=1:nreps(gdindex, paindex);
            trace1=squeeze(M1(gdindex,paindex, k, :));
            peak(gdindex,paindex, k)=(max(abs(trace1(region))));
            plot(gdindex, peak(gdindex,paindex, k),'ko');
        end
        mpeak(gdindex, paindex)=mean(peak(gdindex,paindex, 1:nreps(gdindex, paindex)));
        speak(gdindex, paindex)=(std(peak(gdindex,paindex, 1:nreps(gdindex, paindex))))/sqrt(length(peak(gdindex, paindex, 1:nreps(gdindex, paindex))));
        %Displays the rat's mean peak response for each gap duration in the MATLAB Command Window
        fprintf('\n  pa:%ddB,', pulseamps(paindex));
        fprintf(' gapdur:%dms ,', gapdurs(gdindex));
        fprintf(' mean peak response:%.1f', (mpeak(gdindex, paindex)));
    end
    
    
    %Displays the rat's mean percent Gap Pre-pulse Inhibition for the Acoustic Startle...
    %... (GPIAS) for each gap duration in the MATLAB Command Window
    
    %sanity check that first gapdur is 0 (i.e. control condition)
    if gapdurs(1)~=0
        error('first gapdur is not 0, what is wrong?')
    end
    
    %only makes sense for numgapdurs==2
    for p=2:numgapdurs;
        m1=mpeak(1, paindex);
        m2=mpeak(p, paindex);
        percentGPIAS=((m1-m2)/m1)*100;
        A=peak(1,paindex, 1:nreps(1, paindex));
        B=peak(p,paindex, 1:nreps(p, paindex));
        [H,P(p-1)]=ttest2(A,B);
        fprintf('\n  pa:%ddB,', pulseamps(paindex));
        fprintf(' %%GPIAS = %.1f%%, T-test:%d, p-value:%.3f',percentGPIAS,H,P(p-1));
    end
    %fprintf('\n  (Percent GPIAS = ([(no gap)-(gap)]/no gap)*100)');
    plot(1:numgapdurs, mpeak(:, paindex), 'r*')
    errorbar(1:numgapdurs, mpeak(:, paindex), speak(:, paindex), 'b')
    set(gca, 'xtick', 1:numgapdurs,  'xticklabel', gapdurs)
    str=sprintf('%d,',nreps);str=str(1:end-1);
    title(sprintf('%s-%s-%s mean(Peak) BGNoise: %.1fKhz %.2foct %ddB PulseAmp: %ddB; \n%%GPIAS: %.1f%%; p=%.3f, reps:%s',expdate,session,filenum,noisefreq/1000,noiseBW,noiseamp,pulseamps(paindex),percentGPIAS,P, str))
    ylabel('Startle Response Amplitude')
    xlabel('Gap Duration (ms)')
    yl=ylim;    yl(1)=0; ylim(yl);
end
fprintf('\n NOTE: T-test (alpha:0.05), 0=Null & 1=Null Rejected');

figure
hold on
plot(1:numpulseamps, mpeak(1,:),'-b*', 1:numpulseamps, mpeak(2,:),'-r*')
for paindex=1:numpulseamps
    plot(paindex, squeeze(peak(1,paindex,:)),'bo', paindex, squeeze(peak(2,paindex,:)),'ro')
end
title(sprintf('%s-%s-%s mean(Peak) BGNoise: %.1fKhz %.2foct %ddB PulseAmp: %ddB; \n%GapPPI %.1f%%; p=%.3f',expdate,session,filenum,noisefreq/1000,noiseBW,noiseamp,pulseamps(paindex),percentGPIAS,P))
ylabel('Startle Response Amplitude')
xlabel('Pulse Amplitude (dB)')
set(gca, 'xtick', 1:numpulseamps,  'xticklabel', pulseamps)
legend(int2str(gapdurs(1)), int2str(gapdurs(2)))
yl=ylim;    yl(1)=0; ylim(yl);

outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);
out.M1=M1;
out.xlimits=xlimits;
out.mM1=mM1;
out.nreps=nreps;
out.expdate=expdate;
out.session=session;
out.filenum=filenum;
out.peak=peak; %peak startle response (gapdurs, pulseamps, reps)
out.mpeak=mpeak; %mean of peak
out.speak=speak; %std of peak
out.P=P; %p-value for ttest between no-gap and gap
out.pulseamps=pulseamps;
out.M1stim=M1stim; %matrix of stimulus traces
out.M1=M1; %matrix of startle traces
out.samprate=samprate;
out.noiseBW=noiseBW;
out.noiseamps=noiseamps;
out.noisefreq=noisefreq;
out.baseline=baseline;
out.noisefreqs=noisefreqs;
out.noiselower_frequencies=noiselower_frequencies;
out.noiseupper_frequencies=noiseupper_frequencies;
out.event=event;
out.tracelength=tracelength;
out.numgapdurs=numgapdurs;
out.numpulseamps=numpulseamps;
out.gapdelays=gapdelays;
out.gapdurs=gapdurs;
out.percentGPIAS =percentGPIAS;

godatadir(expdate,session, filenum);
save (outfilename, 'out')
fprintf('\n saved to %s', outfilename)
