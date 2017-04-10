function PlotVCTC_single(expdate, session, filenum, Vout)
% plots tuning curve of synaptic currents
% optimized for fast checking of reversals while you have a cell
% usage:
%     PlotVCTC_single(expdate, session, filenum)
if nargin==0 fprintf('no input');return; end
%Vout=0;


xl=[0 250]; %xlimits
outfile=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
if exist(outfile,'file')
    load(outfile)
else
ProcessVCData(expdate, session, filenum, Vout, xl);
outfile=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
load(outfile)
end
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
potentials=in.potentials;
samprate=in.samprate;
numamps=length(amps);
numdurs=length(durs);
numfreqs=length(freqs);
numpotentials=length(potentials);

%find optimal axis limits
%optimized based on highest potential (will crop low potentials)
axmax=[0 0];
for dindex=[1:numdurs]
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            %         for pindex=1:numpotentials %(optimize for all potentials)
            for pindex=numpotentials %optimized based on highest potential
                trace1=squeeze(mM1(findex, aindex,dindex, pindex, 1, 1:xl(2)*samprate/1000));
                trace1=trace1-mean(trace1(1:100));
                %        if findex==3 & aindex==6 trace2=0*trace2;end %exclude this trace from axis optimatization
                if min([trace1])<axmax(1) axmax(1)=min([trace1]);end
                if max([trace1])>axmax(2) axmax(2)=max([trace1]);end
            end
        end
    end
end

%axmax=[-700 700];
%axmax=[-500 500];
axmax=[-300 300];


%plot the mean tuning curve
for dindex=[1:numdurs]
    figure
    c='bgrycm';
    p=0;
    subplot1( numamps,numfreqs)
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            subplot1( p)
            for pindex=1:numpotentials
                trace1=squeeze(mM1(findex, aindex, dindex, pindex, :));
                trace1=trace1-mean(trace1(1:100));
                try %5th number in matrix does not agree in some files ira 02.18.15
                stimtrace=squeeze(M1stim(findex, aindex, dindex, pindex, 2, :));
                catch
                stimtrace=squeeze(M1stim(findex, aindex, dindex, pindex, 1, :));
                end
                stimtrace=stimtrace-mean(stimtrace(1:100));
                stimtrace=stimtrace./max(abs(stimtrace));
                stimtrace=stimtrace*.1*diff(axmax);
                stimtrace=stimtrace+axmax(1);

                t=1:length(trace1);
                t=t/10;
                plot(t, trace1, c(pindex), t, stimtrace, 'm');
                ylim(axmax)
                %ylim([-600 600])
                xlim(xl);
                %            axis off
            end
        end
    end
    subplot1(ceil(numfreqs/3))
    title(sprintf('%s-%s-%s dur: %dms', expdate,session, filenum, durs(dindex)))

    %label amps and freqs
    p=0;
    for aindex=[numamps:-1:1]
        for findex=1:numfreqs
            p=p+1;
            subplot1(p)
            if findex==1
                text(-400, mean(axmax), int2str(amps(aindex)))
                set(gca, 'xtick', xl)
            else set(gca, 'xtick', [])
            end
            if aindex==1
                vpos=axmax(1);
                text(0, vpos, sprintf('%.1f', freqs(findex)/1000))
            end
        end
    end
    set(gcf, 'pos', [ 90+10*dindex         619-10*dindex        1369         420])
end
fprintf('\n\n')
