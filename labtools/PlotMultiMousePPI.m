
% ***THIS IS THE FUNCTION TO USE: PlotMultiMousePPI***
%   Last updated 9-24-8 at 4:19PM by Michael
% USE THIS PROGRAM TO SUPERIMPOSE MANY MOUSE PPI PLOTS ON ONE GRAPH
% Previously named "AndrewZed.m"
% It works in conjunction with Plot_Mouse_PPI.m, PlotMultiPPI.m & PlotMultiPPI_NBPIAS.m
% To use:
%   1)edit PlotMultiMousePPI.m
%   2)Adjust c as needed
%   3)Use Mouse.m to cut/past mousenum & data/dir/file for each mouse plot
%   4)SAVE
%   5)CLOSE ALL OPEN FIGURES -- I still need to solve this bug...
% If PROGRAMMING CODE changes are made, be sure to update PlotMultiMouseASR.m accordingly

clear all
c=1:(64/8):64; % denominator in middle argument needs to be >= the number of plots
map=colormap;
plotindex=1;
textyax=2550:-100:0; %Alter if necessary
textxax=6;
NBPIAStextyax=135:-10:0;
NBPIAStextxax=0;
% *** For each subplot you must change 1) mousenum(date,dir,fil) & 2) Plot_Mouse_PPI('DDMMYY','DIR','FIL');


% 126
mousenum='Mouse 126(091508,001,007)';
[p,m1,m2,percentNBPIAS,numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_PPI('091508','001','007');
% Copy from here...
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiPPI;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(200)
hold on
PlotMultiPPI_NBPIAS;
h=plot(prepulseamps(2:numprepulseamps),percentNBPIAS(2:numprepulseamps));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(NBPIAStextxax,NBPIAStextyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(1);
plotindex=plotindex+1;
% ... to here, to add each additional graph 

% 130
mousenum='Mouse 130(091508,001,001)';
[p,m1,m2,percentNBPIAS,numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_PPI('091508','001','001');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiPPI;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(200)
hold on
PlotMultiPPI_NBPIAS;
h=plot(prepulseamps(2:numprepulseamps),percentNBPIAS(2:numprepulseamps));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(NBPIAStextxax,NBPIAStextyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(1);
plotindex=plotindex+1;

% 131
mousenum='Mouse 131(091508,001,004)';
[p,m1,m2,percentNBPIAS,numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_PPI('091508','001','004');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiPPI;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(200)
hold on
PlotMultiPPI_NBPIAS;
h=plot(prepulseamps(2:numprepulseamps),percentNBPIAS(2:numprepulseamps));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(NBPIAStextxax,NBPIAStextyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(1);
plotindex=plotindex+1;

% 146
mousenum='Mouse 146(091608,001,003)';
[p,m1,m2,percentNBPIAS,numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_PPI('091608','001','003');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiPPI;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(200)
hold on
PlotMultiPPI_NBPIAS;
h=plot(prepulseamps(2:numprepulseamps),percentNBPIAS(2:numprepulseamps));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(NBPIAStextxax,NBPIAStextyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(1);
plotindex=plotindex+1;

% 148
mousenum='Mouse 148(091608,001,004)';
[p,m1,m2,percentNBPIAS,numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_PPI('091608','001','004');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiPPI;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(200)
hold on
PlotMultiPPI_NBPIAS;
h=plot(prepulseamps(2:numprepulseamps),percentNBPIAS(2:numprepulseamps));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(NBPIAStextxax,NBPIAStextyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(1);
plotindex=plotindex+1;

% 159
mousenum='Mouse 159(091508,001,008)';
[p,m1,m2,percentNBPIAS,numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_PPI('091508','001','008');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiPPI;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(200)
hold on
PlotMultiPPI_NBPIAS;
h=plot(prepulseamps(2:numprepulseamps),percentNBPIAS(2:numprepulseamps));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(NBPIAStextxax,NBPIAStextyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(1);
plotindex=plotindex+1;

% 171
mousenum='Mouse 171(091508,001,002)';
[p,m1,m2,percentNBPIAS,numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_PPI('091508','001','002');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiPPI;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(200)
hold on
PlotMultiPPI_NBPIAS;
h=plot(prepulseamps(2:numprepulseamps),percentNBPIAS(2:numprepulseamps));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(NBPIAStextxax,NBPIAStextyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(1);
plotindex=plotindex+1;

% 175
mousenum='Mouse 175(091508,001,003)';
[p,m1,m2,percentNBPIAS,numprepulseamps,nreps1,M1,startle_start,samprate, window_duration,prepulse_start,baseline_start,prepulseamps]=...
    Plot_Mouse_PPI('091508','001','003');
for i=1:99, figure(i), close, end, clear i
figure(100)
hold on
PlotMultiPPI;
h=plot(1:numprepulseamps, m);
errorbar(1:numprepulseamps, m, s,'color', map(c(plotindex),:));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(textxax,textyax(plotindex),mousenum, 'color', map(c(plotindex),:));

figure(200)
hold on
PlotMultiPPI_NBPIAS;
h=plot(prepulseamps(2:numprepulseamps),percentNBPIAS(2:numprepulseamps));
set(h, 'marker', '.','markersize',10, 'color', map(c(plotindex),:));
text(NBPIAStextxax,NBPIAStextyax(plotindex),mousenum, 'color', map(c(plotindex),:));



% ** Delete the following from the last mouse to plot:
% figure(1);
% plotindex=plotindex+1;

hold off
clear all

