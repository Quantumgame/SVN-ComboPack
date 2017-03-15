function PlotToneTrain_A1(expdate, session, filenum)
% usage: PlotToneTrain_A1(expdate, session, filenum)
%loads data structure processed by ProcessToneTrain_A1
% plots an averaged tuning curve for tonetrain stimuli
%same as PlotToneTrain but some parameters are optimized for A1 responses
%instead of ABRs (like axis limits, maybe some other stuff?)
%looks at multiple ISIs but only a single freq

if nargin~=3 error('PlotToneTrain_A1: wrong number of arguments');end
    
area='ACC';
loadit=1;

%lostat=2.4918e+006; %discard data after this position (in samples)


processed_data_dir=sprintf('D:\\lab\\Data-processed\\%s-lab\\', expdate);
processed_data_session_dir=sprintf('%s-lab-%s', expdate, session);
datafile=sprintf('%s-lab-%s-%s-AxopatchData1-trace.mat', expdate, session, filenum);
eventsfile=sprintf('%s-lab-%s-%s-AxopatchData1-events.mat', expdate, session, filenum);
stimfile=sprintf('%s-lab-%s-%s-stim.mat', expdate, session, filenum);
outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);

fprintf('\ntrying to load %s...', outfilename)
cd(processed_data_dir)
cd(processed_data_session_dir)
load(outfilename);

fprintf('done\n');

samprate=1e4;
%trials=21:40;
trials=1:size(Mc, 3);
mMc=mean(Mc(:,:,:,trials,:), 4);
mMcs=mean(Mcs, 4);




%plot the mean tuning curves for pre and post
figure
p=0;
findex=1;
subplot1( numisis,numamps)
for aindex=[numamps:-1:1]
    for isiindex=1:numisis
        p=p+1;
        subplot1( p)
        trace1=squeeze(mMc(findex, aindex, isiindex, :));
        trace1=trace1-mean(trace1(1:100));
         trace1=trace1/max(abs(trace1)); %normalize trace
        trace_stim=squeeze(mMcs(findex, aindex, isiindex,  :));
        trace_stim=trace_stim-mean(trace_stim(1:100));
        trace_stim=trace_stim/max(trace_stim); %normalize stim
        t=1:length(trace1);
        t=t/10;
        plot(t, trace_stim-.5, 'r', t, trace1, 'b' );
%         plot(t, trace1, 'b', t, .005*trace_stim-.03, 'r');
%         xlim([0 10])
%         axis([0 10 -0.040    0.040])
ylim([-1 1])
if findex==1
    xlabel(sprintf('isi %d ms', round(isis(isiindex))))
end
if aindex==1
    xlabel(sprintf(' %d dB', round(amps(aindex))))
end

%        axis off
      %  xlabel(sprintf('%.1fkHz', freqs(findex)))
    end
end
subplot1(ceil(numfreqs/3))
if ~exist('isi'); isi=-666; end
title(sprintf('%s-%s-%s, %s, isi=%dms, mean of %d tones', expdate,session, filenum,area, isi,size(Mc, 3)))
shg

% keyboard

return

%examine trial-by-trial
figure;hold on
offset=.1*max(max(max(max(Mc))));
%findex=numfreqs;
findex=1;
aindex=1;
t=1:size(Mc, 4);t=t*1000/samprate;
for i=1:size(Mc,3)
    trace=squeeze(Mc(findex, aindex, i, :));
    plot(t, trace + offset*i)
end
trace_stim=squeeze(Mcs(1,1,1,:));
trace_stim=trace_stim./max(abs(trace_stim));
plot(t, max(trace)*trace_stim, 'r')

% figure;
% hold on;
% for i=1:size(Mt,1)
%     plot(Mt(i,1:3800)+15*i);
%     plot(Ms(i,1:3800)+15*i, 'r');
% end

% keyboard

