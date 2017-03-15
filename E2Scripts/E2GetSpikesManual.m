function spikes=E2GetSpikesManual(data, nativeScaling, nativeOffset)

% (Interactively) Gets the positions of spikes in the data vector
% Uses E2ExtractSpikesManual to do the spike detection
% Input:
%       data            -   data vector (double or int16)
%       nativeScaling   -   
%       nativeOffset    -   scaling factors if the input is in int16
%
% Output:
%       spikes          -   vector with POSITIONS of spikes in data (in samples)
%                           empty if unsuccessful
%
% in each window -  left click or right arrow=continue to next trial, 
%                   middle click=change threshold (with left click), 
%                   right click=pause (to zoom in, for example) and continue with Enter,
%                   0 = change downward_spikes to 0
%                   1 = change downward spikes to 1
%

spikes=[];

if nargin<1 | isempty(data)
	return;
end

if nargin<2 | isempty(nativeScaling)
	nativeScaling=1;
end

if nargin<1 | isempty(nativeOffset)
	nativeOffset=1;
end

% sweeplength=10;                      % max. length (in sec) of one sweep on screen
% sweepsamples=sweeplength*samplerate;
sweepsamples=100000;    % max. length of one sweep on screen (10s @ 10kHz)
% overlap=samplerate/10;              % 100ms overlap
overlap=1000;           % window overlap (100ms @ 10kHz)

% default parameters for E2ExtractSpikes
remove_downward_spikes=0;
threshold=1;

screensize=get(0,'Screensize');
fig=figure('Unit','pixels','Position',[screensize(3)*.1 screensize(4)*.1 screensize(3)*.8 screensize(4)*.8]);
plot1=subplot(2,1,1);
plot2=subplot(2,1,2);

spikes=[];

    alldatasamples=length(data);
    ndatapasses=ceil(alldatasamples/sweepsamples);
    
    for datapass=1:ndatapasses
        fromdatasample=(datapass-1)*sweepsamples+1;
        todatasample=datapass*sweepsamples+overlap;
        if todatasample>alldatasamples;
            todatasample=alldatasamples;
        end
        raw_sweep=nativeScaling.*(double(data(fromdatasample:todatasample)))+nativeOffset;
        [sweep_spikes,filtered]=E2ExtractSpikesManual(raw_sweep,threshold,remove_downward_spikes);
        subplot(plot1); hold off;
        plot(raw_sweep);
        set(gca,'XLim',[1 length(raw_sweep)]);
	    labels=get(gca,'XTick');
	    %set(gca,'XTickLabel',(labels+fromsample+fromdatasample-2)./samplerate);
        subplot(plot2); hold off;
        plot(filtered);
        set(gca,'XLim',[1 length(filtered)]);
	    labels=get(gca,'XTick');
	    %set(gca,'XTickLabel',(labels+fromsample+fromdatasample-2)./samplerate);
	    xlim=get(gca,'XLim');
	    plotfrom=xlim(1);   minplot=plotfrom;
	    plotto=xlim(2);     maxplot=plotto;
        hold on;
        spplot=plot(sweep_spikes,'r');
        thplot=plot([1; length(sweep_spikes)],[threshold; threshold],'g');        
        reextract=0;
        
        while 1  %'interactive' loop
         [x,y,b]=ginput(1);
         switch b
            case   {1, 29} %left click, right arrow = accept and advance to next datapass
                break;
            case   2 % middle click = I want to change the threshold
                [x,y,b]=ginput(1);
                if b==1
                    threshold=y;
                    reextract=1;
                end
            case   3 % I just want to take a look and maybe change the resolution
		        zoom xon;
                pause;
		        zoom off;
            case 48 %0
                remove_downward_spikes=0;
                reextract=1;
            case 49 %1
                remove_downward_spikes=1;
                reextract=1;
         end %switch

         subplot(plot2);
	     xlim=get(gca,'XLim');
	     plotfrom=max([minplot round(xlim(1))]);
	     plotto=min([maxplot round(xlim(2))]);
         if reextract
             [sweep_spikes(plotfrom:plotto),filtered(plotfrom:plotto)]=E2ExtractSpikesManual(raw_sweep(plotfrom:plotto),threshold,remove_downward_spikes);
             reextract=0;
         end
         plot(filtered);
         set(gca,'XLim',[plotfrom plotto]);
         delete(spplot);
	     spplot=plot(sweep_spikes,'r');
	     delete(thplot);
         thplot=plot([1; length(sweep_spikes)],[threshold; threshold],'g');        
  	     labels=get(gca,'XTick');
 	     %set(gca,'XTickLabel',(labels+fromsample+fromdatasample-2)./samplerate);
        end % while 1

        spike_pos=find(sweep_spikes==1);    % before we go the next datapass, we remember the position of the spikes so far
	if ~isempty(spike_pos)
		spikes=[spikes; spike_pos+fromdatasample-1];
	end
        
    end   %for datapass=1:ndatapasses   % individual data sweeps in the huge chunk of data
 
% end %for pass=1:npasses     % main data file processing loop
 
spikes=unique(spikes);  % IMPORTANT, because we are using overlapping windows

close(fig);
