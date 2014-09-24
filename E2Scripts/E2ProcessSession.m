function E2ProcessSession(datadir, saveit, outputdir)

% processes all (multiple) directories in datadir containing (E2) data
% directories.
% datadir corresponds to a single (experimental) session (Expid directory in
% Exper2 terminology), ie it can contain multiple experiments. Each
% experiment (each directory in datadir) is processed using
% E2ProcessExperiment
% Input:
%       datadir     -   directory containing directories with Exper2 recordings
%       saveit      -   saves the results if saveit==1, otherwise just
%                       processes the data
%       outputdir   -   directory where the processed data will be saved

% Exper2 function

if nargin<1 | isempty(datadir) | strcmp(datadir,'.')
    datadir=pwd;
end

if nargin<2 | isempty(saveit)
    saveit=0;
end
saveit=saveit>0;              % let's make sure saveit is either 0 or 1

if nargin<3 | isempty(outputdir) | strcmp(outputdir,'.')
    outputdir=pwd;
end

alldirs=dir(datadir);       % get everything from datadir
isdir=[alldirs.isdir];      % find out which ones are directories
isdir=find(isdir==1);       % find their indices
isdir(1:2)=[];              % the first two are '.' and '..', delete them
dirnames={alldirs(isdir).name}; % get the names of dirs

h=waitbar(0,'Processing...');
ndirs=length(isdir);        % just a counter for the waitbar
n=0;

for name=dirnames
    name=name{:};                                       % convert from cell;    
    fulldatadir=fullfile(datadir,name);                     % get the full dir names
    fulloutputdir=fullfile(outputdir,name);
    % or fulloutputdir=[datadir '/' name '-extracted'];
    n=n+1;
    waitbar(n/ndirs,h,['Processing ' name]);            % update the waitbar
    E2ProcessExperiment(fulldatadir, saveit, fulloutputdir);    % and process a single dir
end

close(h);