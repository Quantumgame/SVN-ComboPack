
% THIS IS THE FUNCTION TO USE: PlotMultiMouseASR***
%   Last updated 9-26-8 at 2:23PM by Michael
% USE THIS PROGRAM TO SUPERIMPOSE MANY MOUSE ASR PLOTS ON ONE GRAPH
% Modeled after "PlotMultiMousePPI.m"
% It works in conjunction with Plot_Mouse_ASR.m & PlotMultiASR.m
% To use:
%   1)edit PlotMultiMouseASR.m
%   2)Adjust c as needed
%   3)Use Mouse.m to cut/past mousenum & data/dir/file for each mouse plot
%   4)SAVE
%   5)CLOSE ALL OPEN FIGURES -- I still need to solve this bug...
% If PROGRAMMING CODE changes are made, update PlotMultiMousePPI.m accordingly

clear all
c=1:(64/4):64; % denominator in middle argument needs to be >= the number of plots
map=colormap;
plotindex=1;
textyax=2400:-100:0; %Plots for up to ~12 mice on one graph, alter if necessary
textxax=0.5;

% *** For each subplot you must change 1) mousenum(date,dir,fil) & 2) Plot_Mouse_ASR('DDMMYY','DIR','FIL');

% Copy from here...

mousenum='Mouse 110(091508,001,006)';
[numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_ASR('091508','001','006');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiASR;
h=plot([1:numprepulseamps numprepulseamps+1], [mPP m(1)]);
errorbar([1:numprepulseamps numprepulseamps+1], [mPP m(1)], [sPP s(1)],'color', map(c(plotindex),:));
%     The previous two lines are hacks to include the response to the pulse
%     when ppa is -1000, which is currently 80dB
%   9-26-8 at 1:23PM by Michael
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));
figure(1);
plotindex=plotindex+1;

% ... to here, to add each additional graph 



mousenum='Mouse 111(091608,001,001)';
[numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_ASR('091608','001','001');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiASR;
h=plot([1:numprepulseamps numprepulseamps+1], [mPP m(1)]);
errorbar([1:numprepulseamps numprepulseamps+1], [mPP m(1)], [sPP s(1)],'color', map(c(plotindex),:));
%     The previous two lines are hacks to include the response to the pulse
%     when ppa is -1000, which is currently 80dB
%   9-26-8 at 1:23PM by Michael
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));
figure(1);
plotindex=plotindex+1;


mousenum='Mouse 112(091508,001,005)';
[numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_ASR('091508','001','005');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiASR;
h=plot([1:numprepulseamps numprepulseamps+1], [mPP m(1)]);
errorbar([1:numprepulseamps numprepulseamps+1], [mPP m(1)], [sPP s(1)],'color', map(c(plotindex),:));
%     The previous two lines are hacks to include the response to the pulse
%     when ppa is -1000, which is currently 80dB
%   9-26-8 at 1:23PM by Michael
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));
figure(1);
plotindex=plotindex+1;


% This is the last of the superimposed graphs
mousenum='Mouse 113(091608,001,002)';
[numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_ASR('091608','001','002');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiASR;
h=plot([1:numprepulseamps numprepulseamps+1], [mPP m(1)]);
errorbar([1:numprepulseamps numprepulseamps+1], [mPP m(1)], [sPP s(1)],'color', map(c(plotindex),:));
%     The previous two lines are hacks to include the response to the pulse
%     when ppa is -1000, which is currently 80dB
%   9-26-8 at 1:23PM by Michael
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

hold off
clear all

