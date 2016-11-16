function PlotTC_spikes_dual(expdate1, session1, filenum1, thresh)
% extracts spikes and plots a single spikecount tuning curve 
% usage: PlotTC_spikes_dual(expdate, session, filenum, thresh)
% requires thresh to be passes as last argument, in number of standard
% deviations, uses same thresh for both channels
% if you want separate thresh for each channels,  hard code it below
% E2 analysis function
% mw 070406
% modified to extract/plot for both channels
% expects a second data channel
% mw 032207
% lines marked "ANDREW'S LINE" added 070326
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global pref
if isempty(pref) Prefs; end
username=pref.username;
if nargin==0 fprintf('\nno input');return;end
loadit=1;
monitor=0;
lostat1=-1; %discard data after this position (in samples), -1 to skip
lostat1=-1; %discard data after this position (in samples), -1 to skip
lostat2=lostat1; %discard data after this position (in samples), -1 to skip
datafile1=sprintf('%s-%s-%s-%s-AxopatchData1-trace.mat', expdate1, username, session1, filenum1);
datafile2=sprintf('%s-%s-%s-%s-AxopatchData2-trace.mat', expdate1, username, session1, filenum1);
eventsfile1=sprintf('%s-%s-%s-%s-AxopatchData1-events.mat', expdate1, username, session1, filenum1);

if loadit
    fprintf('\nload file 1: ')
    try
        fprintf('\ntrying to load %s...', datafile1)
        godatadir(username, expdate1,  session1, filenum1);
        L1=load(datafile1);
        L2=load(datafile2);
        E=load(eventsfile1);
        fprintf('done.');
    catch
        fprintf('failed. Could not find data')
    end
end
event1=E.event;
% trace1=L1.trace;
% nativeOffset1=L1.nativeOffset;
% nativeScaling1=L1.nativeScaling;
% trace2=L2.trace;
% nativeOffset2=L2.nativeOffset;
% nativeScaling2=L2.nativeScaling;
scaledtrace1=L1.nativeScaling*double(L1.trace)+ L1.nativeOffset;
scaledtrace2=L2.nativeScaling*double(L2.trace)+ L2.nativeOffset;
clear E L1 L2


fprintf('\ncomputing tuning curve...');

samprate=1e4;
if lostat1==-1 lostat1=length(scaledtrace1);end
if lostat2==-1 lostat2=length(scaledtrace2);end
%note: we used to use baseline and tracelength, and count spikes from
%onset-baseline to onset-baseline+tracelength
%now using response_region_start and response_region_stop
%and counting spikes in that region
response_region_start=0;  %in ms
response_region_stop=50; %in ms
fprintf('\nresponse window: %d to %d ms after tone onset',response_region_start, response_region_stop);

high_pass_cutoff=300; %Hz
[b,a]=butter(1, high_pass_cutoff/(samprate/2), 'high');
fprintf('\nhigh-pass filtering at %d Hz', high_pass_cutoff);
filteredtrace1=-filtfilt(b,a,scaledtrace1);
filteredtrace2=-filtfilt(b,a,scaledtrace2);
nstd1=thresh;
nstd2=thresh;
thresh1=nstd1*std(filteredtrace1);
thresh2=nstd1*std(filteredtrace2);
fprintf('\nusing ch1 spike detection threshold of %.1f mV (%d sd)', thresh1, nstd1);
fprintf('\nusing ch2 spike detection threshold of %.1f mV (%d sd)', thresh2, nstd1);
refract=5;
fprintf('\nusing refractory period of %.1f ms (%d samples)', 1000*refract/samprate,refract );
% %thresh=1.5;
% thresh1=0.5;   %ANDERW'S LINE
% thresh2=0.325;  %ANDREW'S LINE  
spikes1=find(abs(filteredtrace1)>thresh1);
spikes2=find(abs(filteredtrace2)>thresh2);
%
figure
plot(filteredtrace1(1:10*samprate), 'b')
hold on
plot(thresh1+zeros(size(filteredtrace1(1:10*samprate))), 'm--')
plot(-thresh1+zeros(size(filteredtrace1(1:10*samprate))), 'm--')
plot(spikes1, thresh1*ones(size(spikes1)), 'g*')
dspikes1=spikes1(1+find(diff(spikes1)>refract));
dspikes1=[spikes1(1) dspikes1'];
plot(dspikes1, thresh1*ones(size(dspikes1)), 'r*')
xlim([1 10*samprate])
% xmin=120000; xmax=121000;   %ANDREW'S LINE 
% yminn=round(xmin*length(filteredtrace1)/max(t));   %ANDREW'S LINE
% ymaxn=round(xmax*length(filteredtrace1)/max(t));   %ANDREW'S LINE
% axis([1200000 1210000 min(filteredtrace1(yminn:ymaxn))/1.5 max(filteredtrace1(yminn:ymaxn))/1.5])   %ANDREW'S LINE
title(sprintf('%s-%s-%s channel 1',expdate1,session1, filenum1))
%
figure
plot(filteredtrace2(1:10*samprate), 'b')
hold on
plot(thresh2+zeros(size(filteredtrace2(1:10*samprate))), 'm--')
plot(-thresh2+zeros(size(filteredtrace2(1:10*samprate))), 'm--')
plot(spikes2, thresh2*ones(size(spikes2)), 'g*')
dspikes2=spikes2(1+find(diff(spikes2)>refract));
dspikes2=[spikes2(1) dspikes2'];
plot(dspikes2, thresh2*ones(size(dspikes2)), 'r*')
% xmin=120000; xmax=121500;   %ANDREW'S LINE 
% yminn=round(xmin*length(filteredtrace2)/max(t));   %ANDREW'S LINE
% ymaxn=round(xmax*length(filteredtrace2)/max(t));   %ANDREW'S LINE
% axis([1200000 1215000 min(filteredtrace2(yminn:ymaxn))/1.5 max(filteredtrace2(yminn:ymaxn))/1.5])   %ANDREW'S LINE
title(sprintf('%s-%s-%s channel 2',expdate1,session1, filenum1))
xlim([1 10*samprate])

if monitor
    nspikes2plot=20;
    wb=waitbar(0, 'extraction monitor', 'pos', [884 769 270 56]);
    figure
    title(sprintf('%s-%s-%s channel 1',expdate1,session1, filenum1))
    ylim([-3*thresh1 3*thresh1]);
    for ds=dspikes1(1:nspikes2plot)
        waitbar(ds/nspikes2plot, wb) 
        xlim([ds-100 ds+100])
        t=1:length(filteredtrace1);
        region=[ds-100:ds+100];
        region=region(region>0);
        hold on
        plot(t(region), filteredtrace1(region), 'b')
        plot(spikes1, thresh1*ones(size(spikes1)), 'g*')
        plot(dspikes1, thresh1*ones(size(dspikes1)), 'r*')
        plot(t(region),thresh1+zeros(size(t(region))), 'm--')
        plot(t(region),-thresh1+zeros(size(t(region))), 'm--')
        pause(.1)
        hold off
    end
    close(wb)
%
    wb=waitbar(0, 'extraction monitor', 'pos', [884 769 270 56]);   
    figure
    title(sprintf('%s-%s-%s channel 2',expdate1,session1, filenum1))
    ylim([-3*thresh2 3*thresh2]);
    for ds=dspikes2(1:nspikes2plot)
        waitbar(ds/nspikes2plot, wb) 
        xlim([ds-100 ds+100])
        t=1:length(filteredtrace2);
        region=[ds-100:ds+100];
        hold on
        plot(t(region), filteredtrace2(region), 'b')
        plot(spikes2, thresh2*ones(size(spikes2)), 'g*')
        plot(dspikes2, thresh2*ones(size(dspikes2)), 'r*')
        plot(t(region),thresh2+zeros(size(t(region))), 'm--')
        plot(t(region),-thresh2+zeros(size(t(region))), 'm--')
        pause(.1)
        hold off
    end
    close(wb)
end

%get freqs/amps
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'tone')
        j=j+1;
        allfreqs(j)=event1(i).Param.frequency;
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.duration;
    elseif strcmp(event1(i).Type, 'whitenoise') | strcmp(event1(i).Type, 'clicktrain')
        j=j+1;
        allfreqs(j)=-1;
        allamps(j)=event1(i).Param.amplitude;
        alldurs(j)=event1(i).Param.duration;
    end
end
freqs=unique(allfreqs);
amps=unique(allamps);
durs=unique(alldurs);
numfreqs=length(freqs);
numamps=length(amps);
numdurs=length(durs);

expectednumrepeats=ceil(length(allfreqs)/(numfreqs*numamps*numdurs));
%M1=zeros(numfreqs, numamps, numdurs, expectednumrepeats, tracelength*samprate/1000);
M1=[];
M2=M1;
nreps1=zeros(numfreqs, numamps, numdurs);


%extract the traces into a big matrix M
j=0;
for i=1:length(event1)
    if strcmp(event1(i).Type, 'tone') | strcmp(event1(i).Type, 'whitenoise') | strcmp(event1(i).Type, 'clicktrain')
        if isfield(event1(i), 'soundcardtriggerPos')
            pos=event1(i).soundcardtriggerPos;
        else
            pos=event1(i).Position_rising;
        end

        start=(pos+response_region_start*1e-3*samprate);
        stop=(pos+response_region_stop*1e-3*samprate)-1;
        region=start:stop;
        if isempty(find(region<0)) %(disallow negative start times)
            if stop>lostat1
                fprintf('\ndiscarding trace')
            else
                if strcmp(event1(i).Type, 'tone')
                    freq=event1(i).Param.frequency;
                elseif strcmp(event1(i).Type, 'whitenoise') | strcmp(event1(i).Type, 'clicktrain')
                    freq=-1;
                end
                amp=event1(i).Param.amplitude;
                dur=event1(i).Param.duration;
                findex= find(freqs==freq);
                aindex= find(amps==amp);
                dindex= find(durs==dur);
                nreps1(findex, aindex, dindex)=nreps1(findex, aindex, dindex)+1;
                spikecount1=length(find(dspikes1>start & dspikes1<stop)); %num spikes in region

                M1(findex,aindex,dindex, nreps1(findex, aindex, dindex))=spikecount1;
            %
            spikecount2=length(find(dspikes2>start & dspikes2<stop)); %num spikes in region

                M2(findex,aindex,dindex, nreps1(findex, aindex, dindex))=spikecount2;
            end
        end
    end
end


fprintf('\nmin num reps: %d\nmax num reps: %d', min(min(min(nreps1))), max(max(max(nreps1))))
fprintf('\nch1: num spikes in response window: %d', sum(sum(sum(sum(M1))))                )
fprintf('\nch1: total num spikes: %d', length(dspikes1))
fprintf('\nch2: num spikes in response window: %d', sum(sum(sum(sum(M2))))                )
fprintf('\nch2: total num spikes: %d', length(dspikes2))


dindex=1;
traces_to_keep=[];
if ~isempty(traces_to_keep) 
    fprintf('\n using only traces %d, discarding others', traces_to_keep); 
    mM1=mean(M1(:,:,:,traces_to_keep,:), 4);
    mM2=mean(M2(:,:,:,traces_to_keep,:), 4);
else
    mM1=mean(M1, 4);
    mM2=mean(M2, 4);
end

%mM=mean(M(:,:,:,21:38,:), 4);


figure
i=imagesc(mM1');
set(gca, 'ydir', 'normal')
% set(gca, 'xtick', 1:length(freqs));
% set(gca, 'xticklabel', round(freqs/100)/10);
set(gca, 'xtick', [3:3:length(freqs)]);
xticklabelvectorA=round(freqs/100)/10;
for index=1:floor(length(xticklabelvectorA)/3)
    xticklabelvectorB(index)=xticklabelvectorA(3*index);
end
clear index
set(gca, 'xticklabel', xticklabelvectorB);
clear xticklabelvectorA xticklabelvectorB
xlabel('frequency, kHz')
ylabel('amplitude index')
c=colorbar;
clab=get(c, 'ylabel');
set(clab, 'string','spike count')
title(sprintf('%s-%s-%s channel 1',expdate1,session1, filenum1))
title(sprintf('%s-%s-%s ch 1, nstd=%d, %d total spikes, %d evoked spikes(%d-%dms)',expdate1,session1, filenum1, nstd1,length(dspikes1), sum(sum(sum(sum(M1)))) , response_region_start, response_region_stop))

figure
i=imagesc(mM2');
set(gca, 'ydir', 'normal')
% set(gca, 'xtick', 1:length(freqs));
% set(gca, 'xticklabel', round(freqs/100)/10);
set(gca, 'xtick', [3:3:length(freqs)]);
xticklabelvectorA=round(freqs/100)/10;
for index=1:floor(length(xticklabelvectorA)/3)
    xticklabelvectorB(index)=xticklabelvectorA(3*index);
end
clear index
set(gca, 'xticklabel', xticklabelvectorB);
clear xticklabelvectorA xticklabelvectorB
xlabel('frequency, kHz')
ylabel('amplitude index')
c=colorbar;
clab=get(c, 'ylabel');
set(clab, 'string','spike count')
%title(sprintf('%s-%s-%s channel 2',expdate1,session1, filenum1))
title(sprintf('%s-%s-%s ch 2, nstd=%d, %d total spikes, %d evoked spikes(%d-%dms)',expdate1,session1, filenum1, nstd1,length(dspikes2), sum(sum(sum(sum(M2)))), response_region_start, response_region_stop ))



