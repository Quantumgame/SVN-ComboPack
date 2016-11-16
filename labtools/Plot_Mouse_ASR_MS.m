
% USE THIS PROGRAM TO SUPERIMPOSE MANY MOUSE ASR PLOTS ON ONE GRAPH
% Modeled after "PlotMultiMousePPI.m"
% It works in conjunction with Plot_Mouse_NBPIAS_MS.m & PlotMultiASR.m
% To use:
%   1)edit PlotMultiMouseASR.m
%   2)Adjust c as needed
%   3)Adjust mousenum & data/dir/file for each mouse added
%   4)SAVE
%   5)CLOSE ALL OPEN FIGURES -- I still need to solve this bug...
% Last edited by Michael on 9-24-8 time???
% If PROGRAMMING CODE changes are made, update PlotMultiMousePPI.m accordingly

clear all
c=1:(64/8):64; % denominator in middle argument needs to be >= the number of plots
map=colormap;
plotindex=1;
textyax=2500:-100:0; %Plots for up to 12 mice on one graph, alter if necessary
textxax=8;

% *** For each subplot you must change 1) mousenum(date,dir,fil) & 2) Plot_Mouse_NBPIAS_MS('DDMMYY','DIR','FIL');

% Copy from here...

mousenum='Mouse 126(091508,001,007)';
[numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_NBPIAS_MS('091508','001','007');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiASR;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));
figure(1);
plotindex=plotindex+1;

% ... to here, to add each additional graph 

% This is the last of the superimposed graphs
mousenum='Mouse 175(091508,001,003)';
[numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_NBPIAS_MS('091508','001','003');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiASR;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

hold off
clear all

