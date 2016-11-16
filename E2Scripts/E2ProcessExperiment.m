function expLog=E2ProcessExperiment(datadir, saveit, outputdir)

% Processes a single (E2) experiment, i.e. all (E2) DAQ files in a given directory (datadir). 
% The outputs are (eventually) saved into outputdir.
% Datadir corresponds to FullExpid in Exper2 terminology.
% Input:
%       datadir     -   directory containig DAQ file(s), and all the
%                       supporting stuff: exper structures, log files, etc...
%       saveit      -   saves the results if saveit==1, otherwise just
%                       processes the data
%       outputdir   -   directory where the processed data will be saved
% Output:
%       explog      -   structure containing information about the
%                       experiment

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

expLog=[];

% First, process the experiment log we were supposed to save
expLog=E2ProcessExperimentLog(datadir);
if isempty(expLog)
    return;
end
expType=expLog.Experiment.Type;
if strcmpi(expLog.Experiment.Type,'nodata') % there are no data, so return with what we have
    expLog.Data=[];
    return;
end

% Then we process the individual dag files
daqfiles=dir([datadir '/*.daq']);       % get all daq files from datadir
filenames={daqfiles.name};              % get the names of dirs
if isempty(filenames)                   % nothing to do here
    return;
end

h=waitbar(0,'Processing files...');
nfiles=length(filenames);
n=0;

expLogData=[];

for name=filenames
    name=name{:};                                       % convert from cell;    
    %Backup here if necessary
    %(put in backup code here) mw 012712
    fulldaqfilename=fullfile(datadir,name);                 % get the full daq file name
    n=n+1;
    waitbar(n/nfiles,h,['Processing ' name]);            % update the waitbar
%     spikeMethod='auto'; %automatically detect spikes
    spikeMethod='skip'; %don't detect spikes
    expLogDataSingle=E2ProcessDAQFile(fulldaqfilename, expType, saveit, outputdir, spikeMethod);     % and process a single file    
    expLogData=[expLogData expLogDataSingle];
end

% add the information about data to the log
expLog.Data=expLogData;

% and save it 
if saveit
   if ~isdir(outputdir)
       mkdir(outputdir);    %!!!! THIS WILL ONLY WORK FOR FULL PATHS!!!!
   end
   logFile=fullfile(outputdir,[expLog.ExperimentID '-log']);
   save(logFile,'expLog');   %TEMPORARY!!!
end
    
close(h);