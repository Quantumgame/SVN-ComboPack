function out=Control(varargin)
% CONTROL(ACTION,[NAME])
% Call them all or just one called NAME.
% ACTION is 'init', 'sweep', 'trial', 'close'.
% 'init' must be called with module NAME and
% optionally with it's priority.



global exper pref controltimer   % i made controltimer global instead of control parameter,
% because the exper structure would crash Linux Matlab, if it contained
% timer object!!!??? Thank you, Mathworks

out = [];
if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end


switch action
    case 'init'
        fig= ModuleFigure(me,'pos',[5 608 128 120]);

        hs = 60;
        h = 5;
        vs = 20;
        n = 0;

        InitParam(me,'sequence','list',{});
        InitParam(me,'priority','value',0);		% control is not called like a normal module!
        InitParam(me,'ExpStart','ui','disp','format','clock','save',1,'units','normal','pos',[0.02 0.02 0.58 0.1]); n=n+1;
        SetParamUI(me,'ExpStart','label','Exp Time');
        InitParam(me,'ExpTime','ui','disp','format','clock','save',1,'units','normal','pos',[0.02 0.12 0.58 0.1]); n=n+1;
        SetParamUI(me,'ExpTime','label','Exp Time');

        %Now set the (data)paths and associated parameters

        %%%%% The paths are organized as follows:
        % Example:
        % c:\data\       20030101-xxx999  \  20030101-xxx999-001  \  20030101-xxx999-001-001.daq
        % -------------  ---------------     -------------------     -----------------------
        %  MainDatapath   Expid               FullExpid               FullExpidDataFile
        %
        %                                                    ---                         ---
        %                                                  NRecording                  NDataFile
        %
        % ---------------------------------
        %  SessionDatapath
        %
        % ---------------------------------------------------------
        %  FullDatapath
        %
        % Notes: in this version, MainDatapath and Expid are the only
        % parameters that can be changed by user. The other parameters depend on
        % these two
        % Both MainDatapath and Expid can be also set in preferences (Prefs.m).
        % MainDatapath corresponds to pref.data, and Expid to pref.expid.

        % MainDatapath is the main data path
        InitParam(me,'MainDatapath','value',pref.data);
        if ~isdir(GetParam(me,'MainDatapath'))
            str=sprintf('Warning: cannot find data directories for user "%s". Did you mistype your username? Do you need to add this user? I suggest that you cancel, quit Exper and try again.', pref.username);
            warndlg(str, 'Warning: User not found', 'modal');
            pause(3)
            set_path('MainDatapath','Select main DATA directory...');
        end
        % Expid is the main identification of the recording session (as given
        % by pref.expid)
        InitParam(me,'Expid','value',pref.expid,'ui','edit');
        SetParamUI(me,'Expid','label','ExpID','units','normal','pos',[0.02 0.22 0.58 0.1]); n=n+1;

        % NRecording keeps track of the number of recordings
        InitParam(me,'NRecording','value',1);  % let's start with 0
        % FullExpid is the name of data subdirectory and files inside the
        % subdirectory (it's a combination of Expid and ExpidSuffix)
        fullexpid=CreateFullExpid;
        InitParam(me,'FullExpid','value',fullexpid);

        % SessionDatapath contains the fullpath for the directory containing
        % subdirectories with different recordings
        sessiondatapath=[GetParam(me,'MainDatapath') GetParam(me,'Expid') '\'];
        InitParam(me,'SessionDatapath','value',sessiondatapath);
        % FullDatapath is the full data path:-)
        fulldatapath=[GetParam(me,'SessionDatapath') GetParam(me,'FullExpid') '\']
        InitParam(me,'FullDatapath','value',fulldatapath);
        % Finally FullExpidDataFile is the data file itself
        InitParam(me,'NDataFile','value',1);
        fullexpiddatafile=CreateFullExpidDataFile;
        InitParam(me,'FullExpidDataFile','value',fullexpiddatafile);

        % and now create the data dir
        SetNewDir;

        user=pref.username;
        InitParam(me,'User','value',user,'ui','edit');
        SetParamUI(me,'User','label','User','units','normal','pos',[0.02 0.32 0.58 0.1]); n=n+1;

        % New Dir
        uicontrol(fig,'string','New Dir','tag','newdir','style','pushbutton',...
            'callback',[me '(''newdir'');'],'fontweight','bold','units','normal','pos',[0.02 0.42 0.32 0.18]);
        % New File
        uicontrol(fig,'string','New File','tag','newfile','style','pushbutton',...
            'callback',[me '(''newfile'');'],'fontweight','bold','units','normal','pos',[0.34 0.42 0.32 0.18]);

        % reset
        uicontrol(fig,'string','Reset','tag','reset','style','pushbutton',...
            'callback',[me '(''sure_reset'');'],'foregroundcolor',[.9 0.9 0.9],'backgroundcolor',[.9 0 0],...
            'fontweight','bold','units','normal','pos',[0.66 0.42 0.32 0.18]);
        n=n+2;

        % Run button.
        InitParam(me,'Run','value',0,'ui','togglebutton','pref',0,'units','normal','pos',[0.02 0.70 0.96 0.3]);
        SetParamUI(me,'Run','string','Run','backgroundcolor',[0 .9 0],'fontweight','bold','fontsize',14,'fontname','Arial','label',''); n=n+2

        % message box
        uicontrol(fig,'tag','message','style','edit',...
            'enable','inact','horiz','left','units','normal','pos',[0.02 0.60 0.96 0.1]); n = n+1;

        InitParam(me,'modpath','value',pref.modules);
        if isempty(dir(GetParam(me,'modpath')))
            set_path('modpath','Select MODULE directory...');
        end

        hf = uimenu('label','File');
        uimenu(hf,'label','New...','tag','sure_reset','callback',[me ';']);
        uimenu(hf,'label','Open...','tag','restore_matfile','callback',[me ';']);
        uimenu(hf,'label','Save','tag','save_matfile','callback',[me ';']);
        uimenu(hf,'label','Save as...','tag','save_as_matfile','callback',[me ';']);
        uimenu(hf,'label','Autosave','tag','autosave','checked','on','callback',[me ';'],'separator','on');
        uimenu(hf,'label','Data path...','tag','datapath','callback',[me ';']);

        hf2 = uimenu('label','Prefs');
        uimenu(hf2,'label','Save prefs','tag','save_prefs','callback',[me ';']);
        uimenu(hf2,'label','Restore prefs','tag','restore_prefs','callback',[me ';']);
        uimenu(hf2,'label','Clear prefs','tag','clear_prefs','callback',[me ';']);

        uimenu(fig,'label','Modules','tag','modules');
        mod_menu(fig,'modload');

        set(fig,'pos',[5 768-n*vs-40 200 n*vs]);

        % And now we should have some basic initialization of the main modules
        for n=1:length(pref.default_modules)
            if ~isfield(exper,pref.default_modules{n})  % if the module name is already in the exper structure,
                % then it has been already initialized (either by another
                % module as a requirement, or the module is specified
                % multiple times in pref.default_modules
                ModuleInit(pref.default_modules{n});
            end
        end

        % get and store a list of all open modules
        seq=sequence;           % sequence is a local function
        SetParam(me,'sequence','list',seq,'value',1);
        SetParam(me,'dependents','list',seq,'value',1);
        out=seq;
        if strcmp(pref.loadpref, 'y')
            restore_layout;
        end

        controltimer=timer('TimerFcn',[me '(''update_time'');'],'Period',10,'ExecutionMode','FixedRate');

    case 'close'
        %SendEvent('close',[],me,'all');

    case 'reset'
        SetParam(me,'run',0);
        if ~check_paths  %local function
            return;
        end
        ResetFullExpidDataFile;
        % tell the other modules to reset
        SendEvent('reset',[],me,'all');
        SetParam(me,'ExpStart',0);
        SetParam(me,'ExpTime',0);
        Message(me,'');
        SetParamUI(me,'run','backgroundcolor',[0 0.9 0],'string','Run');
        % tell the other modules to get ready
        %SendEvent('getready',[],me,'all'); % prepare for the next data acquisition

        % handle UI button callbacks

    case 'sure_reset'
        resp=questdlg('Would you like to save Exper?','Curious question','Yes','No','Cancel','Cancel');
        if strcmpi(resp,'Yes')
            CallModule(me,'save_as_matfile');
        elseif strcmpi(resp,'Cancel')
            return;
        end
        resp=questdlg('Do you want to DELETE ALL CURRENT DATA and create a new Exper?','Curious question','Yes','No','No');
        if strcmpi(resp,'Yes')
            CallModule(me,'reset');
        end

    case 'run'
        trigger;

    case 'save_matfile'
        save_exper;

    case 'save_as_matfile'
        save_as_exper;

    case 'autosave'
        show = get(gcbo,'checked');
        if strcmp(show,'off')
            set(gcbo,'checked','on');
        else
            set(gcbo,'checked','off');
        end

    case 'restore_prefs'
        % Restores user preferences from global Matlab preferences
        RestorePrefs(GetParam(me,'user'));
        restore_layout;
        Message(me,sprintf('Restored %s prefs',GetParam(me,'user')));

    case 'save_prefs'
        % Stores user preferences in global Matlab preferences
        SavePrefs(GetParam(me,'user'));
        save_layout;
        Message(me,sprintf('Saved %s prefs',GetParam(me,'user')));

    case 'clear_prefs'
        % clears user preferences in global Matlab preferences
        if ispref(GetParam(me,'user'))
            rmpref(GetParam(me,'user'));
        end
        Message(me,sprintf('Cleared %s prefs',GetParam(me,'user')));

    case 'getdatapath'  % returns all datapaths set in control
        out={GetParam(me,'MainDatapath') GetParam(me,'SessionDatapath') GetParam(me,'FullDatapath')};

    case 'getexpid'     % returns all expids set in control
        out={GetParam(me,'Expid') GetParam(me,'FullExpid') GetParam(me,'FullExpidDataFile')};

    case 'getdatafilename'
        out=[GetParam(me,'FullDatapath') GetParam(me,'FullExpidDataFile')];

    case 'newdir'
        % creates new data directory and sets new datapath
        suffix=GetParam(me,'NRecording');   % get the old rec number
        suffix=suffix+1;                    % increment it
        SetParam(me,'NRecording',suffix);   % and save
        fullexpid=CreateFullExpid;          % create new subdir string
        SetParam(me,'FullExpid',fullexpid);
        try
            SetNewDir;
        catch
            Message(me,'Cannot create new dir!!!');
            SetParam(me,'NRecording',suffix-1);
            fullexpid=CreateFullExpid;
            SetParam(me,'FullExpid',fullexpid);
        end

    case 'newfile'
        nrec=GetParam(me,'NDataFile');  % increment ndatafile before another possible recording in the same directory
        SetParam(me,'NDataFile',nrec+1);
        datafile=CreateFullExpidDataFile;
        SetParam(me,'FullExpidDataFile',datafile);
        SendEvent('Epathchange','datapath',me,'all');

    case 'modload'
        % opens (closes) the module the user has just checked (unchecked) in the
        % module submenu
        name = get(gcbo,'user');
        if strcmp(get(gcbo,'checked'),'on')
            set(gcbo,'checked','off');
            ModuleClose(name);
        else
            set(gcbo,'checked','on');
            ModuleInit(name);
        end

    case 'save_layout'
        save_layout;
        Message(me,'Saved layout');

    case 'restore_layout'
        restore_layout;
        Message(me,'Restored layout');

    case 'sequence'
        seq=sequence;       % sequence is a local function
        SetParam(me,'sequence','list',seq,'value',1);
        SetParam(me,'dependents','list',seq,'value',1);
        out=seq;

    case 'update_time'
        newtime=etime(clock,GetParam(me,'ExpStart'));
        SetParam(me,'ExpTime',newtime);

    case 'enewexpid'
        % someone wants to change the expid
        if nargin<2
            return;
        end
        try
            SetParam(me,'Expid',varargin{2});
            SetNewExpid;        % local function
        catch
            Message(me,'Cannot change Expid!!!');
        end

    case 'expid'
        SetNewExpid;

    case 'esealteston'
        SetParam(me,'Run','enable','off');
        set(findobj('type','uicontrol','tag','reset'),'enable','off');
        set(findobj('type','uicontrol','tag','newdir'),'enable','off');

    case 'esealtestoff'
        SetParam(me,'Run','enable','on');
        set(findobj('type','uicontrol','tag','reset'),'enable','on');
        set(findobj('type','uicontrol','tag','newdir'),'enable','on');

    otherwise
end

% begin local functions
%%%%%%%
function out = me
% returns the name of the module (i.e. this file)
out = lower(mfilename);
%function out = me
%%%%%%%

%%%%%%%
function out = callback
% returns the name of the module as a command (for callback purposes)
out = [lower(mfilename) ';'];
%function out = callback
%%%%%%%

%%%%%%%
function mod_menu(fig,tag)
% Creates modules submenu in the control module
global exper pref
men = findobj(fig,'type','uimenu','tag','modules');
% get rid of any items already in this menu
delete(findobj('parent',men));

% Save and restore layout options
uimenu(men,'tag','save_layout','label','Save layout','callback',callback);
uimenu(men,'tag','restore_layout','label','Restore layout','callback',callback);

% put all modules in a submenu
n=0;
w = dir([GetParam(me,'modpath') '\*.m']);
for p=1:length(w)
    m = w(p).name;
    if ~w(p).isdir
        name = lower(m(1:end-2));
        switch name
            case {'control', 'exper', 'rexper'}
                % ignore these
            otherwise
                op = 0;
                if n==0
                    mh = uimenu(men,'tag',tag,'label',name,'user',name,'callback',callback,'separator','on');
                else
                    mh = uimenu(men,'tag',tag,'label',name,'user',name,'callback',callback);
                end
                % check the open modules
                if ExistParam(name,'open')
                    op = GetParam(name,'open');
                end
                if op
                    set(mh,'checked','on');
                else
                    set(mh,'checked','off');
                end
                n = n+1;
        end
    end
end
%function mod_menu(fig,tag)
%%%%%%%

%%%%%%%
function out=sequence
% creates a sequence of open modules a sorts them according to their
% priorities
global exper pref
seq = {};
% figure out the order in which to call modules using their priorities
names = fieldnames(exper);
for p=1:length(names)
    prior(p) = GetParam(names{p},'priority') * GetParam(names{p},'open');
end
[y sorted] = sort(prior);
n = 1;
for p=1:length(sorted)
    name = names{sorted(p)};
    useit = prior(sorted(p))>0;
    if useit
        seq(n) = {name};
        n=n+1;
    end
end
out = seq;
%function out = sequence
%%%%%%%

%%%%%%
function set_path(name,prompt)
% displays a directory selection dialog (with a 'prompt')
% stores the new path to a parameter 'name'
global exper pref
directory = GetParam(me,name);
if isstr(directory) & exist(directory, 'dir')
    apath=uigetdir(directory,prompt);
    apath=[apath '\'];
else
    apath=uigetdir('',prompt);
    apath=[apath '\'];
end
if isequal(apath,0)
    return;
end
SetParam(me,name,apath);
% the new path is also set in the global Matlab preferences for the
% user
prefstr = sprintf('%s_%s',me,name);
setpref(GetParam(me,'user'),prefstr,apath);
% notifies the open modules of the changed path.
% if a module cares it should read the corresponding path params in
% control and do something
if strcmpi(name,'MainDatapath')
    ResetFullExpid;
    ResetFullExpidDataFile;
    SetParam(me,'SessionDatapath',[apath GetParam(me,'Expid') '\']);
    SetParam(me,'FullDatapath',[apath GetParam(me,'Expid') '\' GetParam(me,'FullExpid') '\']);
end
SendEvent('Epathchange',name,me,'all');
%%%%%%

%%%%%%
function out=check_paths
% checks whether the exper paths are OK
global exper pref
out=0;
datapath=GetParam(me,'MainDatapath');
if ~exist(datapath,'dir')
    set_path('datapath','Select main DATA directory...');
end
fulldatapath=GetParam(me,'FullDatapath');
if ~isempty(dir([fulldatapath '*.daq']))
    resp=questdlg(['There''s already data in ' fulldatapath '. Do you want to DELETE or KEEP the data?'],'Delete Existing Data?','DELETE','KEEP','KEEP');
    % Adusted 19May09 by M. Kyweriga
    if strcmpi(resp,'KEEP')
        %mw 101007
        resp=questdlg(['Would you like to create a new directory or restart at 001 (you can later set the dir/file)?'],'New Directory?','NEW DIR','RESTART at 001','RESTART at 001');
        % Adusted 19May09 by M. Kyweriga
        return;
    else
        delete([fulldatapath '*.*']);
    end
end
out=1;
%function check_paths
%%%%%%

%%%%%
function trigger
global exper pref controltimer
Message(me,'');
if GetParam(me,'run')
       %disable stimulusprotocol for 3 seconds (enabled below)
    set(findobj('type','uicontrol','string','Play'),'enable','off');
 
    SendEvent('getready',[],me,'all'); % prepare for the next data acquisition
    SetParamUI(me,'run','backgroundcolor',[0.9 0 0],'string','Running...');
    SetParam(me,'ExpStart',clock);
    set(findobj('type','uicontrol','tag','reset'),'enable','off');
    set(findobj('type','uicontrol','tag','newdir'),'enable','off');

    % if the Run button is pressed
    % first start ao, which either waits for trigger or
    % starts immediately
    if ModuleOpen('ao')
        ao('start');
    end
    if ModuleOpen('ai')
        ai('start');
    end
    %		dio('trigger');  % we don't want trigger now...
    Message(me,'Acquiring data...');
    start(controltimer);

    pause(3)
    %enable stimulusprotocol
    set(findobj('type','uicontrol','string','Play'),'enable','on');

else
    % if the Run button is not pressed (=we want to stop)
    if ModuleOpen('ai')
        ai('pause');
    end
    if ModuleOpen('ao')
        ao('pause');
    end
    stop(controltimer);
    auto_save;
    SetParam(me,'run',0);
    SetParamUI(me,'run','backgroundcolor',[0 0.9 0],'string','Run');
    set(findobj('type','uicontrol','tag','reset'),'enable','on');
    set(findobj('type','uicontrol','tag','newdir'),'enable','on');
    SendEvent('trialend',[],me,'all'); % prepare for the next data acquisition
    nrec=GetParam(me,'NDataFile');  % increment ndatafile before another possible recording in the same directory
    SetParam(me,'NDataFile',nrec+1);
    datafile=CreateFullExpidDataFile;
    SetParam(me,'FullExpidDataFile',datafile);
    SendEvent('Epathchange','datapath',me,'all');
end
% function trigger
%%%%%

%%%%%
function save_as_exper
global exper pref
prompt='Save experiment...';
filetype='*.mat';
filterspec=[GetParam(me,'FullDatapath') '\' filetype];
[filename, pathname]=uiputfile(filterspec, prompt);
if filename==0
    return;
end
Message(me, sprintf('Saving %s...',filename));
save([pathname filename], 'exper');
Message(me,'');
%function save_as_exper
%%%%%

%%%%%
function save_exper
global exper pref
filename=[GetParam(me,'FullExpidDataFile') '.mat'];
pathname=GetParam(me,'FullDatapath');
Message(me, sprintf('Saving %s...',filename));
save([pathname filename], 'exper');
Message(me,'');
%function save_exper
%%%%%

%%%%%
function save_layout
% stores the layout (position of each window) in global Matlab preferences
global exper pref
windows = getparam('control','sequence','list');
windows{end+1} = 'control';
for n=1:length(windows)
    h = findobj('type','figure','tag',windows{n},'parent',0);
    pos = get(h,'position');
    if n==1
        layout = struct(windows{n},pos);
    else
        layout = setfield(layout,windows{n},pos);
    end
end
setpref(GetParam('control','user'),'control_layout',layout);
% function save_layout
%%%%%

%%%%%
function restore_layout
% restores the layout (position of each window) from global Matlab preferences
global exper pref
user = GetParam('control','user');
if ~ispref(user,'control_layout')
    return
end
layout = getpref(user,'control_layout');
windows = fieldnames(layout);
for n=1:length(windows);
    h = findobj('type','figure','tag',windows{n},'parent',0);
    if ~isempty(h) & ishandle(h)
        new_pos = getfield(layout,windows{n});
        old_pos = get(h,'pos');
        set(h,'pos',new_pos);
    end
end
% function restore_layout
%%%%%

%%%%%
function auto_save
global exper pref
saveit=strcmp(get(findobj('tag','autosave'),'checked'),'on');
if ~saveit
    return
end
modules=getparam(me,'sequence','list');
modules{end+1}='control';
exper_str=sprintf('exper_%03d',GetParam(me,'NDataFile'));
for n=1:length(modules)
    eval_str=sprintf('%s.%s.param = exper.%s.param;',exper_str,modules{n},modules{n});
    eval(eval_str);
end
filename=sprintf('%s.mat',GetParam(me,'FullExpidDataFile'));
pathname=GetParam(me,'FullDatapath');
save([pathname filename], exper_str);
SavePrefs(GetParam(me,'user'));
save_layout;
%%%%%

%%%%%
function complete=CreateFullExpid
% creates a complete experiment id, ie combines expid (as given by
% preferences) with the number of recording
global exper pref
expid=GetParam(me,'Expid');
suffix=GetParam(me,'NRecording');
complete=[expid '-' sprintf('%03d',suffix)];
%%%%%

%%%%%
function complete=CreateFullExpidDataFile
% creates a complete experiment data file id, ie combines fullexpid (as given by
% preferences) with the number of data file
global exper pref
expid=GetParam(me,'FullExpid');
suffix=GetParam(me,'NDataFile');
complete=[expid '-' sprintf('%03d',suffix)];
%%%%%

%%%%%
function ResetFullExpidDataFile
% resets the FullExpidDataFile (resets to suffix=1). This is used whenever
% the user presses the Reset button, or a NewDir is created, or...
% Starts with 1, because it gets incremented AFTER recording (after
% releasing Run button)
SetParam(me,'NDataFile','value',1);
fullexpiddatafile=CreateFullExpidDataFile;
SetParam(me,'FullExpidDataFile','value',fullexpiddatafile);
%%%%%

%%%%%
function ResetFullExpid
% resets FullExpid, for example when the Expid changes
% stats with 0, because it gets incremented while creating new directory
% (after pressing NewDir button)
SetParam(me,'NRecording','value',1);  % let's start with 0
fullexpid=CreateFullExpid;
SetParam(me,'FullExpid',fullexpid);

%%%%%
function SetNewDir
expid=GetParam(me,'Expid');
fullexpid=GetParam(me,'FullExpid');
datapath=GetParam(me,'MainDatapath');
sessiondatapath=[datapath expid '\'];
% FullDatapath is the full data path:-)
fulldatapath=[sessiondatapath fullexpid '\'];
% first, we create the session directory ('main' dir for today's data) if we don't have it
% already
if ~exist(sessiondatapath,'dir')
    mkdir(datapath,expid);
end
% second, let's create the new subdirectory for the new recording(s)
if ~exist(fulldatapath,'dir')
    mkdir(sessiondatapath,fullexpid);
end
% check if there's already something in datadir
if ~isempty(dir([fulldatapath '*.daq']))
    resp=questdlg(['There''s already data in ', fulldatapath, '. Do you want to DELETE or KEEP the data?'],'Delete Existing Data?','DELETE','KEEP','KEEP');
    % Adusted 19May09 by M. Kyweriga
    if strcmpi(resp,'DELETE')
        delete([fulldatapath '*.*']);
    else
        %mw 101007
        resp=questdlg(['Would you like to create a new directory or restart at 001 (you can later set the dir/file)?'],'New Directory?','NEW DIR','RESTART at 001','RESTART at 001');
        % Adusted 19May09 by M. Kyweriga
        if strcmpi(resp,'NEW DIR')
            control('newdir');
            expid=GetParam(me,'Expid');
            fullexpid=GetParam(me,'FullExpid');
            datapath=GetParam(me,'MainDatapath');
            sessiondatapath=[datapath expid '\'];
            % FullDatapath is the full data path:-)
            fulldatapath=[sessiondatapath fullexpid '\'];
        end
    end
end
% set the full datapath in this module
SetParam(me,'SessionDatapath',sessiondatapath);
SetParam(me,'FullDatapath',fulldatapath);
ResetFullExpidDataFile;
% and tell the other modules about the change
SendEvent('Epathchange','datapath',me,'all');
%%%%%

function SetNewExpid
ResetFullExpid;
ResetFullExpidDataFile;
SetNewDir;
SendEvent('Epathchange','datapath',me,'all');
Message(me,'Expid changed');
%%%%%

function status=ModuleOpen(module)
status=0;
modules=GetParam(me,'Dependents','list');
idx=strcmpi(modules,module);
status=sum(idx);
