function Plot_many_RRTFs_lfp(expdate, session, varargin)
%usage Plot_many_RRTFs_lfp(expdate, session, filneum1, filenum2, ...)
%assumes you have already run ProcessWNTrain2_lfp
if nargin==0; fprintf('\nno input'); return; end

figure 
hold on
c=colormap;
cstep=round(64/(nargin-2));

for i=1:nargin-2
    filenum=varargin{i};
    outfilename=sprintf('out%s-%s-%s',expdate,session, filenum);

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
    nreps=out.nreps;
    for isiindex=1:size(RRTF, 1)
        mRRTF(isiindex)=mean(RRTF(isiindex,1:nreps(isiindex)),2);
        sdRRTF(isiindex)=std(squeeze(RRTF(isiindex,1:nreps(isiindex))));        
        seRRTF(isiindex)=std(squeeze(RRTF(isiindex,1:nreps(isiindex))))/sqrt(nreps(isiindex));
    end
    e=errorbar(1:out.numisis, mRRTF, seRRTF);
    set(e, 'marker', 'o', 'color', c(1+(i-1)*cstep,:))
end

legend(varargin)
set(gca, 'xtick', 1:out.numisis, 'xticklabel', out.isis)
xlabel('isi, ms')
ylabel('last5/first click ratio, +- S.E.M.')
title(sprintf('RRTFs LFP for %s-%s: %s', expdate, session, sprintf('%s  ',varargin{:})))
set(gca, 'xdir', 'reverse')



