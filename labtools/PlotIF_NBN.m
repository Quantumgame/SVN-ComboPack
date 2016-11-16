function PlotIF_NBN(expdate, session, filenum, thresh, refract, varargin)
%usage:     PlotIF_NBN(expdate, session, filenum, thresh, refract)
%           PlotIF_NBN(expdate, session, filenum, thresh, refract, [xlimits])
%uses a simple threshold model (IFvm.m) to predict spiking output from
%Iclamp recordings of Vm
%for narrow-band stimuli
%to start, try thresh=5; refract=15

% plots NBN tuning curve of lfp or Vm

if nargin==0 fprintf('no input');return;
elseif nargin==5
    xlimits=[]; 
elseif nargin==6
    xlimits=varargin{1};
    if isempty(xlimits) | length(xlimits)~=2
            xlimits=[]; 
    end       
else help PlotIF_NBN; error('PlotIF_NBN: wrong number of inputs')
end

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
    ProcessTC_NBN(expdate, session, filenum, xlimits);
end
load(outfile)

fprintf('\nnumber of reps:\n')
squeeze(out.nreps)

if isempty(xlimits) xlimits=out.xlimits; 
elseif xlimits(2)>out.xlimits(2)
    ProcessTC_NBN(expdate, session, filenum, xlimits)
    load(outfile)
end

M1=out.M1;
mM1=out.mM1;
M1stim=out.M1stim;
mM1stim=out.mM1stim;
expdate=out.expdate;
session=out.session;
filenum=out.filenum;
freqs=out.freqs;
amps=out.amps;
durs=out.durs;
bws=out.bws;
samprate=out.samprate;
numamps=length(amps);
numdurs=length(durs);
numbws=length(bws);
numfreqs=length(freqs);


%find optimal axis limits
%optimized based on highest potential (will crop low potentials)

ylimits=[0 0];
dindex=1;
for bwindex=[1:numbws]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs


            trace1=squeeze(mM1(findex, aindex,bwindex, :));
            trace1=trace1-mean(trace1(1:100));
            %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
            if min([trace1])<ylimits(1) ylimits(1)=min([trace1]);end
            if max([trace1])>ylimits(2) ylimits(2)=max([trace1]);end
        end
    end
end
%add some room for stim 
ylimits(1)=ylimits(1)-.1*diff(ylimits);

%plot the mean tuning curve
for aindex=[1:numamps]
    figure
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
            stimtrace=squeeze(mM1stim(findex, aindex, bwindex, :));
            stimtrace=stimtrace-mean(stimtrace(1:100));
            stimtrace=stimtrace./max(abs(stimtrace));
            stimtrace=stimtrace*.1*diff(ylimits);
            stimtrace=stimtrace+ylimits(1)+.05*diff(ylimits);
            plot(t, stimtrace, 'm')
            hold on

            vm=squeeze(mM1(findex, aindex, bwindex, :));
            vm=vm-mean(vm(1:100));

            dt=.1; 
           
            [V, spiketimes] = IFvm(vm, dt, thresh, refract);
            plot(t, V, 'c', t, vm, 'k');
            spikecounts(bwindex)=length(spiketimes);
            x=repmat(spiketimes, 2, 1);
            y=repmat(ylimits, length(spiketimes), 1)';
            L=line(x, y);
            set(L, 'color', 'k')
            ylim(ylimits)
            xlim(xlimits);



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

                set(gca, 'xtick', xlimits)
            else set(gca, 'xtick', [])

            end
            if bwindex==1
                T=text(-20, ylimits(2), sprintf('BW\nOct'));
                set(T, 'HorizontalAlignment', 'right')
            end
            if bwindex==numbws

                vpos=ylimits(1);
                text(mean(xlimits), vpos, sprintf('%.1f', freqs(findex)/1000))
            else
                set(gca, 'yticklabel', '')
            end
        end
    end
    % set(gcf, 'pos', [ 90+10*aindex         619-10*aindex        1369         420])
end

figure
    t=1:numbws;
    plot(t, spikecounts, 'ko-')
    xlimits=[.5 numbws+.5];
    xlim(xlimits);
    set(gca, 'xtick', 1:numbws)
    set(gca, 'xticklabel', bws)
    xlabel('bandwidth, oct')
    ylabel('IF spikecount')


fprintf('\n\n')
