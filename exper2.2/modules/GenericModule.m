function varargout = GenericModule( varargin )

% Simple template for a generic Exper module

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
	
case 'trialready'
    
case 'trialend'

case 'close'
    
case 'reset'
    
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
    
    Param=1;
	InitParam(me,'Param',...
		'value',Param,...
		'ui','edit','pos',[h n*vs hs vs]); n=n+1;

	% message box
	uicontrol(fig,'tag','message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs*1]); n = n+1;
	
    % pushbuttons are little different
    uicontrol('parent',fig,'string','Pushbutton Name','tag','pushbutton_action',...
		'units','normal','position',[0.45 0.075 0.1 0.05],...
		'style','pushbutton','callback',[me ';']);
    
	
	set(fig,'pos',[163 646 128 n*vs]);
	% Make figure visible again.
	set(fig,'visible','on');

%function CreateGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%