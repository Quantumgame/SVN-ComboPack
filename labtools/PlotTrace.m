function PlotTrace(in, findex, aindex)
%plots traces for a freq/amp combo 
%note: to plot a pair of traces (e.g. a pre/post pair) use PlotTracePair
% usage: PlotTrace(in, findex, aindex)
% where in is a datastructure generated e.g. by ProcessVCData
%mw 081406



traces_to_discard1=[];
traces_to_discard2=[];

mM1=in.mM1;
M1=in.M1;
samprate=in.samprate;
expdate1=in.expdate;
session1=in.session;
filenum1=in.filenum;
freqs=in.freqs;
amps=in.amps;

a=(squeeze(mM1(findex,aindex, 1, 1, :)));

a1=a-mean(a(1:500));
t=1:length(a);
t=1000*t/samprate;
figure
r=plot(t, a1);
set(r, 'linewidth', 2)
shg


a=(squeeze(M1(findex,aindex, 1, :, :)));


figure
set(gcf, 'pos', [850   107   536   989])
offset=10;
hold on

traces_to_plot1=1:size(a, 1);
traces_to_plot1=setdiff(traces_to_plot1, traces_to_discard1);
%plot means at bottom
r=plot(t, mean(a(traces_to_plot1,:))-mean(mean(a(traces_to_plot1,1:500))));
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

title(sprintf('%s-%s-%s, %.1fkHz, %ddB',expdate1,session1, filenum1, freqs(findex)/1000, amps(aindex)))
shg

return
combplot([19 20 ], [1 2])
orient tall
