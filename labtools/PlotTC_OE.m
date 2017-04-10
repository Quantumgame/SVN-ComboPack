function PlotTC_OE(varargin)

% usage: PlotTC_OE(expdate,session,filenum, [xlimits],[ylimits],channel number)
%or PlotTC_OE(outfilename, [xlimits],[ylimits])
% (xlimits & ylimits are optional)
% xlimits default to [0 100]
% channel number must be a string 
%
%now only plots, uses ProcessTC to process
%mw 09-10-2013
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
 if ~out.isrecording==1
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
mM1stim=out.mM1stim;
mM1=out.mM1;
freqs=out.freqs;
amps=out.amps;
durs=out.durs;
nreps=out.nreps;
numfreqs=out.numfreqs;
numamps=out.numamps;
numdurs=out.numdurs;
traces_to_keep=out.traces_to_keep;
expdate=out.expdate;
session=out.session;
filenum=out.filenum;
samprate=out.samprate; %in Hz
M1=out.M1;

if isempty(xlimits)
    xlimits=out.xlimits;
end

%find optimal axis limits
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



%plot the mean tuning curve
for dindex=1:numdurs
    figure
    p=0;
    subplot1(numamps,numfreqs)
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            trace1=squeeze(mM1(findex, aindex, dindex, :));
            trace1=trace1-mean(trace1(1:100));
            
            t=1:length(trace1);
            t=1000*t/samprate; %in ms
            t=t+out.xlimits(1);
            line([0 0+durs(dindex)], [0 0], 'color', 'm', 'linewidth', 5)
            plot(t, trace1, 'b');
            ylim(ylimits)
             xlim(xlimits)
            axis off
        end
    end
    subplot1(1)
    h=title(sprintf('%s-%s-%s: %dms, nreps: %d-%d',expdate,session,filenum,durs(dindex),min(min(min(nreps))),max(max(max(nreps)))));
    set(h, 'HorizontalAlignment', 'left')

    hold on;
    %label amps and freqs
    p=0;
    
    for aindex=numamps:-1:1
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(xlimits(1), mean(ylimits), int2str(amps(aindex)))
            end
            if aindex==1
                if mod(findex,2) %odd freq
                    vpos=ylimits(1)-mean(ylimits);
                else
                    vpos=ylimits(1)-mean(ylimits);
                end
                T=text(xlimits(1), vpos, sprintf('%.1f', freqs(findex)/1000));
               if findex==numfreqs
                   set(T, 'string', [get(T, 'string'), sprintf('\n%dms', xlimits(2))], 'horizontalalign', 'center')
               end
            end
        end
    end
end
    xlabel('Frequences (kHz)')
ylabel('Attenuation (dB)')
hold off
