function PlotILNBN_OE(varargin)

% usage: PlotILNBN_OE(expdate,session,filenum, [xlimits],[ylimits],channel number)
%or PlotTC_OE(outfilename, [xlimits],[ylimits])
% (xlimits & ylimits are optional)
% xlimits default to [0 300]
% channel number must be a string
%
%Processes data if outfile is not found; ProcessTC is only used to find
%correct data files
%ira 04-01-2014

%adapted from PlotILTC_OE by ira 05.16.14
%

expdate=varargin{1};
session=varargin{2};
filenum=varargin{3};

try
    xlimits=varargin{4};
catch
    xlimits=[0 300];
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

fprintf('\nusing xlimits [%d-%d]', xlimits(1), xlimits(2))
gogetdata(expdate,session,filenum);
outfilename=sprintf('outOE%s_%s-%s-%s.mat',channel, expdate, session, filenum);
if exist(outfilename,'file')
    load(outfilename)
else
    ProcessILNBN_OE(expdate,session,filenum, xlimits, ylimits, channel);
    load(outfilename);
end

try
    if out.isrecording==0
        warning('Open Ephys appears not to have been recording when the exper file was taken')
    end
end


M1stim=out.M1stim;
freqs=out.freqs;
amps=out.amps;
durs=out.durs;
bws=out.bws;
nreps=out.nreps;
numfreqs=out.numfreqs;
numamps=out.numamps;
numdurs=out.numdurs;
numbws=out.numbws;
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


% %find optimal axis limits
if isempty(ylimits)
    ylimits=[0 0];
    for dindex=1:numdurs
        for aindex=numamps:-1:1
            for findex=1:numfreqs
                trace1=squeeze(mM1(findex, aindex, dindex, :));
                trace1=trace1-mean(trace1(1:100));
                if min([trace1])<ylimits(1); ylimits(1)=min([trace1]);end
                if max([trace1])>ylimits(2); ylimits(2)=max([trace1]);end
            end
        end
    end
end
ylimits=round(ylimits*100)/100;

%plot the mean tuning curve BOTH

for dindex=1:numdurs;
    
    figure
    p=0;
    if dindex~=1
        subplot1(numbws,numfreqs-1)
    end
    if dindex==1
        subplot1(numamps-1,numfreqs-1)
    end
    for bwindex=1:numbws
        for aindex=[1:numamps]
            for findex=1:numfreqs
                %                 if bwindex==numbws
                %                     findex=1;
                %                 end
                if nrepsON(findex, aindex, dindex, bwindex)==0
                    fprintf('\n no reps')
                else
                    p=p+1;
                    subplot1(p)
                    hold on
                    
                    trace1=squeeze(squeeze(out.mM1ON(findex, aindex, dindex, bwindex,:)));
                    trace2=(squeeze(out.mM1OFF(findex, aindex, dindex, bwindex, :)));
                    
                    trace1=trace1 -mean(trace1(1:10));
                    trace2=trace2-mean(trace2(1:10));
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
        end
    end
end
% Label amps and freqs.
p=0;
if dindex==1
    xlabel('Quiet white noise, 25 ms')
    title(sprintf('%s-%s-%s: -1000 dB (Max reps ON=%.0f, OFF=%.0f channel %s)',expdate,session, filenum, max(max(max(max(nrepsON)))),max(max(max(max(nrepsOFF)))), clust))
else
    for bwindex=[1:numbws]
        for findex=2:numfreqs
            p=p+1;
            subplot1(p)
            if findex==2
                T=text(xlimits(1)-diff(xlimits)/16, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                set(T, 'HorizontalAlignment', 'right')
                
                if bwindex==1
                    T=text(xlimits(1)-diff(xlimits)/16, ylimits(2), sprintf('BW\nOct'));
                    set(T, 'HorizontalAlignment', 'right')
                end
            else
                set(gca, 'xticklabel', '')
            end
            set(gca, 'xtickmode', 'auto')
            grid on
            if bwindex==numbws
                vpos=ylimits(1)-diff(ylimits)/4;
                text(mean(xlimits), vpos, sprintf('%.1f kHz', freqs(findex)/1000))
            else
                set(gca, 'yticklabel', '')
            end
        end
        
        subplot1(ceil(numfreqs/3))
        title(sprintf('%s-%s-%s: %.0f dB (Max reps ON=%.0f, OFF=%.0f channel number %s)',expdate,session, filenum, amps(aindex), max(max(max(max(nrepsON)))),max(max(max(max(nrepsOFF)))), channel))
        
    end
end %dindex



%%
%plot the mean tuning curve OFF
for dindex=1:numdurs;
    figure
    p=0;
    if dindex~=1
        subplot1(numbws,numfreqs-1)
    end
    if dindex==1
        subplot1(numamps-1,numfreqs-1)
    end
    for bwindex=1:numbws
        for aindex=[1:numamps]
            for findex=1:numfreqs
                %                 if bwindex==numbws
                %                     findex=1;
                %                 end
                if nrepsOFF(findex, aindex, dindex, bwindex)==0
                    fprintf('\n no reps')
                else
                    p=p+1;
                    subplot1(p)
                    hold on
                    trace1=squeeze(mM1OFF(findex, aindex, dindex, bwindex, :));
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
        end
    end
    subplot1(1)
    h=title(sprintf('OFF %s-%s-%s: %dms, nreps: %d-%d',expdate,session,filenum,durs(dindex),min(min(min(nrepsOFF))),max(max(max(nrepsOFF)))));
    set(h, 'HorizontalAlignment', 'left')
    
    
    % Label amps and freqs.
    p=0;
    if dindex==1
        xlabel('Quiet white noise, 25 ms')
        title(sprintf('Off responses, %s-%s-%s: -1000 dB (Max reps ON=%.0f, OFF=%.0f channel %s)',expdate,session, filenum, max(max(max(max(nrepsON)))),max(max(max(max(nrepsOFF)))), channel))
    else
        for bwindex=[1:numbws]
            for findex=2:numfreqs
                p=p+1;
                subplot1(p)
                if findex==2
                    T=text(xlimits(1)-diff(xlimits)/16, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                    set(T, 'HorizontalAlignment', 'right')
                    
                    if bwindex==1
                        T=text(xlimits(1)-diff(xlimits)/16, ylimits(2), sprintf('BW\nOct'));
                        set(T, 'HorizontalAlignment', 'right')
                    end
                else
                    set(gca, 'xticklabel', '')
                end
                set(gca, 'xtickmode', 'auto')
                grid on
                if bwindex==numbws
                    vpos=ylimits(1)-diff(ylimits)/4;
                    text(mean(xlimits), vpos, sprintf('%.1f kHz', freqs(findex)/1000))
                else
                    set(gca, 'yticklabel', '')
                end
            end
            
            subplot1(ceil(numfreqs/3))
            title(sprintf('Off responses %s-%s-%s: %.0f dB (Max reps OFF=%.0f channel number %s)',expdate,session, filenum, amps(aindex), max(max(max(max(nrepsOFF)))), channel))
        end
    end
end


%% Plot ON
for dindex=1:numdurs;
    figure
    p=0;
    if dindex~=1
        subplot1(numbws,numfreqs-1)
    end
    if dindex==1
        subplot1(numamps-1,numfreqs-1)
    end
    for bwindex=1:numbws
        for aindex=[1:numamps]
            for findex=1:numfreqs
                %                 if bwindex==numbws
                %                     findex=1;
                %                 end
                if nrepsON(findex, aindex, dindex, bwindex)==0
                    fprintf('\n no reps')
                else
                    p=p+1;
                    subplot1(p)
                    hold on
                    trace1=squeeze(mM1ON(findex, aindex, dindex, bwindex, :));
                    trace1=trace1 -mean(trace1(1:100));
                    t=1:length(trace1);
                    t=1000*t/out.samprate; %convert to ms
                    t=t+out.xlimits(1); %correct for xlim in original processing call
                    line([0 0+durs(dindex)], [0 0], 'color', 'm', 'linewidth', 5)
                    hold on; plot(t, trace1, 'b');
                    ylim(ylimits)
                    xlim(xlimits)
                    xlabel off
                    ylabel off
                    axis off
                end
            end
        end
    end
    subplot1(1)
    h=title(sprintf('On responses, %s-%s-%s: %dms, nreps: %d-%d',expdate,session,filenum,durs(dindex),min(min(min(nrepsOFF))),max(max(max(nrepsOFF)))));
    set(h, 'HorizontalAlignment', 'left')
    
    
    % Label amps and freqs.
    p=0;
    if dindex==1
        xlabel('Quiet white noise, 25 ms')
        title(sprintf('On responses, %s-%s-%s: -1000 dB (Max reps ON=%.0f channel %s)',expdate,session, filenum, max(max(max(max(nrepsON)))), channel))
    else
        for bwindex=[1:numbws]
            for findex=2:numfreqs
                p=p+1;
                subplot1(p)
                if findex==2
                    T=text(xlimits(1)-diff(xlimits)/16, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                    set(T, 'HorizontalAlignment', 'right')
                    
                    if bwindex==1
                        T=text(xlimits(1)-diff(xlimits)/16, ylimits(2), sprintf('BW\nOct'));
                        set(T, 'HorizontalAlignment', 'right')
                    end
                else
                    set(gca, 'xticklabel', '')
                end
                set(gca, 'xtickmode', 'auto')
                grid on
                if bwindex==numbws
                    vpos=ylimits(1)-diff(ylimits)/4;
                    text(mean(xlimits), vpos, sprintf('%.1f kHz', freqs(findex)/1000))
                else
                    set(gca, 'yticklabel', '')
                end
            end
            
            subplot1(ceil(numfreqs/3))
            title(sprintf('On responses, %s-%s-%s: %.0f dB (Max reps ON=%.0f, OFF=%.0f channel number %s)',expdate,session, filenum, amps(aindex), max(max(max(max(nrepsON)))),max(max(max(max(nrepsOFF)))), channel))
        end
    end
end


end






