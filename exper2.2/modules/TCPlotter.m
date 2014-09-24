function varargout = TCPlotter( varargin )

% exper 2 module that acts as a GUI interface to commonly used plotting
% functions. You can select from recently acquired data. The command is
% echoed to the command window, to make cutting and pasting convenient. 

global exper pref 

%last updated 01-26-2012 mw


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

            case 'plot'
        Plot;

        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Plot
if GetParam('control', 'run')
    Message(me, 'Stop running first (in Control)', 'append');
else
    PlotFunctions=GetParam(me,'PlotFunctions','value');
    SelectedPlotFunctionIndex=GetParam(me, 'PlotMenu', 'value');
    SelectedPlotFunction=PlotFunctions{SelectedPlotFunctionIndex};
    expids=Control('GetExpid');
    f=expids{3}; %full filename
    [expdate, remain]=strtok(f, '-');
    [temp, remain]=strtok(remain, '-');
    [session, remain]=strtok(remain, '-');
    [filestr, remain]=strtok(remain, '-');
    fnum=str2num(filestr)-1;
    filenum=sprintf('%03d', fnum);
    cmdstr=sprintf('%s(''%s'', ''%s'', ''%s'')', SelectedPlotFunction, expdate, session, filenum);
    fprintf('%s', cmdstr');
    feval(SelectedPlotFunction, expdate, session, filenum);
    Message(me, cmdstr, 'append');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateGUI
global  pref
% this creates all the ui controls for this module
fig = ModuleFigure(me,'visible','off');

% GUI positioning factors
hs = 60;
h = 5;
vs = 20;
n = 1;

% message box panel container ?
hpmsg = uipanel('Title','Messages', 'Position',[.05 .75 .8 .25]);

% message box
hmsg=uicontrol('parent', hpmsg,'tag','message','style','text',...
    'backgroundcolor', [.9 .9 .9],...
    'enable','inact','horiz','left',...
    'units', 'normalized', 'pos',[0 0 1 1]); n = n+1; %[h n*vs 3*hs vs]
% uicontrol(fig,'parent', hpmsg,'tag','message','style','text',...
%     'backgroundcolor', [.9 .9 .9],...
%     'enable','inact','horiz','left','pos',[h n*vs hs*2 vs*10]); n = n+1;
n=10;
uicontrol('parent',fig,'string','Plot','tag','Plot',...
    'position',[h (n)*vs hs vs],...
    'style','pushbutton','callback',[me ';']); n=n-1;


PlotFunctions={'PlotTC', 'PlotTC_psth', 'PlotRLF'};
InitParam(me,'PlotFunctions','value',PlotFunctions);
InitParam(me,'PlotMenu','pref',0, 'value', 1,...
    'ui','popupmenu','pos',[h (n)*vs 2*hs vs]);
SetParamUI(me,'PlotMenu','String',PlotFunctions,'value',1);
 n=n-1;
 n=n-1;
 
m=0;
InitParam(me,'thresh',...
    'value',4,...
    'ui','edit','pos',[h+m*hs n*vs hs vs]); n=n-1;
InitParam(me,'binwidth',...
    'value',5,...
    'ui','edit','pos',[h+m*hs n*vs hs vs]); n=n-1;

m=0;
InitParam(me,'x_autoscale',...
    'string','xlim auto','value',1,'ui','togglebutton',...
    'pos',[h+m*hs n*vs 1.5*hs vs]);m=m+2;
InitParam(me,'xlim1',...
    'value',[],'enable', 'off',...
    'ui','edit','pos',[h+m*hs n*vs hs vs]); ;m=m+1;
InitParam(me,'xlim2',...
    'value',[],'enable', 'off',...
    'ui','edit','pos',[h+m*hs n*vs hs vs]); n=n-1;
m=0;
InitParam(me,'y_autoscale',...
    'string','ylim auto','value',1,'ui','togglebutton',...
    'pos',[h+m*hs n*vs 1.5*hs vs]);m=m+2;
InitParam(me,'ylim1',...
    'value',[],'enable', 'off',...
    'ui','edit','pos',[h+m*hs n*vs hs vs]);m=m+1;
InitParam(me,'ylim2',...
    'value',[],'enable', 'off',...
    'ui','edit','pos',[h+m*hs n*vs hs vs]); n=n-1;


set(fig,'pos',[1190         635         358         367]);
% Make figure visible again.
set(fig,'visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the name of this file/module.
function out = me
out = lower(mfilename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%