
% PlotMultiPPI_NBPIAS.m
%   Last updated 10-13-8 at 2:00AM by Michael
% This program is called on by PlotMultiMousePPI.m to superimpose many Mouse NBPIAS plots
% Works in conjunction with Plot_Mouse_PPI.m 


for p=2:numprepulseamps;
    m1=m(1);
    m2=m(p);
    percentNBPIAS(p)=((m1-m2)/m1)*100;
end
hold on
title(sprintf('Percent Pre-Pulse Inhibition \n%%PPI=[(No Startle at -1000)-(Startle at Prepulses)]/(No Startle at -1000) \nPulse Amp: 80(dB SPL)  \nDate Printed: %s',datestr(floor(now))))
ylabel('Percent Inhibition')
xlabel('Pre-pulse Amplitude (dB SPL)')
xlim([-5 prepulseamps(end)+5])
ylim([-60 140])
