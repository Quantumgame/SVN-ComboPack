function PlotVCTC_NBN(expdate, session, filenum, varargin)
%usage: PlotVCTC_NBN(expdate, session, filenum, [xlimits])
%
% plots NBN tuning curve of synaptic currents
% optimized for fast checking of reversals while you have a cell
% to set user, use the su command
if nargin==0 fprintf('no input');return;
elseif nargin==3
    xl=[];
elseif nargin==4
    xl=varargin{1};
end
user=whoami;

Vout=0;
fprintf('\nWarning: assuming Vout=0')


outfile=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
godatadir(expdate, session, filenum)
if exist(outfile, 'file')~=2 %need to generate local outfile
    global pref
    if pref.usebak
        godatadirbak(expdate, session, filenum)
    else
        godatadir(expdate, session, filenum)
    end
    if exist(getfilenames(expdate, session, filenum))~=2 %need to create axopatchdata
            if pref.usebak
                ProcessData_singlebak(expdate, session, filenum)
            else
                ProcessData_single(expdate, session, filenum)
            end
    end
        ProcessVCData_NBN(expdate, session, filenum, Vout, xl);    
end
load(outfile)
in=out;


fprintf('\nnumber of reps:\n')
squeeze(in.nreps)


M1=in.M1;
mM1=in.mM1;
M1stim=in.M1stim;
expdate=in.expdate;
session=in.session;
filenum=in.filenum;
freqs=in.freqs;
amps=in.amps;
durs=in.durs;
bws=in.bws;
potentials=in.potentials;
samprate=in.samprate;
numamps=length(amps);
numdurs=length(durs);
numbws=length(bws);
numfreqs=length(freqs);
numpotentials=length(potentials);
xlimits=out.xlimits;

%xl are the xlimits we want to use for plotting
%may or may not be same as xlimits used to create outfile
if nargin==4
    xl=varargin{1};
    if isempty(xl) | length(xl)~=2 xl=xlimits;end
else
    xl=xlimits;
end

%find optimal axis limits
%optimized based on highest potential (will crop low potentials)

ylimits=[0 0];
dindex=1;
for bwindex=[1:numbws]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            %         for pindex=1:numpotentials %(optimize for all potentials)
            for pindex=1:numpotentials %optimized based on highest potential
                trace1=squeeze(mM1(findex, aindex,bwindex, pindex, 1, :));
                trace1=trace1-mean(trace1(1:100));
                %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
                if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
                if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
            end
        end
    end
end


%ylimits=[-700 700];
%ylimits=[-500 500];
%ylimits=[-300 300];


%plot the mean tuning curve
for aindex=[1:numamps]
    figure
    set(gca, 'fontsize', 18)
    c='bgrycm';
    p=0;
    subplot1( numbws,numfreqs-1)
    for bwindex=[1:numbws]
        for findex=2:numfreqs
            if bwindex==numbws %inf==wn
                findex=1;
            end
            p=p+1;
            subplot1( p)
            t=1:length(trace1);
            t=t/10;
            t=t+xlimits(1);
            stimtrace=squeeze(M1stim(findex, aindex, bwindex, pindex, 2, :));
            stimtrace=stimtrace-mean(stimtrace(1:100));
            stimtrace=stimtrace./max(abs(stimtrace));
            stimtrace=stimtrace*.1*diff(ylimits);
            stimtrace=stimtrace+ylimits(1);
            plot(t, stimtrace, 'm')
            hold on
            for pindex=1:numpotentials
                trace1=squeeze(mM1(findex, aindex, bwindex, pindex, :));
                trace1=trace1-mean(trace1(1:100));
                
                plot(t, trace1, c(pindex));
                ylim(ylimits)
                %ylim([-600 600])
                xlim(xl);
                
                %            axis off
            end
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s amp: %ddB', expdate,session, filenum, amps(aindex)))
    
    %label amps and freqs
    p=0;
    for bwindex=[1:numbws]
        for findex=2:numfreqs
            p=p+1;
            subplot1(p)
            pos=get(gca, 'pos');
            pos(3)=pos(3)/2;
            set(gca, 'pos', pos)
            if findex==2
                T=text(-20, mean(ylimits), sprintf('%.1f', bws(bwindex)));
                set(T, 'HorizontalAlignment', 'right')
                
                set(gca, 'xtick', xl)
            else set(gca, 'xtick', [])
                
            end
            if bwindex==1
                T=text(-20, ylimits(2), sprintf('BW\nOct'));
                set(T, 'HorizontalAlignment', 'right')
            end
            if bwindex==numbws
                
                vpos=ylimits(1);
                text(mean(xl), vpos, sprintf('%.1f', freqs(findex)/1000))
            else
                set(gca, 'yticklabel', '')
            end
        end
    end
    % set(gcf, 'pos', [ 90+10*aindex         619-10*aindex        1369         420])
end
fprintf('\n\n')
