function varargout = DAQMonitor( varargin )

% a debugging tool that monitors writing of data to disk

global exper pref DAQtimer

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
        DAQtimer=timer('TimerFcn',[me '(''update_datawritten'');'],'Period',1,'ExecutionMode','FixedRate');

    case 'getready'
        Message(me,'start')
        start(DAQtimer)

    case 'trialend'
        stop(DAQtimer)
        Message(me, 'stopped')
    case 'close'

    case 'reset'

    case 'update_datawritten'

        Message(me, sprintf('SamplesAcquired: %d', exper.ai.daq.SamplesAcquired))

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


% message box
n = .5;
uicontrol(fig,'tag','message','style','edit',...
    'enable','inact','horiz','left','pos',[h n*vs hs*2 vs*1]); n = n+1;



set(fig,'pos',[18   864 128 n*vs]);
% Make figure visible again.
set(fig,'visible','on');

%function CreateGUI;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Return the name of this file/module.
function out = me
out = lower(mfilename);

% me

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%