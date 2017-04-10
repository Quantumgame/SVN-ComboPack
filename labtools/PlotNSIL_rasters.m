function PlotNSIL_rasters(filename,filepath)
% PlotNSIL_rasters(filename,filepath)
% Plots spike raster for natural sound stimuli from a spike time outfile.
% Laser-on trials plotted in green, laser-off trials plotted in black.

cd(filepath);
load(filename); % out_NSspiketimes...
in=out;

expdate=in.expdate; % File identifiers
session=in.session;
filenum=in.filenum;
xlimits=in.xlimits; % Window for extracting spikes (relative to sound onset, in ms)
laserduration=in.laserduration;  % Laser onset and offset time (ms), relative to sound onset
numepochs=in.numepochs; % # of unique sound segments
epochfilenames=in.epochfilenames; % Names of segments
durs=in.durs; % Duration(s) of the stimuli.


% Trial-by-trial spike times are stored in structures 
% M1OFF (laser-off) and M1ON (laser-on), according to the stimulus that was played 
% and the repetition number. We store pretty much every kind of data 
% we collect in the lab in this way -- be it spike times, 
% membrane potential traces,  synaptic conductances, etc... 

% Laser-on trials
M1ON=in.M1ON; % Spike times (in ms), organized by stimulus & repetition.
M1stimON=in.M1stimON; % Sound stimulus (in digital samples/s)
nrepsON=in.nrepsON; % # repetitions
% Laser-off trials
M1OFF=in.M1OFF;
M1stimOFF=in.M1stimOFF;
nrepsOFF=in.nrepsOFF;

%% Plot rasters

figure
if numepochs>1; subplot1(round(numepochs/3),3,'YTickL','None'); end
p=0

time=xlimits(1)+.1:.1:xlimits(2); % (For ploting stimulus traces in ms instead of samples. We sample at 10kHz.)

for ep=1:numepochs % Cycle through stimuli...
    
    p=p+1;
    if numepochs>1; subplot1(p); end
    inc=10;
    set(gca,'yticklabel','');
    
    repstimtrace=squeeze(M1stimON(ep,1,:));
    plot(time,25*mean(repstimtrace,2),'color',[0.6602 0.6602 0.6602]); % Plot the sound, for visualization
    
    % Plot spiketimes for each repetition, laser-off trials
    for rep=1:nrepsOFF(ep)
        hold on
        line(xlimits, [inc inc],'color',[0.6602 0.6602 0.6602])
        spiketimes1=M1OFF(ep,rep).spiketimes;
        h=plot(spiketimes1, repmat(inc,1,length(spiketimes1)),'k.','markersize', 10);
        inc=inc+1;
    end
    
    % Each repetition, laser-on trials
    inc=inc+2;
    for rep=1:nrepsON(ep)
        hold on
        line(xlimits, [inc inc],'color',[0.6602 0.6602 0.6602])
        spiketimes1=M1ON(ep,rep).spiketimes;
        h=plot(spiketimes1, repmat(inc,1,length(spiketimes1)),'.','color',[0.2344 0.6992 0.4414],'markersize', 10);
        inc=inc+1;
    end
    
    % When the laser was on?
    line([laserduration],[inc+2 inc+2],'color',[0.2344 0.6992 0.4414],'linewidth',2)
    xlim(xlimits); ylim([-5 inc+5]);
    
    if numepochs==1 || p==numepochs-2;
        xlabel('ms');
        set(gca,'YTick',[])
        box off
    else
        axis off
    end
    
end

% Total number of spikes
offcount=0; oncount=0;
for ep=1:numepochs
    for rep=1:nrepsON(ep)
        oncount=oncount+length(find(M1ON(ep,rep).spiketimes>0)); % (Prestimulus spikes will be counted as poststimulus spikes for another trial)
    end
    for rep=1:nrepsOFF(ep)
        offcount=offcount+length(find(M1OFF(ep,rep).spiketimes>0));
    end
end

try; subplot1(2); catch; end
title(sprintf('File %s-%s-%s, %.0f unique segment(s), %.0f rep(s): All spikes = %.0f (on trials), %.0f (off trials)',...
    expdate,session,filenum,numepochs,max(max(nrepsOFF)),oncount,offcount));

set(gcf,'color',[1 1 1]);
end
    
    