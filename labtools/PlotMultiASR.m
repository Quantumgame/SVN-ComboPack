

% PlotMultiASR.m
%   Last edited by Michael on 9-26-8 at 1:25PM
% This program is called on by PlotMultiMouseASR.m to superimpose many Mouse ASR plots
% Modeled after "PlotMultiPPI.m"
% Works in conjunction with Plot_Mouse_ASR.m 

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
set(gca, 'xtick', [1:numprepulseamps numprepulseamps+1],  'xticklabel', [prepulseamps prepulseamps(end)+10]);
%     The previous line is a hack to include the response to the pulse
%     when ppa is -1000, which is currently set to 80dB 
%     9-26-8 at 1:23PM by Michael
title(sprintf('Acoustic Startle Response \nDate Printed: %s',datestr(now,'dd-mmm-yyyy HH:MM PM')));
ylabel('Startle Response Amplitude (mV)');
xlabel('Startle Pulse Amplitude (dB SPL)');
ylim([0 2500]);

