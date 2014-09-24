function PlotRLF_many(varargin)
% extracts spikes and plots a Rate Level Function for each tone frequency
% and overlays files (especially useful for before, during, after drug
% application).
%you must run PlotRLF on each file first (preferably with the
%same fixed voltage threshold). Specify thresh and xlimits (which is used for spike count
%window) at the time you run PlotRLF.
%
%usage:
%   PlotRLF_many(expdate1, session1, filenum1, expdate2, session2, filenum2, ... )
%   use as many expdate-session-filenum triples as you want.
%
%example call: PlotRLF_many('073009','001','001','073009','001','002','073009','001','003')
% mak 14Oct2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    fprintf('\nno input\n')
    return
elseif nargin<3
    fprintf('\nnot enough inputs\n')
    return
elseif mod(nargin,3)==0 %multiple of 3
    nfiles=nargin/3;
    for filen=1:nfiles
        expdate(filen,:)=varargin{(filen-1)*3+1};
        session(filen,:)=varargin{(filen-1)*3+2};
        filenum(filen,:)=varargin{(filen-1)*3+3};
    end
else
    error('wrong number of arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%for rainbow colors:
c=colormap;
cstep=round(64/(nfiles));
%hard-coded colors
%c='krg';c=c';
%cstep=1;

figure
hold on
counter=0;
for filen=1:nfiles
    [datafile, eventsfile, stimfile]=getfilenames(expdate(filen,:), session(filen,:), filenum(filen,:));
    outfilename=sprintf('outRLF%s-%s-%s.mat',expdate(filen,:),session(filen,:), filenum(filen,:));
godatadir(expdate(filen,:),session(filen,:), filenum(filen,:))
    if exist(outfilename,'file')==2;
        load(outfilename);
    else 
        error('RLF outfile not found')
    end
    counter=counter+1;
    legendname(counter,:)=outfilename;
    e=errorbar(out.amps, out.mM1, out.semM1);
    set(e, 'marker', '.','linewidth', 2, 'markersize', 20,'color', c(1+(filen-1)*cstep,:))
end
title(sprintf('Many RLFs'));
ylabel('Spikecount (+/- SEM)');
xlabel('Amplitude (dB)');
legend(legendname,'location','northwest');
% ylim([0 20]);


