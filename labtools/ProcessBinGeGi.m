function ProcessBinGeGi(expdate, session, filenum, Vout, varargin)
%usage: ProcessBinGeGi('expdate', 'session', 'filenum', Vout, [xlimits])
%runs all the necessary processing steps to extract and save ge and gi,
%storing the results in an outfile
%note: computing ge and gi is computationally intensive and can take a long
%time

if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==4
    xlimits=[-50 250]; %default xlimits. Note that getdurs returns a too-long dur from holdcmd
elseif nargin==5
    xlimits=varargin{1};
    if length(xlimits)~=2
        xlimits=[-50 250]; %default xlimits. Note that getdurs returns a too-long dur from holdcmd
    end
else
    error('ProcessBinGeGi: wrong number of arguments')
end

outfilename=sprintf('out%s-%s-%s.mat', expdate, session, filenum);
if exist(outfilename,'file')==2;
    load(outfilename)
    if nargin==4
        xlimits=out.xlimits;
    elseif nargin==5
        if xlimits~=out.xlimits
            ProcessBinVCData(expdate, session, filenum, Vout, xlimits);
            load(outfilename)
        end
    end
else
    ProcessBinVCData(expdate, session, filenum, Vout, xlimits);
    load(outfilename)
end

out.A=1;
out.Ee=0;
out.Ei=-85;
out=get_bin_correctedV(out);
out=compute_bin_ge_gi(out);

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
fprintf('\n saved to %s\n\n', outfilename)
try godatadir(expdate, session, filenum)
catch
    godatadirbak(expdate, session, filenum)
end
save (outfilename, 'out')


