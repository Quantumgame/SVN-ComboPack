function ProcessGeGi(expdate, session, filenum, Vout, varargin)
%usage: ProcessGeGi('expdate', 'session', 'filenum', Vout, [xlimits])
%runs all the necessary processing steps to extract and save ge and gi,
%storing the results in an outfile
%note: computing ge and gi is computationally intensive and can take a long
%time
%
%NOTE: Found, corrected the xlimits bug in compute_ge_gi. The baseline period used for estimating/subtracting
%holding current is converted into samples twice. AKH 10/28/13
%
%NOTE: There is an issue with computing rate level functions using xlimits
%with xlimits(1)<0. Thus, I changed the default xlimits to [0 250]. I
%believe the problem occurs in compute_ge_gi.m at line 55 with the
%assignment of baseline.
% mk 7Jul2011

if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin==4
%     durs=getdurs(expdate, session, filenum, 'user', 'xg', 'rig', 'rig1', 'bk', 1);
%     dur=max([durs 100]);
    xlimits=[0 250]; %x limits for axis
elseif nargin==5
    xlimits=varargin{1};
    if isempty(xlimits)
%         durs=getdurs(expdate, session, filenum);
%         dur=max([durs 100]);
        xlimits=[0 250]; %x limits for axis
    end
else
    error('ProcessGeGi: wrong number of arguments')
end


ProcessVCData(expdate, session, filenum, Vout, xlimits);
outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
load(outfilename)
out.A=1;
out.Ee=0;
out.Ei=-85;
out=get_correctedV(out);
out=compute_ge_gi(out);

outfilename=sprintf('out%s-%s-%s', expdate, session, filenum);
save (outfilename, 'out')
fprintf('\n saved to %s\n', outfilename)

