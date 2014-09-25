function MonitorSpikes(outfilename,filteredtrace,nstd,dspikes)
% Created due to widespread use in many spike threshold functions to
% maintain consistency throughout the Wehr lab platforms
% (e.g., PlotTC_psth, PlotILArch_mak)
% usage: MonitorSpikes(outfilename,filteredtrace,nstd,dspikes,lostat)
% Place the above line within the if monitor... ...end condition
% If you want to use the individual spike 'video' I'll need to further
% update this.
% 28Apr2013 by mak

dbstop if error
global pref
if isempty(pref); Prefs; end

if length(nstd)==2
    if nstd(1)==-1
        thresh=nstd(2);
        nstd=thresh/std(filteredtrace);
    end
else
    thresh=nstd*std(filteredtrace);
end

figure; hold on
plot(filteredtrace, 'b')
plot(dspikes, thresh*ones(size(dspikes)), 'r*')
h=get(gca,'ylim');
xlimits=get(gca,'xlim');
L1=line(xlimits, thresh*[1 1]);
L2=line(xlimits, thresh*[-1 -1]);
set([L1 L2], 'color', 'g');

lostatfile=sprintf('lostat-%s',outfilename(end-16:end));
try load(lostatfile);
catch
    lostat=length(filteredtrace);
end
L3=line([lostat lostat],h);
set(L3,'linestyle',':','color','k','linewidth',2)
title(sprintf('%s -- %.2f mV, %.2f std',outfilename(end-17:end-4),thresh,nstd))
   
if false % monitor video looking at each spike with a brief pause
    figure
    ylim([min(filteredtrace) max(filteredtrace)]);
    for ds=dspikes(1:20)
        xlim([ds-100 ds+100])
        t=1:length(filteredtrace);
        region=[ds-100:ds+100];
        if min(region)<1
            region=[1:ds+100];
        end
        hold on
        plot(t(region), filteredtrace(region), 'b')
        plot(spikes, thresh*ones(size(spikes)), 'g*')
        plot(dspikes, thresh*ones(size(dspikes)), 'r*')
        line(xlim, thresh*[1 1])
        line(xlim, thresh*[-1 -1])
        pause(.05)
        hold off
    end
    pause(.5)
    close
end



