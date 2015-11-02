function PlotILTC_OE(varargin)

% usage: PlotILTC_OE(expdate,session,filenum, [xlimits],[ylimits],channel number)
%or PlotTC_OE(outfilename, [xlimits],[ylimits])
% (xlimits & ylimits are optional)
% xlimits default to [0 200]
% channel number must be a string
%
%Processes data if outfile is not found; ProcessTC is only used to find
%correct data files
%ira 04-01-2014
%

expdate=varargin{1};
session=varargin{2};
filenum=varargin{3};

try
    xlimits=varargin{4};
catch
    xlimits=[0 200];
end
try
    ylimits=varargin{5};
catch
    ylimits=[];
end
try
    channel=varargin{6};
catch
    promt=('please enter channel number: ');
    channel=input(promt,'s')
end
if ~strcmp('char',class(channel))
    channel=num2str(channel);
    %error('Channel number argument must be a string!')
end
high_pass_cutoff=400;
[a,b]=butter(1, high_pass_cutoff/(30e3/2), 'high');
fprintf('\nusing xlimits [%d-%d]', xlimits(1), xlimits(2))
gogetdata(expdate,session,filenum);
outfilename=sprintf('outOE%s_%s-%s-%s.mat',channel, expdate, session, filenum);
%outfilename=sprintf('outOE%s-%s-%s.mat', expdate, session, filenum);
if exist(outfilename,'file')
    load(outfilename)
else
    ProcessTC_OE(expdate,session,filenum, xlimits, ylimits, channel);
    load(outfilename);
end

try
    if out.isrecording==0
        warning('Open Ephys appears not to have been recording when the exper file was taken')
    end
end
%     case 1
%         outfilename=varargin{1};
%         load(outfilename)
%         xlimits=[];
%         ylimits=[];
%     case 2
%         outfilename=varargin{1};
%         load(outfilename)
%         xlimits=varargin{2};
%         ylimits=[];
%     case 3
%         if strfind(varargin{1}, '.mat')
%             outfilename=varargin{1};
%             xlimits=varargin{2};
%             ylimits=varargin{3};
%             load(outfilename)
%         else
%             expdate=varargin{1};
%             session=varargin{2};
%             filenum=varargin{3};
%             godatadir(expdate, session, filenum)
%             outfilename=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
%             load(outfilename)
%             xlimits=[];
%             ylimits=[];
%         end
%     case 4
%         expdate=varargin{1};
%         session=varargin{2};
%         filenum=varargin{3};
%         xlimits=varargin{4};
%         ylimits=[];
%         godatadir(expdate, session, filenum)
%         outfilename=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
%         load(outfilename)
%     case 5
%         expdate=varargin{1};
%         session=varargin{2};
%         filenum=varargin{3};
%         xlimits=varargin{4};
%         ylimits=varargin{5};
%         godatadir(expdate, session, filenum)
%         outfilename=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
%         load(outfilename)
% end

M1stim=out.M1stim;
freqs=out.freqs;
amps=out.amps;
durs=out.durs;
nreps=out.nreps;
numfreqs=out.numfreqs;
numamps=out.numamps;
numdurs=out.numdurs;
expdate=out.expdate;
session=out.session;
filenum=out.filenum;
samprate=out.samprate; %in Hz
M1=out.M1;
lostat=out.lostat;
scaledtrace=out.scaledtrace;
traces_to_keep=out.traces_to_keep;
mM1=out.mM1;
mM1ON=out.mM1ON;
mM1OFF=out.mM1OFF;
nrepsON=out.nrepsON;
nrepsOFF=out.nrepsOFF;

% %
% % [datafile, eventsfile, stimfile]=getfilenames(expdate, session, filenum);
% % OEeventsfile=strrep(eventsfile, 'AxopatchData1', 'OE');
% % godatadir(expdate,session,filenum);
% % try
% %     load(OEeventsfile);
% % catch
% %     OEgetEvents(expdate, session, filenum);
% %     load(OEeventsfile)
% % end
% %
% % %check for laser in events
% % for i=1:length(event)
% %     if isfield(event(i).Param, 'AOPulseOn')
% %         aopulseon(i)=event(i).Param.AOPulseOn;
% %     else
% %         aopulseon(i)=0;
% %         event(i).Param.AOPulseOn=0;
% %     end
% % end
% % fprintf('\n%d laser pulses in this events file', sum(aopulseon))
% %
% % numfreqs=length(freqs);
% % numamps=length(amps);
% % numdurs=length(durs);
% % nrepsON=zeros(numfreqs, numamps, numdurs);
% % nrepsOFF=zeros(numfreqs, numamps, numdurs);
% % M1=[];
% %
% % if isempty(xlimits)
% %     xlimits=out.xlimits;
% % end

% % %extract the traces into a big matrix M
% % j=0;
% % for i=1:length(event)
% %     if strcmp(event(i).Type, 'tone') || strcmp(event(i).Type, 'whitenoise') ||...
% %             strcmp(event(i).Type, 'fmtone')
% %         if isfield(event(i), 'soundcardtriggerPos')
% %             pos=event(i).soundcardtriggerPos; %in samples
% %             if isempty(pos) && ~isempty(event(i).Position_rising)
% %                 pos=event(i).Position;
% %                 fprintf('\nWARNING! Missing a soundcard trigger. Using hardware trigger instead.')
% %             end
% %         else
% %             pos=event(i).Position*samprate; %in samples
% %             fprintf('noSCT %d ',event(i).Param.AOPulseOn )
% %         end
% %
% %         aopulseon=event(i).Param.AOPulseOn;
% %
% %         start=(pos+xlimits(1)*1e-3*samprate);
% %         stop=(pos+xlimits(2)*1e-3*samprate)-1;
% %         start=round(start); stop=round(stop);
% %         start=start+out.xlimits(1); %correct for original xlimits
% %         stop=stop+out.xlimits(1);
% %         region=start:stop;
% %         if isempty(find(region<0)) %(disallow negative start times)
% %             if stop>lostat
% %                 fprintf('\ndiscarding trace')
% %             else
% %                 if strcmp(event(i).Type, 'tone')
% %                     freq=event(i).Param.frequency;
% %                 elseif strcmp(event(i).Type, 'whitenoise')
% %                     freq=-1;
% %                 elseif strcmp(event(i).Type, 'fmtone')
% %                     freq=event(i).Param.carrier_frequency;
% %                 end
% %                 amp=event(i).Param.amplitude;
% %                 dur=event(i).Param.duration;
% %                 findex= find(freqs==freq);
% %                 aindex= find(amps==amp);
% %                 dindex= find(durs==dur);
% %
% %                 if aopulseon
% %                     nrepsON(findex, aindex, dindex)=nrepsON(findex, aindex, dindex)+1;
% %                     M1ON(findex,aindex,dindex, nrepsON(findex, aindex, dindex),:)=scaledtrace(region);
% %                 else
% %                     nrepsOFF(findex, aindex, dindex)=nrepsOFF(findex, aindex, dindex)+1;
% %                     M1OFF(findex,aindex,dindex, nrepsOFF(findex, aindex, dindex),:)=scaledtrace(region);
% %                 end
% %             end
% %         end
% %     end
% % end

% % baseline=[];
% % if false % Find baseline trace (median value of trace 50ms before soundcardtriggerPos)
% %     for i=1:length(event)
% %         if strcmp(event(i).Type, 'tone') || strcmp(event(i).Type, 'whitenoise') ||...
% %                 strcmp(event(i).Type, 'fmtone')
% %             if isfield(event(i), 'soundcardtriggerPos')
% %                 pos=event(i).soundcardtriggerPos;
% %                 if isempty(pos) && ~isempty(event(i).Position_rising)
% %                     pos=event(i).Position_rising;
% %                 end
% %             else
% %                 pos=event(i).Position_rising;
% %             end
% %
% %             start=(pos-50*1e-3*samprate);
% %             stop=pos-1;
% %             region=start:stop;
% %             if isempty(find(region<0)) %(disallow negative start times)
% %                 if stop>lostat
% %                 else
% %                     baseline(i,:)=median(scaledtrace(region));
% %                 end
% %             end
% %         end
% %     end
% %     baseline=median(baseline);
% % end

% % %traces_to_keep=[];
% % if ~isempty(traces_to_keep)
% %     fprintf('\n using only traces %d, discarding others', traces_to_keep);
% %     mM1ON=mean(M1ON(:,:,:,traces_to_keep,:), 4);
% %     mM1OFF=mean(M1OFF(:,:,:,traces_to_keep,:), 4);
% % else
% %     for aindex=1:numamps
% %         for findex=1:numfreqs
% %             for dindex=1:numdurs
% %
% %                 for rep=1:nrepsOFF(findex, aindex, dindex)
% %                     trace1=M1OFF(findex, aindex, dindex, rep,:);
% %                     trace1=trace1 -mean(trace1(1:10));
% %                     meanOFFbl(findex, aindex, dindex,:)=trace1;
% %                 end
% %
% %                 for rep=1:nrepsON(findex, aindex, dindex)
% %                     trace1=M1ON(findex, aindex, dindex, rep,:);
% %                     trace1=trace1 -mean(trace1(1:10));
% %                     meanONbl(findex, aindex, dindex,:)=trace1;
% %                 end
% %                 mM1ON(findex, aindex, dindex,:)=mean(M1ON(findex, aindex, dindex, 1:nrepsON(findex, aindex, dindex),:), 4);
% %                 mM1OFF(findex, aindex, dindex,:)=mean(M1OFF(findex, aindex, dindex, 1:nrepsOFF(findex, aindex, dindex),:), 4);
% %
% %             end
% %         end
% %     end
% % end
% mM1OFF=mean(meanOFFb1(:,:,:,:), 4);
% mM1ON=mean(meanONb1(:,:,:,:), 4);

% %find optimal axis limits
if isempty(ylimits)
    ylimits=[0 0];
    for dindex=1:numdurs
        for aindex=numamps:-1:1
            for findex=1:numfreqs
                trace1=squeeze(mM1(findex, aindex, dindex, :));
%                 trace1=filtfilt(b,a,trace1);
                trace1=trace1-mean(trace1(1:100));
                if min([trace1])<ylimits(1); ylimits(1)=min([trace1]);end
                if max([trace1])>ylimits(2); ylimits(2)=max([trace1]);end
            end
        end
    end
end
ylimits=round(ylimits*100)/100;

%plot the mean tuning curve BOTH
for dindex=1:numdurs
    figure
    p=0;
    subplot1(numamps,numfreqs)
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            %
            %             for i=1:length(nrepsON)
            %             end
            %             trace1=squeeze(squeeze(meanONbl(findex, aindex, dindex, :)));
            %             trace2=(squeeze(meanOFFbl(findex, aindex, dindex, :)));
            trace1=squeeze(squeeze(out.mM1ON(findex, aindex, dindex, :)));
            trace2=(squeeze(out.mM1OFF(findex, aindex, dindex, :)));
            
            trace1=trace1 -mean(trace1(1:10));
            trace2=trace2-mean(trace2(1:10));
%             trace1=filtfilt(b,a,trace1);
%             trace2=filtfilt(b,a,trace2);
            t=1:length(trace1);
            t=1000*t/out.samprate; %convert to ms
            t=t+out.xlimits(1); %correct for xlim in original processing call
            line([0 0+durs(dindex)], [0 0], 'color', 'm', 'linewidth', 5)
            plot(t, trace1, 'b');
            hold on; plot(t, trace2, 'k');
            %ylim([-5000 5000])
            ylim(ylimits)
            xlim(xlimits)
            box off
            
        end
    end
    subplot1(1)
    h=title(sprintf('%s-%s-%s: %dms, nreps: %d-%d, ON&OFF',expdate,session,filenum,durs(dindex),min(min(min(nrepsOFF))),max(max(max(nrepsOFF)))));
    set(h, 'HorizontalAlignment', 'left')
    
    %label amps and freqs
    p=0;
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(-400, mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(findex,2) %odd freq
                    vpos=ylimits(1)-mean(ylimits);
                else
                    vpos=ylimits(1)-mean(ylimits);
                end
                text(xlimits(1), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
        end
    end
end

%plot the mean tuning curve OFF
for dindex=1:numdurs
    figure
    p=0;
    subplot1(numamps,numfreqs)
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            trace1=squeeze(mM1OFF(findex, aindex, dindex, :));
%             trace1=filtfilt(b,a,trace1);
            trace1=trace1 -mean(trace1(1:100));
            
            t=1:length(trace1);
            t=1000*t/out.samprate; %convert to ms
            t=t+out.xlimits(1); %correct for xlim in original processing call
            line([0 0+durs(dindex)], [0 0], 'color', 'm', 'linewidth', 5)
            hold on; plot(t, trace1, 'k');
            ylim(ylimits)
            xlim(xlimits)
            xlabel off
            ylabel off
            axis off
        end
    end
    subplot1(1)
    h=title(sprintf('OFF %s-%s-%s: %dms, nreps: %d-%d',expdate,session,filenum,durs(dindex),min(min(min(nrepsOFF))),max(max(max(nrepsOFF)))));
    set(h, 'HorizontalAlignment', 'left')
    
    %label amps and freqs
    p=0;
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(-400, mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(findex,2) %odd freq
                    vpos=ylimits(1)-mean(ylimits);
                else
                    vpos=ylimits(1)-mean(ylimits);
                end
                text(xlimits(1), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
            %             if findex==numfreqs && aindex==numamps
            %                 axis on
            %                 ylab=[ceil(ylimits(1)*10)/10 floor(ylimits(2)*10)/10];
            %                 set(gca,'ytick',ylab,'yticklabel',ylab,'YAxisLocation','right')
            %             end
        end
    end
end

%% plot on
for dindex=1:numdurs
    figure
    p=0;
    subplot1(numamps,numfreqs)
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            axis off
            
            trace1=squeeze(mM1ON(findex, aindex, dindex, :));
%             trace1=filtfilt(b,a,trace1);
            trace1=trace1 -mean(trace1(1:100));
            t=1:length(trace1);
           t=1000*t/out.samprate; %convert to ms
            t=t+out.xlimits(1); %correct for xlim in original processing call
             line([0 0+durs(dindex)], [0 0], 'color', 'm', 'linewidth', 5)
            hold on; plot(t, trace1, 'b');
            ylim(ylimits)
            xlim(xlimits)
            axis off
            
        end
    end
    subplot1(1)
    h=title(sprintf('ON %s-%s-%s: %dms, nreps: %d-%d',expdate,session,filenum,durs(dindex),min(min(min(nrepsON))),max(max(max(nrepsON)))));
    set(h, 'HorizontalAlignment', 'left')
    
    %label amps and freqs
    p=0;
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(-400, mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(findex,2) %odd freq
                    vpos=ylimits(1)-mean(ylimits);
                else
                    vpos=ylimits(1)-mean(ylimits);
                end
                text(xlimits(1), vpos, sprintf('%.1f', freqs(findex)/1000))
            end
            %             if findex==numfreqs && aindex==numamps
            %                 axis on
            %                 ylab=[ceil(ylimits(1)*10)/10 floor(ylimits(2)*10)/10];
            %                 set(gca,'ytick',ylab,'yticklabel',ylab,'YAxisLocation','right')
            %             end
        end
    end
end

