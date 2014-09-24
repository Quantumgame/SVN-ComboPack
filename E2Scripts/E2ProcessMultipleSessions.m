function E2ProcessMultipleSessions(datadir, saveit, outputdir)

% processes all (multiple) Exper2 experimental sessions in datadir. Each
% session is processed with E2ProcessSession, and the experiment(s) in the
% session are then processed with E2ProcessExperiment
% Input:
%       datadir     -   directory containing directories with Exper2
%                       sessions
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
    n=n+1;
    waitbar(n/ndirs,h,['Processing ' name]);            % update the waitbar
    E2ProcessSession(fulldatadir, saveit, fulloutputdir);    % and process a single dir
end

close(h);