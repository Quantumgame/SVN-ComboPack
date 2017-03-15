function Plot_many_PNs_lfp(expdate, session, varargin)
%usage Plot_many_PNs_lfp(expdate, session, filneum1, filenum2, ...)
%assumes you have already run ProcessWNTrain2_lfp
%this plots P1, P2, and PN (mean of last 5)
if nargin==0; fprintf('\nno input'); return; end

f1=figure;hold on
f2=figure;hold on
f3=figure;hold on

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
    
    figure(f1)
    P1=out.P1;
    nreps=out.nreps;
    for isiindex=1:size(P1, 1)
        mP1(isiindex)=mean(P1(isiindex,1:nreps(isiindex)),2);
        sdP1(isiindex)=std(squeeze(P1(isiindex,1:nreps(isiindex))));
        seP1(isiindex)=std(squeeze(P1(isiindex,1:nreps(isiindex))))/sqrt(nreps(isiindex));
    end
    e=errorbar(1:out.numisis, mP1, seP1);
    set(e, 'marker', 'o', 'color', c(1+(i-1)*cstep,:))

        
    figure(f2)
    P2=out.P2;
    nreps=out.nreps;
    for isiindex=1:size(P2, 1)
        mP2(isiindex)=mean(P2(isiindex,1:nreps(isiindex)),2);
        sdP2(isiindex)=std(squeeze(P2(isiindex,1:nreps(isiindex))));
        seP2(isiindex)=std(squeeze(P2(isiindex,1:nreps(isiindex))))/sqrt(nreps(isiindex));
    end
    e=errorbar(1:out.numisis, mP2, seP2);
    set(e, 'marker', 'o', 'color', c(1+(i-1)*cstep,:))

        
    figure(f3)
    PN=out.PN;
    nreps=out.nreps;
    for isiindex=1:size(PN, 1)
        mPN(isiindex)=mean(PN(isiindex,1:nreps(isiindex)),2);
        sdPN(isiindex)=std(squeeze(PN(isiindex,1:nreps(isiindex))));
        sePN(isiindex)=std(squeeze(PN(isiindex,1:nreps(isiindex))))/sqrt(nreps(isiindex));
    end
    e=errorbar(1:out.numisis, mPN, sePN);
    set(e, 'marker', 'o', 'color', c(1+(i-1)*cstep,:))

end

figure(f1)
legend(varargin)
set(gca, 'xtick', 1:out.numisis, 'xticklabel', out.isis)
xlabel('isi, ms')
ylabel('P1 (first click response), +- S.E.M.')
title(sprintf('P1s LFP for %s-%s: %s', expdate, session, sprintf('%s  ',varargin{:})))
set(gca, 'xdir', 'reverse')

figure(f2)
legend(varargin)
set(gca, 'xtick', 1:out.numisis, 'xticklabel', out.isis)
xlabel('isi, ms')
ylabel('P2 (second click response), +- S.E.M.')
title(sprintf('P2s LFP for %s-%s: %s', expdate, session, sprintf('%s  ',varargin{:})))
set(gca, 'xdir', 'reverse')

figure(f3)
legend(varargin)
set(gca, 'xtick', 1:out.numisis, 'xticklabel', out.isis)
xlabel('isi, ms')
ylabel('PN (mean of last 5 click responses), +- S.E.M.')
title(sprintf('PNs LFP for %s-%s: %s', expdate, session, sprintf('%s  ',varargin{:})))
set(gca, 'xdir', 'reverse')



