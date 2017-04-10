function PlotVmTC_NBN(expdate, session, filenum, varargin)
%usage: PlotVmTC_NBN(expdate, session, filenum, [xlimits])
%
% plots tuning curve of peak Vm vs. bandwidth
% also plots sum Vm vs. bandwidth
%
% use xlimits to specify the time window for peak detection and Vm
% integration
%
%clips spikes


if nargin==0 fprintf('no input');return;
elseif nargin==3
    xlimits=[];
elseif nargin==4
    xlimits=varargin{1};
    if isempty(xlimits) | length(xlimits)~=2
        xlimits=[];
    end
else error('PlotTC_NBN: wrong number of inputs')
end

outfile=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
godatadir(expdate, session, filenum);
if exist(outfile, 'file')~=2
    ProcessTC_NBN(expdate, session, filenum, xlimits)
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

xlsamples=1:samprate*.001*(xlimits(2)-xlimits(1));

% find grand mean Vrest
baseline=abs(xlimits(1))*samprate/1000; %in samples
if baseline==0 baseline=50; end
vrest=nanmean(nanmean(nanmean(nanmean(mM1(:, :, :, 1:baseline)))));
fprintf('\nVrest=%.1f', vrest);
fprintf('\nclipping spikes with default settings');


%plot the mean tuning curve
for aindex=[1:numamps]
    figure
    p=0;
    subplot1( numbws,numfreqs-1)

    for bwindex=[1:numbws-1]
        for findex=2:numfreqs
            trace1=squeeze(mM1(findex, aindex, bwindex, :));
            trace1=trace1-vrest;
            ctrace=clipspikes(trace1, [], [], 0);
            deltaV(bwindex, findex-1)= max(ctrace(xlsamples));
            sumV(bwindex, findex-1)= sum(ctrace(xlsamples));
            t=1:length(trace1); t=t/10;t=t+xlimits(1);
            p=p+1;subplot1(p)
            h=plot(t, trace1, t, ctrace, 'r');
            set(h(1), 'linewidth', 2)
            line([xlimits(1) xlimits(1)], ylim);
            line([xlimits(2) xlimits(2)], ylim);
        end
    end
    bwindex=numbws; %inf==wn
    for findex=2:numfreqs
        trace1=squeeze(mM1(1, aindex, bwindex, :));
        trace1=trace1-vrest;
        ctrace=clipspikes(trace1, [], [], 0);
        deltaV(bwindex, findex-1)= max(ctrace(xlsamples));        
        sumV(bwindex, findex-1)= sum(ctrace(xlsamples));
              p=p+1;subplot1(p)
            h=plot(t, trace1, t, ctrace, 'r');
            set(h(1), 'linewidth', 2)
            line([xlimits(1) xlimits(1)], ylim);
            line([xlimits(2) xlimits(2)], ylim);
    end


    figure
    for findex=1:numfreqs-1
        set(gca, 'fontsize', 18)
        p=plot(1:numbws, deltaV(:, findex), '.-');
        set(p, 'markersize', 30, 'linewidth', 2)
        set(gca, 'xtick',1:numbws, 'xticklabel', bws)
        xlabel(sprintf('bandwidth, oct (carrier %.1fkHz)', 1e-3*freqs(findex+1)))
        ylabel('\DeltaVm')
    end
    title(sprintf('%s-%s-%s amp: %ddB', expdate,session, filenum, amps(aindex)))

        figure
    for findex=1:numfreqs-1
        set(gca, 'fontsize', 18)
        p=plot(1:numbws, sumV(:, findex), '.-');
        set(p, 'markersize', 30, 'linewidth', 2)
        set(gca, 'xtick',1:numbws, 'xticklabel', bws)
        xlabel(sprintf('bandwidth, oct (carrier %.1fkHz)', 1e-3*freqs(findex+1)))
        ylabel('Sum Vm')
    end
    title(sprintf('%s-%s-%s amp: %ddB', expdate,session, filenum, amps(aindex)))

        figure
    for findex=1:numfreqs-1
        set(gca, 'fontsize', 18)
        p=plot(1:numbws, sumV(:, findex)./max(sumV(:, findex)), 'b.-');
        set(p, 'markersize', 30, 'linewidth', 2)
        hold on
               p=plot(1:numbws, deltaV(:, findex)./max(deltaV(:, findex)), 'g.-');
        set(p, 'markersize', 30, 'linewidth', 2)
        set(gca, 'xtick',1:numbws, 'xticklabel', bws)
        xlabel(sprintf('bandwidth, oct (carrier %.1fkHz)', 1e-3*freqs(findex+1)))
legend('\SigmaVm', '\DeltaVm')
    end
    title(sprintf('%s-%s-%s amp: %ddB', expdate,session, filenum, amps(aindex)))

end



