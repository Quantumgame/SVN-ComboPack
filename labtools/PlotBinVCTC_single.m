function PlotBinVCTC_single(expdate, session, filenum,Vout,varargin)
% usage:
% PlotBinVCTC_single('expdate', 'session', 'filenum',Vout,[xlimits])
% default xlimits are [0 300]
% plots binaural tuning curve of synaptic currents
% optimized for fast checking of reversals while you have a cell
% NOTE: to change the xlimits after the .mat file has been made you will
% need to delete it and reprocess the data with new xlimits.
% last updated by mak 31mar2010
% last updated by mak 14feb2011 to fix a plotting bug

if nargin<4 || nargin>5; error('Wrong number of inputs!!!'); end

outfile=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
if nargin==4
    xl=[0 300]; %xlimits
    if exist(outfile,'file')==2;
        load(outfile);
        if xl(1)<out.xlimits(1) || xl(2)>out.xlimits(2) || Vout~=out.Vout
            ProcessBinVCData(expdate, session, filenum,Vout,xl);
            load(outfile);
        end
    else
        ProcessBinVCData(expdate, session, filenum,Vout,xl);
        load(outfile);
    end
elseif nargin==5
    xl=varargin{1};
    if exist(outfile,'file')==2;
        load(outfile);
        if xl(1)<out.xlimits(1) || xl(2)>out.xlimits(2) || Vout~=out.Vout
            ProcessBinVCData(expdate, session, filenum,Vout,xl);
            load(outfile);
        end
    else
        ProcessBinVCData(expdate, session, filenum,Vout,xl);
        try godatadir(expdate, session, filenum)
            load(outfile);
        catch
            godatadirbak(expdate, session, filenum)
            load(outfile);
            
        end
    end
else
    error('PlotBinVCTC_single: wrong number of arguments');
end
in=out;


% fprintf('\nnumber of reps:\n')

M1=in.M1;
mM1=in.mM1;
M1stim=in.M1stim;
expdate=in.expdate;
session=in.session;
filenum=in.filenum;
freqs=in.freqs;
Ramps=in.Ramps;
Lamps=in.Lamps;
durs=in.durs;
potentials=in.potentials;
samprate=in.samprate;
numamps=length(Ramps);
numdurs=length(durs);
numfreqs=length(freqs);
numpotentials=length(potentials);
xlimits=out.xlimits;

filterspikes=out.filterspikes;
nstd=out.nstd;
M1spikes=out.M1spikes;
mM1spikes=out.mM1spikes;
trialsremoved=out.trialsremoved;

if filterspikes==0
    nrepsmax=max(max(max(squeeze(in.nreps))));
    nrepsmin=min(min(min(squeeze(in.nreps))));
elseif filterspikes==1
    aa=squeeze(in.TrialRemainingAfter);
    nrepsmax=max(max(max(sum(aa,4))));
    nrepsmin=min(min(min(sum(aa,4))));
end

%xl are the xlimits we want to use for plotting
%may or may not be same as xlimits used to create outfile

if  length(xl)~=2
    xl=xlimits;
end

%find optimal axis limits
%optimized based on highest potential (will crop low potentials)
ylimits=[0 0];
eachylimit=[0 0];
for dindex=1:numdurs
    for Raindex=numamps:-1:1
        for Laindex=numamps:-1:1
            for findex=1:numfreqs
                %         for pindex=1:numpotentials %(optimize for all potentials)
                for pindex=1:numpotentials %optimized based on highest potential
                    trace1=squeeze(mM1(findex, Raindex, Laindex,dindex, pindex, 1, :));
                    trace1=trace1-mean(trace1(1:100));
                    %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
                    if min(trace1)<ylimits(1); ylimits(1)=min(trace1);end
                    if max(trace1)>ylimits(2); ylimits(2)=max(trace1);end
                    for nrepindex=1:size(M1,6)
                        eachtrace=squeeze(M1(findex, Raindex, Laindex,dindex, pindex,nrepindex, :));
                        eachtrace=eachtrace-mean(eachtrace(1:100));
                        if min(eachtrace)<eachylimit(1); eachylimit(1)=min(eachtrace);end
                        if max(eachtrace)>eachylimit(2); eachylimit(2)=max(eachtrace);end
                    end
                end
            end
        end
    end
end

%ylimits=[-700 700];
%ylimits=[-500 500];
%ylimits=[-300 300];
ylimits(1)=ylimits(1)-.1*diff(ylimits);
eachylimit(1)=eachylimit(1)-.1*diff(eachylimit);


%plot the mean tuning curve
for dindex=1:numdurs
    for findex=1:numfreqs
        figure
        c='bgrycm';
        p=0;
        subplot1( numamps,numamps)
        for Raindex=numamps:-1:1
            for Laindex=1:numamps
                p=p+1;
                subplot1( p)
                for pindex=1:numpotentials
                    trace1=squeeze(mM1(findex, Raindex, Laindex, dindex, pindex, :));
                    trace1=trace1-mean(trace1(1:100));
                    stimtrace=squeeze(mean(M1stim(findex, Raindex, Laindex, dindex, pindex, :, :),6));
                    stimtrace=stimtrace-mean(stimtrace(1:100));
                    stimtrace=stimtrace./max(abs(stimtrace));
                    stimtrace=stimtrace*.1*diff(ylimits);
                    stimtrace=stimtrace+ylimits(1);
                    t=1:length(trace1);
                    t=t/10;
                    t=t+xlimits(1);
                    plot(t, trace1, c(pindex), t, stimtrace, 'm');
                    ylim(ylimits)
                    %ylim([-600 600])
                    xlim(xl);
                    %            axis off
                end
            end
        end
        
        subplot1(1)
        if freqs(findex)/1000 < 1
            h=title(sprintf('%s-%s-%s, WN (%d ms), Max %d, Min %d trials (%d removed)', expdate,session,filenum,durs(dindex),nrepsmax,nrepsmin,trialsremoved));
            set(h, 'HorizontalAlignment', 'left')
        else
            h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), Max %d, Min %d trials (%d removed)', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmax,nrepsmin,trialsremoved));
            set(h, 'HorizontalAlignment', 'left')
        end
        
        %label amps and freqs
        p=0;
        for Raindex=numamps:-1:1
            for Laindex=1:numamps
                p=p+1;
                subplot1(p)
                if Laindex==1
                    if Ramps(Raindex)==-1000
                        text(xl(1)-.2*diff(xl), mean(ylimits), 'silence', 'HorizontalAlignment', 'right');
                    else
                        text(xl(1)-.2*diff(xl), mean(ylimits), int2str(Ramps(Raindex)))
                        set(gca, 'yticklabel', '')
                    end
                end
                if Raindex==1
                    vpos=ylimits(1)-.4*diff(ylimits);
                    if Lamps(Laindex)==-1000
                        text(mean(xl), vpos, 'silence','HorizontalAlignment', 'center');
                    else
                        text(mean(xl), vpos, int2str(Lamps(Laindex)))
                        set(gca, 'xticklabel', '')
                    end
                end
                
                if Laindex==1 & Raindex==floor(numamps/2)
                    vpos=mean(ylimits);
                    T=text(xl(1)-.3*diff(xl), vpos, 'Right','rotation', 90,'HorizontalAlignment', 'center');
                end
                if Laindex==floor(numamps/2) & Raindex==1
                    vpos=ylimits(1)-.3*diff(ylimits);
                    T=text(mean(xl), vpos, 'Left','HorizontalAlignment', 'center');
                end
            end
        end
    end
    
    %set(gcf, 'pos', [588   234   928   719])
end

%plot individual traces all on one plot
for dindex=1:numdurs
    for findex=1:numfreqs
        figure
        c='bgrycm';
        p=0;
        subplot1(numamps,numamps)
        for Raindex=numamps:-1:1
            for Laindex=1:numamps
                p=p+1;
                subplot1(p)
                hold on
                for pindex=1:numpotentials
                    for nrepindex=1:size(M1,6)
                        trace1=squeeze(M1(findex, Raindex, Laindex, dindex, pindex,nrepindex, :));
                        trace1=trace1-mean(trace1(1:100));
                        stimtrace=squeeze(mean(M1stim(findex, Raindex, Laindex, dindex, pindex, :, :),6));
                        stimtrace=stimtrace-mean(stimtrace(1:100));
                        stimtrace=stimtrace./max(abs(stimtrace));
                        stimtrace=stimtrace*.1*diff(ylimits);
                        stimtrace=stimtrace+ylimits(1);
                        t=1:length(trace1);
                        t=t/10;
                        t=t+xlimits(1);
                        plot(t, trace1, c(pindex), t, stimtrace, 'm');
                        ylim(eachylimit)
                        %ylim([-600 600])
                        xlim(xl);
                        %            axis off
                    end
                end
            end
        end
        
        subplot1(1)
        if freqs(findex)/1000 < 1
            h=title(sprintf('%s-%s-%s, WN (%d ms), Max %d, Min %d trials (%d removed)', expdate,session,filenum,durs(dindex),nrepsmax,nrepsmin,trialsremoved));
            set(h, 'HorizontalAlignment', 'left')
        else
            h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), Max %d, Min %d trials (%d removed)', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmax,nrepsmin,trialsremoved));
            set(h, 'HorizontalAlignment', 'left')
        end
        %label amps and freqs
        p=0;
        for Raindex=numamps:-1:1
            for Laindex=1:numamps
                p=p+1;
                subplot1(p)
                if Laindex==1
                    if Ramps(Raindex)==-1000
                        text(xl(1)-.2*diff(xl), mean(ylimits), 'silence', 'HorizontalAlignment', 'right');
                    else
                        text(xl(1)-.2*diff(xl), mean(ylimits), int2str(Ramps(Raindex)))
                        set(gca, 'yticklabel', '')
                    end
                end
                if Raindex==1
                    vpos=ylimits(1)-.4*diff(ylimits);
                    if Lamps(Laindex)==-1000
                        text(mean(xl), vpos, 'silence','HorizontalAlignment', 'center');
                    else
                        text(mean(xl), vpos, int2str(Lamps(Laindex)))
                        set(gca, 'xticklabel', '')
                    end
                end
                
                if Laindex==1 & Raindex==floor(numamps/2)
                    vpos=mean(ylimits);
                    T=text(xl(1)-.3*diff(xl), vpos, 'Right','rotation', 90,'HorizontalAlignment', 'center');
                end
                if Laindex==floor(numamps/2) & Raindex==1
                    vpos=ylimits(1)-.3*diff(ylimits);
                    T=text(mean(xl), vpos, 'Left','HorizontalAlignment', 'center');
                end
            end
        end
    end
    
    %set(gcf, 'pos', [588   234   928   719])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % This plots only the removed trials

if filterspikes==1 || trialsremoved>0
    %find optimal axis limits
    %optimized based on highest potential (will crop low potentials)
    ylimits=[0 0];
    eachylimit=[0 0];
    for dindex=1:numdurs
        for Raindex=numamps:-1:1
            for Laindex=numamps:-1:1
                for findex=1:numfreqs
                    %         for pindex=1:numpotentials %(optimize for all potentials)
                    for pindex=1:numpotentials %optimized based on highest potential
                        trace1=squeeze(mM1spikes(findex, Raindex, Laindex,dindex, pindex, 1, :));
                        trace1=trace1-mean(trace1(1:100));
                        %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
                        if min(trace1)<ylimits(1); ylimits(1)=min(trace1);end
                        if max(trace1)>ylimits(2); ylimits(2)=max(trace1);end
                        for nrepindex=1:size(M1spikes,6)
                            eachtrace=squeeze(M1spikes(findex, Raindex, Laindex,dindex, pindex,nrepindex, :));
                            eachtrace=eachtrace-mean(eachtrace(1:100));
                            if min(eachtrace)<eachylimit(1); eachylimit(1)=min(eachtrace);end
                            if max(eachtrace)>eachylimit(2); eachylimit(2)=max(eachtrace);end
                        end
                    end
                end
            end
        end
    end
    
    ylimits(1)=ylimits(1)-.1*diff(ylimits);
    eachylimit(1)=eachylimit(1)-.1*diff(eachylimit);
    
    %plot individual traces all on one plot
    for dindex=1:numdurs
        for findex=1:numfreqs
            figure
            c='bgrycm';
            p=0;
            subplot1(numamps,numamps)
            for Raindex=numamps:-1:1
                for Laindex=1:numamps
                    p=p+1;
                    subplot1(p)
                    hold on
                    for pindex=1:numpotentials
                        for nrepindex=1:size(M1spikes,6)
                            trace1=squeeze(M1spikes(findex, Raindex, Laindex, dindex, pindex,nrepindex, :));
                            trace1=trace1-mean(trace1(1:100));
                            stimtrace=squeeze(mean(M1stim(findex, Raindex, Laindex, dindex, pindex, :, :),6));
                            stimtrace=stimtrace-mean(stimtrace(1:100));
                            stimtrace=stimtrace./max(abs(stimtrace));
                            stimtrace=stimtrace*.1*diff(ylimits);
                            stimtrace=stimtrace+ylimits(1);
                            t=1:length(trace1);
                            t=t/10;
                            t=t+xlimits(1);
                            plot(t, trace1, c(pindex), t, stimtrace, 'm');
                            ylim(eachylimit)
                            %ylim([-600 600])
                            xlim(xl);
                            %            axis off
                        end
                    end
                end
            end
            
            subplot1(1)
            if freqs(findex)/1000 < 1
                h=title(sprintf('%s-%s-%s, WN (%d ms), Max %d, Min %d trials (%d removed)', expdate,session,filenum,durs(dindex),nrepsmax,nrepsmin,trialsremoved));
                set(h, 'HorizontalAlignment', 'left')
            else
                h=title(sprintf('%s-%s-%s, %.1f kHz (%d ms), Max %d, Min %d trials (%d removed)', expdate,session,filenum,freqs(findex)/1000,durs(dindex),nrepsmax,nrepsmin,trialsremoved));
                set(h, 'HorizontalAlignment', 'left')
            end
            %label amps and freqs
            p=0;
            for Raindex=numamps:-1:1
                for Laindex=1:numamps
                    p=p+1;
                    subplot1(p)
                    if Laindex==1
                        if Ramps(Raindex)==-1000
                            text(xl(1)-.2*diff(xl), mean(ylimits), 'silence', 'HorizontalAlignment', 'right');
                        else
                            text(xl(1)-.2*diff(xl), mean(ylimits), int2str(Ramps(Raindex)))
                            set(gca, 'yticklabel', '')
                        end
                    end
                    if Raindex==1
                        vpos=ylimits(1)-.4*diff(ylimits);
                        if Lamps(Laindex)==-1000
                            text(mean(xl), vpos, 'silence','HorizontalAlignment', 'center');
                        else
                            text(mean(xl), vpos, int2str(Lamps(Laindex)))
                            set(gca, 'xticklabel', '')
                        end
                    end
                    
                    if Laindex==1 & Raindex==floor(numamps/2)
                        vpos=mean(ylimits);
                        T=text(xl(1)-.3*diff(xl), vpos, 'Right','rotation', 90,'HorizontalAlignment', 'center');
                    end
                    if Laindex==floor(numamps/2) & Raindex==1
                        vpos=ylimits(1)-.3*diff(ylimits);
                        T=text(mean(xl), vpos, 'Left','HorizontalAlignment', 'center');
                    end
                end
            end
        end
        
        %set(gcf, 'pos', [588   234   928   719])
    end
end

fprintf('\n')
