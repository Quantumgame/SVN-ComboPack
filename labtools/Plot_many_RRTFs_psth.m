function Plot_many_RRTFs_psth(expdate, session, varargin)
%usage Plot_many_RRTFs_psth(expdate, session, filneum1, filenum2, ...)
%assumes you have already run ProcessWNTrain2_psth
if nargin==0; fprintf('\nno input'); return; end

figure
hold on
c=colormap;
cstep=round(64/(nargin-2));
for i=1:nargin-2
    filenum=varargin{i};
    outfilename=sprintf('out%s-%s-%s-psth',expdate,session, filenum);
    fprintf('\ntrying to load %s...', outfilename)
    try
        godatadir(expdate, session, filenum)
        load(outfilename)
    catch
        fprintf('failed to load outfile')
        return
    end

    fprintf('done\n');

    RRTF=out.RRTF;
    % if size(RRTF, 2)==1, RRTF is 1D and is the mean spikecount across trials
    % if size(RRTF, 2)>1, RRTF is 2D and is the spikecount for each trial
    
    %plot the mean RRTF computed across reps (not rep-by-rep)
    %         e=plot(1:out.numisis, out.mRRTF);
    %         set(e, 'marker', 'o', 'color', c(1+(i-1)*cstep,:))
    %         ylabel('last/first click ratio')

    nreps=out.nreps;
        for isiindex=1:size(RRTF, 1)
            mRRTF(isiindex)=nanmean(RRTF(isiindex,1:nreps(isiindex)),2);
            sdRRTF(isiindex)=nanstd(squeeze(RRTF(isiindex,1:nreps(isiindex))));
            seRRTF(isiindex)=nanstd(squeeze(RRTF(isiindex,1:nreps(isiindex))))/sqrt(nreps(isiindex));
        end
        e=errorbar(1:out.numisis, mRRTF, seRRTF);
        set(e, 'marker', 'o', 'color', c(1+(i-1)*cstep,:))
        ylabel('last5/first click ratio, +- S.E.M.')
end

legend(varargin)
set(gca, 'xtick', 1:out.numisis, 'xticklabel', out.isis)
xlabel('isi, ms')
title(sprintf('RRTFs PSTH for %s-%s: %s', expdate, session, sprintf('%s  ',varargin{:})))
set(gca, 'xdir', 'reverse')



