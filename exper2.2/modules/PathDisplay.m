function out = PathDisplay(varargin)
%PathDisplay
%exper module which displays data path in its own window
%mw 9-01
% foma 02/2004

global exper pref

out = lower(mfilename);
if nargin > 0
    action = lower(varargin{1});
else
    action = lower(get(gcbo,'tag'));
end

switch action
    
case 'init'
    fig = ModuleFigure(me,'visible','off');	
%     SetParam(me,'priority',7);
    hs = 100;
    h = 5;
    vs = 20;
    n = 0;
    % message box
     uicontrol('parent',fig,'tag','message','style','text',...
         'enable','inact','horiz','left','pos',[h h+n*vs hs*3 3*vs]);
    n=n+3;       
    n=n+.25;    
    set(fig,'pos', [5 521 hs*3 n*vs] ,'visible','on'); 

    ShowMyMessage;
    
case 'epathchange'
    ShowMyMessage;
    
case 'reset' 
    ShowMyMessage;
    
otherwise    
end

% begin local functions

function out = me
out = lower(mfilename); 

function ShowMyMessage;
    paths=Control('GetDataPath');
    expids=Control('GetExpid');
    p=sprintf('Main:\t%s',paths{2});
    e=sprintf('Full:\t%s',expids{2});
    f=sprintf('File:\t%s',expids{3});
    mymessage={p,e,f};        
    Message(me,mymessage);
