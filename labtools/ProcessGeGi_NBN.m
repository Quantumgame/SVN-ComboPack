function ProcessGeGi_NBN(expdate, session, filenum, Vout, varargin)
%usage: ProcessGeGi_NBN(expdate, session, filenum, Vout, [xlimits])
%runs all the necessary processing steps to extract and save ge and gi,
%storing the results in an outfile
%same as ProcessGeGi but for narrow-band noise stimuli
%note: computing ge and gi is computationally intensive and can take a long
%time

if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==4
    durs=getdurs(expdate, session, filenum);
    dur=max([durs 100]);
    xlimits=[-.5*dur 1.5*dur]; %x limits for axis
elseif nargin==5
    xlimits=varargin{1};
    if isempty(xlimits)
        durs=getdurs(expdate, session, filenum);
        dur=max([durs 100]);
        xlimits=[-.5*dur 1.5*dur]; %x limits for axis
    end
else
    error('ProcessGeGi_NBN: wrong number of arguments')
end


ProcessVCData_NBN(expdate, session, filenum, Vout, xlimits);
outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
load(outfilename)
out.A=1;
out.Ee=0;
out.Ei=-85;
out=get_correctedV_NBN(out);
out=compute_ge_gi_NBN(out);

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
save (outfilename, 'out')
fprintf('\n saved to %s', outfilename)

