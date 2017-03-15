function varargout=ExperLog(varargin)

% ExperLog module: keeps track of the recording parameters

global exper pref

varargout{1} = lower(mfilename);
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case 'init'
	ModuleNeeds(me,{'ao','ai'});
	CreateGUI; %local function that creates ui controls and initializes ui variables
%     InitParam(me,'AnimalID','value','');
    InitParam(me,'Expid','value','');
    InitParam(me,'FullDatapath','value','');
    InitParam(me,'Photo','value','');       % PATH to the craniotomy picture
                                            % Photo will be saved to the recording
                                            % directory after pressing Save Log
    InitParam(me,'AllPenetrations','value',zeros(10,2)); % initially we make space for
                                            % 20 penetrations. If that is not enough
                                            % we add more later (automagically)
%     InitParam(me,'Stimuli','value',{});    % here we keep track of all stimuli that were played
                                                
case 'getready'
%     SetParam(me,'Stimuli',{});
    %DisableParamChange;

case 'reset'    
%     SetParam(me,'Stimuli',{});
    
case 'trialend'
    %EnableParamChange;

% case 'eaddstimulus'                      % response to addstimulus event
%     if nargin<3
%         return;
%     else
%         stimuli=GetParam(me,'Stimuli');
%         SetParam(me,'Stimuli',{stimuli{:} GetParam(varargin{3},varargin{2})});
%     end
 
case 'epathchange'                      %response to pathchange event - the path has changed, if it's datapath, we need to update recording number
    if nargin<2
        return;
    end
    if strcmpi(varargin{2},'datapath')
        paths=control('getdatapath');
        fullpath=paths(3);
        SetParam(me,'FullDatapath',fullpath);
        expids=control('getexpid');
        SetParam(me,'Expid',expids(1));
        SetParam(me,'RecordingName',expids{2});
        % finally we enable the SaveExper button (SaveLog button is enabled
        % when the user chooses the type of recording
        fig=GetParam(me,'Fig');
        h=findobj(fig,'Tag','saveexper');
        set(h,'Enable','on');
%         SetParam(me,'Type',1);
        h=findobj(fig,'Tag','savelog');
%         disp(h);
        set(h,'Enable','off');
    end

% case 'type'    
%     type=GetParam(me,'Type');
%     fig=GetParam(me,'Fig');
%     h=findobj(fig,'Tag','savelog');
%     if type>1       % NOT Unknown
%         set(h,'Enable','on');
%     else            % Unknown type
%         set(h,'Enable','off');
%     end                

case 'typebutton'    % one of the type buttons was presses, so we now know the recording type 
    fig=GetParam(me,'Fig');
    h=findobj(fig,'Tag','savelog');
    set(h,'Enable','on');
    
case 'newanimal'
    %first, we need to know the animal's id
    subjectid=inputdlg('Animal ID:','What is the animal''s ID',1,{'xxx999'});
    SetParam(me,'SubjectID','value',subjectid{:});
    expid=pref.expid;       % get the original expid, as defined in preferences
    dash=findstr(expid,'-');
    myexpid=[expid(1:dash(1)) subjectid{:}];
    SetParam(me,'Expid',myexpid);

    h=GetParam(me,'PhotoHandle');
    delete(h);
    
    h=findobj('tag',me,'type','figure');    
    figure(h);
%     handle=axes('Units','pixels','Position',[20 210 420 300]);
    handle=axes('Units','normal','Position',[0.02 0.30 0.48 0.60]);
    SetParam(me,'PhotoHandle','value',handle);
    axisoff;
    title(myexpid,'FontSize',12,'FontWeight','bold');
    
    fig=GetParam(me,'Fig');
    h=findobj(fig,'Tag','newpenetration');
    set(h,'Enable','off');
    h=findobj(fig,'Tag','mark');
    set(h,'Enable','off');
    h=findobj(fig,'Tag','clearphoto');
    set(h,'Enable','off');
    SetParam(me,'NoData',0);
    h=findobj(fig,'Tag','newlog');
    set(h,'Enable','on');
    h=findobj(fig,'Tag','openphoto');
    set(h,'Enable','on');
    SetParam(me,'AllPenetrations',zeros(20,2));
    SendEvent('Enewexpid',myexpid,me,'all');    % tell the others we eant to change Expid
        
case 'savelog'
    SaveLog;

case 'saveexper'
    SaveExper;
    
case 'openphoto'
    [file,path]=uigetfile([pref.home '\*.*'],'Select photo...');
    photofilename=[path '\' file];
    if exist(photofilename,'file')
        SetParam(me,'Photo',photofilename);
        h=GetParam(me,'PhotoHandle');
        axes(h);
        im=imread(photofilename);
        h=imagesc(im);
        hpar=get(h,'Parent');
        set(hpar,'DataAspectRatio',[1 size(im,2)/size(im,1) 1]);
        axisoff;
        title(GetParam(me,'Expid'),'FontSize',12,'FontWeight','bold');
        %set(h,'ButtonDownFcn',[me '(''mark'');']);
        fig=GetParam(me,'Fig');
        h=findobj(fig,'Tag','clearphoto');
        set(h,'Enable','on');
        h=findobj(fig,'Tag','newpenetration');
        set(h,'Enable','on');
        SetParam(me,'PenetrationX',0);
        SetParam(me,'PenetrationY',0);
        SetParam(me,'PhotoName',[GetParam(me,'RecordingName') '.jpg']);
    end
    
case 'newpenetration'
    p=GetParam(me,'Penetration')+1;
    SetParam(me,'Penetration',p);
    callmodule(me,'clearphoto');
    
case 'mark'    
    h=GetParam(me,'PhotoHandle');
    axes(h);
    x=ginput(1);
    SetParam(me,'PenetrationX',x(1));
    SetParam(me,'PenetrationY',x(2));
    p=GetParam(me,'Penetration');
    allp=GetParam(me,'AllPenetrations');
    allp(p,:)=x;
    SetParam(me,'AllPenetrations',allp);
    hold on;
    plot(x(1),x(2),'ko','LineWidth',3);
    fig=GetParam(me,'Fig');
    h=findobj(fig,'Tag','clearphoto');
    set(h,'Enable','on');
    h=findobj(fig,'Tag','mark');
    set(h,'Enable','off');
    
case 'clearphoto'
    SetParam(me,'PenetrationX',0);
    SetParam(me,'PenetrationY',0);
    photofilename=GetParam(me,'Photo');
    if exist(photofilename,'file')
        h=GetParam(me,'PhotoHandle');
        axes(h);
        hold off;
        im=imread(photofilename);
        h=imagesc(im);
        hpar=get(h,'Parent');
        set(hpar,'DataAspectRatio',[1 size(im,2)/size(im,1) 1]);
        axisoff;
        title(GetParam(me,'Expid'),'FontSize',12,'FontWeight','bold');
        hold on;
        %set(h,'ButtonDownFcn',[me '(''mark'');']);
        fig=GetParam(me,'Fig');
        h=findobj(fig,'Tag','clearphoto');
        set(h,'Enable','off');
        h=findobj(fig,'Tag','mark');
        set(h,'Enable','on');
        DrawPenetrations;
    end
    
% case 'nodata'
%     if GetParam(me,'NoData');
%         DisableParamChange;
%     else
%         EnableParamChange;
%     end;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
	fig = ModuleFigure(me,'visible','off');	
    InitParam(me,'Fig','value',fig);
	% GUI positioning factors
	hs = 60;
	vs = 20;
	n = 0;
    % Photo axes
    figure(fig);
%     handle=axes('Units','pixels','Position',[20 210 420 300]);
    handle=axes('Units','normal','Position',[0.02 0.30 0.48 0.60]);
    InitParam(me,'PhotoHandle','value',handle);
    axisoff;

    % Photo pushbuttons    
    y=180;
    uicontrol('parent',fig,'string','Mark','tag','mark',...
		'units','normal','position',[0.02 0.28 0.12 0.08],'enable','off',...
		'style','pushbutton','callback',[me ';']);
% 		'units','pixels','position',[20 y 80 vs],'enable','off',...
    uicontrol('parent',fig,'string','Clear','tag','clearphoto',...
		'units','normal','position',[0.14 0.28 0.12 0.08],'enable','off',...
		'style','pushbutton','callback',[me ';']);
% 		'units','pixels','position',[120 y 80 vs],'enable','off',...
    uicontrol('parent',fig,'string','Penetration','tag','newpenetration',...
		'units','normal','position',[0.26 0.28 0.12 0.08],'enable','off',...
		'style','pushbutton','callback',[me ';']);
% 		'units','pixels','position',[220 y 80 vs],'enable','off',...
    uicontrol('parent',fig,'string','Photo...','tag','openphoto',...
		'units','normal','position',[0.38 0.28 0.12 0.08],'enable','off',...
		'style','pushbutton','callback',[me ';']);
% 		'units','pixels','position',[320 y 80 vs],'enable','off',...
    
    Notes='';
	InitParam(me,'Notes',...
		'value',Notes,...
		'ui','edit','pref',0,'units','normal','pos',[0.02 0.02 0.48 0.25],'Max',10,'HorizontalAlignment','left'); n=n+1;
% 		'ui','edit','pos',[20 y-8*vs hs*6.5 vs*7],'Max',10,'HorizontalAlignment','left'); n=n+1;
    
    % frames
%     x=460;
%     y=20;
%     uicontrol(fig,'tag','frame','style','frame',...
%         'horiz','left','pos',[x y hs*4 vs*3]);
%     uicontrol(fig,'tag','frame','style','frame',...
%         'horiz','left','pos',[x y+vs*3 hs*4 vs*7]);
%     uicontrol(fig,'tag','frame','style','frame',...
%         'horiz','left','pos',[x y+vs*10 hs*4 vs*4]);
%     uicontrol(fig,'tag','frame','style','frame',...
%         'horiz','left','pos',[x y+vs*14 hs*4 vs*5]);
%     uicontrol(fig,'tag','frame','style','frame',...
%         'horiz','left','pos',[x y+vs*19 hs*4 vs*7]);
    
    % edit controls
    x=480;
%    y=400;
    y=500;
    n=0;
    
    RecordingName='';
    InitParam(me,'RecordingName','value',RecordingName);
% 	InitParam(me,'RecordingName',...
% 		'value',RecordingName,'units','normal',...
% 		'ui','edit','pos',[0.52 0.93 0.15 0.05]); n=n+1;
% % 		'ui','edit','pos',[x y-n*vs hs*2 vs]); n=n+1;
    PhotoName='';
    InitParam(me,'PhotoName','value',PhotoName);
% 	InitParam(me,'PhotoName',...
% 		'value',PhotoName,'units','normal',...
% 		'ui','edit','pos',[0.52 0.88 0.15 0.05]); n=n+1;
% % 		'ui','edit','pos',[x y-n*vs hs*2 vs]); n=n+1;
    SubjectID='';
	InitParam(me,'SubjectID',...
		'value',SubjectID,'units','normal',...
		'ui','edit','pos',[0.52 0.93 0.10 0.05]); n=n+1;
    Age='';
	InitParam(me,'Age',...
		'value',Age,'units','normal',...
		'ui','edit','pos',[0.52 0.88 0.10 0.05]); n=n+1;
    Weight='';
	InitParam(me,'Weight',...
		'value',Weight,'units','normal',...
		'ui','edit','pos',[0.52 0.83 0.10 0.05]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
    AllSexes={'unknown','male','female'};
    InitParam(me,'AllSexes','value',AllSexes);
	InitParam(me,'Sex',...
		'value',1,'String',AllSexes,'units','normal',...
		'ui','popupmenu','pos',[0.52 0.78 0.10 0.05]); n=n+3;
% 		'ui','popupmenu','pos',[x y-n*vs hs vs]); n=n+3;
    
    Surgery='';
	InitParam(me,'Surgery',...
		'value',Surgery,'units','normal',...
		'ui','edit','pos',[0.52 0.68 0.10 0.05]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
    Session=1;
	InitParam(me,'Session',...
		'value',Session,'units','normal',...
		'ui','edit','pos',[0.52 0.63 0.10 0.05]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
    Previous='';
	InitParam(me,'Previous',...
		'value',Previous,'units','normal',...
		'ui','edit','pos',[0.52 0.58 0.10 0.05]); n=n+3;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+3;
    
    Penetration=0;
	InitParam(me,'Penetration',...
		'value',Penetration,'units','normal',...
		'ui','edit','pos',[0.52 0.47 0.10 0.05]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
    InitParam(me,'PenetrationX','value',0);
    InitParam(me,'PenetrationY','value',0);
    Electrode=3.5;
	InitParam(me,'Electrode',...
		'value',Electrode,'units','normal',...
		'ui','edit','pos',[0.52 0.42 0.10 0.05]); n=n+3;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+3;
    
    Depth=600;
	InitParam(me,'Depth',...
		'value',Depth,'units','normal',...
		'ui','edit','pos',[0.52 0.32 0.10 0.05]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
    Pressure=1;
	InitParam(me,'Pressure',...
		'value',Pressure,'units','normal',...
		'ui','edit','pos',[0.52 0.27 0.10 0.05]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
    Rt=4.0;
	InitParam(me,'Rt',...
		'value',Rt,'units','normal',...
		'ui','edit','pos',[0.52 0.22 0.10 0.05]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
    Rs=4.0;
	InitParam(me,'Rs',...
		'value',Rs,'units','normal',...
		'ui','edit','pos',[0.52 0.17 0.10 0.05]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
    Offset=0;
	InitParam(me,'Offset',...
		'value',Offset,'units','normal',...
		'ui','edit','pos',[0.52 0.12 0.10 0.05]); n=n+1;
% 		'ui','edit','pos',[x y-n*vs hs vs]); n=n+1;
    n=n+2;
    
    AllTypes={'LFP','Cell-attached','Whole-cell','Other','No Data'};
    InitParam(me,'AllTypes','value',AllTypes);
% 	InitParam(me,'Type',...
% 		'value',1,'String',AllTypes,'units','normal',...
% 		'ui','popupmenu','pos',[x y-n*vs hs vs]); n=n+1;
    tb1=uicontrol('Style','ToggleButton','value',0,'String','LFP','units','normal',...
        'pos',[0.52 0.02 0.10 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');
    tb2=uicontrol('Style','ToggleButton','value',0,'String','CellAtt','units','normal',...
        'pos',[0.62 0.02 0.10 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');
    tb3=uicontrol('Style','ToggleButton','value',0,'String','WC','units','normal',...
        'pos',[0.72 0.02 0.10 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');
    tb4=uicontrol('Style','ToggleButton','value',0,'String','Other','units','normal',...
        'pos',[0.82 0.02 0.08 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');
    tb5=uicontrol('Style','ToggleButton','value',0,'String','NoData','units','normal',...
        'pos',[0.90 0.02 0.08 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');

     set(tb1,'UserData',[tb2 tb3 tb4 tb5], 'tag', 'typebutton');
     set(tb2,'UserData',[tb1 tb3 tb4 tb5], 'tag', 'typebutton');
     set(tb3,'UserData',[tb1 tb2 tb4 tb5], 'tag', 'typebutton');
     set(tb4,'UserData',[tb1 tb2 tb3 tb5], 'tag', 'typebutton');
     set(tb5,'UserData',[tb1 tb2 tb3 tb4], 'tag', 'typebutton');
     %enforce that the radiobuttons themselves are mutually exclusive
     set([tb1 tb2 tb3 tb4 tb5],'CallBack',...
         'set(get(gco,''UserData''),''Value'',0,''backgroundcolor'',[0.1 0 0.9],''foregroundcolor'',[1 1 1]), set(gco,''Value'',1,''backgroundcolor'',[0 1 1],''foregroundcolor'',[0 0 1]), FigHandler;');
    
    
%     InitParam(me,'TypeLFP','value',0,'String','LFP','ui','togglebutton','units','normal','pref',0,...
%         'pos',[0.52 0.02 0.10 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');
%     InitParam(me,'TypeCAtt','value',0,'String','CellAtt','ui','togglebutton','units','normal','pref',0,...
%         'pos',[0.62 0.02 0.10 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');
%     InitParam(me,'TypeWC','value',0,'String','WC','ui','togglebutton','units','normal','pref',0,...
%         'pos',[0.72 0.02 0.10 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');
%     InitParam(me,'TypeOther','value',0,'String','Other','ui','togglebutton','units','normal','pref',0,...
%         'pos',[0.82 0.02 0.08 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');
%     InitParam(me,'TypeNoData','value',0,'String','NoData','ui','togglebutton','units','normal','pref',0,...
%         'pos',[0.90 0.02 0.08 0.08],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold');
    
    % pushbuttons	
    x=720;
    y=520;
    n=0;
    uicontrol('parent',fig,'string','New Animal','tag','newanimal',...
		'units','normal','position',[0.8 0.86 0.18 0.12],'fontweight','bold',...
		'style','pushbutton','callback',[me ';']); n=n+2
% 		'units','pixels','position',[x y-n*vs 80 vs],...
    uicontrol('parent',fig,'string','New Log','tag','newlog',...
		'units','normal','position',[0.8 0.78 0.18 0.08],'enable','off',...
		'style','pushbutton','callback',[me ';']); n=n+2;
% 		'units','pixels','position',[x y-n*vs 80 vs],'enable','off',...
    InitParam(me,'Awake','String','Awake','ui','togglebutton','value',1,'pref',0,'units','normal',...
        'pos',[0.8 0.70 0.18 0.08],'backgroundcolor',[0 1 1],'foregroundcolor',[0 0 1],'fontweight','bold'); n=n+15;
%     InitParam(me,'Awake','ui','checkbox','value',1,'horiz','left','pos',[x y-n*vs 40 vs]); n=n+15;
%     InitParam(me,'NoData','String','No Data','ui','togglebutton','value',0,'pref',0,'units','normal',...
%         'pos',[0.8 0.26 0.18 0.12],'backgroundcolor',[0.1 0 0.9],'foregroundcolor',[1 1 1],'fontweight','bold'); n=n+2;
%     InitParam(me,'NoData','ui','checkbox','value',0,'horiz','left','pos',[x y-n*vs 40 vs]); n=n+2;
    uicontrol('parent',fig,'string','Save Exper','tag','saveexper',...
		'units','normal','position',[0.8 0.24 0.18 0.12],'enable','off','fontweight','bold',...
		'style','pushbutton','callback',[me ';']); n=n+2;
% 		'units','pixels','position',[x y-n*vs 80 vs],'enable','off',...
    uicontrol('parent',fig,'string','Save Log','tag','savelog','fontweight','bold',...
		'units','normal','position',[0.8 0.12 0.18 0.12],'enable','off',...
		'style','pushbutton','callback',[me ';']); 
% 		'units','pixels','position',[x y-n*vs 80 vs],'enable','off',...
    
%	set(fig,'pos',[150 500 820 480]);
	set(fig,'pos',[150 400 620 380]);
	% Make figure visible again.
	set(fig,'visible','on');

%function CreateGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DisableParamChange
fig=findobj('type','figure','tag',me);
h=findobj(fig,'type','uicontrol','style','edit');
set(h,'enable','off')

% DisableParamChange

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EnableParamChange
if ~GetParam(me,'NoData');
    fig=findobj('type','figure','tag',me);
    h=findobj(fig,'type','uicontrol','style','edit');
    set(h,'enable','on');
end

% EnableParamChange

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axisoff;
handle=GetParam(me,'PhotoHandle');
set(handle,'Box','off','Color','n','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8],'TickLength',[0 0]);

% axisoff

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SaveLog;
global exper pref

    filename=[GetParam(me,'RecordingName') '.log'];
    AllTypes=GetParam(me,'AllTypes');
    AllSexes=GetParam(me,'AllSexes');
    
    directory=GetParam(me,'FullDatapath'); %let's save the stimuli to the datapath
    if exist([directory{:} filename])
        answer=questdlg(['Log file in ' directory{:} ' already exists. Overwrite it?'],'','No');
        if strcmp(answer,'No') | strcmp(answer,'Cancel')
            return;
        end
    end
    
    fig=GetParam(me,'Fig');
    % typebuttons
    tb=findobj(fig,'Tag','typebutton');
    values=get(tb,'Value'); % this returns a cell array with values in opposite order than it's in the experlog module
    typevalues=logical(fliplr([values{:}])); % now we have a logical array that we can use for indexing in AllTypes
    
    fid=fopen([directory{:} filename],'wt');
    fprintf(fid,'%% This is a recording session parameters file.\n');
    fprintf(fid,'%% The following information is stored for every recording:\n');
    fprintf(fid,'%% nodata = 1 if there''s no data recorded for this recording\n');
    fprintf(fid,'%%          (non-responsive, something weird happened, etc.)\n');
    fprintf(fid,'%%        = 0 if there is actually something in this directory\n');
    fprintf(fid,'%% awake = 1-recorded from awake animal; 0-from anaesthetized animal\n');
    fprintf(fid,'%% name = name of the recording session, i.e. 20030101-th011-01\n');
    fprintf(fid,'%% weight = weight of the animal in g\n');
    fprintf(fid,'%% age = string ''describing'' the age (e.g. adult, p20,...)\n');
    fprintf(fid,'%% sex = male, female, or unknown if you''re lazy to find out\n');    
    fprintf(fid,'%% surgery = date of surgery (yyyymmdd)\n');
    fprintf(fid,'%% session = recording session number\n');
    fprintf(fid,'%% previous = date of previous recording session (yyyymmdd)\n');
    fprintf(fid,'%% depth = depth of the recording?\n');
    fprintf(fid,'%% electrode = electrode resistance\n');
    fprintf(fid,'%% pressure = pressure in the electrode during the recording\n');
    fprintf(fid,'%% Rt = Rt (from the sealtest)\n');
    fprintf(fid,'%% Rs = Rs (from the sealtest)\n');
    fprintf(fid,'%% type = can be one from: LFP, cell-attached, whole-cell,...\n');
    fprintf(fid,'%% penetration = number of penetration in the recording session\n');
    fprintf(fid,'%% penetrationx, penetrationy = coordinates for display purposes\n');
    fprintf(fid,'%% photo = file with the photograph of the craniotomy\n');
    fprintf(fid,'%%\n%%---------------------------------------------------------------------------------\n%%\n');
    fprintf(fid,'%% To get the information from this file, you can do the following \n');
    fprintf(fid,'%%\n');
    fprintf(fid,'%% [names,values]=textread(''experiment.info'',''%%s=%%s'',''commentstyle'',''matlab'');\n');
    fprintf(fid,'%% x=[names''; values''];\n');
    fprintf(fid,'%% params=struct(x{:});\n');
    fprintf(fid,'%%\n');
    fprintf(fid,'%% params is structure with field names corresponding to the left column and values\n');
    fprintf(fid,'%% corresponding to the right column.\n');
    fprintf(fid,'%% THE VALUES IN THE STRUCTURE ARE STRINGS!!!\n');
    fprintf(fid,'%%\n');
    fprintf(fid,'%%---------------------------------------------------------------------------------\n');
    fprintf(fid,'%% Is there something useful in this directory?\n');
    fprintf(fid,'\n');
%     fprintf(fid,'nodata       = %1d\n',GetParam(me,'NoData'));
    fprintf(fid,'nodata       = %1d\n',typevalues(5));
    fprintf(fid,'\n');
    fprintf(fid,'%%---------------------------------------------------------------------------------\n');
    fprintf(fid,'\n');
    fprintf(fid,'awake        = %1d\n',GetParam(me,'Awake'));
    fprintf(fid,'\n');
    fprintf(fid,'name         = %s\n',GetParam(me,'RecordingName'));
    fprintf(fid,'photo        = %s\n',GetParam(me,'PhotoName'));
    fprintf(fid,'\n');
    fprintf(fid,'weight       = %s\n',GetParam(me,'Weight'));
    fprintf(fid,'age          = %s\n',GetParam(me,'Age'));
    fprintf(fid,'sex          = %s\n',AllSexes{GetParam(me,'Sex')});
    fprintf(fid,'\n');
    fprintf(fid,'surgery      = %s\n',GetParam(me,'Surgery'));
    fprintf(fid,'session      = %2d\n',GetParam(me,'Session'));
    fprintf(fid,'previous     = %s\n',GetParam(me,'Previous'));
    fprintf(fid,'\n');
    fprintf(fid,'penetration  = %3d\n',GetParam(me,'Penetration'));
    fprintf(fid,'electrode    = %2.2f\n',GetParam(me,'Electrode'));
    fprintf(fid,'\n');
    fprintf(fid,'depth        = %4d\n',GetParam(me,'Depth'));
    fprintf(fid,'pressure     = %3d\n',GetParam(me,'Pressure'));
    fprintf(fid,'Rt           = %4.2f\n',GetParam(me,'Rt'));
    fprintf(fid,'Rs           = %4.2f\n',GetParam(me,'Rs'));
    fprintf(fid,'Offset       = %4.2f\n',GetParam(me,'Offset'));
    fprintf(fid,'\n');
    fprintf(fid,'type         = %s\n',AllTypes{typevalues});
%     fprintf(fid,'type         = %s\n',AllTypes{GetParam(me,'Type')});
    fprintf(fid,'\n');
    fprintf(fid,'penetrationx = %4d\n',GetParam(me,'PenetrationX'));
    fprintf(fid,'penetrationy = %4d\n',GetParam(me,'PenetrationY'));
    fprintf(fid,'\n');
    
    notes=GetParam(me,'Notes');
    nrows=size(notes,1);
    if nrows
        newlines=repmat('\n\n',nrows,1);
        x=strcat(notes,newlines);
        y=cellstr(x);
        outputnotes=['"' strcat(y{:}) '"'];
    else
        outputnotes='';
    end
    
    fprintf(fid,'notes        = %s\n',outputnotes);
    fclose(fid);
    
    if exist(GetParam(me,'Photo'),'file')
        x=imread(GetParam(me,'Photo'));
        photoname=[directory{:} GetParam(me,'PhotoName')];
        imwrite(x,photoname,'jpg');
    end
% SaveLog
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SaveExper
global exper prefs
    filename=GetParam(me,'RecordingName');
    directory=GetParam(me,'FullDatapath'); %let's save exper to the datapath
    if exist([directory{:} filename '.mat'])
        answer=questdlg(['Exper file in ' directory{:} ' already exists. Overwrite it?'],'','No');
        if strcmp(answer,'No') | strcmp(answer,'Cancel')
            return;
        end
    end
    save([directory{:} filename],'exper');

% SaveExper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DrawPenetrations
    p=GetParam(me,'Penetration');
    h=GetParam(me,'PhotoHandle');
    axes(h);
    c=GetParam(me,'AllPenetrations');
    for i=1:p-1
        plot(c(i,1),c(i,2),'co','LineWidth',3);
    end

% DrawPenetrations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
