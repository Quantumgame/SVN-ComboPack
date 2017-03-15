function Plot_many_P2P1s_lfp(expdate, session, varargin)
%usage Plot_many_P2P1s_lfp(expdate, session, filneum1, filenum2, ...)
%assumes you have already run ProcessWNTrain2_lfp
if nargin==0; fprintf('\nno input'); return; end

figure;
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
    
    P2P1=out.P2P1;
    nreps=out.nreps;
    for isiindex=1:size(P2P1, 1)
        mP2P1(isiindex)=mean(P2P1(isiindex,1:nreps(isiindex)),2);
        sdP2P1(isiindex)=std(squeeze(P2P1(isiindex,1:nreps(isiindex))));        
        seP2P1(isiindex)=std(squeeze(P2P1(isiindex,1:nreps(isiindex))))/sqrt(nreps(isiindex));
    end
    e=errorbar(1:out.numisis, mP2P1, seP2P1);
    set(e, 'marker', 'o', 'color', c(1+(i-1)*cstep,:))
end

legend(varargin)
set(gca, 'xtick', 1:out.numisis, 'xticklabel', out.isis)
xlabel('isi, ms')
ylabel('P2/P1 click ratio, +- S.E.M.')
title(sprintf('P2P1s LFP for %s-%s: %s', expdate, session, sprintf('%s  ',varargin{:})))
set(gca, 'xdir', 'reverse')



