function godatadir(varargin)
%usage  godatadir(expdate, session) OR
%       godatadir(expdate, session, filenum) OR
%       godatadir(username, expdate, session, filenum) OR
%       godatadir(expdate-session-filenum)
%
%cd to the user's processed-data directory
%if username is not specified it is taken from prefs

if nargin==1
    str=varargin{1};
    if length(str)==14
        expdate=str(1:6);
        session=str(8:10);
        filenum=str(12:14);
    else
        expdate=str(1:6);
        [t,r]=strtok(str, expdate);
        username=t(2:4);
        session=r(1:3);
        filenum=str(5:7);
    end
elseif nargin==2
    expdate=varargin{1};
    session=varargin{2};
elseif nargin==3
    expdate=varargin{1};
    session=varargin{2};
    filenum=varargin{3};
elseif nargin==4
    username=varargin{1};
    expdate=varargin{2};
    session=varargin{3};
    filenum=varargin{4};
else
    help godatadir
    error('godatadir: wrong number of arguments')
end
username=whoami;

if isempty(username)
    error('please specify username')  
end

global pref
if isempty(pref) Prefs; end
if ~isfield(pref, 'processed_data_dir') Prefs; end
username=pref.username;

% Try/catch for rig4. 
% Don't look for processed data on this machine if pref.rig = 'oldRig3'. 
try
    cd(pref.processed_data_dir)
catch
    if pref.rig=='Rig1'
        cd('\\Desktop\Data\Processed_Data')
    end
end

expdir=sprintf('%s-%s',expdate, username);
sessdir=sprintf('%s-%s-%s',expdate, username, session);

if exist(expdir, 'dir')==7
    cd(expdir)
    if exist(sessdir, 'dir')==7
        cd(sessdir)
    else
        if pref.mkdir
            mkdir(sessdir)
            cd(sessdir)
        else
            error(sprintf('Session directory: %s does not exist',sessdir))
        end
    end

else
%     if isfield(pref, 'mkdir')
%         if pref.mkdir
%             mkdir(expdir)
%             cd(expdir)
%             mkdir(sessdir)
%             cd(sessdir)
%             fprintf('\ncreated directories %s and %s', expdir, session)
%         else error('\ndirectory %s not found', expdir)
%         end
%     else error('directory %s not found', expdir)
%     end
if strcmp(username, 'apw') || strcmp(username, 'ira')
    godatadirbak(expdate, session, filenum)
end
end















