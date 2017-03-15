function PlotTracePair(in, findex, aindex)
%plots traces for a freq/amp combo for a pre/post pair
% usage: PlotTrace(in, findex, aindex)
% where in is a datastructure generated e.g. by analyzeprepostTC
%mw 060806


% example of big response getting small
%findex=1;
%aindex=2;

% example of small response getting big
% findex=15;
% aindex=5;

traces_to_discard1=[];
traces_to_discard2=[];

mM1=in.mM1;
mM2=in.mM2;
M1=in.M1;
M2=in.M2;
samprate=in.samprate;
expdate1=in.expdate1;
session1=in.session1;
filenum1=in.filenum1;
expdate2=in.expdate2;
session2=in.session2;
filenum2=in.filenum2;
freqs=in.freqs;
amps=in.amps;
dindex=1;

stimtrace1=squeeze(in.mM1stim(findex, aindex, dindex,:));
stimtrace1=stimtrace1-mean(stimtrace1(1:100));
stimtrace1=stimtrace1./max(abs(stimtrace1));
stimtrace2=squeeze(in.mM2stim(findex, aindex, dindex,:));
stimtrace2=stimtrace2-mean(stimtrace2(1:100));
stimtrace2=stimtrace2./max(abs(stimtrace2));


a=(squeeze(mM1(findex,aindex, 1, 1, :)));
b=(squeeze(mM2(findex,aindex, 1, 1, :)));

a1=a-mean(a(1:500));
b1=b-mean(b(1:500));
stim_scalefactor=.1*(max([a1; b1])-min([a1; b1]));
stim_offset=min([a1; b1])-stim_scalefactor;

t=1:length(a);
t=1000*t/samprate;
figure
r=plot(t, a1, 'b', t, b1, 'r', t, stim_scalefactor*stimtrace1+stim_offset, 'm');
set(r, 'linewidth', 2)
title(sprintf('%s-%s-%s, %s-%s-%s, %.1fkHz, %ddB',expdate1,session1, filenum1,expdate2,session2,filenum2, freqs(findex)/1000, amps(aindex)))
xlim([0 400])
shg


a=(squeeze(M1(findex,aindex, 1, :, :)));
b=(squeeze(M2(findex,aindex, 1, :, :)));


figure
set(gcf, 'pos', [850   107   536   989])
offset=10;
hold on

traces_to_plot1=1:size(a, 1);
traces_to_plot1=setdiff(traces_to_plot1, traces_to_discard1);
traces_to_plot2=1:size(b, 1);
traces_to_plot2=setdiff(traces_to_plot2, traces_to_discard2);
%plot means at bottom
r=plot(t, mean(a(traces_to_plot1,:))-mean(mean(a(traces_to_plot1,1:500))), 'b', t, mean(b(traces_to_plot2,:))-mean(mean(b(traces_to_plot2,1:500))), 'r');
set(r, 'linewidth', 2)

j=0;
if ~isempty(traces_to_discard1) fprintf('\n discarding traces %d', traces_to_discard1); end
for i=traces_to_plot1 %maybe discard some traces
    j=j+1;
    a1=a(i,:);
    a1=a1-mean(a1(1:500));
    r=plot(t, a1+offset*j, 'b');
    set(r, 'linewidth', 1)
end

if ~isempty(traces_to_discard2) fprintf('\n discarding traces %d', traces_to_discard2); end
for i=traces_to_plot2 %maybe discard some traces
    j=j+1;
    b1=b(i,:);
    b1=b1-mean(b1(1:500));
    r=plot(t, b1+offset*j, 'r');
    set(r, 'linewidth', 1)
end
title(sprintf('%s-%s-%s, %s-%s-%s, %.1fkHz, %ddB',expdate1,session1, filenum1,expdate2,session2,filenum2, freqs(findex)/1000, amps(aindex)))
shg


