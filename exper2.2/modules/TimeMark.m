function varargout = TimeMark( varargin )

% timestamp module: allows user to trigger a timestamp event
% would have called this module timestamp only it was already taken.
% mw 05.30.05
global exper pref

varargout{1} = lower(mfilename);
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case 'init'
	%ModuleNeeds(me,{'ao','ai'});
	%SetParam(me,'priority','value',GetParam('ai','priority')+1);
	CreateGUI; %local function that creates ui controls and initializes ui variables
	
case 'getready' %run button in Control was pushed
    %clear all timemarks and notes
    setparam(me, 'timemarks', []);
    setparam(me, 'notes', []);
    
case 'trialend'

case 'close'
    
case 'reset'
    %clear all timemarks and notes
    setparam(me, 'timemarks', []);
    setparam(me, 'notes', []);
    
case 'mark'
    note=getparam(me, 'note', 'value');
    notes=getparam(me, 'notes', 'value');
    numnotes=length(notes);
    notes{numnotes+1}=note;
    time=getparam('control', 'exptime');
    timemarks=getparam(me, 'timemarks', 'value');
    numtimes=length(timemarks);
    timemarks(numtimes+1)=time;
    SetParam(me, 'timemarks', timemarks);
    SetParam(me, 'notes', notes);
    Message(me, sprintf('marked %s at exptime=%.1f', note, time))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI;
% this creates all the ui controls for this module
	fig = ModuleFigure(me,'visible','off');	
	
	% GUI positioning factors
	hs = 60;
	h = 5;
	vs = 20;
	n = 0;
    
	InitParam(me,'note',...
		'value','enter description here',...
		'ui','edit','pos',[h n*vs 3*hs vs]); n=n+1;
    
    InitParam(me,'timemarks','value',[]);
    InitParam(me,'notes','value',[]);

    % pushbuttons are little different
    uicontrol('parent',fig,'string','mark','tag','mark',...
        		'position',[h n*vs hs*2 vs], ...
        'style','pushbutton','callback',[me ';']);
    n=n+1;

    

    % message box
    uicontrol('parent',fig,'tag','message','style','text','fontweight','bold',...
    'enable','inact','horiz','left','pos',[h n*vs hs*2 vs*5]    );
    n=n+1;
	
	set(fig,'pos',[218   592   220   156]);
	% Make figure visible again.
	set(fig,'visible','on');

%function CreateGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%