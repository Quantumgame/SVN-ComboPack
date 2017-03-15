%getN1_TTS
% script to look at ABR TCs before and after a trauma, and automatically calculate the
% threshold shift of the N1 component using a ttest 

expdate='101707';
session='001';
filenum1='002';% pre:
filenum2='003';% post:


%  process
if (0)
    ProcessData_single(expdate, session, filenum1)
    ProcessData_single(expdate, session, filenum2)

    ProcessToneTrain(expdate, session, filenum1)
    ProcessToneTrain(expdate, session, filenum2)

    PlotToneTrain(expdate, session, filenum1)
    PlotToneTrain(expdate, session, filenum2)
end

%load data for file1
if(1)
    filenum=filenum2;
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
end
samprate=1e4;
mMc=mean(Mc, 3);
mMcs=mean(Mcs, 3);
xl=[5 20];
yl=[-.1 .1];
stim_scalefactor=.2*diff(yl);
stim_offset=-yl(1)/2;

%identify window for N1 component
N1window=[7 10]; %in ms

loudestWN=squeeze(mMc(1, 7, :));
loudestWN=loudestWN-mean(loudestWN); 
loudestmAll=squeeze(mean(mMc(:, 7, :)));
loudestmAll=loudestmAll-mean(loudestmAll); 
N1window_samples=N1window(1)*samprate/1000: N1window(2)*samprate/1000;
PREwindow_samples=N1window_samples-N1window_samples(1)+1;
t=1:length(loudestWN);
t=t*1000/samprate;

figure
plot(t, loudestmAll)
L(1)=line(N1window, [0 0]);
L(2)=line([N1window(1) N1window(1)], ylim);
L(3)=line([N1window(2) N1window(2)], ylim);
hold on
plot(t(PREwindow_samples),loudestWN(PREwindow_samples), 'g')
set(L, 'color', 'r')
title('mean of all loudest tones')

figure
plot(t, loudestWN)
L(1)=line(N1window, [0 0]);
L(2)=line([N1window(1) N1window(1)], ylim);
L(3)=line([N1window(2) N1window(2)], ylim);
set(L, 'color', 'r')
hold on
plot(t(PREwindow_samples),loudestWN(PREwindow_samples), 'g')
title('loudest click')

aindex=7;
findex=20;
N1traces=squeeze(Mc(findex, aindex, :,N1window_samples));
PREtraces=squeeze(Mc(findex, aindex, :,PREwindow_samples));
[h, p]=ttest(max(N1traces'), max(PREtraces'))

% figure
% plot(trace1')
% figure
% plot(mean(trace1))



%figure out where max N1 is significantly greater than max baseline
for aindex=[numamps:-1:1]
    for findex=1:numfreqs
        N1traces=squeeze(Mc(findex, aindex, :,N1window_samples));
        PREtraces=squeeze(Mc(findex, aindex, :,PREwindow_samples));
        [h, p]=ttest(max(N1traces'), max(PREtraces'), [],'right');
        N1p(findex, aindex)=p;
        N1h(findex, aindex)=h;
    end
end
        
% %figure out where mean N1 is significantly greater than mean baseline
% for aindex=[numamps:-1:1]
%     for findex=1:numfreqs
%         N1traces=squeeze(Mc(findex, aindex, :,N1window_samples));
%         PREtraces=squeeze(Mc(findex, aindex, :,PREwindow_samples));
%         [h, p]=ttest(median(N1traces'), median(PREtraces'));
%         N1p(findex, aindex)=p;
%         N1h(findex, aindex)=h;
%     end
% end
        
figure
imagesc(1-N1p')
set(gca, 'ydir', 'normal')

figure
imagesc(N1h')
set(gca, 'ydir', 'normal')

        
% 
% %plot the mean tuning curves for pre and post
figure
aindex=2;
findex=13;
trace1=squeeze(mMc(findex, aindex, :));
trace1=trace1-mean(trace1(1:100));
trace_stim=squeeze(mMcs(findex, aindex, :));
trace_stim=trace_stim-mean(trace_stim(1:100));
trace_stimn=trace_stim/max(trace_stim); %normalize stim
t=1:length(trace1);
t=t/10;
plot(t, trace1, 'b', t, stim_scalefactor*trace_stimn-stim_offset, 'r');
ylim(yl)
a=(sprintf('%d dB',    round(amps(aindex))));
f=(sprintf('%d kHz', round(freqs1(findex))));
title([a, f])
L(1)=line(N1window, [0 0]);
L(2)=line([N1window(1) N1window(1)], ylim);
L(3)=line([N1window(2) N1window(2)], ylim);
hold on
plot(t(PREwindow_samples),trace1(PREwindow_samples), 'g')
shg

% %plot the mean tuning curves for pre and post
% figure
% p=0;
% for aindex=[numamps:-1:1]
%     for findex=1:numfreqs
%         p=p+1;
%         %        subplot1( p)
%         trace1=squeeze(mMc(findex, aindex, :));
%         trace1=trace1-mean(trace1(1:100));
%         trace_stim=squeeze(mMcs(findex, aindex, :));
%         trace_stim=trace_stim-mean(trace_stim(1:100));
%         trace_stimn=trace_stim/max(trace_stim); %normalize stim
%         t=1:length(trace1);
%         t=t/10;
%         plot(t, trace1, 'b', t, stim_scalefactor*trace_stimn-stim_offset, 'r');
%         xlim(xl)
%         ylim(yl)
%         %        axis([0 15 -0.040    0.040])
% 
%         a=(sprintf('%d dB',    round(amps(aindex))));
%         f=(sprintf('%d kHz', round(freqs1(findex))));
%         title([a, f])
% shg
% pause(.5)
%     end
% end



