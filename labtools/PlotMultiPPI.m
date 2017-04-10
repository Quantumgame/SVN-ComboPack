
% PlotMultiPPI.m
%   Last updated 9-26-8 at 1:40PM by Michael
% This program is called on by PlotMultiMousePPI.m to superimpose many Mouse PPI plots
% Previously named "AndrewZed2"
% Works in conjunction with Plot_Mouse_PPI 

%Plot the mean of the peaks for each ppa
for ppaindex=1:numprepulseamps;
    for k=1:nreps1(ppaindex);
        trace1=squeeze(M1(ppaindex, k, :));
        peak(ppaindex, k)=(max(abs(trace1(startle_start*samprate/1000:(startle_start+window_duration)*samprate/1000))));
        peak_prepulse(ppaindex, k)=(max(abs(trace1(prepulse_start*samprate/1000:(prepulse_start+window_duration)*samprate/1000))));
        peak_baseline(ppaindex, k)=(max(abs(trace1(baseline_start*samprate/1000:(baseline_start+window_duration)*samprate/1000))));

    end
    m(ppaindex)=mean(peak(ppaindex, 1:nreps1(ppaindex)));
    mPP(ppaindex)=mean(peak_prepulse(ppaindex, 1:nreps1(ppaindex)));
    mBL(ppaindex)=mean(peak_baseline(ppaindex, 1:nreps1(ppaindex)));
    s(ppaindex)=(std(peak(ppaindex, 1:nreps1(ppaindex))))/sqrt(length(peak(ppaindex, 1:nreps1(ppaindex))));
    sPP(ppaindex)=(std(peak_prepulse(ppaindex, 1:nreps1(ppaindex))))/sqrt(length(peak_prepulse(ppaindex, 1:nreps1(ppaindex))));
    sBL(ppaindex)=(std(peak_baseline(ppaindex, 1:nreps1(ppaindex))))/sqrt(length(peak_baseline(ppaindex, 1:nreps1(ppaindex))));
end

set(gca, 'linewidth', 2);
set(gca, 'xtick', 1:numprepulseamps,  'xticklabel', prepulseamps);
title(sprintf('Pre-Pulse Inhibition \nPulse Amplitude: 80(dB SPL)\n Date Printed: %s',datestr(now,'dd-mmm-yyyy HH:MM PM')));
ylabel('Startle Response Amplitude (mV)');
xlabel('Pre-pulse Amplitude (dB SPL)');
ylim([0 2600]);

