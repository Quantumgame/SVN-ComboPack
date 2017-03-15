function expLog=E2ProcessExperimentLog(datadir)

% ONLY TEMPORARY FUNCTION. WILL CHANGE WHEN I CHANGE THE LOG FORMAT!!!

% Processes an experiment log, that was supposed to be saved during the
% experiment.
% Input:
%       datadir     -   directory with the log
%
% Output:
%       expLog      -   structure with the basic information about the
%                       experiment

expLog=[];

if nargin<1 | isempty(datadir)
    datadir=pwd;
end

dirnames=dir([datadir '/*.log']);   % look for log files
if ~isempty(dirnames)

    logFilename=dirnames(1).name;   % take the first one

    [names,values]=textread([datadir '/' logFilename],'%s=%q','commentstyle','matlab');
    x=[names'; values'];
    params=struct(x{:});            % params is now a structure with all log information (everything is strings)


    expLog.ExperimentID=params.name;
    expDate=params.name(1:8);
    expLog.Date=[expDate(1:4) '-' expDate(5:6) '-' expDate(7:8)]; % MATLAB's datestr format #29 YYYY-MM-DD
    expLog.UserID='Tomas';
    expLog.Label='';
    expLog.Annotation='';

    expLog.Subject.SubjectID=params.name(10:15);
    expLog.Subject.Param.Species='SD rat';
    expLog.Subject.Param.Age=params.age;
    expLog.Subject.Param.Weight=params.weight;
    expLog.Subject.Param.Sex=params.sex;
    if length(params.surgery)==8
        expLog.Subject.Param.Surgery=[params.surgery(1:4) '-' params.surgery(5:6) '-' params.surgery(7:8)];
    else
        expLog.Subject.Param.Surgery=[];
    end
    expLog.Subject.Param.Session=params.session;
    if length(params.previous)==8
        expLog.Subject.Param.Previous=[params.previous(1:4) '-' params.previous(5:6) '-' params.previous(7:8)];
    else
        expLog.Subject.Param.Previous=[];
    end
    expLog.Subject.Param.State='awake';
    expLog.Subject.Param.Anesthesia='';
    expLog.Subject.Param.Trained_Naive='naive';
    expLog.Subject.Param.Task='';

    expLog.Experiment.Type=params.type;
    expLog.Experiment.Param.Penetration=params.penetration;
    expLog.Experiment.Param.Electrode=params.electrode;
    expLog.Experiment.Param.Depth=params.depth;
    expLog.Experiment.Param.Pressure=params.pressure;
    expLog.Experiment.Param.Rt=params.Rt;
    expLog.Experiment.Param.Rs=params.Rs;
    expLog.Experiment.Param.Offset=params.Offset;
    expLog.Experiment.Param.Notes=params.notes;
    expLog.Experiment.Param.Photo=params.photo;
    expLog.Experiment.Param.PenetrationCoord=[params.penetrationx params.penetrationy];
else    % no log available, so let's save the default values
    expLog.ExperimentID='unknown';
    expLog.Date='';
    expLog.UserID='unknown';
    expLog.Label='';
    expLog.Annotation='';

    expLog.Subject.SubjectID='';
    expLog.Subject.Param.Species='unknown';
    expLog.Subject.Param.Age='';
    expLog.Subject.Param.Weight=-1;
    expLog.Subject.Param.Sex='unknown';
    expLog.Subject.Param.Surgery=[];
    expLog.Subject.Param.Session=-1;
    expLog.Subject.Param.Previous=-1;
    expLog.Subject.Param.State='';
    expLog.Subject.Param.Anesthesia='';
    expLog.Subject.Param.Trained_Naive='';
    expLog.Subject.Param.Task='';

    expLog.Experiment.Type='cell-attached';     % extract 'spikes' by default
    expLog.Experiment.Param.Penetration=-1;
    expLog.Experiment.Param.Electrode=-1;
    expLog.Experiment.Param.Depth=-1;
    expLog.Experiment.Param.Pressure=-1;
    expLog.Experiment.Param.Rt=-1;
    expLog.Experiment.Param.Rs=-1;
    expLog.Experiment.Param.Offset=-1;
    expLog.Experiment.Param.Notes='';
    expLog.Experiment.Param.Photo='';
    expLog.Experiment.Param.PenetrationCoord=[-1 -1];
    
end